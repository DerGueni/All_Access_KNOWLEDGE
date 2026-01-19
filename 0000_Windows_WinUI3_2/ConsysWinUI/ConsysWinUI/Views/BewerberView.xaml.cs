using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using ConsysWinUI.ViewModels;

namespace ConsysWinUI.Views
{
    /// <summary>
    /// Code-Behind für Bewerber-Verarbeitung View
    /// </summary>
    public sealed partial class BewerberView : Page
    {
        public BewerberViewModel ViewModel { get; }

        public BewerberView()
        {
            this.InitializeComponent();
            ViewModel = App.GetRequiredService<BewerberViewModel>();
        }

        protected override async void OnNavigatedTo(NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);
            await ViewModel.InitializeAsync();
        }
    }
}
