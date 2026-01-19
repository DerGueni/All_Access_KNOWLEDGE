using System.Threading.Tasks;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using ConsysWinUI.Services;

namespace ConsysWinUI.ViewModels;

/// <summary>
/// ViewModel für das Haupt-Dashboard (frm_Menuefuehrung1).
/// Zeigt Übersicht über Mitarbeiter, Kunden, Aufträge und bietet Navigation.
/// </summary>
public partial class MainMenuViewModel : BaseViewModel, INavigationAware
{
    [ObservableProperty]
    private int _mitarbeiterCount;

    [ObservableProperty]
    private int _kundenCount;

    [ObservableProperty]
    private int _auftraegeCount;

    [ObservableProperty]
    private int _aktiveAuftraegeCount;

    [ObservableProperty]
    private string _welcomeMessage = "Willkommen im CONSYS Planungssystem";

    public MainMenuViewModel(
        IDatabaseService databaseService,
        INavigationService navigationService,
        IDialogService dialogService)
        : base(databaseService, navigationService, dialogService)
    {
    }

    public override async Task InitializeAsync()
    {
        await LoadDashboardDataAsync();
    }

    public void OnNavigatedTo(object? parameter)
    {
        _ = LoadDashboardDataAsync();
    }

    public void OnNavigatedFrom()
    {
        // Cleanup wenn nötig
    }

    [RelayCommand]
    private async Task LoadDashboardDataAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            // Mitarbeiter zählen (nur aktive)
            var mitarbeiterSql = "SELECT COUNT(*) FROM tbl_MA_Mitarbeiterstamm WHERE IstAktiv = True";
            MitarbeiterCount = await _databaseService.ExecuteScalarAsync<int?>(mitarbeiterSql) ?? 0;

            // Kunden zählen (nur aktive)
            var kundenSql = "SELECT COUNT(*) FROM tbl_KD_Kundenstamm WHERE kun_IstAktiv = True";
            KundenCount = await _databaseService.ExecuteScalarAsync<int?>(kundenSql) ?? 0;

            // Aufträge zählen (gesamt)
            var auftragSql = "SELECT COUNT(*) FROM tbl_VA_Auftragstamm";
            AuftraegeCount = await _databaseService.ExecuteScalarAsync<int?>(auftragSql) ?? 0;

            // Aktive Aufträge (mit Status 1 = Aktiv)
            var aktiveAuftragSql = "SELECT COUNT(*) FROM tbl_VA_Auftragstamm WHERE VA_Status = 1";
            AktiveAuftraegeCount = await _databaseService.ExecuteScalarAsync<int?>(aktiveAuftragSql) ?? 0;

            ShowSuccess("Dashboard aktualisiert");
        }, "Lade Dashboard-Daten...");
    }

    [RelayCommand]
    private void NavigateToMitarbeiter()
    {
        _navigationService.NavigateTo<MitarbeiterstammViewModel>();
    }

    [RelayCommand]
    private void NavigateToKunden()
    {
        _navigationService.NavigateTo<KundenstammViewModel>();
    }

    [RelayCommand]
    private void NavigateToObjekte()
    {
        _navigationService.NavigateTo<ObjektstammViewModel>();
    }

    [RelayCommand]
    private void NavigateToAuftraege()
    {
        _navigationService.NavigateTo<AuftragstammViewModel>();
    }

    [RelayCommand]
    private void NavigateToDienstplanMA()
    {
        _navigationService.NavigateTo<DienstplanMAViewModel>();
    }

    [RelayCommand]
    private void NavigateToDienstplanObjekt()
    {
        _navigationService.NavigateTo<DienstplanObjektViewModel>();
    }

    [RelayCommand]
    private void NavigateToSchnellauswahl()
    {
        _navigationService.NavigateTo<SchnellauswahlViewModel>();
    }

    [RelayCommand]
    private async Task RefreshAsync()
    {
        await LoadDashboardDataAsync();
    }
}
