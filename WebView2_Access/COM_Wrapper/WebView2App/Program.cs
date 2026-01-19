using System;
using System.Windows.Forms;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;
using System.Threading.Tasks;

namespace WebView2App
{
    static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            string url = "about:blank";
            string title = "WebView2 Browser";
            int width = 1200;
            int height = 800;

            // Kommandozeilen-Argumente parsen
            for (int i = 0; i < args.Length; i++)
            {
                if (args[i] == "--url" && i + 1 < args.Length)
                {
                    url = args[i + 1];
                    i++;
                }
                else if (args[i] == "--title" && i + 1 < args.Length)
                {
                    title = args[i + 1];
                    i++;
                }
                else if (args[i] == "--width" && i + 1 < args.Length)
                {
                    int.TryParse(args[i + 1], out width);
                    i++;
                }
                else if (args[i] == "--height" && i + 1 < args.Length)
                {
                    int.TryParse(args[i + 1], out height);
                    i++;
                }
                else if (!args[i].StartsWith("--"))
                {
                    // Erster Nicht-Option Parameter ist die URL
                    url = args[i];
                }
            }

            // Lokale Dateipfade in file:// URLs umwandeln
            if (url.Contains(":\\") && !url.StartsWith("file:"))
            {
                url = "file:///" + url.Replace("\\", "/");
            }

            Application.Run(new MainForm(url, title, width, height));
        }
    }

    public class MainForm : Form
    {
        private WebView2 webView;

        public MainForm(string url, string title, int width = 1200, int height = 800)
        {
            this.Text = title;
            this.Width = width;
            this.Height = height;
            this.StartPosition = FormStartPosition.CenterScreen;

            webView = new WebView2
            {
                Dock = DockStyle.Fill
            };
            this.Controls.Add(webView);

            this.Load += async (s, e) => await InitializeAsync(url);
        }

        private async Task InitializeAsync(string url)
        {
            var userDataFolder = System.IO.Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "Consys", "WebView2"
            );

            if (!System.IO.Directory.Exists(userDataFolder))
            {
                System.IO.Directory.CreateDirectory(userDataFolder);
            }

            var env = await CoreWebView2Environment.CreateAsync(
                browserExecutableFolder: null,
                userDataFolder: userDataFolder,
                options: null
            );

            await webView.EnsureCoreWebView2Async(env);

            webView.CoreWebView2.Settings.IsScriptEnabled = true;
            webView.CoreWebView2.Settings.AreDefaultScriptDialogsEnabled = true;
            webView.CoreWebView2.Settings.IsWebMessageEnabled = true;
            webView.CoreWebView2.Settings.AreDevToolsEnabled = true;

            if (!string.IsNullOrEmpty(url) && url != "about:blank")
            {
                webView.CoreWebView2.Navigate(url);
            }
        }
    }
}
