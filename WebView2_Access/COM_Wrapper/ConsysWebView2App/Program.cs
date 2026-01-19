using System;
using System.Windows.Forms;
using System.Threading.Tasks;
using System.IO;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;
using ConsysWebView2;  // AccessDataBridge

namespace ConsysWebView2App
{
    static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            
            string htmlPath = "";
            string title = "WebView2 Browser";
            int width = 1200;
            int height = 800;
            string initialData = "";
            
            // Argumente parsen
            for (int i = 0; i < args.Length; i++)
            {
                switch (args[i].ToLower())
                {
                    case "-url":
                    case "-html":
                        if (i + 1 < args.Length) htmlPath = args[++i];
                        break;
                    case "-title":
                        if (i + 1 < args.Length) title = args[++i];
                        break;
                    case "-width":
                        if (i + 1 < args.Length) int.TryParse(args[++i], out width);
                        break;
                    case "-height":
                        if (i + 1 < args.Length) int.TryParse(args[++i], out height);
                        break;
                    case "-data":
                        if (i + 1 < args.Length) initialData = args[++i];
                        break;
                }
            }
            
            if (string.IsNullOrEmpty(htmlPath))
            {
                MessageBox.Show("Verwendung:\nConsysWebView2App.exe -html <pfad> [-title <titel>] [-width <breite>] [-height <hoehe>] [-data <json>]", 
                    "ConsysWebView2", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }
            
            var form = new WebViewForm(htmlPath, title, width, height, initialData);
            Application.Run(form);
        }
    }
    
    public class WebViewForm : Form
    {
        private WebView2 _webView;
        private string _htmlPath;
        private string _initialData;
        private AccessDataBridge _dataBridge;
        
        public WebViewForm(string htmlPath, string title, int width, int height, string initialData)
        {
            _htmlPath = htmlPath;
            _initialData = initialData;
            _dataBridge = new AccessDataBridge();  // DB-Bridge initialisieren

            this.Text = title;
            this.Width = width;
            this.Height = height;
            this.StartPosition = FormStartPosition.CenterScreen;
            this.FormBorderStyle = FormBorderStyle.Sizable;
            
            _webView = new WebView2();
            _webView.Dock = DockStyle.Fill;
            this.Controls.Add(_webView);
            
            this.Load += OnFormLoad;
            this.FormClosing += OnFormClosing;
        }
        
        private async void OnFormLoad(object sender, EventArgs e)
        {
            try
            {
                var userDataFolder = Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    "Consys", "WebView2"
                );
                
                if (!Directory.Exists(userDataFolder))
                    Directory.CreateDirectory(userDataFolder);
                
                var env = await CoreWebView2Environment.CreateAsync(null, userDataFolder, null);
                await _webView.EnsureCoreWebView2Async(env);
                
                _webView.CoreWebView2.Settings.IsScriptEnabled = true;
                _webView.CoreWebView2.Settings.AreDefaultScriptDialogsEnabled = true;
                _webView.CoreWebView2.Settings.IsWebMessageEnabled = true;
                _webView.CoreWebView2.Settings.AreDevToolsEnabled = true;
                
                _webView.CoreWebView2.WebMessageReceived += OnWebMessageReceived;
                _webView.CoreWebView2.NavigationCompleted += OnNavigationCompleted;
                
                // URL laden
                string url = _htmlPath;
                if (_htmlPath.Contains(":\\") && !_htmlPath.StartsWith("file:"))
                    url = "file:///" + _htmlPath.Replace("\\", "/");
                
                _webView.CoreWebView2.Navigate(url);
            }
            catch (Exception ex)
            {
                string innerMsg = "";
                if (ex.InnerException != null) innerMsg = ex.InnerException.Message;
                
                MessageBox.Show("Fehler beim Initialisieren:\n" + ex.Message + "\n\nInner: " + innerMsg, 
                    "WebView2 Fehler", MessageBoxButtons.OK, MessageBoxIcon.Error);
                this.Close();
            }
        }
        
        private void OnNavigationCompleted(object sender, CoreWebView2NavigationCompletedEventArgs e)
        {
            if (e.IsSuccess && !string.IsNullOrEmpty(_initialData))
            {
                try
                {
                    string escapedData = _initialData.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\r", "").Replace("\n", "");
                    string script = "if(typeof Bridge !== 'undefined' && Bridge.onDataReceived) { Bridge.onDataReceived('" + escapedData + "'); }";
                    _webView.CoreWebView2.ExecuteScriptAsync(script);
                    _initialData = "";
                }
                catch { }
            }
        }
        
        private void OnWebMessageReceived(object sender, CoreWebView2WebMessageReceivedEventArgs e)
        {
            try
            {
                string message = e.TryGetWebMessageAsString();
                if (!string.IsNullOrEmpty(message))
                {
                    Console.WriteLine("[WebView2] Request: " + message);

                    // Request an AccessDataBridge weiterleiten
                    string response = _dataBridge.ProcessRequest(message);

                    Console.WriteLine("[WebView2] Response: " + (response.Length > 200 ? response.Substring(0, 200) + "..." : response));

                    // Antwort zurück an JavaScript senden
                    _webView.CoreWebView2.PostWebMessageAsString(response);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("[WebView2] ERROR: " + ex.Message);
                string errorResponse = "{\"ok\":false,\"error\":{\"message\":\"" + ex.Message.Replace("\"", "\\\"") + "\"}}";
                try { _webView.CoreWebView2.PostWebMessageAsString(errorResponse); } catch { }
            }
        }
        
        private void OnFormClosing(object sender, FormClosingEventArgs e)
        {
            try
            {
                if (_webView != null) _webView.Dispose();
            }
            catch { }
        }
    }
}
