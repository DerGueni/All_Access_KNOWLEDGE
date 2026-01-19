using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using ConsysWinUI.Services;

namespace ConsysWinUI.ViewModels;

/// <summary>
/// ViewModel für Kundenverwaltung (frm_KD_Kundenstamm).
/// CRUD für Kunden mit Navigation und Auftragsübersicht.
/// </summary>
public partial class KundenstammViewModel : BaseViewModel, INavigationAware
{
    #region Properties - Kunden Stammdaten

    [ObservableProperty]
    private int _kunId;

    [ObservableProperty]
    private string? _kunFirma;

    [ObservableProperty]
    private bool _kunIstAktiv = true;

    [ObservableProperty]
    private string? _kunStrasse;

    [ObservableProperty]
    private string? _kunPlz;

    [ObservableProperty]
    private string? _kunOrt;

    [ObservableProperty]
    private string? _kunLand;

    [ObservableProperty]
    private string? _kunTelefon;

    [ObservableProperty]
    private string? _kunFax;

    [ObservableProperty]
    private string? _kunEmail;

    [ObservableProperty]
    private string? _kunWebsite;

    [ObservableProperty]
    private string? _kunAnsprechpartner;

    [ObservableProperty]
    private string? _kunKontaktNachname;

    [ObservableProperty]
    private string? _kunKontaktVorname;

    /// <summary>
    /// Vollständiger Kontaktname (Nachname, Vorname)
    /// </summary>
    public string KontaktnameDisplay
    {
        get
        {
            if (string.IsNullOrWhiteSpace(KunKontaktNachname) && string.IsNullOrWhiteSpace(KunKontaktVorname))
                return KunAnsprechpartner ?? "";
            if (string.IsNullOrWhiteSpace(KunKontaktVorname))
                return KunKontaktNachname ?? "";
            if (string.IsNullOrWhiteSpace(KunKontaktNachname))
                return KunKontaktVorname ?? "";
            return $"{KunKontaktNachname}, {KunKontaktVorname}";
        }
    }

    [ObservableProperty]
    private string? _kunBemerkung;

    [ObservableProperty]
    private string? _kunUstId;

    [ObservableProperty]
    private string? _kunSteuernummer;

    [ObservableProperty]
    private int? _zahlungsziel;

    public string ZahlungszielText
    {
        get => Zahlungsziel?.ToString() ?? "30";
        set
        {
            if (int.TryParse(value, out var result))
            {
                Zahlungsziel = result;
            }
            else if (string.IsNullOrWhiteSpace(value))
            {
                Zahlungsziel = null;
            }
        }
    }

    [ObservableProperty]
    private int _anzahlAuftraege;

    #endregion

    #region Properties - UI State

    [ObservableProperty]
    private bool _isEditMode;

    [ObservableProperty]
    private bool _isNewRecord;

    [ObservableProperty]
    private int _currentRecordIndex;

    [ObservableProperty]
    private int _totalRecords;

    [ObservableProperty]
    private bool _canNavigateFirst;

    [ObservableProperty]
    private bool _canNavigatePrevious;

    [ObservableProperty]
    private bool _canNavigateNext;

    [ObservableProperty]
    private bool _canNavigateLast;

    [ObservableProperty]
    private string? _searchText;

    [ObservableProperty]
    private System.Collections.ObjectModel.ObservableCollection<KundenListItem> _kundenListe = new();

    [ObservableProperty]
    private KundenListItem? _selectedKunde;

    partial void OnSelectedKundeChanged(KundenListItem? value)
    {
        if (value != null && value.KunId != KunId)
        {
            _ = LoadKundeAsync(value.KunId);
        }
    }

    #endregion

    private List<int> _allKundenIds = new();
    private List<int> _filteredKundenIds = new();

    public KundenstammViewModel(
        IDatabaseService databaseService,
        INavigationService navigationService,
        IDialogService dialogService)
        : base(databaseService, navigationService, dialogService)
    {
    }

    public override async Task InitializeAsync()
    {
        await LoadKundenIdsAsync();

        if (_filteredKundenIds.Any())
        {
            await LoadKundeAsync(_filteredKundenIds.First());
        }
        else
        {
            NewRecordCommand.Execute(null);
        }
    }

    public void OnNavigatedTo(object? parameter)
    {
        if (parameter is int kunId)
        {
            _ = LoadKundeAsync(kunId);
        }
    }

    public void OnNavigatedFrom()
    {
        // Cleanup wenn nötig
    }

    #region Data Loading

    private async Task LoadKundenIdsAsync(bool activeOnly = true)
    {
        // Korrekte Felder aus tbl_KD_Kundenstamm:
        // kun_Id, kun_Firma, kun_Ort, kun_Bezeichnung (enthält Kontaktname)
        // KEINE kun_Kontakt_Nachname oder kun_Kontakt_Vorname!
        var sql = activeOnly
            ? @"SELECT kun_Id, kun_Firma, kun_Ort, kun_Bezeichnung
               FROM tbl_KD_Kundenstamm WHERE kun_IstAktiv = True ORDER BY kun_Firma"
            : @"SELECT kun_Id, kun_Firma, kun_Ort, kun_Bezeichnung
               FROM tbl_KD_Kundenstamm ORDER BY kun_Firma";

        var data = await _databaseService.ExecuteQueryAsync(sql);

        _allKundenIds = new List<int>();
        var kundenItems = new System.Collections.ObjectModel.ObservableCollection<KundenListItem>();

        foreach (DataRow row in data.Rows)
        {
            var kunId = Convert.ToInt32(row["kun_Id"]);
            _allKundenIds.Add(kunId);

            // kun_Bezeichnung enthält den Kontaktnamen
            var kontaktname = row["kun_Bezeichnung"]?.ToString() ?? "";

            kundenItems.Add(new KundenListItem
            {
                KunId = kunId,
                Firma = row["kun_Firma"]?.ToString() ?? "",
                Ort = row["kun_Ort"]?.ToString() ?? "",
                Kontaktname = kontaktname
            });
        }

        KundenListe = kundenItems;
        _filteredKundenIds = new List<int>(_allKundenIds);
        TotalRecords = _filteredKundenIds.Count;
        UpdateNavigationState();
    }

    private async Task LoadKundeAsync(int kunId)
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            // Korrekte Feldnamen - KEINE kun_Kontakt_Nachname/Vorname!
            // Zahlungsziel heißt kun_Zahlbed
            var sql = @"
                SELECT kun_Id, kun_Firma, kun_IstAktiv, kun_Strasse, kun_PLZ, kun_Ort, kun_LKZ,
                       kun_telefon, kun_telefax, kun_email, kun_URL, kun_Bezeichnung,
                       kun_memo, kun_ustidnr, kun_Zahlbed
                FROM tbl_KD_Kundenstamm
                WHERE kun_Id = @KunId";

            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "KunId", kunId }
            });

            if (data.Rows.Count > 0)
            {
                var row = data.Rows[0];

                KunId = Convert.ToInt32(row["kun_Id"]);
                KunFirma = row["kun_Firma"]?.ToString();
                KunIstAktiv = row["kun_IstAktiv"] != DBNull.Value && Convert.ToBoolean(row["kun_IstAktiv"]);
                KunStrasse = row["kun_Strasse"]?.ToString();
                KunPlz = row["kun_PLZ"]?.ToString();
                KunOrt = row["kun_Ort"]?.ToString();
                KunLand = row["kun_LKZ"]?.ToString();
                KunTelefon = row["kun_telefon"]?.ToString();
                KunFax = row["kun_telefax"]?.ToString();
                KunEmail = row["kun_email"]?.ToString();
                KunWebsite = row["kun_URL"]?.ToString();
                KunAnsprechpartner = row["kun_Bezeichnung"]?.ToString(); // kun_Bezeichnung enthält Ansprechpartner
                KunKontaktNachname = null; // Felder existieren nicht
                KunKontaktVorname = null;  // Felder existieren nicht
                KunBemerkung = row["kun_memo"]?.ToString();
                KunUstId = row["kun_ustidnr"]?.ToString();
                KunSteuernummer = null; // Feld existiert nicht
                Zahlungsziel = row["kun_Zahlbed"] != DBNull.Value ? Convert.ToInt32(row["kun_Zahlbed"]) : null;

                IsNewRecord = false;
                IsEditMode = false;

                CurrentRecordIndex = _filteredKundenIds.IndexOf(kunId) + 1;
                UpdateNavigationState();

                // SelectedKunde in Liste aktualisieren
                SelectedKunde = KundenListe.FirstOrDefault(k => k.KunId == kunId);

                // Load Aufträge count
                var auftraegeCount = await _databaseService.ExecuteScalarAsync<int?>(
                    "SELECT COUNT(*) FROM tbl_VA_Auftragstamm WHERE Veranstalter_ID = @KunId",
                    new Dictionary<string, object> { { "KunId", kunId } });
                AnzahlAuftraege = auftraegeCount ?? 0;

                ShowSuccess($"Kunde {KunId} geladen");
            }
        }, $"Lade Kunde {kunId}...");
    }

    #endregion

    #region Navigation Commands

    [RelayCommand(CanExecute = nameof(CanNavigateFirst))]
    private async Task NavigateFirstAsync()
    {
        if (_filteredKundenIds.Any())
        {
            await LoadKundeAsync(_filteredKundenIds.First());
        }
    }

    [RelayCommand(CanExecute = nameof(CanNavigatePrevious))]
    private async Task NavigatePreviousAsync()
    {
        var currentIndex = _filteredKundenIds.IndexOf(KunId);
        if (currentIndex > 0)
        {
            await LoadKundeAsync(_filteredKundenIds[currentIndex - 1]);
        }
    }

    [RelayCommand(CanExecute = nameof(CanNavigateNext))]
    private async Task NavigateNextAsync()
    {
        var currentIndex = _filteredKundenIds.IndexOf(KunId);
        if (currentIndex < _filteredKundenIds.Count - 1)
        {
            await LoadKundeAsync(_filteredKundenIds[currentIndex + 1]);
        }
    }

    [RelayCommand(CanExecute = nameof(CanNavigateLast))]
    private async Task NavigateLastAsync()
    {
        if (_filteredKundenIds.Any())
        {
            await LoadKundeAsync(_filteredKundenIds.Last());
        }
    }

    private void UpdateNavigationState()
    {
        if (!_filteredKundenIds.Any())
        {
            CanNavigateFirst = CanNavigatePrevious = CanNavigateNext = CanNavigateLast = false;
            return;
        }

        var currentIndex = _filteredKundenIds.IndexOf(KunId);

        CanNavigateFirst = currentIndex > 0;
        CanNavigatePrevious = currentIndex > 0;
        CanNavigateNext = currentIndex < _filteredKundenIds.Count - 1;
        CanNavigateLast = currentIndex < _filteredKundenIds.Count - 1;

        NavigateFirstCommand.NotifyCanExecuteChanged();
        NavigatePreviousCommand.NotifyCanExecuteChanged();
        NavigateNextCommand.NotifyCanExecuteChanged();
        NavigateLastCommand.NotifyCanExecuteChanged();
    }

    #endregion

    #region CRUD Commands

    [RelayCommand]
    private void NewRecord()
    {
        KunId = 0;
        KunFirma = null;
        KunIstAktiv = true;
        KunStrasse = null;
        KunPlz = null;
        KunOrt = null;
        KunLand = "Deutschland";
        KunTelefon = null;
        KunFax = null;
        KunEmail = null;
        KunWebsite = null;
        KunAnsprechpartner = null;
        KunBemerkung = null;
        KunUstId = null;
        KunSteuernummer = null;
        Zahlungsziel = 30;
        AnzahlAuftraege = 0;

        IsNewRecord = true;
        IsEditMode = true;

        ShowSuccess("Neuer Kunde");
    }

    [RelayCommand]
    private void Edit()
    {
        IsEditMode = true;
        ShowSuccess("Bearbeitungsmodus aktiviert");
    }

    [RelayCommand]
    private async Task SaveAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            if (string.IsNullOrWhiteSpace(KunFirma))
            {
                ShowError("Firma muss ausgefüllt sein");
                return;
            }

            if (IsNewRecord)
            {
                // Insert - Korrekte Feldnamen
                var sql = @"
                    INSERT INTO tbl_KD_Kundenstamm
                    (kun_Firma, kun_IstAktiv, kun_Strasse, kun_PLZ, kun_Ort, kun_LKZ,
                     kun_telefon, kun_telefax, kun_email, kun_URL, kun_Bezeichnung,
                     kun_memo, kun_ustidnr, kun_Zahlbed)
                    VALUES (@KunFirma, @KunIstAktiv, @KunStrasse, @KunPlz, @KunOrt, @KunLand,
                            @KunTelefon, @KunFax, @KunEmail, @KunWebsite, @KunAnsprechpartner,
                            @KunBemerkung, @KunUstId, @Zahlungsziel)";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "KunFirma", KunFirma! },
                    { "KunIstAktiv", KunIstAktiv },
                    { "KunStrasse", (object?)KunStrasse ?? DBNull.Value },
                    { "KunPlz", (object?)KunPlz ?? DBNull.Value },
                    { "KunOrt", (object?)KunOrt ?? DBNull.Value },
                    { "KunLand", (object?)KunLand ?? DBNull.Value },
                    { "KunTelefon", (object?)KunTelefon ?? DBNull.Value },
                    { "KunFax", (object?)KunFax ?? DBNull.Value },
                    { "KunEmail", (object?)KunEmail ?? DBNull.Value },
                    { "KunWebsite", (object?)KunWebsite ?? DBNull.Value },
                    { "KunAnsprechpartner", (object?)KunAnsprechpartner ?? DBNull.Value },
                    { "KunBemerkung", (object?)KunBemerkung ?? DBNull.Value },
                    { "KunUstId", (object?)KunUstId ?? DBNull.Value },
                    { "Zahlungsziel", (object?)Zahlungsziel ?? DBNull.Value }
                });

                // Get new ID
                var newId = await _databaseService.ExecuteScalarAsync<int>(
                    "SELECT MAX(kun_Id) FROM tbl_KD_Kundenstamm");
                KunId = newId;

                await LoadKundenIdsAsync();
                IsNewRecord = false;

                ShowSuccess($"Kunde {KunId} gespeichert");
            }
            else
            {
                // Update - Korrekte Feldnamen
                var sql = @"
                    UPDATE tbl_KD_Kundenstamm
                    SET kun_Firma = @KunFirma,
                        kun_IstAktiv = @KunIstAktiv,
                        kun_Strasse = @KunStrasse,
                        kun_PLZ = @KunPlz,
                        kun_Ort = @KunOrt,
                        kun_LKZ = @KunLand,
                        kun_telefon = @KunTelefon,
                        kun_telefax = @KunFax,
                        kun_email = @KunEmail,
                        kun_URL = @KunWebsite,
                        kun_Bezeichnung = @KunAnsprechpartner,
                        kun_memo = @KunBemerkung,
                        kun_ustidnr = @KunUstId,
                        kun_Zahlbed = @Zahlungsziel
                    WHERE kun_Id = @KunId";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "KunId", KunId },
                    { "KunFirma", KunFirma! },
                    { "KunIstAktiv", KunIstAktiv },
                    { "KunStrasse", (object?)KunStrasse ?? DBNull.Value },
                    { "KunPlz", (object?)KunPlz ?? DBNull.Value },
                    { "KunOrt", (object?)KunOrt ?? DBNull.Value },
                    { "KunLand", (object?)KunLand ?? DBNull.Value },
                    { "KunTelefon", (object?)KunTelefon ?? DBNull.Value },
                    { "KunFax", (object?)KunFax ?? DBNull.Value },
                    { "KunEmail", (object?)KunEmail ?? DBNull.Value },
                    { "KunWebsite", (object?)KunWebsite ?? DBNull.Value },
                    { "KunAnsprechpartner", (object?)KunAnsprechpartner ?? DBNull.Value },
                    { "KunBemerkung", (object?)KunBemerkung ?? DBNull.Value },
                    { "KunUstId", (object?)KunUstId ?? DBNull.Value },
                    { "Zahlungsziel", (object?)Zahlungsziel ?? DBNull.Value }
                });

                ShowSuccess($"Kunde {KunId} aktualisiert");
            }

            IsEditMode = false;
        }, "Speichere Kunde...");
    }

    [RelayCommand]
    private async Task DeleteAsync()
    {
        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Kunde löschen",
            $"Möchten Sie {KunFirma} wirklich löschen?");

        if (!confirmed)
            return;

        await ExecuteWithLoadingAsync(async () =>
        {
            // Check for dependencies
            var hasAuftraege = await _databaseService.ExecuteScalarAsync<int>(
                "SELECT COUNT(*) FROM tbl_VA_Auftragstamm WHERE Veranstalter_ID = @KunId",
                new Dictionary<string, object> { { "KunId", KunId } });

            if (hasAuftraege > 0)
            {
                ShowError("Kunde kann nicht gelöscht werden, da Aufträge vorhanden sind.");
                return;
            }

            // Delete Kunde
            await _databaseService.ExecuteNonQueryAsync(
                "DELETE FROM tbl_KD_Kundenstamm WHERE kun_Id = @KunId",
                new Dictionary<string, object> { { "KunId", KunId } });

            await LoadKundenIdsAsync();

            if (_filteredKundenIds.Any())
            {
                await LoadKundeAsync(_filteredKundenIds.First());
            }
            else
            {
                NewRecordCommand.Execute(null);
            }

            ShowSuccess("Kunde gelöscht");
        }, "Lösche Kunde...");
    }

    [RelayCommand]
    private async Task CancelAsync()
    {
        if (IsNewRecord)
        {
            if (_filteredKundenIds.Any())
            {
                await LoadKundeAsync(_filteredKundenIds.First());
            }
            else
            {
                NewRecordCommand.Execute(null);
            }
        }
        else
        {
            await LoadKundeAsync(KunId);
        }

        IsEditMode = false;
        ShowSuccess("Abgebrochen");
    }

    #endregion

    #region Search Commands

    [RelayCommand]
    private async Task SearchAsync()
    {
        if (string.IsNullOrWhiteSpace(SearchText))
        {
            await LoadKundenIdsAsync();
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT kun_Id
                FROM tbl_KD_Kundenstamm
                WHERE (kun_Firma LIKE @SearchText OR kun_Ort LIKE @SearchText)
                  AND kun_IstAktiv = True
                ORDER BY kun_Firma";

            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "SearchText", $"%{SearchText}%" }
            });

            _filteredKundenIds = new List<int>();
            foreach (DataRow row in data.Rows)
            {
                _filteredKundenIds.Add(Convert.ToInt32(row["kun_Id"]));
            }

            TotalRecords = _filteredKundenIds.Count;
            UpdateNavigationState();

            if (_filteredKundenIds.Any())
            {
                await LoadKundeAsync(_filteredKundenIds.First());
            }

            ShowSuccess($"{TotalRecords} Kunden gefunden");
        }, "Suche Kunden...");
    }

    [RelayCommand]
    private async Task ClearSearchAsync()
    {
        SearchText = null;
        await LoadKundenIdsAsync();

        if (_filteredKundenIds.Any())
        {
            await LoadKundeAsync(_filteredKundenIds.First());
        }
    }

    #endregion

    #region Aufträge Navigation

    [RelayCommand]
    private void ShowAuftraege()
    {
        _navigationService.NavigateTo<AuftragstammViewModel>(KunId);
    }

    #endregion

    #region Sidebar Navigation Commands

    [RelayCommand]
    private void NavigateToDienstplan()
    {
        // TODO: Navigation zur Dienstplanübersicht
        ShowInfo("Navigation zur Dienstplanübersicht");
    }

    [RelayCommand]
    private void NavigateToPlanung()
    {
        // TODO: Navigation zur Planungsübersicht
        ShowInfo("Navigation zur Planungsübersicht");
    }

    [RelayCommand]
    private void NavigateToAuftrag()
    {
        _navigationService.NavigateTo<AuftragstammViewModel>();
    }

    [RelayCommand]
    private void NavigateToMitarbeiter()
    {
        // TODO: Navigation zur Mitarbeiterverwaltung
        ShowInfo("Navigation zur Mitarbeiterverwaltung");
    }

    [RelayCommand]
    private void NavigateToMailAnfragen()
    {
        // TODO: Navigation zu offenen Mail-Anfragen
        ShowInfo("Navigation zu offenen Mail-Anfragen");
    }

    [RelayCommand]
    private void NavigateToExcelZeitkonten()
    {
        // TODO: Navigation zu Excel Zeitkonten
        ShowInfo("Navigation zu Excel Zeitkonten");
    }

    [RelayCommand]
    private void NavigateToZeitkonten()
    {
        // TODO: Navigation zu Zeitkonten
        ShowInfo("Navigation zu Zeitkonten");
    }

    [RelayCommand]
    private void NavigateToAbwesenheit()
    {
        // TODO: Navigation zur Abwesenheitsplanung
        ShowInfo("Navigation zur Abwesenheitsplanung");
    }

    [RelayCommand]
    private void NavigateToDienstausweis()
    {
        // TODO: Navigation zu Dienstausweis erstellen
        ShowInfo("Navigation zu Dienstausweis erstellen");
    }

    #endregion
}

/// <summary>
/// DTO für Kundenlisten-Einträge mit Kontaktname
/// </summary>
public class KundenListItem
{
    public int KunId { get; set; }
    public string Firma { get; set; } = "";
    public string Ort { get; set; } = "";
    public string Kontaktname { get; set; } = "";

    public override string ToString() => $"{Firma} ({Ort})";
}
