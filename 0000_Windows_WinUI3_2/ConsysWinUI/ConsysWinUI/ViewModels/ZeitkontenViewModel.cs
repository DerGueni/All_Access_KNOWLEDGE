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
/// ViewModel für Zeitkontenverwaltung (frm_MA_Zeitkonten).
/// Zeigt Arbeitsstunden-Übersicht pro Mitarbeiter mit Soll/Ist-Vergleich und Korrekturbuchungen.
/// </summary>
public partial class ZeitkontenViewModel : BaseViewModel, INavigationAware
{
    #region Properties - Auswahl

    [ObservableProperty]
    private ObservableCollection<MitarbeiterItem> _mitarbeiter = new();

    [ObservableProperty]
    private MitarbeiterItem? _selectedMitarbeiter;

    [ObservableProperty]
    private int _selectedJahr = DateTime.Now.Year;

    [ObservableProperty]
    private ObservableCollection<int> _jahre = new();

    partial void OnSelectedMitarbeiterChanged(MitarbeiterItem? value)
    {
        if (value != null)
        {
            _ = LoadZeitkontoAsync();
        }
    }

    partial void OnSelectedJahrChanged(int value)
    {
        if (SelectedMitarbeiter != null)
        {
            _ = LoadZeitkontoAsync();
        }
    }

    #endregion

    #region Properties - Monatsübersicht

    [ObservableProperty]
    private ObservableCollection<ZeitkontoMonat> _monate = new();

    [ObservableProperty]
    private decimal _gesamtSoll;

    [ObservableProperty]
    private decimal _gesamtIst;

    [ObservableProperty]
    private decimal _gesamtDifferenz;

    [ObservableProperty]
    private decimal _endSaldo;

    #endregion

    #region Properties - Korrekturbuchungen

    [ObservableProperty]
    private ObservableCollection<ZkBuchung> _buchungen = new();

    [ObservableProperty]
    private ZkBuchung? _selectedBuchung;

    // Neue Buchung
    [ObservableProperty]
    private DateTimeOffset _neueBuchungDatum = new DateTimeOffset(DateTime.Today);

    [ObservableProperty]
    private decimal _neueBuchungStunden;

    [ObservableProperty]
    private string? _neueBuchungArt;

    [ObservableProperty]
    private string? _neueBuchungBemerkung;

    [ObservableProperty]
    private ObservableCollection<string> _buchungsarten = new()
    {
        "Korrektur +",
        "Korrektur -",
        "Überstunden ausgezahlt",
        "Urlaubsausgleich",
        "Sonstiges"
    };

    #endregion

    public ZeitkontenViewModel(
        IDatabaseService databaseService,
        INavigationService navigationService,
        IDialogService dialogService)
        : base(databaseService, navigationService, dialogService)
    {
        // Jahre von 2020 bis aktuelles Jahr + 1
        var currentYear = DateTime.Now.Year;
        for (int year = 2020; year <= currentYear + 1; year++)
        {
            Jahre.Add(year);
        }
    }

    public override async Task InitializeAsync()
    {
        await LoadMitarbeiterAsync();

        if (Mitarbeiter.Any())
        {
            SelectedMitarbeiter = Mitarbeiter.First();
        }
    }

    public void OnNavigatedTo(object? parameter)
    {
        if (parameter is int maId)
        {
            _ = Task.Run(async () =>
            {
                await LoadMitarbeiterAsync();
                var ma = Mitarbeiter.FirstOrDefault(m => m.MaId == maId);
                if (ma != null)
                {
                    SelectedMitarbeiter = ma;
                }
            });
        }
    }

    public void OnNavigatedFrom()
    {
        // Cleanup wenn nötig
    }

    #region Data Loading

    private async Task LoadMitarbeiterAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT MA_ID, Nachname, Vorname
                FROM tbl_MA_Mitarbeiterstamm
                WHERE IstAktiv = True
                ORDER BY Nachname, Vorname";

            var data = await _databaseService.ExecuteQueryAsync(sql);

            Mitarbeiter.Clear();
            foreach (DataRow row in data.Rows)
            {
                Mitarbeiter.Add(new MitarbeiterItem
                {
                    MaId = Convert.ToInt32(row["MA_ID"]),
                    Nachname = row["Nachname"]?.ToString(),
                    Vorname = row["Vorname"]?.ToString()
                });
            }

            ShowSuccess($"{Mitarbeiter.Count} Mitarbeiter geladen");
        }, "Lade Mitarbeiter...");
    }

    private async Task LoadZeitkontoAsync()
    {
        if (SelectedMitarbeiter == null)
            return;

        await ExecuteWithLoadingAsync(async () =>
        {
            // Monatsübersicht laden
            var sqlMonate = @"
                SELECT Monat, Soll_Stunden, Ist_Stunden
                FROM tbl_MA_Zeitkonto
                WHERE MA_ID = @MaId AND Jahr = @Jahr
                ORDER BY Monat";

            var dataMonate = await _databaseService.ExecuteQueryAsync(sqlMonate, new Dictionary<string, object>
            {
                { "MaId", SelectedMitarbeiter.MaId },
                { "Jahr", SelectedJahr }
            });

            Monate.Clear();
            decimal kumulierterSaldo = 0;

            if (dataMonate.Rows.Count > 0)
            {
                // Echte Daten vorhanden
                foreach (DataRow row in dataMonate.Rows)
                {
                    var sollStunden = row["Soll_Stunden"] != DBNull.Value ? Convert.ToDecimal(row["Soll_Stunden"]) : 0;
                    var istStunden = row["Ist_Stunden"] != DBNull.Value ? Convert.ToDecimal(row["Ist_Stunden"]) : 0;
                    var differenz = istStunden - sollStunden;
                    kumulierterSaldo += differenz;

                    Monate.Add(new ZeitkontoMonat
                    {
                        Monat = Convert.ToInt32(row["Monat"]),
                        SollStunden = sollStunden,
                        IstStunden = istStunden,
                        SaldoKumuliert = kumulierterSaldo
                    });
                }
            }
            else
            {
                // Keine Daten - Platzhalter mit 0-Werten für alle 12 Monate
                for (int monat = 1; monat <= 12; monat++)
                {
                    Monate.Add(new ZeitkontoMonat
                    {
                        Monat = monat,
                        SollStunden = 0,
                        IstStunden = 0,
                        SaldoKumuliert = 0
                    });
                }
            }

            // Summen berechnen
            GesamtSoll = Monate.Sum(m => m.SollStunden);
            GesamtIst = Monate.Sum(m => m.IstStunden);
            GesamtDifferenz = GesamtIst - GesamtSoll;
            EndSaldo = kumulierterSaldo;

            // Korrekturbuchungen laden
            await LoadBuchungenAsync();

            ShowSuccess($"Zeitkonto für {SelectedMitarbeiter.Name} ({SelectedJahr}) geladen");
        }, $"Lade Zeitkonto...");
    }

    private async Task LoadBuchungenAsync()
    {
        if (SelectedMitarbeiter == null)
            return;

        var sqlBuchungen = @"
            SELECT Buchung_ID, MA_ID, Datum, Stunden, Buchungsart, Bemerkung
            FROM tbl_MA_ZK_Buchungen
            WHERE MA_ID = @MaId AND YEAR(Datum) = @Jahr
            ORDER BY Datum DESC";

        var dataBuchungen = await _databaseService.ExecuteQueryAsync(sqlBuchungen, new Dictionary<string, object>
        {
            { "MaId", SelectedMitarbeiter.MaId },
            { "Jahr", SelectedJahr }
        });

        Buchungen.Clear();
        foreach (DataRow row in dataBuchungen.Rows)
        {
            Buchungen.Add(new ZkBuchung
            {
                BuchungId = Convert.ToInt32(row["Buchung_ID"]),
                MaId = Convert.ToInt32(row["MA_ID"]),
                Datum = Convert.ToDateTime(row["Datum"]),
                Stunden = row["Stunden"] != DBNull.Value ? Convert.ToDecimal(row["Stunden"]) : 0,
                Buchungsart = row["Buchungsart"]?.ToString(),
                Bemerkung = row["Bemerkung"]?.ToString()
            });
        }
    }

    #endregion

    #region Commands

    [RelayCommand]
    private async Task AktualisierenAsync()
    {
        await LoadZeitkontoAsync();
    }

    [RelayCommand]
    private async Task BuchungHinzufuegenAsync()
    {
        if (SelectedMitarbeiter == null)
        {
            ShowError("Bitte Mitarbeiter auswählen");
            return;
        }

        if (NeueBuchungStunden == 0)
        {
            ShowError("Bitte Stunden eingeben");
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                INSERT INTO tbl_MA_ZK_Buchungen
                (MA_ID, Datum, Stunden, Buchungsart, Bemerkung)
                VALUES (@MaId, @Datum, @Stunden, @Buchungsart, @Bemerkung)";

            await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
            {
                { "MaId", SelectedMitarbeiter.MaId },
                { "Datum", NeueBuchungDatum.DateTime },
                { "Stunden", NeueBuchungStunden },
                { "Buchungsart", (object?)NeueBuchungArt ?? DBNull.Value },
                { "Bemerkung", (object?)NeueBuchungBemerkung ?? DBNull.Value }
            });

            // Formular zurücksetzen
            NeueBuchungDatum = new DateTimeOffset(DateTime.Today);
            NeueBuchungStunden = 0;
            NeueBuchungArt = null;
            NeueBuchungBemerkung = null;

            // Liste neu laden
            await LoadBuchungenAsync();

            ShowSuccess("Buchung hinzugefügt");
        }, "Speichere Buchung...");
    }

    [RelayCommand]
    private async Task BuchungLoeschenAsync(ZkBuchung? buchung)
    {
        if (buchung == null)
            return;

        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Buchung löschen",
            $"Möchten Sie die Buchung vom {buchung.Datum:dd.MM.yyyy} ({buchung.Stunden} Std.) wirklich löschen?");

        if (!confirmed)
            return;

        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = "DELETE FROM tbl_MA_ZK_Buchungen WHERE Buchung_ID = @BuchungId";

            await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
            {
                { "BuchungId", buchung.BuchungId }
            });

            await LoadBuchungenAsync();

            ShowSuccess("Buchung gelöscht");
        }, "Lösche Buchung...");
    }

    #endregion
}

#region Helper Classes

public class MitarbeiterItem
{
    public int MaId { get; set; }
    public string? Nachname { get; set; }
    public string? Vorname { get; set; }

    public string Name => $"{Nachname}, {Vorname}";
}

public class ZeitkontoMonat
{
    public int Monat { get; set; }
    public string MonatName => new DateTime(2000, Monat, 1).ToString("MMMM");
    public decimal SollStunden { get; set; }
    public decimal IstStunden { get; set; }
    public decimal Differenz => IstStunden - SollStunden;
    public decimal SaldoKumuliert { get; set; }

    // Für Farb-Binding
    public string DifferenzFarbe => Differenz > 0 ? "#22C55E" : Differenz < 0 ? "#EF4444" : "#000000";
}

public class ZkBuchung
{
    public int BuchungId { get; set; }
    public int MaId { get; set; }
    public DateTime Datum { get; set; }
    public decimal Stunden { get; set; }
    public string? Buchungsart { get; set; }
    public string? Bemerkung { get; set; }

    public string DatumText => Datum.ToString("dd.MM.yyyy");
    public string StundenText => Stunden > 0 ? $"+{Stunden:F2}" : Stunden.ToString("F2");
    public string StundenFarbe => Stunden > 0 ? "#22C55E" : "#EF4444";
}

#endregion
