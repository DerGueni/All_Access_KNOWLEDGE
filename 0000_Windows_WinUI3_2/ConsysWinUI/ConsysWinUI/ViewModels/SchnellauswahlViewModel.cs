using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using ConsysWinUI.Services;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Media;

namespace ConsysWinUI.ViewModels;

/// <summary>
/// ViewModel fuer MA-Schnellauswahl (frm_MA_VA_Schnellauswahl).
/// Ermoeglicht schnelle Zuordnung von Mitarbeitern zu einer Schicht.
/// </summary>
public partial class SchnellauswahlViewModel : BaseViewModel, INavigationAware
{
    #region Properties - Schicht-Kontext

    [ObservableProperty]
    private int? _vaId;

    [ObservableProperty]
    private DateTime? _vaDatum;

    [ObservableProperty]
    private TimeSpan? _vaStart;

    [ObservableProperty]
    private TimeSpan? _vaEnde;

    [ObservableProperty]
    private string? _auftragName;

    [ObservableProperty]
    private string? _objektName;

    [ObservableProperty]
    private int _maBenoetigt;

    [ObservableProperty]
    private int _maZugeordnet;

    [ObservableProperty]
    private int _maFehlt;

    [ObservableProperty]
    private int _gesamtMa;

    public Visibility HasAuftragSelected => (VaId.HasValue && VaDatum.HasValue) ? Visibility.Visible : Visibility.Collapsed;

    #endregion

    #region Properties - Auswahl-Listen (Neu)

    [ObservableProperty]
    private ObservableCollection<AuftragAuswahlItem> _auftragListe = new();

    [ObservableProperty]
    private AuftragAuswahlItem? _selectedAuftrag;

    [ObservableProperty]
    private ObservableCollection<DatumAuswahlItem> _datumListe = new();

    [ObservableProperty]
    private DatumAuswahlItem? _selectedDatum;

    [ObservableProperty]
    private ObservableCollection<ZeitItem> _zeitenListe = new();

    [ObservableProperty]
    private ZeitItem? _selectedZeit;

    [ObservableProperty]
    private ObservableCollection<ParallelEinsatzItem> _parallelEinsaetzeListe = new();

    [ObservableProperty]
    private ParallelEinsatzItem? _selectedParallelEinsatz;

    [ObservableProperty]
    private ObservableCollection<ZugeordneterMitarbeiterItem> _mitarbeiterMitZusage = new();

    [ObservableProperty]
    private ZugeordneterMitarbeiterItem? _selectedMitZusage;

    #endregion

    #region Properties - Mitarbeiter-Listen

    [ObservableProperty]
    private ObservableCollection<VerfuegbarerMitarbeiterItem> _verfuegbareMitarbeiter = new();

    [ObservableProperty]
    private ObservableCollection<ZugeordneterMitarbeiterItem> _zugeordneteMitarbeiter = new();

    [ObservableProperty]
    private VerfuegbarerMitarbeiterItem? _selectedVerfuegbarer;

    [ObservableProperty]
    private ZugeordneterMitarbeiterItem? _selectedZugeordneter;

    #endregion

    #region Properties - Filter

    [ObservableProperty]
    private string? _suchbegriff;

    [ObservableProperty]
    private string? _searchTerm;

    [ObservableProperty]
    private bool _nurAktive = true;

    [ObservableProperty]
    private bool _nurVerfuegbare = true;

    [ObservableProperty]
    private bool _filterNurVerfuegbare = true;

    [ObservableProperty]
    private bool _verplantVerfuegbar;

    [ObservableProperty]
    private bool _nur34a;

    [ObservableProperty]
    private bool _nurMitQualifikation;

    [ObservableProperty]
    private ObservableCollection<QualifikationItem> _qualifikationen = new();

    [ObservableProperty]
    private QualifikationItem? _selectedQualifikation;

    [ObservableProperty]
    private ObservableCollection<AnstellungsartItem> _anstellungsartListe = new();

    [ObservableProperty]
    private AnstellungsartItem? _selectedAnstellungsart;

    [ObservableProperty]
    private object? _filterEinsatzart;

    #endregion

    #region Properties - Selection (Mehrfachauswahl)

    public ObservableCollection<VerfuegbarerMitarbeiterItem> SelectedVerfuegbare { get; } = new();
    public ObservableCollection<ZugeordneterMitarbeiterItem> SelectedZugeordnete { get; } = new();

    [ObservableProperty]
    private bool _canZuordnen;

    [ObservableProperty]
    private bool _canEntfernen;

    public int ZugeordnetCount => ZugeordneteMitarbeiter.Count;
    public int BenoetigtCount => MaBenoetigt;

    #endregion

    #region Properties - Display

    public string SchichtInfo => $"{VaDatum:dd.MM.yyyy} {VaStart:hh\\:mm}-{VaEnde:hh\\:mm}";
    public string SchichtZeit => $"{VaStart:hh\\:mm} - {VaEnde:hh\\:mm}";

    [ObservableProperty]
    private string? _statusText = "Bereit";

    [ObservableProperty]
    private Microsoft.UI.Xaml.Media.Brush? _statusColor;

    #endregion

    public SchnellauswahlViewModel(
        IDatabaseService databaseService,
        INavigationService navigationService,
        IDialogService dialogService)
        : base(databaseService, navigationService, dialogService)
    {
    }

    public override async Task InitializeAsync()
    {
        await LoadQualifikationenAsync();
        await LoadAnstellungsartenAsync();
        await LoadAuftragListeAsync();
    }

    public void OnNavigatedTo(object? parameter)
    {
        if (parameter is SchichtDetailItem schicht)
        {
            VaId = schicht.VaId;
            VaDatum = schicht.VaDatum;
            VaStart = schicht.VaStart;
            VaEnde = schicht.VaEnde;
            MaBenoetigt = schicht.MaAnzahl;
            MaZugeordnet = schicht.MaAnzahlIst;
            MaFehlt = schicht.MaAnzahl - schicht.MaAnzahlIst;

            _ = LoadDataAsync();
        }
    }

    public void OnNavigatedFrom()
    {
        // Cleanup wenn noetig
    }

    #region Data Loading

    private async Task LoadAuftragListeAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            // Query basierend auf Access: VA_ID ComboBox Row Source
            var sql = @"
                SELECT DISTINCT a.ID AS VA_ID, d.ID AS VADatum_ID,
                       FORMAT(d.VADatum, 'dd.MM.yyyy') + '   ' + a.Auftrag + '   ' + a.Objekt + '   ' + a.Ort AS DisplayText,
                       d.VADatum
                FROM tbl_VA_Auftragstamm a
                INNER JOIN tbl_VA_AnzTage d ON a.ID = d.VA_ID
                INNER JOIN qry_tbl_Start_proTag s ON d.VA_ID = s.VA_ID AND d.ID = s.VADatum_ID
                WHERE d.VADatum >= CAST(GETDATE() AS DATE)
                ORDER BY d.VADatum";

            try
            {
                var data = await _databaseService.ExecuteQueryAsync(sql);
                AuftragListe.Clear();

                foreach (DataRow row in data.Rows)
                {
                    AuftragListe.Add(new AuftragAuswahlItem
                    {
                        VaId = Convert.ToInt32(row["VA_ID"]),
                        VaDatumId = Convert.ToInt32(row["VADatum_ID"]),
                        DisplayText = row["DisplayText"]?.ToString() ?? "",
                        VaDatum = row["VADatum"] != DBNull.Value ? Convert.ToDateTime(row["VADatum"]) : DateTime.MinValue
                    });
                }
            }
            catch (Exception ex)
            {
                ShowError($"Fehler beim Laden der Aufträge: {ex.Message}");
            }
        });
    }

    private async Task LoadDatumListeAsync()
    {
        if (!VaId.HasValue) return;

        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT ID, VADatum
                FROM tbl_VA_AnzTage
                WHERE VA_ID = @VaId
                ORDER BY VADatum";

            try
            {
                var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
                {
                    { "VaId", VaId.Value }
                });

                DatumListe.Clear();
                foreach (DataRow row in data.Rows)
                {
                    DatumListe.Add(new DatumAuswahlItem
                    {
                        VaDatumId = Convert.ToInt32(row["ID"]),
                        Datum = row["VADatum"] != DBNull.Value ? Convert.ToDateTime(row["VADatum"]) : DateTime.MinValue
                    });
                }

                // Erstes Datum automatisch auswählen
                if (DatumListe.Count > 0)
                {
                    SelectedDatum = DatumListe[0];
                }
            }
            catch (Exception ex)
            {
                ShowError($"Fehler beim Laden der Daten: {ex.Message}");
            }
        });
    }

    private async Task LoadZeitenListeAsync()
    {
        if (!VaId.HasValue || !VaDatum.HasValue) return;

        await ExecuteWithLoadingAsync(async () =>
        {
            // Query basierend auf Access: lstZeiten Row Source
            var sql = @"
                SELECT VAStart_ID, VADatum, MVA_Start, MVA_Ende, MA_Ist as Ist, MA_Soll as Soll,
                       LEFT(VA_Start, 5) As Beginn, LEFT(VA_Ende, 5) as Ende,
                       VA_Start, VA_Ende
                FROM qry_Anz_MA_Start
                WHERE VA_ID = @VaId
                ORDER BY VA_Start, VA_Ende";

            try
            {
                var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
                {
                    { "VaId", VaId.Value }
                });

                ZeitenListe.Clear();
                int gesamtIst = 0;
                int gesamtSoll = 0;

                foreach (DataRow row in data.Rows)
                {
                    var ist = row["Ist"] != DBNull.Value ? Convert.ToInt32(row["Ist"]) : 0;
                    var soll = row["Soll"] != DBNull.Value ? Convert.ToInt32(row["Soll"]) : 0;
                    gesamtIst += ist;
                    gesamtSoll += soll;

                    ZeitenListe.Add(new ZeitItem
                    {
                        VAStartId = Convert.ToInt32(row["VAStart_ID"]),
                        Start = row["VA_Start"] != DBNull.Value ? TimeSpan.Parse(row["VA_Start"].ToString()!) : TimeSpan.Zero,
                        Ende = row["VA_Ende"] != DBNull.Value ? TimeSpan.Parse(row["VA_Ende"].ToString()!) : TimeSpan.Zero,
                        Ist = ist,
                        Soll = soll
                    });
                }

                GesamtMa = gesamtSoll;

                // Erste Zeit automatisch auswählen
                if (ZeitenListe.Count > 0)
                {
                    SelectedZeit = ZeitenListe[0];
                }
            }
            catch (Exception ex)
            {
                ShowError($"Fehler beim Laden der Zeiten: {ex.Message}");
            }
        });
    }

    private async Task LoadParallelEinsaetzeAsync()
    {
        if (!VaDatum.HasValue) return;

        await ExecuteWithLoadingAsync(async () =>
        {
            // Query basierend auf Access: Lst_Parallel_Einsatz Row Source
            var sql = @"
                SELECT *
                FROM qry_VA_Einsatz
                WHERE VADatum = @VaDatum";

            try
            {
                var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
                {
                    { "VaDatum", VaDatum.Value }
                });

                ParallelEinsaetzeListe.Clear();
                foreach (DataRow row in data.Rows)
                {
                    ParallelEinsaetzeListe.Add(new ParallelEinsatzItem
                    {
                        VaId = row["VA_ID"] != DBNull.Value ? Convert.ToInt32(row["VA_ID"]) : 0,
                        Auftrag = row["Auftrag"]?.ToString() ?? "",
                        Objekt = row["Objekt"]?.ToString() ?? "",
                        Ort = row["Ort"]?.ToString() ?? ""
                    });
                }
            }
            catch (Exception ex)
            {
                ShowError($"Fehler beim Laden der Parallel-Einsätze: {ex.Message}");
            }
        });
    }

    private async Task LoadMitarbeiterMitZusageAsync()
    {
        if (!VaId.HasValue || !VaDatum.HasValue) return;

        await ExecuteWithLoadingAsync(async () =>
        {
            // Query basierend auf Access: lstMA_Zusage Row Source
            var sql = @"
                SELECT *
                FROM qry_Mitarbeiter_Zusage
                WHERE VA_ID = @VaId";

            try
            {
                var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
                {
                    { "VaId", VaId.Value }
                });

                MitarbeiterMitZusage.Clear();
                foreach (DataRow row in data.Rows)
                {
                    MitarbeiterMitZusage.Add(new ZugeordneterMitarbeiterItem
                    {
                        MaId = Convert.ToInt32(row["MA_ID"]),
                        Nachname = row["Nachname"]?.ToString() ?? "",
                        Vorname = row["Vorname"]?.ToString() ?? "",
                        TelMobil = row["Tel_Mobil"]?.ToString(),
                        VaStart = row["VA_Start"] != DBNull.Value ? TimeSpan.Parse(row["VA_Start"].ToString()!) : null,
                        VaEnde = row["VA_Ende"] != DBNull.Value ? TimeSpan.Parse(row["VA_Ende"].ToString()!) : null
                    });
                }
            }
            catch (Exception ex)
            {
                ShowError($"Fehler beim Laden der MA mit Zusage: {ex.Message}");
            }
        });
    }

    private async Task LoadAnstellungsartenAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            // Query basierend auf Access: cboAnstArt Row Source
            var sql = @"
                SELECT ID, Anstellungsart, Sortierung
                FROM tbl_hlp_MA_Anstellungsart
                WHERE ID IN (3, 5, 11, 9, 13)
                ORDER BY Sortierung";

            try
            {
                var data = await _databaseService.ExecuteQueryAsync(sql);
                AnstellungsartListe.Clear();
                AnstellungsartListe.Add(new AnstellungsartItem { Id = 0, Name = "(Alle)" });

                foreach (DataRow row in data.Rows)
                {
                    AnstellungsartListe.Add(new AnstellungsartItem
                    {
                        Id = Convert.ToInt32(row["ID"]),
                        Name = row["Anstellungsart"]?.ToString() ?? ""
                    });
                }

                SelectedAnstellungsart = AnstellungsartListe[0];
            }
            catch
            {
                AnstellungsartListe.Clear();
                AnstellungsartListe.Add(new AnstellungsartItem { Id = 0, Name = "(Alle)" });
                SelectedAnstellungsart = AnstellungsartListe[0];
            }
        });
    }

    private async Task LoadQualifikationenAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT DISTINCT Qualifikation
                FROM tbl_MA_Qualifikationen
                WHERE Qualifikation IS NOT NULL
                ORDER BY Qualifikation";

            try
            {
                var data = await _databaseService.ExecuteQueryAsync(sql);
                Qualifikationen.Clear();
                Qualifikationen.Add(new QualifikationItem { Id = 0, Name = "(Alle)" });

                foreach (DataRow row in data.Rows)
                {
                    Qualifikationen.Add(new QualifikationItem
                    {
                        Id = Qualifikationen.Count,
                        Name = row["Qualifikation"]?.ToString() ?? ""
                    });
                }
            }
            catch
            {
                Qualifikationen.Clear();
                Qualifikationen.Add(new QualifikationItem { Id = 0, Name = "(Alle)" });
            }
        });
    }

    private async Task LoadDataAsync()
    {
        await LoadAuftragDetailsAsync();
        await LoadVerfuegbareMitarbeiterAsync();
        await LoadZugeordneteMitarbeiterAsync();
    }

    private async Task LoadAuftragDetailsAsync()
    {
        if (!VaId.HasValue) return;

        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT a.Auftrag, a.Objekt
                FROM tbl_VA_Auftragstamm a
                WHERE a.VA_ID = @VaId";

            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "VaId", VaId.Value }
            });

            if (data.Rows.Count > 0)
            {
                var row = data.Rows[0];
                AuftragName = row["Auftrag"]?.ToString();
                ObjektName = row["Objekt"]?.ToString();
            }
        });
    }

    [RelayCommand]
    private async Task LoadVerfuegbareMitarbeiterAsync()
    {
        if (!VaId.HasValue || !VaDatum.HasValue) return;

        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT m.MA_ID, m.Nachname, m.Vorname, m.Tel_Mobil, m.IstAktiv
                FROM tbl_MA_Mitarbeiterstamm m
                WHERE 1=1";

            var parameters = new Dictionary<string, object>();

            if (NurAktive)
            {
                sql += " AND m.IstAktiv = True";
            }

            if (NurVerfuegbare)
            {
                sql += @" AND m.MA_ID NOT IN (
                    SELECT p.MA_ID FROM tbl_MA_VA_Planung p
                    WHERE p.VADatum = @VaDatum
                      AND ((p.VA_Start <= @VaEnde AND p.VA_Ende >= @VaStart)
                           OR (p.VA_Start IS NULL))
                )";
                parameters.Add("VaDatum", VaDatum.Value);
                parameters.Add("VaStart", VaStart ?? TimeSpan.Zero);
                parameters.Add("VaEnde", VaEnde ?? TimeSpan.FromHours(23).Add(TimeSpan.FromMinutes(59)));

                sql += @" AND m.MA_ID NOT IN (
                    SELECT n.MA_ID FROM tbl_MA_NVerfuegZeiten n
                    WHERE @VaDatum BETWEEN n.vonDat AND n.bisDat
                )";
            }

            if (!string.IsNullOrWhiteSpace(Suchbegriff))
            {
                sql += " AND (m.Nachname LIKE @Such OR m.Vorname LIKE @Such)";
                parameters.Add("Such", $"%{Suchbegriff}%");
            }

            sql += " ORDER BY m.Nachname, m.Vorname";

            var data = await _databaseService.ExecuteQueryAsync(sql, parameters);

            VerfuegbareMitarbeiter.Clear();
            foreach (DataRow row in data.Rows)
            {
                VerfuegbareMitarbeiter.Add(new VerfuegbarerMitarbeiterItem
                {
                    MaId = Convert.ToInt32(row["MA_ID"]),
                    Nachname = row["Nachname"]?.ToString() ?? "",
                    Vorname = row["Vorname"]?.ToString() ?? "",
                    TelMobil = row["Tel_Mobil"]?.ToString(),
                    IstAktiv = row["IstAktiv"] != DBNull.Value && Convert.ToBoolean(row["IstAktiv"])
                });
            }

            ShowSuccess($"{VerfuegbareMitarbeiter.Count} verfuegbare Mitarbeiter");
        }, "Lade verfuegbare Mitarbeiter...");
    }

    private async Task LoadZugeordneteMitarbeiterAsync()
    {
        if (!VaId.HasValue || !VaDatum.HasValue) return;

        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT p.MA_ID, m.Nachname, m.Vorname, m.Tel_Mobil,
                       p.VA_Start, p.VA_Ende
                FROM tbl_MA_VA_Planung p
                INNER JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.MA_ID
                WHERE p.VA_ID = @VaId
                  AND p.VADatum = @VaDatum
                  AND p.VA_Start = @VaStart
                ORDER BY m.Nachname, m.Vorname";

            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "VaId", VaId.Value },
                { "VaDatum", VaDatum.Value },
                { "VaStart", VaStart ?? TimeSpan.Zero }
            });

            ZugeordneteMitarbeiter.Clear();
            foreach (DataRow row in data.Rows)
            {
                ZugeordneteMitarbeiter.Add(new ZugeordneterMitarbeiterItem
                {
                    MaId = Convert.ToInt32(row["MA_ID"]),
                    Nachname = row["Nachname"]?.ToString() ?? "",
                    Vorname = row["Vorname"]?.ToString() ?? "",
                    TelMobil = row["Tel_Mobil"]?.ToString(),
                    VaStart = row["VA_Start"] != DBNull.Value ? TimeSpan.Parse(row["VA_Start"].ToString()!) : null,
                    VaEnde = row["VA_Ende"] != DBNull.Value ? TimeSpan.Parse(row["VA_Ende"].ToString()!) : null
                });
            }

            MaZugeordnet = ZugeordneteMitarbeiter.Count;
            MaFehlt = MaBenoetigt - MaZugeordnet;
        }, "Lade zugeordnete Mitarbeiter...");
    }

    #endregion

    #region Commands - Zuordnung

    [RelayCommand]
    public async Task ZuordnenAsync(VerfuegbarerMitarbeiterItem? mitarbeiter)
    {
        mitarbeiter ??= SelectedVerfuegbarer;
        if (mitarbeiter == null || !VaId.HasValue || !VaDatum.HasValue)
        {
            ShowError("Bitte Mitarbeiter auswaehlen");
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                INSERT INTO tbl_MA_VA_Planung (VA_ID, MA_ID, VADatum, VA_Start, VA_Ende)
                VALUES (@VaId, @MaId, @VaDatum, @VaStart, @VaEnde)";

            await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
            {
                { "VaId", VaId.Value },
                { "MaId", mitarbeiter.MaId },
                { "VaDatum", VaDatum.Value },
                { "VaStart", VaStart ?? TimeSpan.Zero },
                { "VaEnde", VaEnde ?? TimeSpan.FromHours(23).Add(TimeSpan.FromMinutes(59)) }
            });

            await LoadVerfuegbareMitarbeiterAsync();
            await LoadZugeordneteMitarbeiterAsync();

            var updateSql = @"
                UPDATE tbl_VA_Start
                SET MA_Anzahl_Ist = (
                    SELECT COUNT(*) FROM tbl_MA_VA_Planung
                    WHERE VA_ID = @VaId AND VADatum = @VaDatum AND VA_Start = @VaStart
                )
                WHERE VA_ID = @VaId AND VADatum = @VaDatum AND VA_Start = @VaStart";

            await _databaseService.ExecuteNonQueryAsync(updateSql, new Dictionary<string, object>
            {
                { "VaId", VaId.Value },
                { "VaDatum", VaDatum.Value },
                { "VaStart", VaStart ?? TimeSpan.Zero }
            });

            ShowSuccess($"{mitarbeiter.Vorname} {mitarbeiter.Nachname} zugeordnet");
        }, "Ordne Mitarbeiter zu...");
    }

    [RelayCommand]
    public async Task EntfernenAsync(ZugeordneterMitarbeiterItem? mitarbeiter)
    {
        mitarbeiter ??= SelectedZugeordneter;
        if (mitarbeiter == null || !VaId.HasValue || !VaDatum.HasValue)
        {
            ShowError("Bitte Mitarbeiter auswaehlen");
            return;
        }

        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Mitarbeiter entfernen",
            $"Moechten Sie {mitarbeiter.Vorname} {mitarbeiter.Nachname} von dieser Schicht entfernen?");

        if (!confirmed) return;

        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                DELETE FROM tbl_MA_VA_Planung
                WHERE VA_ID = @VaId
                  AND MA_ID = @MaId
                  AND VADatum = @VaDatum
                  AND VA_Start = @VaStart";

            await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
            {
                { "VaId", VaId.Value },
                { "MaId", mitarbeiter.MaId },
                { "VaDatum", VaDatum.Value },
                { "VaStart", VaStart ?? TimeSpan.Zero }
            });

            await LoadVerfuegbareMitarbeiterAsync();
            await LoadZugeordneteMitarbeiterAsync();

            var updateSql = @"
                UPDATE tbl_VA_Start
                SET MA_Anzahl_Ist = (
                    SELECT COUNT(*) FROM tbl_MA_VA_Planung
                    WHERE VA_ID = @VaId AND VADatum = @VaDatum AND VA_Start = @VaStart
                )
                WHERE VA_ID = @VaId AND VADatum = @VaDatum AND VA_Start = @VaStart";

            await _databaseService.ExecuteNonQueryAsync(updateSql, new Dictionary<string, object>
            {
                { "VaId", VaId.Value },
                { "VaDatum", VaDatum.Value },
                { "VaStart", VaStart ?? TimeSpan.Zero }
            });

            ShowSuccess("Mitarbeiter entfernt");
        }, "Entferne Mitarbeiter...");
    }

    [RelayCommand]
    private async Task ZuordnenAlleAsync()
    {
        if (VerfuegbareMitarbeiter.Count == 0)
        {
            ShowError("Keine verfuegbaren Mitarbeiter");
            return;
        }

        var anzahl = Math.Min(VerfuegbareMitarbeiter.Count, MaFehlt);
        if (anzahl <= 0)
        {
            ShowInfo("Schicht ist bereits vollbesetzt");
            return;
        }

        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Alle zuordnen",
            $"Moechten Sie die ersten {anzahl} Mitarbeiter zuordnen?");

        if (!confirmed) return;

        await ExecuteWithLoadingAsync(async () =>
        {
            var zuZuordnen = VerfuegbareMitarbeiter.Take(anzahl).ToList();

            foreach (var ma in zuZuordnen)
            {
                var sql = @"
                    INSERT INTO tbl_MA_VA_Planung (VA_ID, MA_ID, VADatum, VA_Start, VA_Ende)
                    VALUES (@VaId, @MaId, @VaDatum, @VaStart, @VaEnde)";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "VaId", VaId!.Value },
                    { "MaId", ma.MaId },
                    { "VaDatum", VaDatum!.Value },
                    { "VaStart", VaStart ?? TimeSpan.Zero },
                    { "VaEnde", VaEnde ?? TimeSpan.FromHours(23).Add(TimeSpan.FromMinutes(59)) }
                });
            }

            await LoadVerfuegbareMitarbeiterAsync();
            await LoadZugeordneteMitarbeiterAsync();

            ShowSuccess($"{anzahl} Mitarbeiter zugeordnet");
        }, "Ordne Mitarbeiter zu...");
    }

    #endregion

    #region Commands - Filter

    partial void OnSuchbegriffChanged(string? value)
    {
        _ = LoadVerfuegbareMitarbeiterAsync();
    }

    partial void OnNurAktiveChanged(bool value)
    {
        _ = LoadVerfuegbareMitarbeiterAsync();
    }

    partial void OnNurVerfuegbareChanged(bool value)
    {
        _ = LoadVerfuegbareMitarbeiterAsync();
    }

    partial void OnVerplantVerfuegbarChanged(bool value)
    {
        _ = LoadVerfuegbareMitarbeiterAsync();
    }

    partial void OnNur34aChanged(bool value)
    {
        _ = LoadVerfuegbareMitarbeiterAsync();
    }

    partial void OnSelectedAnstellungsartChanged(AnstellungsartItem? value)
    {
        _ = LoadVerfuegbareMitarbeiterAsync();
    }

    partial void OnSelectedQualifikationChanged(QualifikationItem? value)
    {
        _ = LoadVerfuegbareMitarbeiterAsync();
    }

    partial void OnSelectedAuftragChanged(AuftragAuswahlItem? value)
    {
        if (value != null)
        {
            VaId = value.VaId;
            _ = LoadDatumListeAsync();
            _ = LoadAuftragDetailsAsync();
        }
    }

    partial void OnSelectedDatumChanged(DatumAuswahlItem? value)
    {
        if (value != null)
        {
            VaDatum = value.Datum;
            _ = LoadZeitenListeAsync();
            _ = LoadParallelEinsaetzeAsync();
        }
    }

    partial void OnSelectedZeitChanged(ZeitItem? value)
    {
        if (value != null)
        {
            VaStart = value.Start;
            VaEnde = value.Ende;
            MaBenoetigt = value.Soll;
            _ = LoadVerfuegbareMitarbeiterAsync();
            _ = LoadZugeordneteMitarbeiterAsync();
            _ = LoadMitarbeiterMitZusageAsync();
            OnPropertyChanged(nameof(HasAuftragSelected));
        }
    }

    [RelayCommand]
    private void FilterZuruecksetzen()
    {
        Suchbegriff = null;
        NurAktive = true;
        NurVerfuegbare = true;
        VerplantVerfuegbar = false;
        Nur34a = false;
        NurMitQualifikation = false;
        SelectedQualifikation = Qualifikationen.FirstOrDefault();
        SelectedAnstellungsart = AnstellungsartListe.FirstOrDefault();
    }

    #endregion

    #region Commands - Navigation

    [RelayCommand]
    private void OpenMitarbeiterDetails(VerfuegbarerMitarbeiterItem? mitarbeiter)
    {
        mitarbeiter ??= SelectedVerfuegbarer;
        if (mitarbeiter != null)
        {
            _navigationService.NavigateTo<MitarbeiterstammViewModel>(mitarbeiter.MaId);
        }
    }

    [RelayCommand]
    private void Schliessen()
    {
        _navigationService.NavigateBack();
    }

    #endregion

    #region Commands - E-Mail (Test-Modus)

    [RelayCommand]
    private async Task SendEmailAsync()
    {
        // Test-Funktionalität: Zeigt nur Zusammenfassung, sendet keine echten E-Mails
        if (!VaId.HasValue || !VaDatum.HasValue)
        {
            ShowError("Bitte wählen Sie zuerst einen Auftrag und ein Datum aus.");
            return;
        }

        var anzahlZugeordnet = ZugeordneteMitarbeiter.Count;
        if (anzahlZugeordnet == 0)
        {
            ShowError("Keine Mitarbeiter zugeordnet. Bitte zuerst Mitarbeiter zuordnen.");
            return;
        }

        var message = $"TEST-MODUS: E-Mail würde an {anzahlZugeordnet} Mitarbeiter gesendet werden\n\n" +
                      $"Auftrag: {AuftragName}\n" +
                      $"Objekt: {ObjektName}\n" +
                      $"Datum: {VaDatum:dd.MM.yyyy}\n" +
                      $"Zeit: {VaStart:hh\\:mm} - {VaEnde:hh\\:mm}\n\n" +
                      $"Mitarbeiter:\n";

        foreach (var ma in ZugeordneteMitarbeiter)
        {
            message += $"  - {ma.Nachname}, {ma.Vorname}";
            if (!string.IsNullOrEmpty(ma.TelMobil))
            {
                message += $" ({ma.TelMobil})";
            }
            message += "\n";
        }

        await _dialogService.ShowMessageAsync("E-Mail senden (TEST)", message);
        ShowInfo($"Test-E-Mail-Vorschau für {anzahlZugeordnet} Mitarbeiter angezeigt");
    }

    #endregion

    #region Commands - View Buttons

    [RelayCommand]
    private async Task SpeichernAsync()
    {
        ShowSuccess("Aenderungen gespeichert");
        await Task.CompletedTask;
    }

    [RelayCommand]
    private async Task AktualisierenAsync()
    {
        await LoadDataAsync();
    }

    [RelayCommand]
    private async Task FilterChangedAsync()
    {
        NurVerfuegbare = FilterNurVerfuegbare;
        Suchbegriff = SearchTerm;
        await LoadVerfuegbareMitarbeiterAsync();
    }

    [RelayCommand]
    private async Task ZuordnenSelectedAsync()
    {
        if (SelectedVerfuegbare.Count == 0)
        {
            ShowError("Bitte Mitarbeiter auswaehlen");
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            foreach (var ma in SelectedVerfuegbare.ToList())
            {
                var sql = @"
                    INSERT INTO tbl_MA_VA_Planung (VA_ID, MA_ID, VADatum, VA_Start, VA_Ende)
                    VALUES (@VaId, @MaId, @VaDatum, @VaStart, @VaEnde)";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "VaId", VaId!.Value },
                    { "MaId", ma.MaId },
                    { "VaDatum", VaDatum!.Value },
                    { "VaStart", VaStart ?? TimeSpan.Zero },
                    { "VaEnde", VaEnde ?? TimeSpan.FromHours(23).Add(TimeSpan.FromMinutes(59)) }
                });
            }

            await LoadVerfuegbareMitarbeiterAsync();
            await LoadZugeordneteMitarbeiterAsync();
            OnPropertyChanged(nameof(ZugeordnetCount));

            ShowSuccess($"{SelectedVerfuegbare.Count} Mitarbeiter zugeordnet");
            SelectedVerfuegbare.Clear();
            UpdateCanCommands();
        }, "Ordne Mitarbeiter zu...");
    }

    [RelayCommand]
    private async Task EntfernenSelectedAsync()
    {
        if (SelectedZugeordnete.Count == 0)
        {
            ShowError("Bitte Mitarbeiter auswaehlen");
            return;
        }

        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Mitarbeiter entfernen",
            $"Moechten Sie {SelectedZugeordnete.Count} Mitarbeiter von dieser Schicht entfernen?");

        if (!confirmed) return;

        await ExecuteWithLoadingAsync(async () =>
        {
            foreach (var ma in SelectedZugeordnete.ToList())
            {
                var sql = @"
                    DELETE FROM tbl_MA_VA_Planung
                    WHERE VA_ID = @VaId
                      AND MA_ID = @MaId
                      AND VADatum = @VaDatum
                      AND VA_Start = @VaStart";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "VaId", VaId!.Value },
                    { "MaId", ma.MaId },
                    { "VaDatum", VaDatum!.Value },
                    { "VaStart", VaStart ?? TimeSpan.Zero }
                });
            }

            await LoadVerfuegbareMitarbeiterAsync();
            await LoadZugeordneteMitarbeiterAsync();
            OnPropertyChanged(nameof(ZugeordnetCount));

            ShowSuccess("Mitarbeiter entfernt");
            SelectedZugeordnete.Clear();
            UpdateCanCommands();
        }, "Entferne Mitarbeiter...");
    }

    [RelayCommand]
    private async Task AlleZuordnenAsync()
    {
        await ZuordnenAlleAsync();
    }

    [RelayCommand]
    private async Task AlleEntfernenAsync()
    {
        if (ZugeordneteMitarbeiter.Count == 0)
        {
            ShowError("Keine zugeordneten Mitarbeiter");
            return;
        }

        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Alle entfernen",
            $"Moechten Sie alle {ZugeordneteMitarbeiter.Count} Mitarbeiter von dieser Schicht entfernen?");

        if (!confirmed) return;

        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                DELETE FROM tbl_MA_VA_Planung
                WHERE VA_ID = @VaId
                  AND VADatum = @VaDatum
                  AND VA_Start = @VaStart";

            await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
            {
                { "VaId", VaId!.Value },
                { "VaDatum", VaDatum!.Value },
                { "VaStart", VaStart ?? TimeSpan.Zero }
            });

            await LoadVerfuegbareMitarbeiterAsync();
            await LoadZugeordneteMitarbeiterAsync();
            OnPropertyChanged(nameof(ZugeordnetCount));

            ShowSuccess("Alle Mitarbeiter entfernt");
        }, "Entferne alle Mitarbeiter...");
    }

    #endregion

    #region Public Methods

    public void UpdateCanCommands()
    {
        CanZuordnen = SelectedVerfuegbare.Count > 0;
        CanEntfernen = SelectedZugeordnete.Count > 0;
    }

    #endregion
}

#region Helper Classes

public class VerfuegbarerMitarbeiterItem
{
    public int MaId { get; set; }
    public string Nachname { get; set; } = string.Empty;
    public string Vorname { get; set; } = string.Empty;
    public string? TelMobil { get; set; }
    public bool IstAktiv { get; set; }
    public string? Qualifikation { get; set; }
    public string? Anstellungsart { get; set; }
    public bool HasQualification34a { get; set; }
    public bool HasFuehrerschein { get; set; }

    public string FullName => $"{Vorname} {Nachname}";
    public string DisplayName => $"{Nachname}, {Vorname}";
    public string DisplayText => $"{Nachname}, {Vorname}{(string.IsNullOrEmpty(TelMobil) ? "" : $" ({TelMobil})")}";
}

public class ZugeordneterMitarbeiterItem
{
    public int MaId { get; set; }
    public string Nachname { get; set; } = string.Empty;
    public string Vorname { get; set; } = string.Empty;
    public string? TelMobil { get; set; }
    public TimeSpan? VaStart { get; set; }
    public TimeSpan? VaEnde { get; set; }
    public string? Funktion { get; set; }

    public string FullName => $"{Vorname} {Nachname}";
    public string DisplayName => $"{Nachname}, {Vorname}";
    public string ZeitText => $"{VaStart:hh\\:mm} - {VaEnde:hh\\:mm}";
}

public class QualifikationItem
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
}

public class AuftragAuswahlItem
{
    public int VaId { get; set; }
    public int VaDatumId { get; set; }
    public string DisplayText { get; set; } = string.Empty;
    public DateTime VaDatum { get; set; }
}

public class DatumAuswahlItem
{
    public int VaDatumId { get; set; }
    public DateTime Datum { get; set; }
    public string DatumText => Datum.ToString("dd.MM.yyyy");
}

public class ZeitItem
{
    public int VAStartId { get; set; }
    public TimeSpan Start { get; set; }
    public TimeSpan Ende { get; set; }
    public int Ist { get; set; }
    public int Soll { get; set; }
    public string ZeitText => $"{Start:hh\\:mm} - {Ende:hh\\:mm}";
}

public class ParallelEinsatzItem
{
    public int VaId { get; set; }
    public string Auftrag { get; set; } = string.Empty;
    public string Objekt { get; set; } = string.Empty;
    public string Ort { get; set; } = string.Empty;
    public string DisplayText => $"{Auftrag} - {Objekt} ({Ort})";
}

public class AnstellungsartItem
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
}

#endregion
