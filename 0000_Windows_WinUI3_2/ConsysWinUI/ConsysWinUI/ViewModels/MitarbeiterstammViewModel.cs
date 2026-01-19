using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using ConsysWinUI.Services;

namespace ConsysWinUI.ViewModels;

/// <summary>
/// ViewModel für Mitarbeiterverwaltung (frm_MA_Mitarbeiterstamm).
/// CRUD für Mitarbeiter mit Navigation und Abwesenheiten.
/// </summary>
public partial class MitarbeiterstammViewModel : BaseViewModel, INavigationAware
{
    #region Properties - Mitarbeiter Stammdaten

    [ObservableProperty]
    private int _maId;

    [ObservableProperty]
    private int? _persNr;

    [ObservableProperty]
    private int? _lexWareId;

    [ObservableProperty]
    private string? _nachname;

    [ObservableProperty]
    private string? _vorname;

    [ObservableProperty]
    private bool _istAktiv = true;

    [ObservableProperty]
    private bool _istSubunternehmer;

    [ObservableProperty]
    private bool _lexAktiv;

    #endregion

    #region Properties - Adresse

    [ObservableProperty]
    private string? _strasse;

    [ObservableProperty]
    private string? _nr;

    [ObservableProperty]
    private string? _plz;

    [ObservableProperty]
    private string? _ort;

    [ObservableProperty]
    private string? _land;

    [ObservableProperty]
    private string? _bundesland;

    #endregion

    #region Properties - Kontakt

    [ObservableProperty]
    private string? _telMobil;

    [ObservableProperty]
    private string? _telFestnetz;

    [ObservableProperty]
    private string? _email;

    #endregion

    #region Properties - Persönliche Daten

    [ObservableProperty]
    private string? _geschlecht;

    [ObservableProperty]
    private string? _staatsangehoerigkeit;

    [ObservableProperty]
    private DateTimeOffset? _geburtsdatum;

    [ObservableProperty]
    private string? _gebOrt;

    [ObservableProperty]
    private string? _gebName;

    #endregion

    #region Properties - Anstellung

    [ObservableProperty]
    private DateTimeOffset? _eintrittsdatum;

    [ObservableProperty]
    private DateTimeOffset? _austrittsdatum;

    [ObservableProperty]
    private string? _anstellungsart;

    [ObservableProperty]
    private string? _kostenstelle;

    [ObservableProperty]
    private bool _eigenerPkw;

    #endregion

    #region Properties - Ausweise & Zertifikate

    [ObservableProperty]
    private string? _dienstausweisNr;

    [ObservableProperty]
    private DateTimeOffset? _ausweisEndedatum;

    [ObservableProperty]
    private string? _ausweisFunktion;

    [ObservableProperty]
    private string? _epinDfb;

    [ObservableProperty]
    private string? _bewacherId;

    #endregion

    #region Properties - Bankdaten & Lohn

    [ObservableProperty]
    private string? _kontoinhaber;

    [ObservableProperty]
    private string? _bic;

    [ObservableProperty]
    private string? _iban;

    [ObservableProperty]
    private string? _lohngruppe;

    [ObservableProperty]
    private string? _bezuegeGezahltAls;

    [ObservableProperty]
    private decimal? _stundenlohn;

    [ObservableProperty]
    private decimal? _bruttoStd;

    #endregion

    #region Properties - Steuer & Versicherung

    [ObservableProperty]
    private string? _steuerId;

    [ObservableProperty]
    private string? _taetigkeitBezeichnung;

    [ObservableProperty]
    private string? _krankenkasse;

    [ObservableProperty]
    private string? _steuerklasse;

    [ObservableProperty]
    private decimal? _urlaubsanspruchProJahr;

    [ObservableProperty]
    private decimal? _stundenzahlMonatMax;

    [ObservableProperty]
    private bool _rvBefreiungBeantragt;

    [ObservableProperty]
    private bool _abrechnungPerEmail;

    #endregion

    #region Properties - Arbeitszeit

    [ObservableProperty]
    private decimal? _arbeitsstdProArbeitstag;

    [ObservableProperty]
    private int? _arbeitstageProWoche;

    #endregion

    #region Properties - Sonstiges

    [ObservableProperty]
    private string? _lichtbild;

    [ObservableProperty]
    private string? _bemerkung;

    [ObservableProperty]
    private string? _qualifikation;

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

    #endregion

    #region Properties - Abwesenheiten

    [ObservableProperty]
    private ObservableCollection<AbwesenheitItem> _abwesenheiten = new();

    #endregion

    #region Properties - Mitarbeiter-Liste (rechte Sidebar)

    [ObservableProperty]
    private ObservableCollection<MitarbeiterListItem> _mitarbeiter = new();

    [ObservableProperty]
    private MitarbeiterListItem? _selectedMitarbeiter;

    partial void OnSelectedMitarbeiterChanged(MitarbeiterListItem? value)
    {
        if (value != null && value.MaId != MaId)
        {
            _ = LoadMitarbeiterAsync(value.MaId);
        }
    }

    #endregion

    private List<int> _allMitarbeiterIds = new();
    private List<int> _filteredMitarbeiterIds = new();

    public MitarbeiterstammViewModel(
        IDatabaseService databaseService,
        INavigationService navigationService,
        IDialogService dialogService)
        : base(databaseService, navigationService, dialogService)
    {
    }

    public override async Task InitializeAsync()
    {
        await LoadMitarbeiterIdsAsync();

        if (_filteredMitarbeiterIds.Any())
        {
            await LoadMitarbeiterAsync(_filteredMitarbeiterIds.First());
        }
        else
        {
            NewRecordCommand.Execute(null);
        }
    }

    public void OnNavigatedTo(object? parameter)
    {
        if (parameter is int maId)
        {
            _ = LoadMitarbeiterAsync(maId);
        }
    }

    public void OnNavigatedFrom()
    {
        // Cleanup wenn nötig
    }

    #region Data Loading

    private async Task LoadMitarbeiterIdsAsync(bool activeOnly = true)
    {
        // Korrekte Feldnamen: ID statt MA_ID, Nachname, Vorname, Ort, IstAktiv
        var sql = activeOnly
            ? "SELECT ID, Nachname, Vorname, Ort, IstAktiv FROM tbl_MA_Mitarbeiterstamm WHERE IstAktiv = True ORDER BY Nachname, Vorname"
            : "SELECT ID, Nachname, Vorname, Ort, IstAktiv FROM tbl_MA_Mitarbeiterstamm ORDER BY Nachname, Vorname";

        var data = await _databaseService.ExecuteQueryAsync(sql);

        _allMitarbeiterIds = new List<int>();
        Mitarbeiter.Clear();

        foreach (DataRow row in data.Rows)
        {
            var maId = Convert.ToInt32(row["ID"]);
            _allMitarbeiterIds.Add(maId);

            // Liste für die rechte Sidebar befüllen
            Mitarbeiter.Add(new MitarbeiterListItem
            {
                MaId = maId,
                Nachname = row["Nachname"]?.ToString(),
                Vorname = row["Vorname"]?.ToString(),
                Ort = row["Ort"]?.ToString(),
                IstAktiv = row["IstAktiv"] != DBNull.Value && Convert.ToBoolean(row["IstAktiv"])
            });
        }

        _filteredMitarbeiterIds = new List<int>(_allMitarbeiterIds);
        TotalRecords = _filteredMitarbeiterIds.Count;
        UpdateNavigationState();
    }

    private async Task LoadMitarbeiterAsync(int maId)
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            // Korrekte Feldnamen aus tbl_MA_Mitarbeiterstamm:
            // ID, Nachname, Vorname, IstAktiv, Tel_Mobil, Tel_Festnetz, Email,
            // Strasse, PLZ, Ort, Geb_Dat, Eintrittsdatum, Austrittsdatum,
            // Bemerkungen, Stundenlohn_brutto
            var sql = @"
                SELECT ID, Nachname, Vorname, IstAktiv, Tel_Mobil, Tel_Festnetz, Email,
                       Strasse, PLZ, Ort, Geb_Dat, Eintrittsdatum, Austrittsdatum,
                       Bemerkungen, Stundenlohn_brutto
                FROM tbl_MA_Mitarbeiterstamm
                WHERE ID = @MaId";

            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "MaId", maId }
            });

            if (data.Rows.Count > 0)
            {
                var row = data.Rows[0];

                MaId = Convert.ToInt32(row["ID"]);
                Nachname = row["Nachname"]?.ToString();
                Vorname = row["Vorname"]?.ToString();
                IstAktiv = row["IstAktiv"] != DBNull.Value && Convert.ToBoolean(row["IstAktiv"]);
                TelMobil = row["Tel_Mobil"]?.ToString();
                TelFestnetz = row["Tel_Festnetz"]?.ToString();
                Email = row["Email"]?.ToString();
                Strasse = row["Strasse"]?.ToString();
                Plz = row["PLZ"]?.ToString();
                Ort = row["Ort"]?.ToString();
                Geburtsdatum = row["Geb_Dat"] != DBNull.Value ? new DateTimeOffset(Convert.ToDateTime(row["Geb_Dat"])) : null;
                Eintrittsdatum = row["Eintrittsdatum"] != DBNull.Value ? new DateTimeOffset(Convert.ToDateTime(row["Eintrittsdatum"])) : null;
                Austrittsdatum = row["Austrittsdatum"] != DBNull.Value ? new DateTimeOffset(Convert.ToDateTime(row["Austrittsdatum"])) : null;
                Bemerkung = row["Bemerkungen"]?.ToString();
                Qualifikation = null; // Feld existiert nicht in DB
                Stundenlohn = row["Stundenlohn_brutto"] != DBNull.Value ? Convert.ToDecimal(row["Stundenlohn_brutto"]) : null;

                IsNewRecord = false;
                IsEditMode = false;

                CurrentRecordIndex = _filteredMitarbeiterIds.IndexOf(maId) + 1;
                UpdateNavigationState();

                await LoadAbwesenheitenAsync(maId);

                ShowSuccess($"Mitarbeiter {MaId} geladen");
            }
        }, $"Lade Mitarbeiter {maId}...");
    }

    private async Task LoadAbwesenheitenAsync(int maId)
    {
        // Korrekte Feldnamen: MA_ID, vonDat, bisDat, Zeittyp_ID (enthält Grund-Text), Bemerkung
        var sql = @"
            SELECT MA_ID, vonDat, bisDat, Zeittyp_ID, Bemerkung
            FROM tbl_MA_NVerfuegZeiten
            WHERE MA_ID = @MaId
            ORDER BY vonDat DESC";

        var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
        {
            { "MaId", maId }
        });

        Abwesenheiten.Clear();
        foreach (DataRow row in data.Rows)
        {
            Abwesenheiten.Add(new AbwesenheitItem
            {
                MaId = Convert.ToInt32(row["MA_ID"]),
                VonDat = Convert.ToDateTime(row["vonDat"]),
                BisDat = Convert.ToDateTime(row["bisDat"]),
                Grund = row["Zeittyp_ID"]?.ToString(), // Zeittyp_ID enthält den Grund-Text
                Bemerkung = row["Bemerkung"]?.ToString()
            });
        }
    }

    #endregion

    #region Navigation Commands

    [RelayCommand(CanExecute = nameof(CanNavigateFirst))]
    private async Task NavigateFirstAsync()
    {
        if (_filteredMitarbeiterIds.Any())
        {
            await LoadMitarbeiterAsync(_filteredMitarbeiterIds.First());
        }
    }

    [RelayCommand(CanExecute = nameof(CanNavigatePrevious))]
    private async Task NavigatePreviousAsync()
    {
        var currentIndex = _filteredMitarbeiterIds.IndexOf(MaId);
        if (currentIndex > 0)
        {
            await LoadMitarbeiterAsync(_filteredMitarbeiterIds[currentIndex - 1]);
        }
    }

    [RelayCommand(CanExecute = nameof(CanNavigateNext))]
    private async Task NavigateNextAsync()
    {
        var currentIndex = _filteredMitarbeiterIds.IndexOf(MaId);
        if (currentIndex < _filteredMitarbeiterIds.Count - 1)
        {
            await LoadMitarbeiterAsync(_filteredMitarbeiterIds[currentIndex + 1]);
        }
    }

    [RelayCommand(CanExecute = nameof(CanNavigateLast))]
    private async Task NavigateLastAsync()
    {
        if (_filteredMitarbeiterIds.Any())
        {
            await LoadMitarbeiterAsync(_filteredMitarbeiterIds.Last());
        }
    }

    private void UpdateNavigationState()
    {
        if (!_filteredMitarbeiterIds.Any())
        {
            CanNavigateFirst = CanNavigatePrevious = CanNavigateNext = CanNavigateLast = false;
            return;
        }

        var currentIndex = _filteredMitarbeiterIds.IndexOf(MaId);

        CanNavigateFirst = currentIndex > 0;
        CanNavigatePrevious = currentIndex > 0;
        CanNavigateNext = currentIndex < _filteredMitarbeiterIds.Count - 1;
        CanNavigateLast = currentIndex < _filteredMitarbeiterIds.Count - 1;

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
        // Stammdaten
        MaId = 0;
        PersNr = null;
        LexWareId = null;
        Nachname = null;
        Vorname = null;
        IstAktiv = true;
        IstSubunternehmer = false;
        LexAktiv = false;

        // Adresse
        Strasse = null;
        Nr = null;
        Plz = null;
        Ort = null;
        Land = null;
        Bundesland = null;

        // Kontakt
        TelMobil = null;
        TelFestnetz = null;
        Email = null;

        // Persönliche Daten
        Geschlecht = null;
        Staatsangehoerigkeit = null;
        Geburtsdatum = null;
        GebOrt = null;
        GebName = null;

        // Anstellung
        Eintrittsdatum = new DateTimeOffset(DateTime.Today);
        Austrittsdatum = null;
        Anstellungsart = null;
        Kostenstelle = null;
        EigenerPkw = false;

        // Ausweise & Zertifikate
        DienstausweisNr = null;
        AusweisEndedatum = null;
        AusweisFunktion = null;
        EpinDfb = null;
        BewacherId = null;

        // Bankdaten & Lohn
        Kontoinhaber = null;
        Bic = null;
        Iban = null;
        Lohngruppe = null;
        BezuegeGezahltAls = null;
        Stundenlohn = null;
        BruttoStd = null;

        // Steuer & Versicherung
        SteuerId = null;
        TaetigkeitBezeichnung = null;
        Krankenkasse = null;
        Steuerklasse = null;
        UrlaubsanspruchProJahr = null;
        StundenzahlMonatMax = null;
        RvBefreiungBeantragt = false;
        AbrechnungPerEmail = false;

        // Arbeitszeit
        ArbeitsstdProArbeitstag = null;
        ArbeitstageProWoche = null;

        // Sonstiges
        Lichtbild = null;
        Bemerkung = null;
        Qualifikation = null;

        Abwesenheiten.Clear();

        IsNewRecord = true;
        IsEditMode = true;

        ShowSuccess("Neuer Mitarbeiter");
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
            if (string.IsNullOrWhiteSpace(Nachname))
            {
                ShowError("Nachname muss ausgefüllt sein");
                return;
            }

            if (IsNewRecord)
            {
                // Insert - Korrekte Feldnamen
                var sql = @"
                    INSERT INTO tbl_MA_Mitarbeiterstamm
                    (Nachname, Vorname, IstAktiv, Tel_Mobil, Tel_Festnetz, Email,
                     Strasse, PLZ, Ort, Geb_Dat, Eintrittsdatum, Austrittsdatum,
                     Bemerkungen, Stundenlohn_brutto)
                    VALUES (@Nachname, @Vorname, @IstAktiv, @TelMobil, @TelFestnetz, @Email,
                            @Strasse, @Plz, @Ort, @GebDat, @Eintrittsdatum, @Austrittsdatum,
                            @Bemerkungen, @Stundenlohn)";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "Nachname", Nachname! },
                    { "Vorname", (object?)Vorname ?? DBNull.Value },
                    { "IstAktiv", IstAktiv },
                    { "TelMobil", (object?)TelMobil ?? DBNull.Value },
                    { "TelFestnetz", (object?)TelFestnetz ?? DBNull.Value },
                    { "Email", (object?)Email ?? DBNull.Value },
                    { "Strasse", (object?)Strasse ?? DBNull.Value },
                    { "Plz", (object?)Plz ?? DBNull.Value },
                    { "Ort", (object?)Ort ?? DBNull.Value },
                    { "GebDat", Geburtsdatum.HasValue ? (object)Geburtsdatum.Value.DateTime : DBNull.Value },
                    { "Eintrittsdatum", Eintrittsdatum.HasValue ? (object)Eintrittsdatum.Value.DateTime : DBNull.Value },
                    { "Austrittsdatum", Austrittsdatum.HasValue ? (object)Austrittsdatum.Value.DateTime : DBNull.Value },
                    { "Bemerkungen", (object?)Bemerkung ?? DBNull.Value },
                    { "Stundenlohn", (object?)Stundenlohn ?? DBNull.Value }
                });

                // Get new ID
                var newId = await _databaseService.ExecuteScalarAsync<int>(
                    "SELECT MAX(ID) FROM tbl_MA_Mitarbeiterstamm");
                MaId = newId;

                await LoadMitarbeiterIdsAsync();
                IsNewRecord = false;

                ShowSuccess($"Mitarbeiter {MaId} gespeichert");
            }
            else
            {
                // Update - Korrekte Feldnamen
                var sql = @"
                    UPDATE tbl_MA_Mitarbeiterstamm
                    SET Nachname = @Nachname,
                        Vorname = @Vorname,
                        IstAktiv = @IstAktiv,
                        Tel_Mobil = @TelMobil,
                        Tel_Festnetz = @TelFestnetz,
                        Email = @Email,
                        Strasse = @Strasse,
                        PLZ = @Plz,
                        Ort = @Ort,
                        Geb_Dat = @GebDat,
                        Eintrittsdatum = @Eintrittsdatum,
                        Austrittsdatum = @Austrittsdatum,
                        Bemerkungen = @Bemerkungen,
                        Stundenlohn_brutto = @Stundenlohn
                    WHERE ID = @MaId";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "MaId", MaId },
                    { "Nachname", Nachname! },
                    { "Vorname", (object?)Vorname ?? DBNull.Value },
                    { "IstAktiv", IstAktiv },
                    { "TelMobil", (object?)TelMobil ?? DBNull.Value },
                    { "TelFestnetz", (object?)TelFestnetz ?? DBNull.Value },
                    { "Email", (object?)Email ?? DBNull.Value },
                    { "Strasse", (object?)Strasse ?? DBNull.Value },
                    { "Plz", (object?)Plz ?? DBNull.Value },
                    { "Ort", (object?)Ort ?? DBNull.Value },
                    { "GebDat", Geburtsdatum.HasValue ? (object)Geburtsdatum.Value.DateTime : DBNull.Value },
                    { "Eintrittsdatum", Eintrittsdatum.HasValue ? (object)Eintrittsdatum.Value.DateTime : DBNull.Value },
                    { "Austrittsdatum", Austrittsdatum.HasValue ? (object)Austrittsdatum.Value.DateTime : DBNull.Value },
                    { "Bemerkungen", (object?)Bemerkung ?? DBNull.Value },
                    { "Stundenlohn", (object?)Stundenlohn ?? DBNull.Value }
                });

                ShowSuccess($"Mitarbeiter {MaId} aktualisiert");
            }

            IsEditMode = false;
        }, "Speichere Mitarbeiter...");
    }

    [RelayCommand]
    private async Task DeleteAsync()
    {
        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Mitarbeiter löschen",
            $"Möchten Sie {Vorname} {Nachname} wirklich löschen?");

        if (!confirmed)
            return;

        await ExecuteWithLoadingAsync(async () =>
        {
            // Check for dependencies
            var hasPlanungen = await _databaseService.ExecuteScalarAsync<int>(
                "SELECT COUNT(*) FROM tbl_MA_VA_Planung WHERE MA_ID = @MaId",
                new Dictionary<string, object> { { "MaId", MaId } });

            if (hasPlanungen > 0)
            {
                ShowError("Mitarbeiter kann nicht gelöscht werden, da Planungen vorhanden sind.");
                return;
            }

            // Delete Abwesenheiten
            await _databaseService.ExecuteNonQueryAsync(
                "DELETE FROM tbl_MA_NVerfuegZeiten WHERE MA_ID = @MaId",
                new Dictionary<string, object> { { "MaId", MaId } });

            // Delete Mitarbeiter
            await _databaseService.ExecuteNonQueryAsync(
                "DELETE FROM tbl_MA_Mitarbeiterstamm WHERE ID = @MaId",
                new Dictionary<string, object> { { "MaId", MaId } });

            await LoadMitarbeiterIdsAsync();

            if (_filteredMitarbeiterIds.Any())
            {
                await LoadMitarbeiterAsync(_filteredMitarbeiterIds.First());
            }
            else
            {
                NewRecordCommand.Execute(null);
            }

            ShowSuccess("Mitarbeiter gelöscht");
        }, "Lösche Mitarbeiter...");
    }

    [RelayCommand]
    private async Task CancelAsync()
    {
        if (IsNewRecord)
        {
            if (_filteredMitarbeiterIds.Any())
            {
                await LoadMitarbeiterAsync(_filteredMitarbeiterIds.First());
            }
            else
            {
                NewRecordCommand.Execute(null);
            }
        }
        else
        {
            await LoadMitarbeiterAsync(MaId);
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
            await LoadMitarbeiterIdsAsync();
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT ID
                FROM tbl_MA_Mitarbeiterstamm
                WHERE (Nachname LIKE @SearchText OR Vorname LIKE @SearchText)
                  AND IstAktiv = True
                ORDER BY Nachname, Vorname";

            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "SearchText", $"%{SearchText}%" }
            });

            _filteredMitarbeiterIds = new List<int>();
            foreach (DataRow row in data.Rows)
            {
                _filteredMitarbeiterIds.Add(Convert.ToInt32(row["ID"]));
            }

            TotalRecords = _filteredMitarbeiterIds.Count;
            UpdateNavigationState();

            if (_filteredMitarbeiterIds.Any())
            {
                await LoadMitarbeiterAsync(_filteredMitarbeiterIds.First());
            }

            ShowSuccess($"{TotalRecords} Mitarbeiter gefunden");
        }, "Suche Mitarbeiter...");
    }

    [RelayCommand]
    private async Task ClearSearchAsync()
    {
        SearchText = null;
        await LoadMitarbeiterIdsAsync();

        if (_filteredMitarbeiterIds.Any())
        {
            await LoadMitarbeiterAsync(_filteredMitarbeiterIds.First());
        }
    }

    #endregion

    #region Sidebar Navigation Commands

    [RelayCommand]
    private void NavigateToDienstplanuebersicht()
    {
        _navigationService.NavigateTo<DienstplanMAViewModel>(null);
    }

    [RelayCommand]
    private void NavigateToPlanungsuebersicht()
    {
        _navigationService.NavigateTo<DienstplanObjektViewModel>(null);
    }

    [RelayCommand]
    private void NavigateToAuftragsverwaltung()
    {
        _navigationService.NavigateTo<AuftragstammViewModel>(null);
    }

    [RelayCommand]
    private void NavigateToZeitkonten()
    {
        _navigationService.NavigateTo<ZeitkontenViewModel>(MaId);
    }

    [RelayCommand]
    private void NavigateToAbwesenheitsplanung()
    {
        _navigationService.NavigateTo<AbwesenheitViewModel>(MaId);
    }

    [RelayCommand]
    private void OpenDienstplan()
    {
        _navigationService.NavigateTo<DienstplanMAViewModel>(MaId);
    }

    [RelayCommand]
    private async Task OpenZeitkonto()
    {
        if (MaId <= 0)
        {
            ShowError("Kein Mitarbeiter ausgewählt");
            return;
        }
        _navigationService.NavigateTo<ZeitkontenViewModel>(MaId);
        await Task.CompletedTask;
    }

    [RelayCommand]
    private async Task OpenMaps()
    {
        await Task.Delay(100);
        ShowInfo($"Google Maps für {Strasse}, {Plz} {Ort} öffnen...\n\nDiese Funktion ist in Entwicklung.");
    }

    [RelayCommand]
    private async Task OffeneMailAnfragen()
    {
        await Task.Delay(100);
        ShowInfo("Offene Mail-Anfragen anzeigen...\n\nDiese Funktion ist in Entwicklung.");
    }

    [RelayCommand]
    private async Task ExcelZeitkonten()
    {
        await Task.Delay(100);
        ShowInfo("Excel-Zeitkonten exportieren...\n\nDiese Funktion ist in Entwicklung.");
    }

    [RelayCommand]
    private async Task DienstausweisErstellen()
    {
        if (MaId <= 0)
        {
            ShowError("Kein Mitarbeiter ausgewählt");
            return;
        }
        await Task.Delay(100);
        ShowInfo($"Dienstausweis für {Vorname} {Nachname} erstellen...\n\nDiese Funktion ist in Entwicklung.");
    }

    [RelayCommand]
    private async Task EinsaetzeUebertragen()
    {
        if (MaId <= 0)
        {
            ShowError("Kein Mitarbeiter ausgewählt");
            return;
        }
        await Task.Delay(100);
        ShowInfo($"Einsätze für {Vorname} {Nachname} übertragen...\n\nDiese Funktion ist in Entwicklung.");
    }

    [RelayCommand]
    private async Task ZeitkontoFest()
    {
        if (MaId <= 0)
        {
            ShowError("Kein Mitarbeiter ausgewählt");
            return;
        }
        await Task.Delay(100);
        ShowInfo($"Zeitkonto (fest) für {Vorname} {Nachname}...\n\nDiese Funktion ist in Entwicklung.");
    }

    [RelayCommand]
    private async Task ZeitkontoMini()
    {
        if (MaId <= 0)
        {
            ShowError("Kein Mitarbeiter ausgewählt");
            return;
        }
        await Task.Delay(100);
        ShowInfo($"Zeitkonto (Mini) für {Vorname} {Nachname}...\n\nDiese Funktion ist in Entwicklung.");
    }

    [RelayCommand]
    private async Task LichtbildAuswaelen()
    {
        await Task.Delay(100);
        ShowInfo("Lichtbild auswählen...\n\nDiese Funktion ist in Entwicklung.");
    }

    #endregion

    #region Header-Aktionsbuttons

    [RelayCommand]
    private async Task LoeschenAsync()
    {
        if (MaId <= 0)
        {
            ShowError("Kein Mitarbeiter ausgewählt");
            return;
        }

        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Mitarbeiter löschen",
            $"Möchten Sie {Vorname} {Nachname} (ID: {MaId}) wirklich löschen?\n\nDieser Vorgang kann nicht rückgängig gemacht werden.");

        if (!confirmed)
            return;

        await DeleteAsync();
    }

    [RelayCommand]
    private async Task TransferAsync()
    {
        if (MaId <= 0)
        {
            ShowError("Kein Mitarbeiter ausgewählt");
            return;
        }

        await Task.Delay(100);
        ShowInfo($"Transfer-Funktion für {Vorname} {Nachname} ist in Entwicklung.\n\nHier können Mitarbeiter zu einem anderen Standort transferiert werden.");
    }

    [RelayCommand]
    private async Task ListenDruckenAsync()
    {
        await Task.Delay(100);
        ShowInfo("Listen-Druck-Funktion ist in Entwicklung.\n\nHier können verschiedene Mitarbeiterlisten gedruckt werden:\n- Aktive Mitarbeiter\n- Alle Mitarbeiter\n- Mitarbeiter nach Standort");
    }

    [RelayCommand]
    private async Task TabelleOeffnenAsync()
    {
        await Task.Delay(100);
        ShowInfo("Tabellenansicht ist in Entwicklung.\n\nHier wird eine Übersicht aller Mitarbeiter in Tabellenform angezeigt.");
    }

    #endregion
}

#region Helper Classes

public class AbwesenheitItem
{
    public int MaId { get; set; }
    public DateTime VonDat { get; set; }
    public DateTime BisDat { get; set; }
    public string? Grund { get; set; }
    public string? Bemerkung { get; set; }

    public string DisplayText => $"{VonDat:dd.MM.yyyy} - {BisDat:dd.MM.yyyy}: {Grund}";
}

/// <summary>
/// Item für die Mitarbeiter-Liste (rechte Sidebar)
/// </summary>
public class MitarbeiterListItem
{
    public int MaId { get; set; }
    public string? Nachname { get; set; }
    public string? Vorname { get; set; }
    public string? Ort { get; set; }
    public bool IstAktiv { get; set; }
}

#endregion
