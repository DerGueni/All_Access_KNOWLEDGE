using System;
using System.Runtime.InteropServices;

namespace Consys.AccessHost
{
    public class AccessHost
    {
        private dynamic? _app;

        public void StartAccess()
        {
            if (_app != null) return;
            var type = Type.GetTypeFromProgID("Access.Application");
            if (type == null)
            {
                throw new InvalidOperationException("Access.Application COM not available.");
            }
            _app = Activator.CreateInstance(type);
            _app.Visible = true;
        }

        public void OpenDatabase(string accdbPath)
        {
            if (_app == null) throw new InvalidOperationException("Access not started.");
            _app.OpenCurrentDatabase(accdbPath, false);
        }

        public void OpenForm(string formName)
        {
            if (_app == null) throw new InvalidOperationException("Access not started.");
            _app.DoCmd.OpenForm(formName);
        }

        public void CloseAll()
        {
            if (_app == null) return;
            try
            {
                _app.CloseCurrentDatabase();
            }
            catch
            {
                // ignore
            }
            try
            {
                _app.Quit();
            }
            catch
            {
                // ignore
            }
            try
            {
                Marshal.FinalReleaseComObject(_app);
            }
            catch
            {
                // ignore
            }
            _app = null;
        }
    }
}
