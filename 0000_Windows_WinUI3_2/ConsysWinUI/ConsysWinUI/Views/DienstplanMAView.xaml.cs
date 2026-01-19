using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using ConsysWinUI.ViewModels;
using ConsysWinUI.Controls;
using System.Collections.Specialized;
using System.Linq;

namespace ConsysWinUI.Views;

public sealed partial class DienstplanMAView : Page
{
    public DienstplanMAViewModel ViewModel { get; }

    public DienstplanMAView()
    {
        this.InitializeComponent();
        ViewModel = App.GetRequiredService<DienstplanMAViewModel>();
        this.DataContext = ViewModel;

        // Subscribe to collection changes to update calendar
        ViewModel.KalenderEintraege.CollectionChanged += KalenderEintraege_CollectionChanged;
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

    private void KalenderEintraege_CollectionChanged(object? sender, NotifyCollectionChangedEventArgs e)
    {
        // Update calendar when data changes
        CalendarGrid.SetEntries(ViewModel.KalenderEintraege);
    }

    private void ViewMode_Changed(object sender, RoutedEventArgs e)
    {
        if (sender is RadioButton radioButton && radioButton.Tag is string tag)
        {
            CalendarGrid.Visibility = tag == "Calendar" ? Visibility.Visible : Visibility.Collapsed;
            ListViewGrid.Visibility = tag == "List" ? Visibility.Visible : Visibility.Collapsed;
        }
    }

    private void CalendarGrid_EntryClicked(object? sender, CalendarEntryClickedEventArgs e)
    {
        // When user clicks an entry in calendar, show details or navigate
        if (e.Entry.Type == CalendarEntryType.Einsatz && e.Entry.Data is DienstplanEintragItem eintrag)
        {
            ViewModel.SelectedEintrag = eintrag;
        }
    }

    private void CalendarGrid_DateRangeChanged(object? sender, DateRangeChangedEventArgs e)
    {
        // When user navigates weeks, update ViewModel date range
        ViewModel.VonDatum = new System.DateTimeOffset(e.StartDate);
        ViewModel.BisDatum = new System.DateTimeOffset(e.EndDate);

        // Reload data for new date range
        _ = ViewModel.LoadDienstplanCommand.ExecuteAsync(null);
    }
}
