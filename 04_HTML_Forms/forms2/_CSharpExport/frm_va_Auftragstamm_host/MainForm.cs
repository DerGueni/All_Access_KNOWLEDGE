using System;
using System.IO;
using System.Windows.Forms;

namespace Consys.AccessHost
{
    public class MainForm : Form
    {
        private readonly Button _btnStart;
        private readonly Button _btnOpenForm;
        private readonly Button _btnClose;
        private readonly TextBox _txtStatus;
        private AccessHost? _host;
        private HostConfig _config;

        public MainForm()
        {
            Text = "frm_va_Auftragstamm - Access Host";
            Width = 640;
            Height = 300;
            StartPosition = FormStartPosition.CenterScreen;

            _btnStart = new Button { Text = "Start Access", Left = 20, Top = 20, Width = 150 };
            _btnOpenForm = new Button { Text = "Open frm_va_Auftragstamm", Left = 190, Top = 20, Width = 220 };
            _btnClose = new Button { Text = "Close Access", Left = 430, Top = 20, Width = 150 };

            _txtStatus = new TextBox { Left = 20, Top = 70, Width = 560, Height = 160, Multiline = true, ReadOnly = true, ScrollBars = ScrollBars.Vertical };

            Controls.Add(_btnStart);
            Controls.Add(_btnOpenForm);
            Controls.Add(_btnClose);
            Controls.Add(_txtStatus);

            _btnStart.Click += (_, __) => StartAccess();
            _btnOpenForm.Click += (_, __) => OpenForm();
            _btnClose.Click += (_, __) => CloseAccess();

            _config = HostConfig.LoadOrCreate(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "config.json"));
            Shown += (_, __) => AutoStart();
        }

        private void AutoStart()
        {
            try
            {
                StartAccess();
                OpenForm();
            }
            catch (Exception ex)
            {
                AppendStatus("AutoStart failed: " + ex.Message);
            }
        }

        private void StartAccess()
        {
            _host ??= new AccessHost();
            _host.StartAccess();
            if (!File.Exists(_config.AccdbPath))
            {
                AppendStatus("ACCDB not found: " + _config.AccdbPath);
                return;
            }
            _host.OpenDatabase(_config.AccdbPath);
            AppendStatus("Access started and database opened.");
        }

        private void OpenForm()
        {
            if (_host == null)
            {
                AppendStatus("Access not started.");
                return;
            }
            _host.OpenForm(_config.FormName);
            AppendStatus("Form opened: " + _config.FormName);
        }

        private void CloseAccess()
        {
            if (_host == null)
            {
                AppendStatus("Access not started.");
                return;
            }
            _host.CloseAll();
            _host = null;
            AppendStatus("Access closed.");
        }

        private void AppendStatus(string message)
        {
            _txtStatus.AppendText("[" + DateTime.Now.ToString("HH:mm:ss") + "] " + message + Environment.NewLine);
        }
    }
}
