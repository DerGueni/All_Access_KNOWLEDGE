using ConsysWinUI.ViewModels;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;

namespace ConsysWinUI.Views;

/// <summary>
/// Code-behind für EinstellungenView.
/// </summary>
public sealed partial class EinstellungenView : Page
{
    public EinstellungenViewModel ViewModel { get; }

    public EinstellungenView()
    {
        ViewModel = App.GetService<EinstellungenViewModel>();
        this.InitializeComponent();
        this.DataContext = ViewModel;
    }

    protected override async void OnNavigatedTo(NavigationEventArgs e)
    {
        base.OnNavigatedTo(e);
        ViewModel.OnNavigatedTo(e.Parameter);
        await ViewModel.InitializeAsync();
    }

    protected override void OnNavigatedFrom(NavigationEventArgs e)
    {
        base.OnNavigatedFrom(e);
        ViewModel.OnNavigatedFrom();
    }
}
