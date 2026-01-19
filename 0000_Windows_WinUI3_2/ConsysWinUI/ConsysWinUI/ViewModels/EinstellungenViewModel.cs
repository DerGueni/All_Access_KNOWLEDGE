using System;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using ConsysWinUI.Services;

namespace ConsysWinUI.ViewModels;

/// <summary>
/// ViewModel für Einstellungen (frm_Einstellungen).
/// Verwaltet Anwendungseinstellungen und Benutzeroptionen.
/// </summary>
public partial class EinstellungenViewModel : BaseViewModel, INavigationAware
{
    #region Properties - Allgemein

    [ObservableProperty]
    private string _anwendungsTitel = "CONSYS Personalplanung";

    [ObservableProperty]
    private string _datenbankPfad = string.Empty;

    [ObservableProperty]
    private string _backendPfad = string.Empty;

    [ObservableProperty]
    private bool _autoSave = true;

    [ObservableProperty]
    private int _autoSaveIntervall = 5; // Minuten

    #endregion

    #region Properties - Darstellung

    [ObservableProperty]
    private string _selectedTheme = "System";

    [ObservableProperty]
    private ObservableCollection<string> _themeOptionen = new()
    {
        "System",
        "Hell",
        "Dunkel"
    };

    [ObservableProperty]
    private int _schriftgroesse = 12;

    [ObservableProperty]
    private bool _kompakteAnsicht = false;

    [ObservableProperty]
    private bool _sidebarEingeklappt = false;

    #endregion

    #region Properties - Dienstplan

    [ObservableProperty]
    private int _standardAnsichtTage = 7;

    [ObservableProperty]
    private TimeSpan _arbeitsbeginnStandard = new TimeSpan(8, 0, 0);

    [ObservableProperty]
    private TimeSpan _arbeitsendeStandard = new TimeSpan(17, 0, 0);

    [ObservableProperty]
    private bool _wochenendeMarkieren = true;

    [ObservableProperty]
    private bool _feiertageMarkieren = true;

    #endregion

    #region Properties - Benachrichtigungen

    [ObservableProperty]
    private bool _benachrichtigungenAktiv = true;

    [ObservableProperty]
    private bool _emailBenachrichtigungen = false;

    [ObservableProperty]
    private string _emailAdresse = string.Empty;

    [ObservableProperty]
    private bool _soundEffekte = true;

    #endregion

    #region Properties - Export/Import

    [ObservableProperty]
    private string _exportPfad = string.Empty;

    [ObservableProperty]
    private string _selectedExportFormat = "Excel";

    [ObservableProperty]
    private ObservableCollection<string> _exportFormate = new()
    {
        "Excel",
        "CSV",
        "PDF"
    };

    [ObservableProperty]
    private bool _exportMitKopfzeile = true;

    #endregion

    #region Properties - Status

    [ObservableProperty]
    private string _versionInfo = string.Empty;

    [ObservableProperty]
    private string _letzteSynchronisation = string.Empty;

    [ObservableProperty]
    private bool _hasUnsavedChanges = false;

    #endregion

    public EinstellungenViewModel(
        IDatabaseService databaseService,
        INavigationService navigationService,
        IDialogService dialogService)
        : base(databaseService, navigationService, dialogService)
    {
    }

    public override async Task InitializeAsync()
    {
        await LoadSettingsAsync();
    }

    public void OnNavigatedTo(object? parameter)
    {
        _ = LoadSettingsAsync();
    }

    public void OnNavigatedFrom()
    {
        // Bei ungespeicherten Änderungen warnen?
        if (HasUnsavedChanges)
        {
            // TODO: Warnung anzeigen
        }
    }

    #region Data Loading

    [RelayCommand]
    private async Task LoadSettingsAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            // Version Info setzen
            VersionInfo = $"CONSYS WinUI3 v1.0.0 - Build {DateTime.Now:yyyyMMdd}";
            LetzteSynchronisation = DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss");

            // TODO: Einstellungen aus Datenbank/Registry/JSON laden
            // Hier Beispielwerte:
            DatenbankPfad = @"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb";
            BackendPfad = @"S:\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb";
            ExportPfad = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);

            HasUnsavedChanges = false;
            await Task.CompletedTask;

            ShowSuccess("Einstellungen geladen");
        }, "Lade Einstellungen...");
    }

    [RelayCommand]
    private async Task SaveSettingsAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            // TODO: Einstellungen in Datenbank/Registry/JSON speichern

            HasUnsavedChanges = false;
            await Task.CompletedTask;

            ShowSuccess("Einstellungen gespeichert");
        }, "Speichere Einstellungen...");
    }

    #endregion

    #region Commands - Allgemein

    [RelayCommand]
    private async Task DatenbankPfadWaehlenAsync()
    {
        // TODO: Datei-Dialog öffnen
        await _dialogService.ShowMessageAsync("Dateipfad", "Dateiauswahl ist in Entwicklung.");
    }

    [RelayCommand]
    private async Task BackendPfadWaehlenAsync()
    {
        // TODO: Datei-Dialog öffnen
        await _dialogService.ShowMessageAsync("Dateipfad", "Dateiauswahl ist in Entwicklung.");
    }

    [RelayCommand]
    private async Task ExportPfadWaehlenAsync()
    {
        // TODO: Ordner-Dialog öffnen
        await _dialogService.ShowMessageAsync("Ordnerpfad", "Ordnerauswahl ist in Entwicklung.");
    }

    #endregion

    #region Commands - Darstellung

    [RelayCommand]
    private void ThemeAnwenden()
    {
        // TODO: Theme wechseln
        ShowInfo($"Theme '{SelectedTheme}' wird angewendet...");
        HasUnsavedChanges = true;
    }

    [RelayCommand]
    private void SchriftgroesseErhoehen()
    {
        if (Schriftgroesse < 20)
        {
            Schriftgroesse++;
            HasUnsavedChanges = true;
        }
    }

    [RelayCommand]
    private void SchriftgroesseVerringern()
    {
        if (Schriftgroesse > 8)
        {
            Schriftgroesse--;
            HasUnsavedChanges = true;
        }
    }

    #endregion

    #region Commands - Wartung

    [RelayCommand]
    private async Task DatenbankReparierenAsync()
    {
        var confirm = await _dialogService.ShowConfirmationAsync(
            "Datenbank reparieren",
            "Möchten Sie die Datenbank komprimieren und reparieren?\n\nDieser Vorgang kann einige Minuten dauern.");

        if (confirm)
        {
            // TODO: Datenbank reparieren
            ShowInfo("Datenbank-Reparatur ist in Entwicklung.");
        }
    }

    [RelayCommand]
    private async Task CacheLoeschenAsync()
    {
        var confirm = await _dialogService.ShowConfirmationAsync(
            "Cache löschen",
            "Möchten Sie den lokalen Cache löschen?\n\nDie Anwendung wird anschließend neu geladen.");

        if (confirm)
        {
            // TODO: Cache löschen
            ShowSuccess("Cache wurde gelöscht");
        }
    }

    [RelayCommand]
    private async Task LogsAnzeigenAsync()
    {
        // TODO: Log-Viewer öffnen
        await _dialogService.ShowMessageAsync("Logs", "Log-Viewer ist in Entwicklung.");
    }

    #endregion

    #region Commands - Info

    [RelayCommand]
    private async Task UeberAsync()
    {
        await _dialogService.ShowMessageAsync(
            "Über CONSYS",
            $"CONSYS Personalplanung\n\n" +
            $"Version: {VersionInfo}\n" +
            $"Framework: WinUI 3 / .NET 8\n\n" +
            $"Entwickelt für CONSEC GmbH\n" +
            $"© 2025 Alle Rechte vorbehalten");
    }

    [RelayCommand]
    private async Task HilfeAsync()
    {
        // TODO: Hilfe öffnen
        await _dialogService.ShowMessageAsync("Hilfe", "Online-Hilfe ist in Entwicklung.");
    }

    #endregion

    #region Commands - Sidebar Navigation

    [RelayCommand]
    private void NavigateToHauptmenue()
    {
        _navigationService.NavigateTo<MainMenuViewModel>();
    }

    #endregion

    #region Property Change Tracking

    partial void OnSelectedThemeChanged(string value) => HasUnsavedChanges = true;
    partial void OnSchriftgroesseChanged(int value) => HasUnsavedChanges = true;
    partial void OnKompakteAnsichtChanged(bool value) => HasUnsavedChanges = true;
    partial void OnSidebarEingeklapptChanged(bool value) => HasUnsavedChanges = true;
    partial void OnAutoSaveChanged(bool value) => HasUnsavedChanges = true;
    partial void OnAutoSaveIntervallChanged(int value) => HasUnsavedChanges = true;
    partial void OnBenachrichtigungenAktivChanged(bool value) => HasUnsavedChanges = true;
    partial void OnEmailBenachrichtigungenChanged(bool value) => HasUnsavedChanges = true;
    partial void OnSoundEffekteChanged(bool value) => HasUnsavedChanges = true;

    #endregion
}
