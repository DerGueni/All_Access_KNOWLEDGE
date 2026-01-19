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
/// ViewModel für Auftragsverwaltung (frm_va_Auftragstamm).
/// CRUD für Aufträge mit Navigation, Schichten und MA-Zuordnungen.
/// </summary>
public partial class AuftragstammViewModel : BaseViewModel, INavigationAware
{
    #region Properties - Auftrag Stammdaten

    [ObservableProperty]
    private int _vaId;

    [ObservableProperty]
    private string? _auftrag;

    [ObservableProperty]
    private int? _veranstalterId;

    [ObservableProperty]
    private string? _objekt;

    [ObservableProperty]
    private int? _objektId;

    [ObservableProperty]
    private DateTimeOffset? _vaDatumVon;

    [ObservableProperty]
    private DateTimeOffset? _vaDatumBis;

    [ObservableProperty]
    private int? _vaStatus;

    [ObservableProperty]
    private int? _einsatzleiterId;

    [ObservableProperty]
    private string? _bemerkung;

    [ObservableProperty]
    private decimal? _anzahlTage;

    [ObservableProperty]
    private decimal? _anzahlSchichten;

    [ObservableProperty]
    private int? _maAnzahlGesamt;

    [ObservableProperty]
    private int? _maAnzahlIst;

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

    #endregion

    #region Properties - Lookups

    [ObservableProperty]
    private ObservableCollection<VeranstalterItem> _veranstalterListe = new();

    [ObservableProperty]
    private ObservableCollection<ObjektItem> _objektListe = new();

    [ObservableProperty]
    private ObservableCollection<StatusItem> _statusListe = new();

    [ObservableProperty]
    private ObservableCollection<EinsatzleiterItem> _einsatzleiterListe = new();

    #endregion

    #region Properties - Subforms

    [ObservableProperty]
    private ObservableCollection<SchichtItem> _schichten = new();

    [ObservableProperty]
    private ObservableCollection<MaZuordnungItem> _maZuordnungen = new();

    [ObservableProperty]
    private ObservableCollection<MaZuordnungStatusItem> _maZuordnungenStatus = new();

    [ObservableProperty]
    private ObservableCollection<ZusatzdateiItem> _zusatzdateien = new();

    [ObservableProperty]
    private SchichtItem? _selectedSchicht;

    #endregion

    private List<int> _allAuftragIds = new();

    public AuftragstammViewModel(
        IDatabaseService databaseService,
        INavigationService navigationService,
        IDialogService dialogService)
        : base(databaseService, navigationService, dialogService)
    {
    }

    public override async Task InitializeAsync()
    {
        await LoadLookupsAsync();
        await LoadAuftragIdsAsync();

        if (_allAuftragIds.Any())
        {
            await LoadAuftragAsync(_allAuftragIds.First());
        }
        else
        {
            NewRecordCommand.Execute(null);
        }
    }

    public void OnNavigatedTo(object? parameter)
    {
        if (parameter is int vaId)
        {
            _ = LoadAuftragAsync(vaId);
        }
    }

    public void OnNavigatedFrom()
    {
        // Cleanup wenn nötig
    }

    #region Data Loading

    private async Task LoadLookupsAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            // Veranstalter (Kunden)
            var veranstalterData = await _databaseService.ExecuteQueryAsync(
                "SELECT kun_Id, kun_Firma FROM tbl_KD_Kundenstamm WHERE kun_IstAktiv = True ORDER BY kun_Firma");

            VeranstalterListe.Clear();
            foreach (DataRow row in veranstalterData.Rows)
            {
                VeranstalterListe.Add(new VeranstalterItem
                {
                    Id = Convert.ToInt32(row["kun_Id"]),
                    Firma = row["kun_Firma"]?.ToString() ?? ""
                });
            }

            // Objekte
            var objektData = await _databaseService.ExecuteQueryAsync(
                "SELECT Obj_Id, Obj_Name FROM tbl_OB_Objekt WHERE Obj_IstAktiv = True ORDER BY Obj_Name");

            ObjektListe.Clear();
            foreach (DataRow row in objektData.Rows)
            {
                ObjektListe.Add(new ObjektItem
                {
                    Id = Convert.ToInt32(row["Obj_Id"]),
                    Name = row["Obj_Name"]?.ToString() ?? ""
                });
            }

            // Status
            StatusListe.Clear();
            StatusListe.Add(new StatusItem { Id = 0, Bezeichnung = "Anfrage" });
            StatusListe.Add(new StatusItem { Id = 1, Bezeichnung = "Aktiv" });
            StatusListe.Add(new StatusItem { Id = 2, Bezeichnung = "Abgeschlossen" });
            StatusListe.Add(new StatusItem { Id = 3, Bezeichnung = "Storniert" });

            // Einsatzleiter (aktive Mitarbeiter)
            var einsatzleiterData = await _databaseService.ExecuteQueryAsync(
                "SELECT MA_ID, Nachname, Vorname FROM tbl_MA_Mitarbeiterstamm WHERE IstAktiv = True ORDER BY Nachname, Vorname");

            EinsatzleiterListe.Clear();
            foreach (DataRow row in einsatzleiterData.Rows)
            {
                EinsatzleiterListe.Add(new EinsatzleiterItem
                {
                    Id = Convert.ToInt32(row["MA_ID"]),
                    Nachname = row["Nachname"]?.ToString() ?? "",
                    Vorname = row["Vorname"]?.ToString() ?? "",
                    DisplayName = $"{row["Nachname"]}, {row["Vorname"]}"
                });
            }
        }, "Lade Lookup-Daten...");
    }

    private async Task LoadAuftragIdsAsync()
    {
        var data = await _databaseService.ExecuteQueryAsync(
            "SELECT VA_ID FROM tbl_VA_Auftragstamm ORDER BY VA_ID");

        _allAuftragIds = new List<int>();
        foreach (DataRow row in data.Rows)
        {
            _allAuftragIds.Add(Convert.ToInt32(row["VA_ID"]));
        }

        TotalRecords = _allAuftragIds.Count;
        UpdateNavigationState();
    }

    private async Task LoadAuftragAsync(int vaId)
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT VA_ID, Auftrag, Veranstalter_ID, Objekt, Objekt_ID,
                       VA_Datum_von, VA_Datum_bis, VA_Status, Einsatzleiter_ID, Bemerkung
                FROM tbl_VA_Auftragstamm
                WHERE VA_ID = @VaId";

            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "VaId", vaId }
            });

            if (data.Rows.Count > 0)
            {
                var row = data.Rows[0];

                VaId = Convert.ToInt32(row["VA_ID"]);
                Auftrag = row["Auftrag"]?.ToString();
                VeranstalterId = row["Veranstalter_ID"] != DBNull.Value ? Convert.ToInt32(row["Veranstalter_ID"]) : null;
                Objekt = row["Objekt"]?.ToString();
                ObjektId = row["Objekt_ID"] != DBNull.Value ? Convert.ToInt32(row["Objekt_ID"]) : null;
                VaDatumVon = row["VA_Datum_von"] != DBNull.Value ? new DateTimeOffset(Convert.ToDateTime(row["VA_Datum_von"])) : null;
                VaDatumBis = row["VA_Datum_bis"] != DBNull.Value ? new DateTimeOffset(Convert.ToDateTime(row["VA_Datum_bis"])) : null;
                VaStatus = row["VA_Status"] != DBNull.Value ? Convert.ToInt32(row["VA_Status"]) : null;
                EinsatzleiterId = row["Einsatzleiter_ID"] != DBNull.Value ? Convert.ToInt32(row["Einsatzleiter_ID"]) : null;
                Bemerkung = row["Bemerkung"]?.ToString();

                // Berechnete Felder - werden separat ermittelt
                await LoadCalculatedFieldsAsync(vaId);

                IsNewRecord = false;
                IsEditMode = false;

                CurrentRecordIndex = _allAuftragIds.IndexOf(vaId) + 1;
                UpdateNavigationState();

                await LoadSchichtenAsync(vaId);
                await LoadMaZuordnungenAsync(vaId);

                ShowSuccess($"Auftrag {VaId} geladen");
            }
        }, $"Lade Auftrag {vaId}...");
    }

    private async Task LoadCalculatedFieldsAsync(int vaId)
    {
        // AnzahlTage: Anzahl Tage aus tbl_VA_AnzTage
        var tageData = await _databaseService.ExecuteQueryAsync(
            "SELECT COUNT(*) AS Anzahl FROM tbl_VA_AnzTage WHERE VA_ID = @VaId",
            new Dictionary<string, object> { { "VaId", vaId } });
        AnzahlTage = tageData.Rows.Count > 0 ? Convert.ToDecimal(tageData.Rows[0]["Anzahl"]) : null;

        // AnzahlSchichten: Anzahl Schichten aus tbl_VA_Start
        var schichtenData = await _databaseService.ExecuteQueryAsync(
            "SELECT COUNT(*) AS Anzahl FROM tbl_VA_Start WHERE VA_ID = @VaId",
            new Dictionary<string, object> { { "VaId", vaId } });
        AnzahlSchichten = schichtenData.Rows.Count > 0 ? Convert.ToDecimal(schichtenData.Rows[0]["Anzahl"]) : null;

        // MA_Anzahl_Gesamt: Summe MA_Anzahl aus tbl_VA_Start
        var gesamt = await _databaseService.ExecuteQueryAsync(
            "SELECT SUM(MA_Anzahl) AS Gesamt FROM tbl_VA_Start WHERE VA_ID = @VaId",
            new Dictionary<string, object> { { "VaId", vaId } });
        MaAnzahlGesamt = gesamt.Rows.Count > 0 && gesamt.Rows[0]["Gesamt"] != DBNull.Value
            ? Convert.ToInt32(gesamt.Rows[0]["Gesamt"]) : null;

        // MA_Anzahl_Ist: Summe MA_Anzahl_Ist aus tbl_VA_Start
        var ist = await _databaseService.ExecuteQueryAsync(
            "SELECT SUM(MA_Anzahl_Ist) AS Ist FROM tbl_VA_Start WHERE VA_ID = @VaId",
            new Dictionary<string, object> { { "VaId", vaId } });
        MaAnzahlIst = ist.Rows.Count > 0 && ist.Rows[0]["Ist"] != DBNull.Value
            ? Convert.ToInt32(ist.Rows[0]["Ist"]) : null;
    }

    private async Task LoadSchichtenAsync(int vaId)
    {
        var sql = @"
            SELECT VA_ID, VADatum, VA_Start, VA_Ende, MA_Anzahl, MA_Anzahl_Ist, Bemerkung
            FROM tbl_VA_Start
            WHERE VA_ID = @VaId
            ORDER BY VADatum, VA_Start";

        var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
        {
            { "VaId", vaId }
        });

        Schichten.Clear();
        foreach (DataRow row in data.Rows)
        {
            Schichten.Add(new SchichtItem
            {
                VaId = Convert.ToInt32(row["VA_ID"]),
                VaDatum = Convert.ToDateTime(row["VADatum"]),
                VaStart = row["VA_Start"] != DBNull.Value ? TimeSpan.Parse(row["VA_Start"].ToString()!) : null,
                VaEnde = row["VA_Ende"] != DBNull.Value ? TimeSpan.Parse(row["VA_Ende"].ToString()!) : null,
                MaAnzahl = row["MA_Anzahl"] != DBNull.Value ? Convert.ToInt32(row["MA_Anzahl"]) : null,
                MaAnzahlIst = row["MA_Anzahl_Ist"] != DBNull.Value ? Convert.ToInt32(row["MA_Anzahl_Ist"]) : null,
                Bemerkung = row["Bemerkung"]?.ToString()
            });
        }
    }

    private async Task LoadMaZuordnungenAsync(int vaId)
    {
        var sql = @"
            SELECT z.VA_ID, z.VAStart_ID, z.MA_ID, z.VADatum, z.VA_Start, z.VA_Ende,
                   m.Nachname, m.Vorname
            FROM tbl_MA_VA_Planung z
            INNER JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.MA_ID
            WHERE z.VA_ID = @VaId
            ORDER BY z.VADatum, z.VA_Start, m.Nachname";

        var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
        {
            { "VaId", vaId }
        });

        MaZuordnungen.Clear();
        foreach (DataRow row in data.Rows)
        {
            MaZuordnungen.Add(new MaZuordnungItem
            {
                VaId = Convert.ToInt32(row["VA_ID"]),
                VaStartId = row["VAStart_ID"] != DBNull.Value ? Convert.ToInt32(row["VAStart_ID"]) : null,
                MaId = Convert.ToInt32(row["MA_ID"]),
                VaDatum = Convert.ToDateTime(row["VADatum"]),
                VaStart = row["VA_Start"] != DBNull.Value ? TimeSpan.Parse(row["VA_Start"].ToString()!) : null,
                VaEnde = row["VA_Ende"] != DBNull.Value ? TimeSpan.Parse(row["VA_Ende"].ToString()!) : null,
                MitarbeiterName = $"{row["Nachname"]}, {row["Vorname"]}"
            });
        }
    }

    #endregion

    #region Navigation Commands

    [RelayCommand(CanExecute = nameof(CanNavigateFirst))]
    private async Task NavigateFirstAsync()
    {
        if (_allAuftragIds.Any())
        {
            await LoadAuftragAsync(_allAuftragIds.First());
        }
    }

    [RelayCommand(CanExecute = nameof(CanNavigatePrevious))]
    private async Task NavigatePreviousAsync()
    {
        var currentIndex = _allAuftragIds.IndexOf(VaId);
        if (currentIndex > 0)
        {
            await LoadAuftragAsync(_allAuftragIds[currentIndex - 1]);
        }
    }

    [RelayCommand(CanExecute = nameof(CanNavigateNext))]
    private async Task NavigateNextAsync()
    {
        var currentIndex = _allAuftragIds.IndexOf(VaId);
        if (currentIndex < _allAuftragIds.Count - 1)
        {
            await LoadAuftragAsync(_allAuftragIds[currentIndex + 1]);
        }
    }

    [RelayCommand(CanExecute = nameof(CanNavigateLast))]
    private async Task NavigateLastAsync()
    {
        if (_allAuftragIds.Any())
        {
            await LoadAuftragAsync(_allAuftragIds.Last());
        }
    }

    private void UpdateNavigationState()
    {
        if (!_allAuftragIds.Any())
        {
            CanNavigateFirst = CanNavigatePrevious = CanNavigateNext = CanNavigateLast = false;
            return;
        }

        var currentIndex = _allAuftragIds.IndexOf(VaId);

        CanNavigateFirst = currentIndex > 0;
        CanNavigatePrevious = currentIndex > 0;
        CanNavigateNext = currentIndex < _allAuftragIds.Count - 1;
        CanNavigateLast = currentIndex < _allAuftragIds.Count - 1;

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
        VaId = 0;
        Auftrag = null;
        VeranstalterId = null;
        Objekt = null;
        ObjektId = null;
        VaDatumVon = new DateTimeOffset(DateTime.Today);
        VaDatumBis = null;
        VaStatus = 0; // Anfrage
        EinsatzleiterId = null;
        Bemerkung = null;
        AnzahlTage = null;
        AnzahlSchichten = null;
        MaAnzahlGesamt = null;
        MaAnzahlIst = null;

        Schichten.Clear();
        MaZuordnungen.Clear();

        IsNewRecord = true;
        IsEditMode = true;

        ShowSuccess("Neuer Auftrag");
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
            if (string.IsNullOrWhiteSpace(Auftrag))
            {
                ShowError("Auftrag muss ausgefüllt sein");
                return;
            }

            if (IsNewRecord)
            {
                // Insert
                var sql = @"
                    INSERT INTO tbl_VA_Auftragstamm
                    (Auftrag, Veranstalter_ID, Objekt, Objekt_ID, VA_Datum_von, VA_Datum_bis,
                     VA_Status, Einsatzleiter_ID, Bemerkung)
                    VALUES (@Auftrag, @VeranstalterId, @Objekt, @ObjektId, @VaDatumVon, @VaDatumBis,
                            @VaStatus, @EinsatzleiterId, @Bemerkung)";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "Auftrag", Auftrag! },
                    { "VeranstalterId", (object?)VeranstalterId ?? DBNull.Value },
                    { "Objekt", (object?)Objekt ?? DBNull.Value },
                    { "ObjektId", (object?)ObjektId ?? DBNull.Value },
                    { "VaDatumVon", VaDatumVon.HasValue ? (object)VaDatumVon.Value.DateTime : DBNull.Value },
                    { "VaDatumBis", VaDatumBis.HasValue ? (object)VaDatumBis.Value.DateTime : DBNull.Value },
                    { "VaStatus", (object?)VaStatus ?? DBNull.Value },
                    { "EinsatzleiterId", (object?)EinsatzleiterId ?? DBNull.Value },
                    { "Bemerkung", (object?)Bemerkung ?? DBNull.Value }
                });

                // Get new ID
                var newId = await _databaseService.ExecuteScalarAsync<int>(
                    "SELECT MAX(VA_ID) FROM tbl_VA_Auftragstamm");
                VaId = newId;

                await LoadAuftragIdsAsync();
                IsNewRecord = false;

                ShowSuccess($"Auftrag {VaId} gespeichert");
            }
            else
            {
                // Update
                var sql = @"
                    UPDATE tbl_VA_Auftragstamm
                    SET Auftrag = @Auftrag,
                        Veranstalter_ID = @VeranstalterId,
                        Objekt = @Objekt,
                        Objekt_ID = @ObjektId,
                        VA_Datum_von = @VaDatumVon,
                        VA_Datum_bis = @VaDatumBis,
                        VA_Status = @VaStatus,
                        Einsatzleiter_ID = @EinsatzleiterId,
                        Bemerkung = @Bemerkung
                    WHERE VA_ID = @VaId";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "VaId", VaId },
                    { "Auftrag", Auftrag! },
                    { "VeranstalterId", (object?)VeranstalterId ?? DBNull.Value },
                    { "Objekt", (object?)Objekt ?? DBNull.Value },
                    { "ObjektId", (object?)ObjektId ?? DBNull.Value },
                    { "VaDatumVon", VaDatumVon.HasValue ? (object)VaDatumVon.Value.DateTime : DBNull.Value },
                    { "VaDatumBis", VaDatumBis.HasValue ? (object)VaDatumBis.Value.DateTime : DBNull.Value },
                    { "VaStatus", (object?)VaStatus ?? DBNull.Value },
                    { "EinsatzleiterId", (object?)EinsatzleiterId ?? DBNull.Value },
                    { "Bemerkung", (object?)Bemerkung ?? DBNull.Value }
                });

                ShowSuccess($"Auftrag {VaId} aktualisiert");
            }

            IsEditMode = false;
        }, "Speichere Auftrag...");
    }

    [RelayCommand]
    private async Task DeleteAsync()
    {
        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Auftrag löschen",
            $"Möchten Sie den Auftrag {VaId} wirklich löschen?");

        if (!confirmed)
            return;

        await ExecuteWithLoadingAsync(async () =>
        {
            // Delete MA-Zuordnungen
            await _databaseService.ExecuteNonQueryAsync(
                "DELETE FROM tbl_MA_VA_Planung WHERE VA_ID = @VaId",
                new Dictionary<string, object> { { "VaId", VaId } });

            // Delete Schichten
            await _databaseService.ExecuteNonQueryAsync(
                "DELETE FROM tbl_VA_Start WHERE VA_ID = @VaId",
                new Dictionary<string, object> { { "VaId", VaId } });

            // Delete Auftrag
            await _databaseService.ExecuteNonQueryAsync(
                "DELETE FROM tbl_VA_Auftragstamm WHERE VA_ID = @VaId",
                new Dictionary<string, object> { { "VaId", VaId } });

            await LoadAuftragIdsAsync();

            if (_allAuftragIds.Any())
            {
                await LoadAuftragAsync(_allAuftragIds.First());
            }
            else
            {
                NewRecordCommand.Execute(null);
            }

            ShowSuccess("Auftrag gelöscht");
        }, "Lösche Auftrag...");
    }

    [RelayCommand]
    private async Task CancelAsync()
    {
        if (IsNewRecord)
        {
            if (_allAuftragIds.Any())
            {
                await LoadAuftragAsync(_allAuftragIds.First());
            }
            else
            {
                NewRecordCommand.Execute(null);
            }
        }
        else
        {
            await LoadAuftragAsync(VaId);
        }

        IsEditMode = false;
        ShowSuccess("Abgebrochen");
    }

    #endregion

    #region Header-Button Commands

    [RelayCommand]
    private void Mitarbeiterauswahl()
    {
        if (VaId > 0)
        {
            _navigationService.NavigateTo<SchnellauswahlViewModel>(VaId);
            ShowSuccess("Öffne Mitarbeiterauswahl");
        }
        else
        {
            ShowError("Bitte speichern Sie den Auftrag zuerst");
        }
    }

    [RelayCommand]
    private async Task AuftragKopierenAsync()
    {
        if (VaId == 0)
        {
            ShowError("Kein Auftrag zum Kopieren ausgewählt");
            return;
        }

        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Auftrag kopieren",
            $"Möchten Sie den Auftrag {VaId} kopieren?");

        if (!confirmed)
            return;

        await ExecuteWithLoadingAsync(async () =>
        {
            // Placeholder: Kopierlogik implementieren
            ShowSuccess("Auftrag kopieren - Funktion in Entwicklung");
        }, "Kopiere Auftrag...");
    }

    [RelayCommand]
    private async Task EinsatzlisteSendenAsync()
    {
        if (VaId == 0)
        {
            ShowError("Kein Auftrag ausgewählt");
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            // Placeholder: Email-Versand implementieren
            await Task.Delay(500); // Simulate
            ShowSuccess("Einsatzliste senden - Funktion in Entwicklung");
        }, "Sende Einsatzliste...");
    }

    [RelayCommand]
    private async Task EinsatzlisteDruckenAsync()
    {
        if (VaId == 0)
        {
            ShowError("Kein Auftrag ausgewählt");
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            // Placeholder: Druck-Dialog implementieren
            await Task.Delay(500); // Simulate
            ShowSuccess("Einsatzliste drucken - Funktion in Entwicklung");
        }, "Drucke Einsatzliste...");
    }

    [RelayCommand]
    private void PositionenOeffnen()
    {
        if (VaId > 0)
        {
            // Placeholder: Positions-Dialog öffnen
            ShowSuccess("Positionen öffnen - Funktion in Entwicklung");
        }
        else
        {
            ShowError("Kein Auftrag ausgewählt");
        }
    }

    [RelayCommand]
    private async Task AktualisierenAsync()
    {
        if (VaId > 0)
        {
            await LoadAuftragAsync(VaId);
            ShowSuccess("Aktualisiert");
        }
    }

    [RelayCommand]
    private async Task EinsatzlisteBOSAsync()
    {
        if (VaId == 0)
        {
            ShowError("Kein Auftrag ausgewählt");
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            // Placeholder: BOS-Versand implementieren
            await Task.Delay(500);
            ShowSuccess("Einsatzliste BOS senden - Funktion in Entwicklung");
        }, "Sende Einsatzliste BOS...");
    }

    [RelayCommand]
    private async Task EinsatzlisteSubAsync()
    {
        if (VaId == 0)
        {
            ShowError("Kein Auftrag ausgewählt");
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            // Placeholder: SUB-Versand implementieren
            await Task.Delay(500);
            ShowSuccess("Einsatzliste SUB senden - Funktion in Entwicklung");
        }, "Sende Einsatzliste SUB...");
    }

    [RelayCommand]
    private async Task NamenslisteESSAsync()
    {
        if (VaId == 0)
        {
            ShowError("Kein Auftrag ausgewählt");
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            // Placeholder: Namensliste ESS drucken
            await Task.Delay(500);
            ShowSuccess("Namensliste ESS - Funktion in Entwicklung");
        }, "Erstelle Namensliste ESS...");
    }

    [RelayCommand]
    private void RueckmeldeStatistik()
    {
        if (VaId > 0)
        {
            // Placeholder: Rückmelde-Statistik Dialog öffnen
            ShowSuccess("Rückmelde-Statistik - Funktion in Entwicklung");
        }
        else
        {
            ShowError("Kein Auftrag ausgewählt");
        }
    }

    [RelayCommand]
    private async Task SyncfehlerAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            // Placeholder: Syncfehler-Check implementieren
            await Task.Delay(500);
            ShowSuccess("Syncfehler gecheckt - Funktion in Entwicklung");
        }, "Checke Syncfehler...");
    }

    [RelayCommand]
    private void HTMLAnsicht()
    {
        if (VaId > 0)
        {
            // Placeholder: HTML-Ansicht öffnen (WebView2 oder Browser)
            ShowSuccess("HTML-Ansicht öffnen - Funktion in Entwicklung");
        }
        else
        {
            ShowError("Kein Auftrag ausgewählt");
        }
    }

    #endregion

    #region Tab: Zusatzdateien Commands

    [RelayCommand]
    private async Task NeuenAttachHinzufuegenAsync()
    {
        if (VaId == 0)
        {
            ShowError("Bitte speichern Sie den Auftrag zuerst");
            return;
        }

        // Placeholder: File-Picker implementieren
        ShowSuccess("Neuen Attach hinzufügen - Funktion in Entwicklung");
    }

    #endregion

    #region Tab: Rechnung Commands

    [RelayCommand]
    private async Task RechnungPDFAsync()
    {
        if (VaId == 0)
        {
            ShowError("Kein Auftrag ausgewählt");
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            // Placeholder: PDF-Generierung
            await Task.Delay(500);
            ShowSuccess("Rechnung PDF - Funktion in Entwicklung");
        }, "Erstelle Rechnung PDF...");
    }

    [RelayCommand]
    private async Task BerechnungslistePDFAsync()
    {
        if (VaId == 0)
        {
            ShowError("Kein Auftrag ausgewählt");
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            // Placeholder: PDF-Generierung
            await Task.Delay(500);
            ShowSuccess("Berechnungsliste PDF - Funktion in Entwicklung");
        }, "Erstelle Berechnungsliste PDF...");
    }

    [RelayCommand]
    private async Task DatenLadenAsync()
    {
        if (VaId > 0)
        {
            await LoadAuftragAsync(VaId);
            ShowSuccess("Daten neu geladen");
        }
    }

    #endregion

    #region Schichten Commands

    [RelayCommand]
    private void OpenSchnellauswahl()
    {
        if (SelectedSchicht != null)
        {
            _navigationService.NavigateTo<SchnellauswahlViewModel>(SelectedSchicht);
        }
    }

    #endregion

    #region Sidebar Navigation Commands

    [RelayCommand]
    private void NavigateToDienstplan()
    {
        _navigationService.NavigateTo<DienstplanMAViewModel>();
    }

    [RelayCommand]
    private void NavigateToPlanung()
    {
        _navigationService.NavigateTo<DienstplanObjektViewModel>();
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
    private void NavigateToObjekt()
    {
        _navigationService.NavigateTo<ObjektstammViewModel>();
    }

    [RelayCommand]
    private void NavigateToAbwesenheiten()
    {
        _navigationService.NavigateTo<AbwesenheitViewModel>();
    }

    [RelayCommand]
    private void NavigateToZeitkonten()
    {
        _navigationService.NavigateTo<ZeitkontenViewModel>();
    }

    [RelayCommand]
    private void NavigateToLohnabrechnungen()
    {
        _navigationService.NavigateTo<LohnabrechnungenViewModel>();
    }

    [RelayCommand]
    private void NavigateToBewerber()
    {
        _navigationService.NavigateTo<BewerberViewModel>();
    }

    [RelayCommand]
    private void NavigateToEinstellungen()
    {
        _navigationService.NavigateTo<EinstellungenViewModel>();
    }

    #endregion
}

#region Helper Classes

public class VeranstalterItem
{
    public int Id { get; set; }
    public string Firma { get; set; } = string.Empty;
}

public class ObjektItem
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
}

public class StatusItem
{
    public int Id { get; set; }
    public string Bezeichnung { get; set; } = string.Empty;
}

public class EinsatzleiterItem
{
    public int Id { get; set; }
    public string Nachname { get; set; } = string.Empty;
    public string Vorname { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
}

public class SchichtItem
{
    public int VaId { get; set; }
    public DateTime VaDatum { get; set; }
    public TimeSpan? VaStart { get; set; }
    public TimeSpan? VaEnde { get; set; }
    public int? MaAnzahl { get; set; }
    public int? MaAnzahlIst { get; set; }
    public string? Bemerkung { get; set; }

    public string DisplayText => $"{VaDatum:dd.MM.yyyy} {VaStart:hh\\:mm} - {VaEnde:hh\\:mm} ({MaAnzahlIst}/{MaAnzahl} MA)";
}

public class MaZuordnungItem
{
    public int VaId { get; set; }
    public int? VaStartId { get; set; }
    public int MaId { get; set; }
    public DateTime VaDatum { get; set; }
    public TimeSpan? VaStart { get; set; }
    public TimeSpan? VaEnde { get; set; }
    public string MitarbeiterName { get; set; } = string.Empty;

    public string DisplayText => $"{VaDatum:dd.MM.yyyy} {VaStart:hh\\:mm}-{VaEnde:hh\\:mm}: {MitarbeiterName}";
}

public class MaZuordnungStatusItem
{
    public int VaId { get; set; }
    public int MaId { get; set; }
    public string MitarbeiterName { get; set; } = string.Empty;
    public DateTime VaDatum { get; set; }
    public TimeSpan? VaStart { get; set; }
    public string Status { get; set; } = string.Empty;

    public string DisplayText => $"{VaDatum:dd.MM.yyyy} {VaStart:hh\\:mm}: {MitarbeiterName}";
}

public class ZusatzdateiItem
{
    public int Id { get; set; }
    public string Dateiname { get; set; } = string.Empty;
    public string Pfad { get; set; } = string.Empty;
    public DateTime Hochgeladen { get; set; }
}

#endregion
