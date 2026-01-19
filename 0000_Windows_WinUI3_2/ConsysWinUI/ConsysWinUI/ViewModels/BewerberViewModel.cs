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
/// ViewModel für Bewerber-Verarbeitung (frm_N_MA_Bewerber_Verarbeitung).
/// HINWEIS: Die Tabelle tbl_MA_Bewerber existiert noch nicht im Access-Backend.
/// Dieses ViewModel arbeitet mit Platzhalter-Daten und muss angepasst werden,
/// sobald die Tabelle angelegt wurde.
///
/// TODO: Tabelle tbl_MA_Bewerber im Access-Backend anlegen mit folgenden Feldern:
/// - Bewerber_ID (AutoWert, PK)
/// - Vorname (Text)
/// - Nachname (Text)
/// - Email (Text)
/// - Telefon (Text)
/// - Bewerbungsdatum (Datum/Zeit)
/// - Status_ID (Zahl - Referenz zu tbl_MA_Bewerber_Status)
/// - Qualifikation (Memo)
/// - Bemerkung (Memo)
/// - Dokumente_Pfad (Text)
///
/// TODO: Tabelle tbl_MA_Bewerber_Status anlegen mit:
/// - Status_ID (AutoWert, PK)
/// - Bezeichnung (Text: "Neu", "In Prüfung", "Eingeladen", "Eingestellt", "Abgelehnt")
/// - Reihenfolge (Zahl)
/// - Farbe (Text - HEX-Code)
/// </summary>
public partial class BewerberViewModel : BaseViewModel
{
    #region Properties - Bewerber Stammdaten

    [ObservableProperty]
    private int _bewerberId;

    [ObservableProperty]
    private string? _vorname;

    [ObservableProperty]
    private string? _nachname;

    public string VollName => string.IsNullOrWhiteSpace(Nachname) && string.IsNullOrWhiteSpace(Vorname)
        ? "(Neuer Bewerber)"
        : $"{Nachname}, {Vorname}";

    [ObservableProperty]
    private string? _email;

    [ObservableProperty]
    private string? _telefon;

    [ObservableProperty]
    private DateTimeOffset _bewerbungsdatum = DateTimeOffset.Now;

    [ObservableProperty]
    private int _statusId = 1; // 1 = Neu

    [ObservableProperty]
    private string _statusText = "Neu";

    [ObservableProperty]
    private string? _qualifikation;

    [ObservableProperty]
    private string? _bemerkung;

    [ObservableProperty]
    private string? _dokumentePfad;

    #endregion

    #region Properties - UI State

    [ObservableProperty]
    private bool _isEditMode;

    [ObservableProperty]
    private bool _isNewRecord;

    [ObservableProperty]
    private ObservableCollection<BewerberListItem> _bewerber = new();

    [ObservableProperty]
    private BewerberListItem? _selectedBewerber;

    [ObservableProperty]
    private ObservableCollection<BewerberStatus> _statusListe = new();

    [ObservableProperty]
    private BewerberStatus? _selectedStatus;

    [ObservableProperty]
    private string? _searchText;

    [ObservableProperty]
    private int _selectedStatusFilter; // 0 = Alle, 1-5 = spezifischer Status

    partial void OnSelectedBewerberChanged(BewerberListItem? value)
    {
        if (value != null && value.BewerberId != BewerberId)
        {
            _ = LoadBewerberAsync(value.BewerberId);
        }
    }

    partial void OnSelectedStatusChanged(BewerberStatus? value)
    {
        if (value != null)
        {
            StatusId = value.StatusId;
            StatusText = value.Bezeichnung;
        }
    }

    #endregion

    #region Computed Properties

    /// <summary>
    /// Bestimmt, ob der "Als MA anlegen" Button aktiviert ist
    /// </summary>
    public bool CanConvertToMitarbeiter =>
        BewerberId > 0 &&
        !string.IsNullOrWhiteSpace(Vorname) &&
        !string.IsNullOrWhiteSpace(Nachname);

    #endregion

    public BewerberViewModel(
        IDatabaseService databaseService,
        INavigationService navigationService,
        IDialogService dialogService)
        : base(databaseService, navigationService, dialogService)
    {
    }

    public override async Task InitializeAsync()
    {
        // Status-Liste initialisieren
        InitializeStatusListe();

        // HINWEIS: Da die Tabelle nicht existiert, laden wir Platzhalter-Daten
        LoadPlaceholderData();

        await Task.CompletedTask;
    }

    #region Data Loading

    /// <summary>
    /// Initialisiert die Status-Liste mit den vordefinierten Status-Werten
    /// </summary>
    private void InitializeStatusListe()
    {
        StatusListe.Clear();

        // Vordefinierte Status mit Farben
        StatusListe.Add(new BewerberStatus { StatusId = 0, Bezeichnung = "Alle", Farbe = "#808080" });
        StatusListe.Add(new BewerberStatus { StatusId = 1, Bezeichnung = "Neu", Farbe = "#3B82F6" });
        StatusListe.Add(new BewerberStatus { StatusId = 2, Bezeichnung = "In Prüfung", Farbe = "#F59E0B" });
        StatusListe.Add(new BewerberStatus { StatusId = 3, Bezeichnung = "Eingeladen", Farbe = "#06B6D4" });
        StatusListe.Add(new BewerberStatus { StatusId = 4, Bezeichnung = "Eingestellt", Farbe = "#22C55E" });
        StatusListe.Add(new BewerberStatus { StatusId = 5, Bezeichnung = "Abgelehnt", Farbe = "#EF4444" });

        SelectedStatus = StatusListe.FirstOrDefault(s => s.StatusId == StatusId);
    }

    /// <summary>
    /// PLATZHALTER: Lädt Demo-Daten, da die Tabelle noch nicht existiert
    /// TODO: Durch echte Datenbankabfrage ersetzen
    /// </summary>
    private void LoadPlaceholderData()
    {
        Bewerber.Clear();

        // Platzhalter-Bewerber
        Bewerber.Add(new BewerberListItem
        {
            BewerberId = 1,
            Vorname = "Max",
            Nachname = "Mustermann",
            Email = "max.mustermann@email.de",
            Telefon = "0176 12345678",
            Bewerbungsdatum = DateTime.Now.AddDays(-5),
            StatusId = 1,
            StatusText = "Neu"
        });

        Bewerber.Add(new BewerberListItem
        {
            BewerberId = 2,
            Vorname = "Anna",
            Nachname = "Schmidt",
            Email = "a.schmidt@email.de",
            Telefon = "0157 98765432",
            Bewerbungsdatum = DateTime.Now.AddDays(-12),
            StatusId = 2,
            StatusText = "In Prüfung"
        });

        Bewerber.Add(new BewerberListItem
        {
            BewerberId = 3,
            Vorname = "Peter",
            Nachname = "Meyer",
            Email = "p.meyer@email.de",
            Telefon = "0173 55566677",
            Bewerbungsdatum = DateTime.Now.AddDays(-20),
            StatusId = 3,
            StatusText = "Eingeladen"
        });

        Bewerber.Add(new BewerberListItem
        {
            BewerberId = 4,
            Vorname = "Julia",
            Nachname = "Weber",
            Email = "j.weber@email.de",
            Telefon = "0160 11223344",
            Bewerbungsdatum = DateTime.Now.AddDays(-30),
            StatusId = 5,
            StatusText = "Abgelehnt"
        });

        // Ersten Bewerber laden
        if (Bewerber.Any())
        {
            SelectedBewerber = Bewerber.First();
        }
        else
        {
            NewRecordCommand.Execute(null);
        }
    }

    /// <summary>
    /// Lädt einen Bewerber aus der Datenbank
    /// TODO: Echte Implementierung sobald Tabelle existiert
    /// </summary>
    private async Task LoadBewerberAsync(int bewerberId)
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            // PLATZHALTER: Lade von Platzhalter-Daten
            var bewerber = Bewerber.FirstOrDefault(b => b.BewerberId == bewerberId);
            if (bewerber != null)
            {
                BewerberId = bewerber.BewerberId;
                Vorname = bewerber.Vorname;
                Nachname = bewerber.Nachname;
                Email = bewerber.Email;
                Telefon = bewerber.Telefon;
                Bewerbungsdatum = new DateTimeOffset(bewerber.Bewerbungsdatum);
                StatusId = bewerber.StatusId;
                StatusText = bewerber.StatusText;
                Qualifikation = "Beispiel-Qualifikation:\n- Führerschein Klasse B\n- Erste-Hilfe-Kurs\n- Sicherheitsschein §34a";
                Bemerkung = "Platzhalter-Bemerkung";
                DokumentePfad = @"C:\Bewerber\Dokumente\";

                SelectedStatus = StatusListe.FirstOrDefault(s => s.StatusId == StatusId);

                IsNewRecord = false;
                IsEditMode = false;

                ShowSuccess($"Bewerber {BewerberId} geladen (Platzhalter)");
            }

            /* Echte Implementierung (Feldnamen angepasst an tbl_MA_Bewerber)
            var sql = @"
                SELECT ID, BW_Vorname, BW_Nachname, BW_EMail, BW_Tel,
                       BW_Datum, BW_Status, BW_Qualifikation, BW_Bemerkung, BW_DokPfad
                FROM tbl_MA_Bewerber
                WHERE ID = ?";

            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "ID", bewerberId }
            });

            if (data.Rows.Count > 0)
            {
                var row = data.Rows[0];
                BewerberId = Convert.ToInt32(row["ID"]);
                Vorname = row["BW_Vorname"]?.ToString();
                Nachname = row["BW_Nachname"]?.ToString();
                Email = row["BW_EMail"]?.ToString();
                Telefon = row["BW_Tel"]?.ToString();
                Bewerbungsdatum = row["BW_Datum"] != DBNull.Value
                    ? new DateTimeOffset(Convert.ToDateTime(row["BW_Datum"]))
                    : DateTimeOffset.Now;
                var statusStr = row["BW_Status"]?.ToString() ?? "neu";
                StatusId = statusStr switch {
                    "neu" => 1,
                    "in_pruefung" => 2,
                    "eingeladen" => 3,
                    "eingestellt" => 4,
                    "abgelehnt" => 5,
                    _ => 1
                };
                StatusText = StatusListe.FirstOrDefault(s => s.StatusId == StatusId)?.Bezeichnung ?? "Neu";
                Qualifikation = row["BW_Qualifikation"]?.ToString();
                Bemerkung = row["BW_Bemerkung"]?.ToString();
                DokumentePfad = row["BW_DokPfad"]?.ToString();

                SelectedStatus = StatusListe.FirstOrDefault(s => s.StatusId == StatusId);

                IsNewRecord = false;
                IsEditMode = false;

                ShowSuccess($"Bewerber {BewerberId} geladen");
            }
            */

            await Task.CompletedTask;
        }, $"Lade Bewerber {bewerberId}...");
    }

    /// <summary>
    /// Lädt die Bewerberliste mit optionalem Status-Filter
    /// TODO: Echte Implementierung sobald Tabelle existiert
    /// </summary>
    private async Task LoadBewerberListeAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            // PLATZHALTER: Bewerber sind bereits geladen
            ShowInfo($"{Bewerber.Count} Bewerber geladen (Platzhalter)");

            /* Echte Implementierung (Feldnamen angepasst)
            var sql = @"
                SELECT ID, BW_Vorname, BW_Nachname, BW_EMail, BW_Tel,
                       BW_Datum, BW_Status
                FROM tbl_MA_Bewerber";

            // Status-Filter hinzufügen
            if (SelectedStatusFilter > 0)
            {
                var statusStr = SelectedStatusFilter switch {
                    1 => "neu",
                    2 => "in_pruefung",
                    3 => "eingeladen",
                    4 => "eingestellt",
                    5 => "abgelehnt",
                    _ => "neu"
                };
                sql += $" WHERE BW_Status = '{statusStr}'";
            }

            sql += " ORDER BY BW_Datum DESC";

            var data = await _databaseService.ExecuteQueryAsync(sql, null);

            Bewerber.Clear();
            foreach (DataRow row in data.Rows)
            {
                var statusStr = row["BW_Status"]?.ToString() ?? "neu";
                var statusId = statusStr switch {
                    "neu" => 1,
                    "in_pruefung" => 2,
                    "eingeladen" => 3,
                    "eingestellt" => 4,
                    "abgelehnt" => 5,
                    _ => 1
                };

                Bewerber.Add(new BewerberListItem
                {
                    BewerberId = Convert.ToInt32(row["ID"]),
                    Vorname = row["BW_Vorname"]?.ToString(),
                    Nachname = row["BW_Nachname"]?.ToString(),
                    Email = row["BW_EMail"]?.ToString(),
                    Telefon = row["BW_Tel"]?.ToString(),
                    Bewerbungsdatum = Convert.ToDateTime(row["BW_Datum"]),
                    StatusId = statusId,
                    StatusText = StatusListe.FirstOrDefault(s => s.StatusId == statusId)?.Bezeichnung ?? ""
                });
            }

            ShowSuccess($"{Bewerber.Count} Bewerber geladen");
            */

            await Task.CompletedTask;
        }, "Lade Bewerberliste...");
    }

    #endregion

    #region CRUD Commands

    [RelayCommand]
    private void NewRecord()
    {
        BewerberId = 0;
        Vorname = null;
        Nachname = null;
        Email = null;
        Telefon = null;
        Bewerbungsdatum = DateTimeOffset.Now;
        StatusId = 1; // Neu
        StatusText = "Neu";
        Qualifikation = null;
        Bemerkung = null;
        DokumentePfad = null;

        SelectedStatus = StatusListe.FirstOrDefault(s => s.StatusId == 1);

        IsNewRecord = true;
        IsEditMode = true;

        ShowSuccess("Neuer Bewerber");
        OnPropertyChanged(nameof(VollName));
        OnPropertyChanged(nameof(CanConvertToMitarbeiter));
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
                // PLATZHALTER: Simuliere Insert
                var newId = Bewerber.Any() ? Bewerber.Max(b => b.BewerberId) + 1 : 1;
                BewerberId = newId;

                var newBewerber = new BewerberListItem
                {
                    BewerberId = BewerberId,
                    Vorname = Vorname,
                    Nachname = Nachname,
                    Email = Email,
                    Telefon = Telefon,
                    Bewerbungsdatum = Bewerbungsdatum.DateTime,
                    StatusId = StatusId,
                    StatusText = StatusText
                };

                Bewerber.Add(newBewerber);
                SelectedBewerber = newBewerber;

                IsNewRecord = false;
                ShowSuccess($"Bewerber {BewerberId} gespeichert (Platzhalter)");

                /* Echte Implementierung (Feldnamen angepasst)
                var statusStr = StatusId switch {
                    1 => "neu",
                    2 => "in_pruefung",
                    3 => "eingeladen",
                    4 => "eingestellt",
                    5 => "abgelehnt",
                    _ => "neu"
                };

                var sql = @"
                    INSERT INTO tbl_MA_Bewerber
                    (BW_Vorname, BW_Nachname, BW_EMail, BW_Tel, BW_Datum, BW_Status, BW_Qualifikation, BW_Bemerkung, BW_DokPfad)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "BW_Vorname", (object?)Vorname ?? DBNull.Value },
                    { "BW_Nachname", Nachname! },
                    { "BW_EMail", (object?)Email ?? DBNull.Value },
                    { "BW_Tel", (object?)Telefon ?? DBNull.Value },
                    { "BW_Datum", Bewerbungsdatum.DateTime },
                    { "BW_Status", statusStr },
                    { "BW_Qualifikation", (object?)Qualifikation ?? DBNull.Value },
                    { "BW_Bemerkung", (object?)Bemerkung ?? DBNull.Value },
                    { "BW_DokPfad", (object?)DokumentePfad ?? DBNull.Value }
                });

                var newId = await _databaseService.ExecuteScalarAsync<int>(
                    "SELECT MAX(ID) FROM tbl_MA_Bewerber");
                BewerberId = newId;

                await LoadBewerberListeAsync();
                IsNewRecord = false;

                ShowSuccess($"Bewerber {BewerberId} gespeichert");
                */
            }
            else
            {
                // PLATZHALTER: Simuliere Update
                var existing = Bewerber.FirstOrDefault(b => b.BewerberId == BewerberId);
                if (existing != null)
                {
                    existing.Vorname = Vorname;
                    existing.Nachname = Nachname;
                    existing.Email = Email;
                    existing.Telefon = Telefon;
                    existing.Bewerbungsdatum = Bewerbungsdatum.DateTime;
                    existing.StatusId = StatusId;
                    existing.StatusText = StatusText;
                }

                ShowSuccess($"Bewerber {BewerberId} aktualisiert (Platzhalter)");

                /* Echte Implementierung (Feldnamen angepasst)
                var statusStr = StatusId switch {
                    1 => "neu",
                    2 => "in_pruefung",
                    3 => "eingeladen",
                    4 => "eingestellt",
                    5 => "abgelehnt",
                    _ => "neu"
                };

                var sql = @"
                    UPDATE tbl_MA_Bewerber
                    SET BW_Vorname = ?,
                        BW_Nachname = ?,
                        BW_EMail = ?,
                        BW_Tel = ?,
                        BW_Datum = ?,
                        BW_Status = ?,
                        BW_Qualifikation = ?,
                        BW_Bemerkung = ?,
                        BW_DokPfad = ?
                    WHERE ID = ?";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "BW_Vorname", (object?)Vorname ?? DBNull.Value },
                    { "BW_Nachname", Nachname! },
                    { "BW_EMail", (object?)Email ?? DBNull.Value },
                    { "BW_Tel", (object?)Telefon ?? DBNull.Value },
                    { "BW_Datum", Bewerbungsdatum.DateTime },
                    { "BW_Status", statusStr },
                    { "BW_Qualifikation", (object?)Qualifikation ?? DBNull.Value },
                    { "BW_Bemerkung", (object?)Bemerkung ?? DBNull.Value },
                    { "BW_DokPfad", (object?)DokumentePfad ?? DBNull.Value },
                    { "ID", BewerberId }
                });

                ShowSuccess($"Bewerber {BewerberId} aktualisiert");
                */
            }

            IsEditMode = false;
            OnPropertyChanged(nameof(VollName));
            OnPropertyChanged(nameof(CanConvertToMitarbeiter));

            await Task.CompletedTask;
        }, "Speichere Bewerber...");
    }

    [RelayCommand]
    private async Task DeleteAsync()
    {
        if (BewerberId <= 0)
        {
            ShowError("Kein Bewerber ausgewählt");
            return;
        }

        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Bewerber löschen",
            $"Möchten Sie {Vorname} {Nachname} wirklich löschen?\n\nDieser Vorgang kann nicht rückgängig gemacht werden.");

        if (!confirmed)
            return;

        await ExecuteWithLoadingAsync(async () =>
        {
            // PLATZHALTER: Aus Liste entfernen
            var toRemove = Bewerber.FirstOrDefault(b => b.BewerberId == BewerberId);
            if (toRemove != null)
            {
                Bewerber.Remove(toRemove);
            }

            if (Bewerber.Any())
            {
                SelectedBewerber = Bewerber.First();
            }
            else
            {
                NewRecordCommand.Execute(null);
            }

            ShowSuccess("Bewerber gelöscht (Platzhalter)");

            /* Echte Implementierung (Feldnamen angepasst)
            await _databaseService.ExecuteNonQueryAsync(
                "DELETE FROM tbl_MA_Bewerber WHERE ID = ?",
                new Dictionary<string, object> { { "ID", BewerberId } });

            await LoadBewerberListeAsync();

            if (Bewerber.Any())
            {
                await LoadBewerberAsync(Bewerber.First().BewerberId);
            }
            else
            {
                NewRecordCommand.Execute(null);
            }

            ShowSuccess("Bewerber gelöscht");
            */

            await Task.CompletedTask;
        }, "Lösche Bewerber...");
    }

    [RelayCommand]
    private async Task CancelAsync()
    {
        if (IsNewRecord)
        {
            if (Bewerber.Any())
            {
                await LoadBewerberAsync(Bewerber.First().BewerberId);
            }
            else
            {
                NewRecordCommand.Execute(null);
            }
        }
        else
        {
            await LoadBewerberAsync(BewerberId);
        }

        IsEditMode = false;
        ShowSuccess("Abgebrochen");
    }

    #endregion

    #region Search & Filter Commands

    [RelayCommand]
    private async Task SearchAsync()
    {
        if (string.IsNullOrWhiteSpace(SearchText))
        {
            LoadPlaceholderData();
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            // PLATZHALTER: Filter auf Platzhalter-Daten
            var filtered = Bewerber
                .Where(b =>
                    (b.Nachname?.Contains(SearchText, StringComparison.OrdinalIgnoreCase) ?? false) ||
                    (b.Vorname?.Contains(SearchText, StringComparison.OrdinalIgnoreCase) ?? false) ||
                    (b.Email?.Contains(SearchText, StringComparison.OrdinalIgnoreCase) ?? false))
                .ToList();

            ShowSuccess($"{filtered.Count} Bewerber gefunden (Platzhalter)");

            /* Echte Implementierung (Feldnamen angepasst)
            var sql = @"
                SELECT ID, BW_Vorname, BW_Nachname, BW_EMail, BW_Tel,
                       BW_Datum, BW_Status
                FROM tbl_MA_Bewerber
                WHERE (BW_Nachname LIKE ? OR BW_Vorname LIKE ? OR BW_EMail LIKE ?)
                ORDER BY BW_Datum DESC";

            var searchPattern = $"%{SearchText}%";
            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "Search1", searchPattern },
                { "Search2", searchPattern },
                { "Search3", searchPattern }
            });

            Bewerber.Clear();
            foreach (DataRow row in data.Rows)
            {
                var statusStr = row["BW_Status"]?.ToString() ?? "neu";
                var statusId = statusStr switch {
                    "neu" => 1,
                    "in_pruefung" => 2,
                    "eingeladen" => 3,
                    "eingestellt" => 4,
                    "abgelehnt" => 5,
                    _ => 1
                };

                Bewerber.Add(new BewerberListItem
                {
                    BewerberId = Convert.ToInt32(row["ID"]),
                    Vorname = row["BW_Vorname"]?.ToString(),
                    Nachname = row["BW_Nachname"]?.ToString(),
                    Email = row["BW_EMail"]?.ToString(),
                    Telefon = row["BW_Tel"]?.ToString(),
                    Bewerbungsdatum = Convert.ToDateTime(row["BW_Datum"]),
                    StatusId = statusId,
                    StatusText = StatusListe.FirstOrDefault(s => s.StatusId == statusId)?.Bezeichnung ?? ""
                });
            }

            if (Bewerber.Any())
            {
                await LoadBewerberAsync(Bewerber.First().BewerberId);
            }

            ShowSuccess($"{Bewerber.Count} Bewerber gefunden");
            */

            await Task.CompletedTask;
        }, "Suche Bewerber...");
    }

    [RelayCommand]
    private async Task FilterByStatusAsync()
    {
        await LoadBewerberListeAsync();
    }

    #endregion

    #region Bewerber-zu-MA Konvertierung

    /// <summary>
    /// Konvertiert einen Bewerber zu einem Mitarbeiter
    /// </summary>
    [RelayCommand]
    private async Task ConvertToMitarbeiterAsync()
    {
        if (!CanConvertToMitarbeiter)
        {
            ShowError("Bewerber kann nicht konvertiert werden. Vorname und Nachname müssen ausgefüllt sein.");
            return;
        }

        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Als Mitarbeiter anlegen",
            $"Möchten Sie {Vorname} {Nachname} als Mitarbeiter anlegen?\n\nDer Bewerber-Status wird auf 'Eingestellt' gesetzt.");

        if (!confirmed)
            return;

        await ExecuteWithLoadingAsync(async () =>
        {
            // PLATZHALTER: Simuliere Konvertierung
            StatusId = 4; // Eingestellt
            StatusText = "Eingestellt";
            SelectedStatus = StatusListe.FirstOrDefault(s => s.StatusId == 4);

            // Aktualisiere in der Liste
            var existing = Bewerber.FirstOrDefault(b => b.BewerberId == BewerberId);
            if (existing != null)
            {
                existing.StatusId = StatusId;
                existing.StatusText = StatusText;
            }

            ShowSuccess($"{Vorname} {Nachname} wurde als Mitarbeiter angelegt (Platzhalter).\n\nHINWEIS: Echte Implementierung würde neuen Eintrag in tbl_MA_Mitarbeiterstamm erstellen.");

            /* Echte Implementierung (Feldnamen angepasst)
            // 1. Neuen Mitarbeiter in tbl_MA_Mitarbeiterstamm anlegen
            var sql = @"
                INSERT INTO tbl_MA_Mitarbeiterstamm
                (Vorname, Nachname, Email, Tel_Mobil, IstAktiv, Eintrittsdatum, Qualifikation, Bemerkung)
                VALUES (?, ?, ?, ?, True, ?, ?, ?)";

            await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
            {
                { "Vorname", Vorname! },
                { "Nachname", Nachname! },
                { "Email", (object?)Email ?? DBNull.Value },
                { "Tel_Mobil", (object?)Telefon ?? DBNull.Value },
                { "Eintrittsdatum", DateTime.Today },
                { "Qualifikation", (object?)Qualifikation ?? DBNull.Value },
                { "Bemerkung", $"Aus Bewerbung vom {Bewerbungsdatum:dd.MM.yyyy}\n\n{Bemerkung}" }
            });

            // 2. Neue MA-ID abrufen
            var newMaId = await _databaseService.ExecuteScalarAsync<int>(
                "SELECT MAX(ID) FROM tbl_MA_Mitarbeiterstamm");

            // 3. Bewerber-Status auf "Eingestellt" setzen
            await _databaseService.ExecuteNonQueryAsync(
                "UPDATE tbl_MA_Bewerber SET BW_Status = 'eingestellt' WHERE ID = ?",
                new Dictionary<string, object> { { "ID", BewerberId } });

            // 4. Status aktualisieren
            StatusId = 4;
            StatusText = "Eingestellt";
            SelectedStatus = StatusListe.FirstOrDefault(s => s.StatusId == 4);

            // 5. Liste neu laden
            await LoadBewerberListeAsync();

            ShowSuccess($"{Vorname} {Nachname} wurde als Mitarbeiter {newMaId} angelegt!");

            // Optional: Navigation zum Mitarbeiterstamm
            // _navigationService.NavigateTo<MitarbeiterstammViewModel>(newMaId);
            */

            await Task.CompletedTask;
        }, "Lege Mitarbeiter an...");
    }

    /// <summary>
    /// Setzt den Status des Bewerbers auf "Abgelehnt"
    /// </summary>
    [RelayCommand]
    private async Task RejectAsync()
    {
        if (BewerberId <= 0)
        {
            ShowError("Kein Bewerber ausgewählt");
            return;
        }

        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Bewerber ablehnen",
            $"Möchten Sie {Vorname} {Nachname} ablehnen?\n\nDer Status wird auf 'Abgelehnt' gesetzt.");

        if (!confirmed)
            return;

        await ExecuteWithLoadingAsync(async () =>
        {
            // PLATZHALTER: Status ändern
            StatusId = 5; // Abgelehnt
            StatusText = "Abgelehnt";
            SelectedStatus = StatusListe.FirstOrDefault(s => s.StatusId == 5);

            // Aktualisiere in der Liste
            var existing = Bewerber.FirstOrDefault(b => b.BewerberId == BewerberId);
            if (existing != null)
            {
                existing.StatusId = StatusId;
                existing.StatusText = StatusText;
            }

            ShowSuccess($"{Vorname} {Nachname} wurde abgelehnt (Platzhalter)");

            /* Echte Implementierung (Feldnamen angepasst)
            await _databaseService.ExecuteNonQueryAsync(
                "UPDATE tbl_MA_Bewerber SET BW_Status = 'abgelehnt' WHERE ID = ?",
                new Dictionary<string, object> { { "ID", BewerberId } });

            StatusId = 5;
            StatusText = "Abgelehnt";
            SelectedStatus = StatusListe.FirstOrDefault(s => s.StatusId == 5);

            await LoadBewerberListeAsync();

            ShowSuccess($"{Vorname} {Nachname} wurde abgelehnt");
            */

            await Task.CompletedTask;
        }, "Lehne Bewerber ab...");
    }

    #endregion
}

#region Helper Classes

/// <summary>
/// Item für die Bewerberliste
/// </summary>
public class BewerberListItem
{
    public int BewerberId { get; set; }
    public string? Vorname { get; set; }
    public string? Nachname { get; set; }
    public string VollName => $"{Nachname}, {Vorname}";
    public string? Email { get; set; }
    public string? Telefon { get; set; }
    public DateTime Bewerbungsdatum { get; set; }
    public int StatusId { get; set; }
    public string StatusText { get; set; } = "";

    public string DisplayText =>
        $"{Nachname}, {Vorname} ({Bewerbungsdatum:dd.MM.yyyy}) - {StatusText}";

    public string StatusColor => StatusId switch
    {
        1 => "#3B82F6", // Neu - Blau
        2 => "#F59E0B", // In Prüfung - Orange
        3 => "#06B6D4", // Eingeladen - Cyan
        4 => "#22C55E", // Eingestellt - Grün
        5 => "#EF4444", // Abgelehnt - Rot
        _ => "#808080"  // Unbekannt - Grau
    };
}

/// <summary>
/// Status-Item für die Status-Auswahl
/// </summary>
public class BewerberStatus
{
    public int StatusId { get; set; }
    public string Bezeichnung { get; set; } = "";
    public string Farbe { get; set; } = "#808080";
}

#endregion
