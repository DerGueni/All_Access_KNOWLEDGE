using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using ConsysWinUI.ViewModels;

namespace ConsysWinUI.Views;

/// <summary>
/// Hauptmenü-View mit Dashboard und Navigation zu allen Modulen
/// </summary>
public sealed partial class MainMenuView : Page
{
    public MainMenuViewModel ViewModel { get; }

    public MainMenuView()
    {
        this.InitializeComponent();
        ViewModel = App.GetRequiredService<MainMenuViewModel>();
        this.DataContext = ViewModel;
    }

    protected override async void OnNavigatedTo(NavigationEventArgs e)
    {
        base.OnNavigatedTo(e);
        await ViewModel.InitializeAsync();
    }

    private void NavigationCard_ItemClick(object sender, ItemClickEventArgs e)
    {
        if (e.ClickedItem is Border border && border.Tag is string destination)
        {
            switch (destination)
            {
                case "Mitarbeiterstamm":
                    Frame.Navigate(typeof(MitarbeiterstammView));
                    break;
                case "Auftragstamm":
                    Frame.Navigate(typeof(AuftragstammView));
                    break;
                case "Kundenstamm":
                    Frame.Navigate(typeof(KundenstammView));
                    break;
                case "DienstplanMA":
                    Frame.Navigate(typeof(DienstplanMAView));
                    break;
                case "DienstplanObjekt":
                    Frame.Navigate(typeof(DienstplanObjektView));
                    break;
            }
        }
    }
}
