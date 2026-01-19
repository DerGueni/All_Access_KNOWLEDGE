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
/// ViewModel für Objektverwaltung (frm_OB_Objekt).
/// CRUD für Objekte (Einsatzorte/Schichten) mit Navigation und Auftragsübersicht.
/// </summary>
public partial class ObjektstammViewModel : BaseViewModel, INavigationAware
{
    #region Properties - Objekt Stammdaten

    [ObservableProperty]
    private int _objektId;

    [ObservableProperty]
    private string? _objekt;

    [ObservableProperty]
    private bool _istAktiv = true;

    [ObservableProperty]
    private string? _objektStrasse;

    [ObservableProperty]
    private string? _objektPlz;

    [ObservableProperty]
    private string? _objektOrt;

    [ObservableProperty]
    private int? _veranstalterId;

    [ObservableProperty]
    private string? _bemerkung;

    [ObservableProperty]
    private int _anzahlAuftraege;

    [ObservableProperty]
    private int _anzahlSchichten;

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
    private System.Collections.ObjectModel.ObservableCollection<ObjektListItem> _objektListe = new();

    [ObservableProperty]
    private ObjektListItem? _selectedObjekt;

    partial void OnSelectedObjektChanged(ObjektListItem? value)
    {
        if (value != null && value.ObjektId != ObjektId)
        {
            _ = LoadObjektAsync(value.ObjektId);
        }
    }

    [ObservableProperty]
    private System.Collections.ObjectModel.ObservableCollection<KundenDropdownItem> _kundenListe = new();

    [ObservableProperty]
    private KundenDropdownItem? _selectedKunde;

    partial void OnSelectedKundeChanged(KundenDropdownItem? value)
    {
        VeranstalterId = value?.KunId;
    }

    #endregion

    private List<int> _allObjektIds = new();
    private List<int> _filteredObjektIds = new();

    public ObjektstammViewModel(
        IDatabaseService databaseService,
        INavigationService navigationService,
        IDialogService dialogService)
        : base(databaseService, navigationService, dialogService)
    {
    }

    public override async Task InitializeAsync()
    {
        await LoadKundenListeAsync();
        await LoadObjektIdsAsync();

        if (_filteredObjektIds.Any())
        {
            await LoadObjektAsync(_filteredObjektIds.First());
        }
        else
        {
            NewRecordCommand.Execute(null);
        }
    }

    public void OnNavigatedTo(object? parameter)
    {
        if (parameter is int objektId)
        {
            _ = LoadObjektAsync(objektId);
        }
    }

    public void OnNavigatedFrom()
    {
        // Cleanup wenn nötig
    }

    #region Data Loading

    private async Task LoadKundenListeAsync()
    {
        var sql = @"SELECT kun_Id, kun_Firma
                   FROM tbl_KD_Kundenstamm
                   WHERE kun_IstAktiv = True
                   ORDER BY kun_Firma";

        var data = await _databaseService.ExecuteQueryAsync(sql);

        var kundenItems = new System.Collections.ObjectModel.ObservableCollection<KundenDropdownItem>();

        foreach (DataRow row in data.Rows)
        {
            kundenItems.Add(new KundenDropdownItem
            {
                KunId = Convert.ToInt32(row["kun_Id"]),
                Firma = row["kun_Firma"]?.ToString() ?? ""
            });
        }

        KundenListe = kundenItems;
    }

    private async Task LoadObjektIdsAsync(bool activeOnly = true)
    {
        // tbl_OB_Objekt: ID, Objekt, Strasse, PLZ, Ort, Bemerkung, etc.
        // Kein IstAktiv, kein Kunde_ID - Objekte sind unabhängig von Kunden
        var sql = @"SELECT ID, Objekt, Ort
                   FROM tbl_OB_Objekt
                   ORDER BY Objekt";

        var data = await _databaseService.ExecuteQueryAsync(sql);

        _allObjektIds = new List<int>();
        var objektItems = new System.Collections.ObjectModel.ObservableCollection<ObjektListItem>();

        foreach (DataRow row in data.Rows)
        {
            var objektId = Convert.ToInt32(row["ID"]);
            _allObjektIds.Add(objektId);

            objektItems.Add(new ObjektListItem
            {
                ObjektId = objektId,
                Objektname = row["Objekt"]?.ToString() ?? "",
                Ort = row["Ort"]?.ToString() ?? "",
                Kunde = "" // Kein Kunde in tbl_OB_Objekt
            });
        }

        ObjektListe = objektItems;
        _filteredObjektIds = new List<int>(_allObjektIds);
        TotalRecords = _filteredObjektIds.Count;
        UpdateNavigationState();
    }

    private async Task LoadObjektAsync(int objektId)
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            // tbl_OB_Objekt: ID, Objekt, Strasse, PLZ, Ort, Bemerkung, Treffpunkt, Dienstkleidung, Ansprechpartner
            var sql = @"
                SELECT ID, Objekt, Strasse, PLZ, Ort, Bemerkung
                FROM tbl_OB_Objekt
                WHERE ID = @ObjektId";

            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "ObjektId", objektId }
            });

            if (data.Rows.Count > 0)
            {
                var row = data.Rows[0];

                ObjektId = Convert.ToInt32(row["ID"]);
                Objekt = row["Objekt"]?.ToString();
                IstAktiv = true; // Kein IstAktiv in tbl_OB_Objekt
                ObjektStrasse = row["Strasse"]?.ToString();
                ObjektPlz = row["PLZ"]?.ToString();
                ObjektOrt = row["Ort"]?.ToString();
                VeranstalterId = null; // Kein Kunde_ID in tbl_OB_Objekt
                Bemerkung = row["Bemerkung"]?.ToString();

                IsNewRecord = false;
                IsEditMode = false;

                CurrentRecordIndex = _filteredObjektIds.IndexOf(objektId) + 1;
                UpdateNavigationState();

                // SelectedObjekt in Liste aktualisieren
                SelectedObjekt = ObjektListe.FirstOrDefault(o => o.ObjektId == objektId);

                // Kein Kunde in tbl_OB_Objekt
                SelectedKunde = null;

                // Load Aufträge count - über Objekt-Namen
                var auftraegeCount = await _databaseService.ExecuteScalarAsync<int?>(
                    "SELECT COUNT(*) FROM tbl_VA_Auftragstamm WHERE Objekt_ID = @ObjektId",
                    new Dictionary<string, object> { { "ObjektId", objektId } });
                AnzahlAuftraege = auftraegeCount ?? 0;

                // Schichten zählen nicht direkt möglich ohne Objekt_ID in tbl_VA_Start
                AnzahlSchichten = 0;

                ShowSuccess($"Objekt {ObjektId} geladen");
            }
        }, $"Lade Objekt {objektId}...");
    }

    #endregion

    #region Navigation Commands

    [RelayCommand(CanExecute = nameof(CanNavigateFirst))]
    private async Task NavigateFirstAsync()
    {
        if (_filteredObjektIds.Any())
        {
            await LoadObjektAsync(_filteredObjektIds.First());
        }
    }

    [RelayCommand(CanExecute = nameof(CanNavigatePrevious))]
    private async Task NavigatePreviousAsync()
    {
        var currentIndex = _filteredObjektIds.IndexOf(ObjektId);
        if (currentIndex > 0)
        {
            await LoadObjektAsync(_filteredObjektIds[currentIndex - 1]);
        }
    }

    [RelayCommand(CanExecute = nameof(CanNavigateNext))]
    private async Task NavigateNextAsync()
    {
        var currentIndex = _filteredObjektIds.IndexOf(ObjektId);
        if (currentIndex < _filteredObjektIds.Count - 1)
        {
            await LoadObjektAsync(_filteredObjektIds[currentIndex + 1]);
        }
    }

    [RelayCommand(CanExecute = nameof(CanNavigateLast))]
    private async Task NavigateLastAsync()
    {
        if (_filteredObjektIds.Any())
        {
            await LoadObjektAsync(_filteredObjektIds.Last());
        }
    }

    private void UpdateNavigationState()
    {
        if (!_filteredObjektIds.Any())
        {
            CanNavigateFirst = CanNavigatePrevious = CanNavigateNext = CanNavigateLast = false;
            return;
        }

        var currentIndex = _filteredObjektIds.IndexOf(ObjektId);

        CanNavigateFirst = currentIndex > 0;
        CanNavigatePrevious = currentIndex > 0;
        CanNavigateNext = currentIndex < _filteredObjektIds.Count - 1;
        CanNavigateLast = currentIndex < _filteredObjektIds.Count - 1;

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
        ObjektId = 0;
        Objekt = null;
        IstAktiv = true;
        ObjektStrasse = null;
        ObjektPlz = null;
        ObjektOrt = null;
        VeranstalterId = null;
        Bemerkung = null;
        AnzahlAuftraege = 0;
        AnzahlSchichten = 0;
        SelectedKunde = null;

        IsNewRecord = true;
        IsEditMode = true;

        ShowSuccess("Neues Objekt");
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
            if (string.IsNullOrWhiteSpace(Objekt))
            {
                ShowError("Objektname muss ausgefüllt sein");
                return;
            }

            if (IsNewRecord)
            {
                // Insert - tbl_OB_Objekt: Objekt, Strasse, PLZ, Ort, Bemerkung
                var sql = @"
                    INSERT INTO tbl_OB_Objekt
                    (Objekt, Strasse, PLZ, Ort, Bemerkung)
                    VALUES (@Objekt, @ObjektStrasse, @ObjektPlz, @ObjektOrt, @Bemerkung)";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "Objekt", Objekt! },
                    { "ObjektStrasse", (object?)ObjektStrasse ?? DBNull.Value },
                    { "ObjektPlz", (object?)ObjektPlz ?? DBNull.Value },
                    { "ObjektOrt", (object?)ObjektOrt ?? DBNull.Value },
                    { "Bemerkung", (object?)Bemerkung ?? DBNull.Value }
                });

                // Get new ID
                var newId = await _databaseService.ExecuteScalarAsync<int>(
                    "SELECT MAX(ID) FROM tbl_OB_Objekt");
                ObjektId = newId;

                await LoadObjektIdsAsync();
                IsNewRecord = false;

                ShowSuccess($"Objekt {ObjektId} gespeichert");
            }
            else
            {
                // Update - tbl_OB_Objekt
                var sql = @"
                    UPDATE tbl_OB_Objekt
                    SET Objekt = @Objekt,
                        Strasse = @ObjektStrasse,
                        PLZ = @ObjektPlz,
                        Ort = @ObjektOrt,
                        Bemerkung = @Bemerkung
                    WHERE ID = @ObjektId";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "ObjektId", ObjektId },
                    { "Objekt", Objekt! },
                    { "ObjektStrasse", (object?)ObjektStrasse ?? DBNull.Value },
                    { "ObjektPlz", (object?)ObjektPlz ?? DBNull.Value },
                    { "ObjektOrt", (object?)ObjektOrt ?? DBNull.Value },
                    { "Bemerkung", (object?)Bemerkung ?? DBNull.Value }
                });

                ShowSuccess($"Objekt {ObjektId} aktualisiert");
            }

            IsEditMode = false;
        }, "Speichere Objekt...");
    }

    [RelayCommand]
    private async Task DeleteAsync()
    {
        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Objekt löschen",
            $"Möchten Sie {Objekt} wirklich löschen?");

        if (!confirmed)
            return;

        await ExecuteWithLoadingAsync(async () =>
        {
            // Check for dependencies
            var hasAuftraege = await _databaseService.ExecuteScalarAsync<int>(
                "SELECT COUNT(*) FROM tbl_VA_Auftragstamm WHERE Objekt_ID = @ObjektId",
                new Dictionary<string, object> { { "ObjektId", ObjektId } });

            if (hasAuftraege > 0)
            {
                ShowError("Objekt kann nicht gelöscht werden, da Aufträge vorhanden sind.");
                return;
            }

            // tbl_VA_Start hat kein Objekt_ID Feld - überspringen

            // Delete Objekt
            await _databaseService.ExecuteNonQueryAsync(
                "DELETE FROM tbl_OB_Objekt WHERE ID = @ObjektId",
                new Dictionary<string, object> { { "ObjektId", ObjektId } });

            await LoadObjektIdsAsync();

            if (_filteredObjektIds.Any())
            {
                await LoadObjektAsync(_filteredObjektIds.First());
            }
            else
            {
                NewRecordCommand.Execute(null);
            }

            ShowSuccess("Objekt gelöscht");
        }, "Lösche Objekt...");
    }

    [RelayCommand]
    private async Task CancelAsync()
    {
        if (IsNewRecord)
        {
            if (_filteredObjektIds.Any())
            {
                await LoadObjektAsync(_filteredObjektIds.First());
            }
            else
            {
                NewRecordCommand.Execute(null);
            }
        }
        else
        {
            await LoadObjektAsync(ObjektId);
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
            await LoadObjektIdsAsync();
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT ID
                FROM tbl_OB_Objekt
                WHERE (Objekt LIKE @SearchText OR Ort LIKE @SearchText)
                ORDER BY Objekt";

            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "SearchText", $"%{SearchText}%" }
            });

            _filteredObjektIds = new List<int>();
            foreach (DataRow row in data.Rows)
            {
                _filteredObjektIds.Add(Convert.ToInt32(row["ID"]));
            }

            TotalRecords = _filteredObjektIds.Count;
            UpdateNavigationState();

            if (_filteredObjektIds.Any())
            {
                await LoadObjektAsync(_filteredObjektIds.First());
            }

            ShowSuccess($"{TotalRecords} Objekte gefunden");
        }, "Suche Objekte...");
    }

    [RelayCommand]
    private async Task ClearSearchAsync()
    {
        SearchText = null;
        await LoadObjektIdsAsync();

        if (_filteredObjektIds.Any())
        {
            await LoadObjektAsync(_filteredObjektIds.First());
        }
    }

    #endregion

    #region Aufträge Navigation

    [RelayCommand]
    private void ShowAuftraege()
    {
        _navigationService.NavigateTo<AuftragstammViewModel>(ObjektId);
    }

    #endregion
}

/// <summary>
/// DTO für Objektlisten-Einträge
/// </summary>
public class ObjektListItem
{
    public int ObjektId { get; set; }
    public string Objektname { get; set; } = "";
    public string Ort { get; set; } = "";
    public string Kunde { get; set; } = "";

    public override string ToString() => $"{Objektname} ({Ort})";
}

/// <summary>
/// DTO für Kunden-Dropdown
/// </summary>
public class KundenDropdownItem
{
    public int KunId { get; set; }
    public string Firma { get; set; } = "";

    public override string ToString() => Firma;
}
