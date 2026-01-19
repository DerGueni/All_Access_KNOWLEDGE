// WebView2Host - COM-Wrapper fuer Access 2021 (64-Bit)
// =====================================================
// Ermoeglicht das Einbetten von WebView2 in Access-Formulare via ActiveX.
// Kompilieren mit: .NET Framework 4.8, x64, COM-Interop aktiviert
//
// Autor: Claude Code
// Version: 1.0

using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Threading.Tasks;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;

namespace ConsysWebView2
{
    /// <summary>
    /// COM-sichtbare Schnittstelle fuer VBA-Zugriff
    /// </summary>
    [ComVisible(true)]
    [Guid("A1B2C3D4-E5F6-7890-ABCD-EF1234567890")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    public interface IWebView2Host
    {
        // Navigation
        void Navigate(string url);
        void NavigateToString(string htmlContent);
        string GetCurrentUrl();
        void Refresh();
        void GoBack();
        void GoForward();
        bool CanGoBack { get; }
        bool CanGoForward { get; }

        // JavaScript-Kommunikation
        string ExecuteScript(string script);
        void PostWebMessage(string message);

        // Fenster-Kontrolle
        void Show();
        void Hide();
        void SetBounds(int left, int top, int width, int height);
        void Close();

        // Status
        bool IsInitialized { get; }
        string LastError { get; }

        // Events (fuer VBA-Callbacks)
        event EventHandler NavigationCompleted;
        event EventHandler<string> WebMessageReceived;
    }

    /// <summary>
    /// COM-Klasse: WebView2-Host fuer Access 2021 64-Bit
    /// </summary>
    [ComVisible(true)]
    [Guid("B2C3D4E5-F6A7-8901-BCDE-F12345678901")]
    [ClassInterface(ClassInterfaceType.None)]
    [ComDefaultInterface(typeof(IWebView2Host))]
    [ProgId("Consys.WebView2Host")]
    public class WebView2Host : IWebView2Host, IDisposable
    {
        // Internes Fenster und WebView2
        private Form _hostForm;
        private WebView2 _webView;
        private bool _isInitialized = false;
        private string _lastError = "";
        private TaskCompletionSource<string> _scriptResult;

        // Events
        public event EventHandler NavigationCompleted;
        public event EventHandler<string> WebMessageReceived;

        /// <summary>
        /// Konstruktor - initialisiert WebView2 in eigenem Fenster
        /// </summary>
        public WebView2Host()
        {
            InitializeAsync();
        }

        private async void InitializeAsync()
        {
            try
            {
                // Host-Fenster erstellen (frameless, wird in Access positioniert)
                _hostForm = new Form
                {
                    FormBorderStyle = FormBorderStyle.None,
                    ShowInTaskbar = false,
                    StartPosition = FormStartPosition.Manual,
                    TopMost = false
                };

                // WebView2-Control erstellen
                _webView = new WebView2
                {
                    Dock = DockStyle.Fill
                };
                _hostForm.Controls.Add(_webView);

                // WebView2 initialisieren
                var userDataFolder = System.IO.Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    "Consys", "WebView2"
                );

                var env = await CoreWebView2Environment.CreateAsync(
                    browserExecutableFolder: null,  // Nutzt installierte Runtime
                    userDataFolder: userDataFolder,
                    options: new CoreWebView2EnvironmentOptions()
                );

                await _webView.EnsureCoreWebView2Async(env);

                // Event-Handler
                _webView.NavigationCompleted += OnNavigationCompleted;
                _webView.WebMessageReceived += OnWebMessageReceived;

                // Sicherheitseinstellungen fuer localhost
                _webView.CoreWebView2.Settings.IsScriptEnabled = true;
                _webView.CoreWebView2.Settings.AreDefaultScriptDialogsEnabled = true;
                _webView.CoreWebView2.Settings.IsWebMessageEnabled = true;
                _webView.CoreWebView2.Settings.AreDevToolsEnabled = true;  // Fuer Debugging

                _isInitialized = true;
            }
            catch (Exception ex)
            {
                _lastError = $"Initialisierung fehlgeschlagen: {ex.Message}";
                _isInitialized = false;
            }
        }

        // ====================================================================
        // Navigation
        // ====================================================================

        public void Navigate(string url)
        {
            if (!EnsureInitialized()) return;

            try
            {
                _webView.CoreWebView2.Navigate(url);
            }
            catch (Exception ex)
            {
                _lastError = ex.Message;
            }
        }

        public void NavigateToString(string htmlContent)
        {
            if (!EnsureInitialized()) return;

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
            if (!EnsureInitialized()) return "";
            return _webView.Source?.ToString() ?? "";
        }

        public void Refresh()
        {
            if (!EnsureInitialized()) return;
            _webView.CoreWebView2.Reload();
        }

        public void GoBack()
        {
            if (!EnsureInitialized()) return;
            if (_webView.CanGoBack) _webView.GoBack();
        }

        public void GoForward()
        {
            if (!EnsureInitialized()) return;
            if (_webView.CanGoForward) _webView.GoForward();
        }

        public bool CanGoBack => _webView?.CanGoBack ?? false;
        public bool CanGoForward => _webView?.CanGoForward ?? false;

        // ====================================================================
        // JavaScript-Kommunikation
        // ====================================================================

        public string ExecuteScript(string script)
        {
            if (!EnsureInitialized()) return "";

            try
            {
                // Synchrone Ausfuehrung via Task.Result (VBA kann kein async)
                var task = _webView.CoreWebView2.ExecuteScriptAsync(script);
                task.Wait(5000);  // Timeout 5 Sekunden
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
            if (!EnsureInitialized()) return;

            try
            {
                _webView.CoreWebView2.PostWebMessageAsString(message);
            }
            catch (Exception ex)
            {
                _lastError = ex.Message;
            }
        }

        // ====================================================================
        // Fenster-Kontrolle
        // ====================================================================

        public void Show()
        {
            if (_hostForm != null && !_hostForm.IsDisposed)
            {
                _hostForm.Show();
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

        // ====================================================================
        // Status
        // ====================================================================

        public bool IsInitialized => _isInitialized;
        public string LastError => _lastError;

        // ====================================================================
        // Private Helpers
        // ====================================================================

        private bool EnsureInitialized()
        {
            if (!_isInitialized)
            {
                // Warte max 5 Sekunden auf Initialisierung
                int waited = 0;
                while (!_isInitialized && waited < 5000)
                {
                    System.Threading.Thread.Sleep(100);
                    Application.DoEvents();
                    waited += 100;
                }
            }
            return _isInitialized;
        }

        private void OnNavigationCompleted(object sender, CoreWebView2NavigationCompletedEventArgs e)
        {
            NavigationCompleted?.Invoke(this, EventArgs.Empty);
        }

        private void OnWebMessageReceived(object sender, CoreWebView2WebMessageReceivedEventArgs e)
        {
            WebMessageReceived?.Invoke(this, e.TryGetWebMessageAsString());
        }

        // ====================================================================
        // IDisposable
        // ====================================================================

        private bool _disposed = false;

        public void Dispose()
        {
            if (_disposed) return;

            _webView?.Dispose();
            _hostForm?.Dispose();
            _disposed = true;
        }
    }

    /// <summary>
    /// Embedded WebView2 Control - kann direkt in Access eingebettet werden
    /// </summary>
    [ComVisible(true)]
    [Guid("C3D4E5F6-A7B8-9012-CDEF-123456789012")]
    [ClassInterface(ClassInterfaceType.None)]
    [ProgId("Consys.WebView2Control")]
    public class WebView2Control : UserControl
    {
        private WebView2 _webView;
        private bool _isInitialized = false;

        public WebView2Control()
        {
            _webView = new WebView2 { Dock = DockStyle.Fill };
            Controls.Add(_webView);
            InitializeWebView();
        }

        private async void InitializeWebView()
        {
            try
            {
                var userDataFolder = System.IO.Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    "Consys", "WebView2"
                );

                var env = await CoreWebView2Environment.CreateAsync(
                    userDataFolder: userDataFolder
                );

                await _webView.EnsureCoreWebView2Async(env);
                _isInitialized = true;
            }
            catch { }
        }

        public void Navigate(string url)
        {
            if (_isInitialized && _webView.CoreWebView2 != null)
            {
                _webView.CoreWebView2.Navigate(url);
            }
        }

        public string ExecuteScript(string script)
        {
            if (!_isInitialized) return "";
            var task = _webView.CoreWebView2.ExecuteScriptAsync(script);
            task.Wait(5000);
            return task.Result;
        }
    }
}
