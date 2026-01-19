using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using ConsysWinUI.ViewModels;

namespace ConsysWinUI.Views;

/// <summary>
/// View für Zeitkontenverwaltung (frm_MA_Zeitkonten).
/// Zeigt Arbeitsstunden-Übersicht pro Mitarbeiter mit Soll/Ist-Vergleich und Korrekturbuchungen.
/// </summary>
public sealed partial class ZeitkontenView : Page
{
    public ZeitkontenViewModel ViewModel { get; }

    public ZeitkontenView()
    {
        this.InitializeComponent();

        // ViewModel wird per Dependency Injection bereitgestellt
        ViewModel = App.GetService<ZeitkontenViewModel>();
        DataContext = ViewModel;
    }

    protected override async void OnNavigatedTo(NavigationEventArgs e)
    {
        base.OnNavigatedTo(e);

        // ViewModel initialisieren
        await ViewModel.InitializeAsync();

        // Parameter weitergeben (z.B. MA_ID)
        if (e.Parameter != null)
        {
            ViewModel.OnNavigatedTo(e.Parameter);
        }
    }

    protected override void OnNavigatedFrom(NavigationEventArgs e)
    {
        base.OnNavigatedFrom(e);
        ViewModel.OnNavigatedFrom();
    }
}
