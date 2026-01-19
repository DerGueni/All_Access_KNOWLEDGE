using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using ConsysWinUI.ViewModels;
using System;

namespace ConsysWinUI.Views;

/// <summary>
/// Auftragsverwaltungs-View mit Stammdaten, Schichten und MA-Zuordnungen
/// </summary>
public sealed partial class AuftragstammView : Page
{
    public AuftragstammViewModel ViewModel { get; }

    public AuftragstammView()
    {
        this.InitializeComponent();
        ViewModel = App.GetRequiredService<AuftragstammViewModel>();
        this.DataContext = ViewModel;
    }

    protected override async void OnNavigatedTo(NavigationEventArgs e)
    {
        base.OnNavigatedTo(e);
        await ViewModel.InitializeAsync();

        if (e.Parameter is int vaId)
        {
            ViewModel.OnNavigatedTo(vaId);
        }
    }

    protected override void OnNavigatedFrom(NavigationEventArgs e)
    {
        base.OnNavigatedFrom(e);
        ViewModel.OnNavigatedFrom();
    }

    private void OnBackClick(object sender, RoutedEventArgs e)
    {
        if (Frame.CanGoBack)
        {
            Frame.GoBack();
        }
    }

    /// <summary>
    /// Handler für Tab-Wechsel
    /// </summary>
    private void OnTabSelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        // Hier können Tab-spezifische Daten nachgeladen werden
        if (sender is TabView tabView && tabView.SelectedItem is TabViewItem tabItem)
        {
            var header = tabItem.Header?.ToString();
            System.Diagnostics.Debug.WriteLine($"Tab gewechselt zu: {header}");

            // Bei Bedarf: Daten für Tab nachladen
            // z.B. if (header == "Rechnung") await ViewModel.LoadRechnungsdatenAsync();
        }
    }
}
