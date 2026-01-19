using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using ConsysWinUI.ViewModels;

namespace ConsysWinUI.Views;

/// <summary>
/// Code-Behind für Abwesenheitsverwaltung (frm_MA_Abwesenheit).
/// Verwaltet Mitarbeiter-Abwesenheiten mit Kalenderansicht.
/// </summary>
public sealed partial class AbwesenheitView : Page
{
    public AbwesenheitViewModel ViewModel { get; }

    public AbwesenheitView()
    {
        this.InitializeComponent();
        ViewModel = App.GetRequiredService<AbwesenheitViewModel>();
        this.DataContext = ViewModel;
    }

    protected override async void OnNavigatedTo(NavigationEventArgs e)
    {
        base.OnNavigatedTo(e);

        // Initialisierung beim ersten Laden
        await ViewModel.InitializeAsync();

        // Parameter-basierte Navigation (z.B. MA_ID)
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
