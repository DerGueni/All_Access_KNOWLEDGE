using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using ConsysWinUI.ViewModels;
using System.Collections.Generic;

namespace ConsysWinUI.Views
{
    public sealed partial class SchnellauswahlView : Page
    {
        public SchnellauswahlViewModel ViewModel { get; }

        public SchnellauswahlView()
        {
            this.InitializeComponent();
            ViewModel = App.GetRequiredService<SchnellauswahlViewModel>();
            this.DataContext = ViewModel;
        }

        protected override async void OnNavigatedTo(NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);

            // ViewModel initialisieren und Navigation-Parameter uebergeben
            await ViewModel.InitializeAsync();

            if (e.Parameter is SchichtDetailItem schicht)
            {
                ViewModel.OnNavigatedTo(schicht);
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

        private void OnSaveClick(object sender, RoutedEventArgs e)
        {
            ViewModel.SpeichernCommand.Execute(null);
        }

        private void OnCancelClick(object sender, RoutedEventArgs e)
        {
            if (Frame.CanGoBack)
            {
                Frame.GoBack();
            }
        }

        private void OnRefreshClick(object sender, RoutedEventArgs e)
        {
            ViewModel.AktualisierenCommand.Execute(null);
        }

        private void OnFilterChanged(object sender, RoutedEventArgs e)
        {
            ViewModel.FilterChangedCommand.Execute(null);
        }

        private void OnSearchTextChanged(AutoSuggestBox sender, AutoSuggestBoxTextChangedEventArgs args)
        {
            if (args.Reason == AutoSuggestionBoxTextChangeReason.UserInput)
            {
                ViewModel.SearchTerm = sender.Text;
                ViewModel.FilterChangedCommand.Execute(null);
            }
        }

        private void OnVerfuegbareSelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (sender is ListView listView)
            {
                ViewModel.SelectedVerfuegbare.Clear();
                foreach (var item in listView.SelectedItems)
                {
                    if (item is VerfuegbarerMitarbeiterItem ma)
                    {
                        ViewModel.SelectedVerfuegbare.Add(ma);
                    }
                }
                ViewModel.UpdateCanCommands();
            }
        }

        private void OnZugeordneteSelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (sender is ListView listView)
            {
                ViewModel.SelectedZugeordnete.Clear();
                foreach (var item in listView.SelectedItems)
                {
                    if (item is ZugeordneterMitarbeiterItem ma)
                    {
                        ViewModel.SelectedZugeordnete.Add(ma);
                    }
                }
                ViewModel.UpdateCanCommands();
            }
        }

        private void OnZuordnenClick(object sender, RoutedEventArgs e)
        {
            ViewModel.ZuordnenSelectedCommand.Execute(null);
        }

        private void OnEntfernenClick(object sender, RoutedEventArgs e)
        {
            ViewModel.EntfernenSelectedCommand.Execute(null);
        }

        private void OnAlleZuordnenClick(object sender, RoutedEventArgs e)
        {
            ViewModel.AlleZuordnenCommand.Execute(null);
        }

        private void OnAlleEntfernenClick(object sender, RoutedEventArgs e)
        {
            ViewModel.AlleEntfernenCommand.Execute(null);
        }

        private void VerfuegbareList_DoubleTapped(object sender, Microsoft.UI.Xaml.Input.DoubleTappedRoutedEventArgs e)
        {
            if (ViewModel.SelectedVerfuegbarer != null)
            {
                ViewModel.ZuordnenCommand.Execute(ViewModel.SelectedVerfuegbarer);
            }
        }

        private void ZugeordneteList_DoubleTapped(object sender, Microsoft.UI.Xaml.Input.DoubleTappedRoutedEventArgs e)
        {
            if (ViewModel.SelectedZugeordneter != null)
            {
                ViewModel.EntfernenCommand.Execute(ViewModel.SelectedZugeordneter);
            }
        }
    }
}
