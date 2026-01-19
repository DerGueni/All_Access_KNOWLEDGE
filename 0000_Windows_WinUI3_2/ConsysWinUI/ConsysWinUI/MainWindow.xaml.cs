using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;

namespace ConsysWinUI
{
    public sealed partial class MainWindow : Window
    {
        private bool _canGoBack;

        public bool CanGoBack
        {
            get => _canGoBack;
            set
            {
                if (_canGoBack != value)
                {
                    _canGoBack = value;
                }
            }
        }

        private readonly Dictionary<string, Type> _pageTypes = new()
        {
            { "Dashboard", typeof(Views.MainMenuView) },
            { "Mitarbeiter", typeof(Views.MitarbeiterstammView) },
            { "Kunden", typeof(Views.KundenstammView) },
            { "Objekte", typeof(Views.ObjektstammView) },
            { "Auftraege", typeof(Views.AuftragstammView) },
            { "DienstplanMA", typeof(Views.DienstplanMAView) },
            { "DienstplanObjekt", typeof(Views.DienstplanObjektView) },
            { "Schnellauswahl", typeof(Views.SchnellauswahlView) },
            { "Bewerber", typeof(Views.BewerberView) },
            { "Abwesenheit", typeof(Views.AbwesenheitView) },
            { "Zeitkonten", typeof(Views.ZeitkontenView) },
            { "Lohnabrechnungen", typeof(Views.LohnabrechnungenView) },
            { "Einstellungen", typeof(Views.EinstellungenView) }
        };

        private readonly Dictionary<string, string> _pageTitles = new()
        {
            { "Dashboard", "Dashboard" },
            { "Mitarbeiter", "Mitarbeiter" },
            { "Kunden", "Kunden" },
            { "Objekte", "Objekte" },
            { "Auftraege", "Auftraege" },
            { "DienstplanMA", "Dienstplan (Mitarbeiter)" },
            { "DienstplanObjekt", "Dienstplan (Objekt)" },
            { "Schnellauswahl", "Schnellauswahl" },
            { "Bewerber", "Bewerber" },
            { "Abwesenheit", "Abwesenheit" },
            { "Zeitkonten", "Zeitkonten" },
            { "Lohnabrechnungen", "Lohnabrechnungen" },
            { "Einstellungen", "Einstellungen" }
        };

        public MainWindow()
        {
            try
            {
                LogMessage("MainWindow constructor start");
                this.InitializeComponent();
                LogMessage("InitializeComponent done");

                // Set window size
                var appWindow = this.AppWindow;
                appWindow.Resize(new Windows.Graphics.SizeInt32(1400, 900));
                LogMessage("Window resized");

                // Navigate to Dashboard on startup
                NavigateToPage("Dashboard");
                LogMessage("Navigated to Dashboard");

                // Set initial selection
                NavigationViewControl.SelectedItem = NavigationViewControl.MenuItems
                    .OfType<NavigationViewItem>()
                    .FirstOrDefault(item => item.Tag?.ToString() == "Dashboard");
                LogMessage("MainWindow constructor complete");
            }
            catch (Exception ex)
            {
                LogMessage($"MainWindow constructor error: {ex}");
                throw;
            }
        }

        private static void LogMessage(string message)
        {
            var logPath = Path.Combine(AppContext.BaseDirectory, "app.log");
            var logLine = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] {message}\n";
            File.AppendAllText(logPath, logLine);
            Debug.WriteLine(logLine);
        }

        private void NavigationView_ItemInvoked(NavigationView sender, NavigationViewItemInvokedEventArgs args)
        {
            if (args.IsSettingsInvoked)
            {
                // Settings page not implemented yet
            }
            else if (args.InvokedItemContainer is NavigationViewItem item)
            {
                var tag = item.Tag?.ToString();
                if (!string.IsNullOrEmpty(tag))
                {
                    NavigateToPage(tag);
                }
            }
        }

        private void NavigationView_BackRequested(NavigationView sender, NavigationViewBackRequestedEventArgs args)
        {
            if (ContentFrame.CanGoBack)
            {
                ContentFrame.GoBack();
            }
        }

        private void NavigateToPage(string pageTag)
        {
            if (_pageTypes.TryGetValue(pageTag, out var pageType))
            {
                ContentFrame.Navigate(pageType);

                // Update page title
                if (_pageTitles.TryGetValue(pageTag, out var title))
                {
                    PageTitleText.Text = title;
                }
            }
        }

        private void ContentFrame_Navigated(object sender, NavigationEventArgs e)
        {
            CanGoBack = ContentFrame.CanGoBack;

            // Update NavigationView selection
            var pageType = e.SourcePageType;
            var selectedItem = NavigationViewControl.MenuItems
                .OfType<NavigationViewItem>()
                .FirstOrDefault(item =>
                {
                    var tag = item.Tag?.ToString();
                    return tag != null && _pageTypes.TryGetValue(tag, out var type) && type == pageType;
                });

            if (selectedItem != null)
            {
                NavigationViewControl.SelectedItem = selectedItem;
            }
        }

        public void NavigateToDetail(Type detailPageType, object? parameter = null)
        {
            ContentFrame.Navigate(detailPageType, parameter);
        }
    }
}
