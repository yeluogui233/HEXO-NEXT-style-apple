using Microsoft.Web.WebView2.WinForms;
using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Net.Sockets;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

internal static class Program
{
    private const int WM_NCHITTEST = 0x0084;
    private const int CS_DROPSHADOW = 0x00020000;
    private const int WS_THICKFRAME = 0x00040000;
    private const int WS_MINIMIZEBOX = 0x00020000;
    private const int WS_MAXIMIZEBOX = 0x00010000;
    private const int HTCLIENT = 1;
    private const int HTCAPTION = 2;
    private const int HTRIGHT = 11;
    private const int HTBOTTOM = 15;
    private const int HTBOTTOMRIGHT = 17;
    private const int WM_NCLBUTTONDOWN = 0x00A1;
    private const int DWMWA_WINDOW_CORNER_PREFERENCE = 33;
    private const int DWMWCP_ROUND = 2;

    [STAThread]
    private static int Main()
    {
        string baseDir = AppDomain.CurrentDomain.BaseDirectory;
        string adminDir = Path.Combine(baseDir, "admin");
        string serverFile = Path.Combine(adminDir, "server.js");
        string port = Environment.GetEnvironmentVariable("BLOG_ADMIN_PORT");
        if (string.IsNullOrWhiteSpace(port)) port = "4788";
        string url = "http://localhost:" + port;

        if (!File.Exists(serverFile))
        {
            MessageBox.Show("没有找到管理端服务文件：" + serverFile, "博客管理器");
            return 1;
        }

        if (!CommandExists("node"))
        {
            MessageBox.Show("没有找到 Node.js。你的 Hexo 博客也依赖 Node.js，请先安装或修复 PATH。", "博客管理器");
            return 1;
        }

        Process server = null;
        try
        {
            int parsedPort;
            if (!int.TryParse(port, out parsedPort)) parsedPort = 4788;

            if (!PortIsOpen("127.0.0.1", parsedPort))
            {
                ProcessStartInfo startInfo = new ProcessStartInfo();
                startInfo.FileName = "node";
                startInfo.Arguments = "\"" + serverFile + "\"";
                startInfo.WorkingDirectory = adminDir;
                startInfo.UseShellExecute = false;
                startInfo.CreateNoWindow = true;
                startInfo.EnvironmentVariables["BLOG_ROOT"] = Environment.GetEnvironmentVariable("BLOG_ROOT") ?? @".";
                startInfo.EnvironmentVariables["BLOG_ADMIN_PORT"] = port;
                server = Process.Start(startInfo);
                Thread.Sleep(1000);
            }

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            using (BlogAdminForm form = new BlogAdminForm(url))
            {
                Application.Run(form);
            }
        }
        finally
        {
            if (server != null && !server.HasExited)
            {
                try { server.Kill(); } catch { }
            }
        }

        return 0;
    }

    private static bool CommandExists(string command)
    {
        try
        {
            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "where";
            startInfo.Arguments = command;
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = true;
            startInfo.RedirectStandardOutput = true;
            startInfo.RedirectStandardError = true;
            Process process = Process.Start(startInfo);
            if (process == null) return false;
            process.WaitForExit(2000);
            return process.ExitCode == 0;
        }
        catch { return false; }
    }

    private static bool PortIsOpen(string host, int port)
    {
        try
        {
            using (TcpClient client = new TcpClient())
            {
                IAsyncResult result = client.BeginConnect(host, port, null, null);
                bool success = result.AsyncWaitHandle.WaitOne(TimeSpan.FromMilliseconds(250));
                if (!success) return false;
                client.EndConnect(result);
                return true;
            }
        }
        catch { return false; }
    }

    private sealed class BlogAdminForm : Form
    {
        private readonly WebView2 webView;
        private readonly string url;

        [DllImport("user32.dll")]
        private static extern bool ReleaseCapture();

        [DllImport("user32.dll")]
        private static extern IntPtr SendMessage(IntPtr hWnd, int msg, IntPtr wParam, IntPtr lParam);

        [DllImport("dwmapi.dll")]
        private static extern int DwmSetWindowAttribute(IntPtr hwnd, int attribute, ref int attributeValue, int attributeSize);

        public BlogAdminForm(string url)
        {
            this.url = url;
            Text = "博客管理器";
            StartPosition = FormStartPosition.CenterScreen;
            Size = new Size(1280, 860);
            MinimumSize = new Size(980, 680);
            FormBorderStyle = FormBorderStyle.None;
            BackColor = Color.FromArgb(238, 247, 241);
            DoubleBuffered = true;
            Icon = LoadAppIcon();

            webView = new WebView2();
            webView.Dock = DockStyle.Fill;
            Controls.Add(webView);
            Load += OnLoad;
            HandleCreated += delegate { ApplyNativeRoundedCorners(); };
            Shown += delegate { ApplyNativeRoundedCorners(); };
            Resize += delegate { ApplyNativeRoundedCorners(); };
        }

        private Icon LoadAppIcon()
        {
            string localIcon = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "BlogAdmin.ico");
            if (File.Exists(localIcon))
            {
                try { return new Icon(localIcon); } catch { }
            }

            try { return Icon.ExtractAssociatedIcon(Application.ExecutablePath); }
            catch { return SystemIcons.Application; }
        }

        private async void OnLoad(object sender, EventArgs e)
        {
            await webView.EnsureCoreWebView2Async();
            webView.CoreWebView2.Settings.AreDefaultContextMenusEnabled = false;
            webView.CoreWebView2.Settings.AreDevToolsEnabled = false;
            webView.CoreWebView2.WebMessageReceived += delegate(object s, Microsoft.Web.WebView2.Core.CoreWebView2WebMessageReceivedEventArgs args)
            {
                string message = args.TryGetWebMessageAsString();
                if (message == "close") Close();
                else if (message == "minimize") WindowState = FormWindowState.Minimized;
                else if (message == "toggleMaximize") WindowState = WindowState == FormWindowState.Maximized ? FormWindowState.Normal : FormWindowState.Maximized;
                else if (message == "dragWindow") BeginNativeMove(HTCAPTION);
                else if (message == "resize:right") BeginNativeMove(HTRIGHT);
                else if (message == "resize:bottom") BeginNativeMove(HTBOTTOM);
                else if (message == "resize:bottomRight") BeginNativeMove(HTBOTTOMRIGHT);
            };
            webView.CoreWebView2.Navigate(url);
            ApplyNativeRoundedCorners();
        }

        private void ApplyNativeRoundedCorners()
        {
            int preference = DWMWCP_ROUND;
            try
            {
                DwmSetWindowAttribute(Handle, DWMWA_WINDOW_CORNER_PREFERENCE, ref preference, sizeof(int));
            }
            catch { }
        }

        private void BeginNativeMove(int hitTest)
        {
            if (WindowState == FormWindowState.Maximized && hitTest != HTCAPTION) return;
            ReleaseCapture();
            SendMessage(Handle, WM_NCLBUTTONDOWN, (IntPtr)hitTest, IntPtr.Zero);
        }

        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams cp = base.CreateParams;
                cp.ClassStyle |= CS_DROPSHADOW;
                cp.Style |= WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
                return cp;
            }
        }

        protected override void WndProc(ref Message m)
        {
            base.WndProc(ref m);
            if (m.Msg != WM_NCHITTEST || (int)m.Result != HTCLIENT) return;

            Point p = PointToClient(new Point(m.LParam.ToInt32()));
            bool right = p.X >= ClientSize.Width - 10;
            bool bottom = p.Y >= ClientSize.Height - 10;
            if (right && bottom) m.Result = (IntPtr)HTBOTTOMRIGHT;
            else if (right) m.Result = (IntPtr)HTRIGHT;
            else if (bottom) m.Result = (IntPtr)HTBOTTOM;
            else if (p.Y <= 42) m.Result = (IntPtr)HTCAPTION;
        }
    }
}
