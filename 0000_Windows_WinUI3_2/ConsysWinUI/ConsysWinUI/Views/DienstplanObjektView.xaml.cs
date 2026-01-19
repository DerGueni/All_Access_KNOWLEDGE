using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using ConsysWinUI.ViewModels;
using ConsysWinUI.Controls;
using System.Collections.Specialized;

namespace ConsysWinUI.Views;

public sealed partial class DienstplanObjektView : Page
{
    public DienstplanObjektViewModel ViewModel { get; }

    public DienstplanObjektView()
    {
        this.InitializeComponent();
        ViewModel = App.GetRequiredService<DienstplanObjektViewModel>();
        this.DataContext = ViewModel;

        // Subscribe to collection changes to update calendar
        ViewModel.KalenderEintraege.CollectionChanged += KalenderEintraege_CollectionChanged;
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
        // When user clicks a schicht in calendar
        if (e.Entry.Type == CalendarEntryType.Schicht && e.Entry.Data is SchichtDetailItem schicht)
        {
            ViewModel.SelectedSchicht = schicht;
        }
    }

    private void CalendarGrid_DateRangeChanged(object? sender, DateRangeChangedEventArgs e)
    {
        // When user navigates weeks, update filter
        ViewModel.FilterDatumVon = e.StartDate;
        ViewModel.FilterDatumBis = e.EndDate;

        // Reload data for new date range
        _ = ViewModel.LoadDienstplanCommand.ExecuteAsync(null);
    }
}
