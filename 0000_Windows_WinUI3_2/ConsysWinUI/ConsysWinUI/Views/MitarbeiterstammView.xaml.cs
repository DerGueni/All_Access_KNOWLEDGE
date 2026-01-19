using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using ConsysWinUI.ViewModels;

namespace ConsysWinUI.Views;

/// <summary>
/// Mitarbeiterverwaltungs-View mit Stammdaten, Qualifikationen, Bankdaten und Dokumenten
/// </summary>
public sealed partial class MitarbeiterstammView : Page
{
    public MitarbeiterstammViewModel ViewModel { get; }

    public MitarbeiterstammView()
    {
        this.InitializeComponent();
        ViewModel = App.GetRequiredService<MitarbeiterstammViewModel>();
        this.DataContext = ViewModel;
    }

    protected override async void OnNavigatedTo(NavigationEventArgs e)
    {
        base.OnNavigatedTo(e);
        await ViewModel.InitializeAsync();

        if (e.Parameter is int maId)
        {
            ViewModel.OnNavigatedTo(maId);
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
}
