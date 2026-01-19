using ConsysWinUI.ViewModels;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;

namespace ConsysWinUI.Views;

/// <summary>
/// Code-behind für LohnabrechnungenView.
/// </summary>
public sealed partial class LohnabrechnungenView : Page
{
    public LohnabrechnungenViewModel ViewModel { get; }

    public LohnabrechnungenView()
    {
        ViewModel = App.GetService<LohnabrechnungenViewModel>();
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
