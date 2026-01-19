using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;

namespace ConsysWV2
{
    [ComVisible(true)]
    [Guid("C3D4E5F6-A7B8-9012-CDEF-012345678901")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    public interface IWebView2Host
    {
        bool Initialize();
        void Navigate(string url);
        void NavigateToString(string htmlContent);
        string GetCurrentUrl();
        void Refresh();
        void GoBack();
        void GoForward();
        void Show();
        void Hide();
        void SetBounds(int left, int top, int width, int height);
        void Close();
        bool IsInitialized { get; }
        string LastError { get; }
        string ExecuteScript(string script);
        void PostWebMessage(string message);
    }

    [ComVisible(true)]
    [Guid("D4E5F6A7-B8C9-0123-DEF0-123456789ABC")]
    [ClassInterface(ClassInterfaceType.AutoDual)]
    [ProgId("Consys.WebView2Host")]
    public class WebView2Host : IWebView2Host, IDisposable
    {
        private Form _hostForm;
        private WebView2 _webView;
        private bool _isInitialized = false;
        private string _lastError = "";
        private ManualResetEvent _initEvent = new ManualResetEvent(false);

        public WebView2Host()
        {
            // Konstruktor macht nichts - Initialize() muss aufgerufen werden
        }

        public bool Initialize()
        {
            if (_isInitialized) return true;

            try
            {
                // Form und WebView im UI-Thread erstellen
                _hostForm = new Form
                {
                    Text = "WebView2 Browser",
                    FormBorderStyle = FormBorderStyle.Sizable,
                    ShowInTaskbar = true,
                    StartPosition = FormStartPosition.CenterScreen,
                    Width = 1200,
                    Height = 800
                };

                _webView = new WebView2
                {
                    Dock = DockStyle.Fill
                };
                _hostForm.Controls.Add(_webView);

                // WebView2 synchron initialisieren
                var userDataFolder = System.IO.Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    "Consys", "WebView2"
                );

                // Verzeichnis erstellen falls nicht vorhanden
                if (!System.IO.Directory.Exists(userDataFolder))
                {
                    System.IO.Directory.CreateDirectory(userDataFolder);
                }

                // Synchrone Initialisierung mit Warten
                var initTask = InitWebViewAsync(userDataFolder);

                // Warten mit DoEvents um UI nicht zu blockieren
                int timeout = 10000; // 10 Sekunden
                int waited = 0;
                while (!initTask.IsCompleted && waited < timeout)
                {
                    Application.DoEvents();
                    Thread.Sleep(50);
                    waited += 50;
                }

                if (!initTask.IsCompleted)
                {
                    _lastError = "Timeout bei WebView2 Initialisierung";
                    return false;
                }

                if (initTask.IsFaulted)
                {
                    _lastError = initTask.Exception?.InnerException?.Message ?? "Unbekannter Fehler";
                    return false;
                }

                _isInitialized = true;
                return true;
            }
            catch (Exception ex)
            {
                _lastError = "Init Error: " + ex.Message + " | " + ex.GetType().Name;
                if (ex.InnerException != null)
                {
                    _lastError += " | Inner: " + ex.InnerException.Message;
                }
                return false;
            }
        }

        private async Task InitWebViewAsync(string userDataFolder)
        {
            var env = await CoreWebView2Environment.CreateAsync(
                browserExecutableFolder: null,
                userDataFolder: userDataFolder,
                options: null
            );

            await _webView.EnsureCoreWebView2Async(env);

            _webView.CoreWebView2.Settings.IsScriptEnabled = true;
            _webView.CoreWebView2.Settings.AreDefaultScriptDialogsEnabled = true;
            _webView.CoreWebView2.Settings.IsWebMessageEnabled = true;
            _webView.CoreWebView2.Settings.AreDevToolsEnabled = true;
        }

        public void Navigate(string url)
        {
            if (!_isInitialized)
            {
                _lastError = "Nicht initialisiert - erst Initialize() aufrufen";
                return;
            }
            try
            {
                // file:// Pfad korrigieren
                if (url.Contains(":\\") && !url.StartsWith("file:"))
                {
                    url = "file:///" + url.Replace("\\", "/");
                }
                _webView.CoreWebView2.Navigate(url);
            }
            catch (Exception ex)
            {
                _lastError = ex.Message;
            }
        }

        public void NavigateToString(string htmlContent)
        {
            if (!_isInitialized) return;
            try
            {
                _webView.CoreWebView2.NavigateToString(htmlContent);
            }
            catch (Exception ex)
            {
                _lastError = ex.Message;
            }
        }

        public string GetCurrentUrl()
        {
            if (!_isInitialized) return "";
            return _webView.Source?.ToString() ?? "";
        }

        public void Refresh()
        {
            if (!_isInitialized) return;
            _webView.CoreWebView2.Reload();
        }

        public void GoBack()
        {
            if (!_isInitialized) return;
            if (_webView.CanGoBack) _webView.GoBack();
        }

        public void GoForward()
        {
            if (!_isInitialized) return;
            if (_webView.CanGoForward) _webView.GoForward();
        }

        public string ExecuteScript(string script)
        {
            if (!_isInitialized) return "";
            try
            {
                var task = _webView.CoreWebView2.ExecuteScriptAsync(script);
                task.Wait(5000);
                return task.Result;
            }
            catch (Exception ex)
            {
                _lastError = ex.Message;
                return "";
            }
        }

        public void PostWebMessage(string message)
        {
            if (!_isInitialized) return;
            try
            {
                _webView.CoreWebView2.PostWebMessageAsString(message);
            }
            catch (Exception ex)
            {
                _lastError = ex.Message;
            }
        }

        public void Show()
        {
            if (_hostForm != null && !_hostForm.IsDisposed)
            {
                _hostForm.Show();
                _hostForm.BringToFront();
            }
        }

        public void Hide()
        {
            if (_hostForm != null && !_hostForm.IsDisposed)
            {
                _hostForm.Hide();
            }
        }

        public void SetBounds(int left, int top, int width, int height)
        {
            if (_hostForm != null && !_hostForm.IsDisposed)
            {
                _hostForm.SetBounds(left, top, width, height);
            }
        }

        public void Close()
        {
            Dispose();
        }

        public bool IsInitialized => _isInitialized;
        public string LastError => _lastError;

        private bool _disposed = false;
        public void Dispose()
        {
            if (_disposed) return;
            try
            {
                _webView?.Dispose();
                _hostForm?.Close();
                _hostForm?.Dispose();
            }
            catch { }
            _disposed = true;
        }
    }
}
