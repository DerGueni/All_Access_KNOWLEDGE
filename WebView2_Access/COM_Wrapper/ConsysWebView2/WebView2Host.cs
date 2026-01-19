using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace ConsysWebView2
{
    // Einfacher File-Logger für Debugging
    internal static class FileLog
    {
        private static readonly string LogPath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "Consys", "webview2_debug.log");

        public static void Write(string message)
        {
            try
            {
                string dir = Path.GetDirectoryName(LogPath);
                if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

                string line = "[" + DateTime.Now.ToString("HH:mm:ss.fff") + "] " + message + "\r\n";
                File.AppendAllText(LogPath, line);
            }
            catch { }
        }

        public static void Clear()
        {
            try { if (File.Exists(LogPath)) File.Delete(LogPath); } catch { }
        }
    }
    [ComVisible(true)]
    [Guid("A1B2C3D4-E5F6-7890-ABCD-EF1234567890")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    public interface IWebView2Host
    {
        bool Initialize();
        void Navigate(string url);
        void NavigateToString(string htmlContent);
        string QueryCurrentUrl();
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
        bool HasPendingEvents();
        string GetNextEvent();
        void ClearEvents();
        int GetEventCount();
    }

    [ComVisible(true)]
    [Guid("C3D4E5F6-A7B8-9012-CDEF-234567890123")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    public interface IWebFormHost
    {
        bool ShowForm(string htmlPath, string title, int width, int height);
        bool ShowFormWithData(string htmlPath, string title, int width, int height, string jsonData);
        void CloseForm();
        bool IsFormOpen { get; }
        void SendData(string jsonData);
        string GetFormData();
        void ExecuteScript(string script);
        void Refresh();
        string LastError { get; }
        bool HasPendingEvents();
        string GetNextEvent();
        void ClearEvents();
        int GetEventCount();
        void ProcessEvents();
        void OpenDevTools();
    }

    [ComVisible(true)]
    [Guid("B2C3D4E5-F6A7-8901-BCDE-F12345678901")]
    [ClassInterface(ClassInterfaceType.None)]
    [ComDefaultInterface(typeof(IWebView2Host))]
    [ProgId("Consys.WebView2Host")]
    public class WebView2Host : IWebView2Host, IDisposable
    {
        private Form _hostForm;
        private WebView2 _webView;
        private bool _isInitialized = false;
        private string _lastError = "";
        private Queue<string> _eventQueue = new Queue<string>();
        private readonly object _queueLock = new object();

        // NEU: Direkte Datenbank-Bridge (kein API-Server nötig!)
        private AccessDataBridge _dataBridge;

        public bool Initialize()
        {
            if (_isInitialized) return true;
            try
            {
                // NEU: Datenbank-Bridge initialisieren
                _dataBridge = new AccessDataBridge();

                _hostForm = new Form();
                _hostForm.Text = "WebView2 Browser";
                _hostForm.FormBorderStyle = FormBorderStyle.Sizable;
                _hostForm.ShowInTaskbar = true;
                _hostForm.StartPosition = FormStartPosition.CenterScreen;
                _hostForm.Width = 1200;
                _hostForm.Height = 800;

                _webView = new WebView2();
                _webView.Dock = DockStyle.Fill;
                _hostForm.Controls.Add(_webView);

                var userDataFolder = System.IO.Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    "Consys", "WebView2"
                );

                if (!System.IO.Directory.Exists(userDataFolder))
                    System.IO.Directory.CreateDirectory(userDataFolder);

                var initTask = InitWebViewAsync(userDataFolder);
                WaitWithDoEvents(initTask, 10000);

                if (!initTask.IsCompleted) { _lastError = "Timeout"; return false; }
                if (initTask.IsFaulted) { _lastError = initTask.Exception.InnerException.Message; return false; }

                _isInitialized = true;
                return true;
            }
            catch (Exception ex) { _lastError = ex.Message; return false; }
        }

        private void WaitWithDoEvents(Task task, int timeoutMs)
        {
            int waited = 0;
            while (!task.IsCompleted && waited < timeoutMs)
            {
                Application.DoEvents();
                Thread.Sleep(50);
                waited += 50;
            }
        }

        private async Task InitWebViewAsync(string userDataFolder)
        {
            var env = await CoreWebView2Environment.CreateAsync(null, userDataFolder, null);
            await _webView.EnsureCoreWebView2Async(env);
            _webView.CoreWebView2.Settings.IsScriptEnabled = true;
            _webView.CoreWebView2.Settings.AreDefaultScriptDialogsEnabled = true;
            _webView.CoreWebView2.Settings.IsWebMessageEnabled = true;
            _webView.CoreWebView2.Settings.AreDevToolsEnabled = true;
            _webView.CoreWebView2.WebMessageReceived += OnWebMessageReceived_Host;
        }

        private void OnWebMessageReceived_Host(object sender, CoreWebView2WebMessageReceivedEventArgs e)
        {
            try
            {
                string message = e.TryGetWebMessageAsString();
                if (string.IsNullOrEmpty(message)) return;

                // Prüfen ob es ein Datenbank-Request ist
                var json = JObject.Parse(message);
                if (json.ContainsKey("action") && json.ContainsKey("requestId"))
                {
                    // NEU: Direkt an AccessDataBridge weiterleiten
                    string response = _dataBridge.ProcessRequest(message);

                    // Antwort zurück an JavaScript senden
                    _webView.CoreWebView2.PostWebMessageAsString(response);
                }
                else
                {
                    // Kein DB-Request - in Queue für manuelles Polling
                    lock (_queueLock) { _eventQueue.Enqueue(message); }
                }
            }
            catch (Exception ex)
            {
                // Bei Parse-Fehler: In Queue speichern
                try
                {
                    string msg = e.TryGetWebMessageAsString();
                    if (!string.IsNullOrEmpty(msg))
                        lock (_queueLock) { _eventQueue.Enqueue(msg); }
                }
                catch { }
                _lastError = ex.Message;
            }
        }

        public void Navigate(string url)
        {
            if (!_isInitialized) { _lastError = "Nicht initialisiert"; return; }
            try
            {
                if (url.Contains(":\\") && !url.StartsWith("file:"))
                    url = "file:///" + url.Replace("\\", "/");
                _webView.CoreWebView2.Navigate(url);
            }
            catch (Exception ex) { _lastError = ex.Message; }
        }

        public void NavigateToString(string htmlContent)
        {
            if (!_isInitialized) return;
            try { _webView.CoreWebView2.NavigateToString(htmlContent); }
            catch (Exception ex) { _lastError = ex.Message; }
        }

        public string QueryCurrentUrl()
        {
            if (!_isInitialized) return "";
            return _webView.Source != null ? _webView.Source.ToString() : "";
        }

        public void Refresh() { if (_isInitialized) _webView.CoreWebView2.Reload(); }
        public void GoBack() { if (_isInitialized && _webView.CanGoBack) _webView.GoBack(); }
        public void GoForward() { if (_isInitialized && _webView.CanGoForward) _webView.GoForward(); }

        public string ExecuteScript(string script)
        {
            if (!_isInitialized) return "";
            try { var t = _webView.CoreWebView2.ExecuteScriptAsync(script); t.Wait(5000); return t.Result; }
            catch (Exception ex) { _lastError = ex.Message; return ""; }
        }

        public void PostWebMessage(string message)
        {
            if (!_isInitialized) return;
            try { _webView.CoreWebView2.PostWebMessageAsString(message); }
            catch (Exception ex) { _lastError = ex.Message; }
        }

        public void Show() { if (_hostForm != null && !_hostForm.IsDisposed) { _hostForm.Show(); _hostForm.BringToFront(); } }
        public void Hide() { if (_hostForm != null && !_hostForm.IsDisposed) _hostForm.Hide(); }
        public void SetBounds(int left, int top, int width, int height) { if (_hostForm != null && !_hostForm.IsDisposed) _hostForm.SetBounds(left, top, width, height); }
        public void Close() { Dispose(); }

        public bool IsInitialized { get { return _isInitialized; } }
        public string LastError { get { return _lastError; } }
        public bool HasPendingEvents() { lock (_queueLock) { return _eventQueue.Count > 0; } }
        public string GetNextEvent() { lock (_queueLock) { return _eventQueue.Count > 0 ? _eventQueue.Dequeue() : ""; } }
        public void ClearEvents() { lock (_queueLock) { _eventQueue.Clear(); } }
        public int GetEventCount() { lock (_queueLock) { return _eventQueue.Count; } }

        private bool _disposed = false;
        public void Dispose()
        {
            if (_disposed) return;
            try { if (_webView != null) _webView.Dispose(); if (_hostForm != null) { _hostForm.Close(); _hostForm.Dispose(); } } catch { }
            _disposed = true;
        }
    }

    /// <summary>
    /// WebFormHost - Öffnet HTML-Formulare in einem eigenständigen Fenster
    /// Das Fenster bleibt offen bis CloseForm() aufgerufen wird oder der Benutzer es schließt
    /// </summary>
    [ComVisible(true)]
    [Guid("D4E5F6A7-B8C9-0123-DEF0-345678901234")]
    [ClassInterface(ClassInterfaceType.None)]
    [ComDefaultInterface(typeof(IWebFormHost))]
    [ProgId("ConsysWebView2.WebFormHost")]
    public class WebFormHost : IWebFormHost, IDisposable
    {
        private Form _hostForm;
        // NEU: Direkt CoreWebView2Controller statt WinForms-Control verwenden
        private CoreWebView2Controller _controller;
        private CoreWebView2 _coreWebView2;
        private bool _isFormOpen = false;
        private string _lastError = "";
        private string _pendingData = "";
        private Queue<string> _eventQueue = new Queue<string>();
        private readonly object _queueLock = new object();
        private bool _webViewReady = false;

        // NEU: Direkte Datenbank-Bridge (kein API-Server nötig!)
        private AccessDataBridge _dataBridge = new AccessDataBridge();

        public bool ShowForm(string htmlPath, string title, int width, int height)
        {
            return ShowFormWithData(htmlPath, title, width, height, "");
        }

        public bool ShowFormWithData(string htmlPath, string title, int width, int height, string jsonData)
        {
            try
            {
                FileLog.Clear();
                FileLog.Write("=== ShowFormWithData START (Controller-Methode) ===");
                FileLog.Write("htmlPath: " + htmlPath);
                FileLog.Write("title: " + title);
                FileLog.Write("size: " + width + "x" + height);

                CloseForm();
                _pendingData = jsonData;
                _webViewReady = false;
                _lastError = "";

                // Form erstellen
                _hostForm = new Form();
                _hostForm.Text = title;
                _hostForm.FormBorderStyle = FormBorderStyle.Sizable;
                _hostForm.ShowInTaskbar = true;
                _hostForm.StartPosition = FormStartPosition.CenterScreen;
                _hostForm.Width = width;
                _hostForm.Height = height;
                _hostForm.BackColor = System.Drawing.Color.White;

                _hostForm.FormClosed += (s, e) =>
                {
                    _isFormOpen = false;
                    _webViewReady = false;
                    if (_controller != null)
                    {
                        _controller.Close();
                        _controller = null;
                    }
                };

                // Form Resize Handler für Controller-Bounds
                _hostForm.Resize += (s, e) =>
                {
                    if (_controller != null && _hostForm != null)
                    {
                        _controller.Bounds = new System.Drawing.Rectangle(0, 0,
                            _hostForm.ClientSize.Width, _hostForm.ClientSize.Height);
                    }
                };

                // Form anzeigen
                FileLog.Write("Form Show...");
                _hostForm.Show();
                _isFormOpen = true;
                Application.DoEvents();
                FileLog.Write("Form sichtbar, Handle: " + _hostForm.Handle);

                // WebView2 Controller direkt erstellen (OHNE WinForms-Control)
                var userDataFolder = System.IO.Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    "Consys", "WebView2"
                );
                if (!System.IO.Directory.Exists(userDataFolder))
                    System.IO.Directory.CreateDirectory(userDataFolder);

                FileLog.Write("Starte InitControllerAsync...");
                var initTask = InitControllerAsync(userDataFolder, htmlPath);

                // Warten mit DoEvents damit UI responsiv bleibt
                int timeout = 15000, waited = 0;
                while (!_webViewReady && waited < timeout)
                {
                    Application.DoEvents();
                    Thread.Sleep(50);
                    waited += 50;
                }

                FileLog.Write("WebViewReady: " + _webViewReady + ", waited: " + waited + "ms");

                if (!_webViewReady)
                {
                    _lastError = "WebView2 Initialisierung timeout";
                    FileLog.Write("TIMEOUT - _lastError: " + _lastError);
                    return false;
                }

                _hostForm.BringToFront();
                _hostForm.Activate();

                FileLog.Write("=== ShowFormWithData ERFOLGREICH ===");
                return true;
            }
            catch (Exception ex)
            {
                _lastError = "ShowFormWithData: " + ex.Message;
                if (ex.InnerException != null)
                    _lastError += " | Inner: " + ex.InnerException.Message;
                FileLog.Write("EXCEPTION: " + _lastError);
                return false;
            }
        }

        // NEUE METHODE: Controller direkt erstellen (ohne WinForms-Control)
        private async Task InitControllerAsync(string userDataFolder, string htmlPath)
        {
            try
            {
                FileLog.Write("InitControllerAsync START - Path: " + htmlPath);
                FileLog.Write("userDataFolder: " + userDataFolder);

                // Environment erstellen
                var env = await CoreWebView2Environment.CreateAsync(null, userDataFolder, null);
                FileLog.Write("Environment erstellt");

                // Controller DIREKT erstellen (umgeht WinForms-Control und dessen DefaultBackgroundColor-Problem)
                _controller = await env.CreateCoreWebView2ControllerAsync(_hostForm.Handle);
                FileLog.Write("Controller erstellt");

                // Bounds setzen
                _controller.Bounds = new System.Drawing.Rectangle(0, 0,
                    _hostForm.ClientSize.Width, _hostForm.ClientSize.Height);
                _controller.IsVisible = true;
                FileLog.Write("Controller Bounds gesetzt und sichtbar");

                // CoreWebView2 Referenz holen
                _coreWebView2 = _controller.CoreWebView2;
                FileLog.Write("CoreWebView2 Referenz: " + (_coreWebView2 != null ? "OK" : "NULL"));

                if (_coreWebView2 == null)
                {
                    FileLog.Write("FATAL: CoreWebView2 ist NULL");
                    _lastError = "WebView2 konnte nicht initialisiert werden";
                    _webViewReady = true;
                    return;
                }

                // Settings konfigurieren
                _coreWebView2.Settings.IsScriptEnabled = true;
                _coreWebView2.Settings.AreDefaultScriptDialogsEnabled = true;
                _coreWebView2.Settings.IsWebMessageEnabled = true;
                _coreWebView2.Settings.AreDevToolsEnabled = true;
                _coreWebView2.Settings.AreDefaultContextMenusEnabled = true;
                FileLog.Write("Settings konfiguriert");

                // Event-Handler registrieren
                _coreWebView2.WebMessageReceived += OnWebMessageReceived_Direct;
                _coreWebView2.NavigationCompleted += OnNavigationCompleted_Direct;
                _coreWebView2.NavigationStarting += (s, e) =>
                {
                    FileLog.Write("Navigation startet: " + e.Uri);
                };

                // URL erstellen
                string url = htmlPath;
                if (htmlPath.Contains(":\\") && !htmlPath.StartsWith("file:"))
                    url = "file:///" + htmlPath.Replace("\\", "/");

                FileLog.Write("Navigiere zu URL: " + url);

                // Prüfe ob Datei existiert
                bool fileExists = !htmlPath.Contains(":\\") || System.IO.File.Exists(htmlPath);
                FileLog.Write("Datei existiert: " + fileExists);

                if (!fileExists)
                {
                    _lastError = "Datei nicht gefunden: " + htmlPath;
                    FileLog.Write("FEHLER: " + _lastError);
                    _coreWebView2.NavigateToString("<html><body style='font-family:Arial;padding:50px;'><h1 style='color:red;'>Fehler</h1><p>Datei nicht gefunden:</p><code>" + htmlPath + "</code></body></html>");
                }
                else
                {
                    FileLog.Write("Rufe Navigate auf...");
                    _coreWebView2.Navigate(url);
                    FileLog.Write("Navigate aufgerufen");
                }

                _webViewReady = true;
                FileLog.Write("InitControllerAsync ENDE - Ready=true");
            }
            catch (Exception ex)
            {
                _lastError = "InitController: " + ex.Message;
                FileLog.Write("EXCEPTION: " + ex.ToString());
                _webViewReady = true; // Damit die Schleife endet
            }
        }

        // Event-Handler für direkte Controller-Nutzung
        private void OnNavigationCompleted_Direct(object sender, CoreWebView2NavigationCompletedEventArgs e)
        {
            FileLog.Write("NavigationCompleted_Direct - Success: " + e.IsSuccess +
                ", Status: " + e.WebErrorStatus);

            if (!e.IsSuccess)
            {
                _lastError = "Navigation fehlgeschlagen: " + e.WebErrorStatus.ToString();
                FileLog.Write("Navigation FEHLER: " + _lastError);
            }

            if (e.IsSuccess && !string.IsNullOrEmpty(_pendingData))
            {
                try
                {
                    string escapedData = _pendingData
                        .Replace("\\", "\\\\")
                        .Replace("'", "\\'")
                        .Replace("\r", "")
                        .Replace("\n", "")
                        .Replace("\t", " ");

                    string script = "setTimeout(function() { if(typeof Bridge !== 'undefined' && Bridge.onDataReceived) { Bridge.onDataReceived('" + escapedData + "'); } }, 500);";
                    _coreWebView2.ExecuteScriptAsync(script);
                    _pendingData = "";
                    FileLog.Write("PendingData gesendet");
                }
                catch (Exception ex)
                {
                    _lastError = "OnNavigationCompleted_Direct: " + ex.Message;
                    FileLog.Write("EXCEPTION bei PendingData: " + ex.Message);
                }
            }
        }

        private void OnWebMessageReceived_Direct(object sender, CoreWebView2WebMessageReceivedEventArgs e)
        {
            try
            {
                string message = e.TryGetWebMessageAsString();
                if (string.IsNullOrEmpty(message)) return;

                FileLog.Write("WebMessage empfangen: " + message.Substring(0, Math.Min(100, message.Length)));

                var json = JObject.Parse(message);
                if (json.ContainsKey("action") && json.ContainsKey("requestId"))
                {
                    string response = _dataBridge.ProcessRequest(message);
                    _coreWebView2.PostWebMessageAsString(response);
                    FileLog.Write("Response gesendet");
                }
                else
                {
                    lock (_queueLock) { _eventQueue.Enqueue(message); }
                }
            }
            catch (Exception ex)
            {
                try
                {
                    string msg = e.TryGetWebMessageAsString();
                    if (!string.IsNullOrEmpty(msg))
                        lock (_queueLock) { _eventQueue.Enqueue(msg); }
                }
                catch { }
                _lastError = ex.Message;
                FileLog.Write("WebMessage EXCEPTION: " + ex.Message);
            }
        }

        public void CloseForm()
        {
            try
            {
                if (_controller != null)
                {
                    _controller.Close();
                    _controller = null;
                }
                _coreWebView2 = null;
                if (_hostForm != null && !_hostForm.IsDisposed)
                {
                    _hostForm.Close();
                    _hostForm.Dispose();
                    _hostForm = null;
                }
                _isFormOpen = false;
                _webViewReady = false;
                ClearEvents();
            }
            catch { }
        }

        public bool IsFormOpen { get { return _isFormOpen && _hostForm != null && !_hostForm.IsDisposed; } }
        public string LastError { get { return _lastError; } }

        public void SendData(string jsonData)
        {
            if (!IsFormOpen || _coreWebView2 == null || !_webViewReady) return;
            try
            {
                string escapedData = jsonData
                    .Replace("\\", "\\\\")
                    .Replace("'", "\\'")
                    .Replace("\r", "")
                    .Replace("\n", "");
                string script = "if(typeof Bridge !== 'undefined' && Bridge.onDataReceived) { Bridge.onDataReceived('" + escapedData + "'); }";
                _coreWebView2.ExecuteScriptAsync(script);
            }
            catch (Exception ex) { _lastError = ex.Message; }
        }

        public string GetFormData()
        {
            if (!IsFormOpen || _coreWebView2 == null || !_webViewReady) return "{}";
            try
            {
                string script = "typeof Bridge !== 'undefined' && Bridge.getFormData ? JSON.stringify(Bridge.getFormData()) : '{}'";
                var task = _coreWebView2.ExecuteScriptAsync(script);
                task.Wait(5000);
                string result = task.Result;
                if (result != null && result.StartsWith("\"") && result.EndsWith("\""))
                    result = JsonConvert.DeserializeObject<string>(result);
                return result ?? "{}";
            }
            catch (Exception ex) { _lastError = ex.Message; return "{}"; }
        }

        public void ExecuteScript(string script)
        {
            if (!IsFormOpen || _coreWebView2 == null || !_webViewReady) return;
            try { _coreWebView2.ExecuteScriptAsync(script); }
            catch (Exception ex) { _lastError = ex.Message; }
        }

        public void Refresh()
        {
            if (!IsFormOpen || _coreWebView2 == null || !_webViewReady) return;
            try { _coreWebView2.Reload(); }
            catch { }
        }

        /// <summary>
        /// Muss regelmäßig aufgerufen werden um Windows-Events zu verarbeiten
        /// In VBA: In einem Timer alle 100ms aufrufen
        /// </summary>
        public void ProcessEvents()
        {
            Application.DoEvents();
        }

        public bool HasPendingEvents() { lock (_queueLock) { return _eventQueue.Count > 0; } }
        public string GetNextEvent() { lock (_queueLock) { return _eventQueue.Count > 0 ? _eventQueue.Dequeue() : ""; } }
        public void ClearEvents() { lock (_queueLock) { _eventQueue.Clear(); } }
        public int GetEventCount() { lock (_queueLock) { return _eventQueue.Count; } }

        public void OpenDevTools()
        {
            if (_coreWebView2 != null)
            {
                try
                {
                    _coreWebView2.OpenDevToolsWindow();
                    FileLog.Write("DevTools geöffnet");
                }
                catch (Exception ex)
                {
                    FileLog.Write("DevTools Fehler: " + ex.Message);
                }
            }
        }

        public void Dispose() { CloseForm(); }
    }
}
