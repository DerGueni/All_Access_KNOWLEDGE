# Access-Formulare Master-Inventar

**Exportiert:** 2026-01-12
**Anzahl Formulare:** 53 (37 Haupt + 16 Sub)
**Anzahl Controls gesamt:** 1,209
**Anzahl Events gesamt:** 46

## Übersicht nach Kategorie

### Auftraege (9 Formulare: 4 Haupt + 5 Sub)

| Formular | Typ | Controls | Events | Buttons | TextBoxen | ComboBoxen | RecordSource |
|----------|-----|----------|--------|---------|-----------|------------|--------------|
| frmTop_VA_Akt_Objekt_Kopf | Haupt | 0 | 0 | 0 | 0 | 0 |  |
| frm_MA_VA_Positionszuordnung | Haupt | 0 | 2 | 0 | 0 | 0 |  |
| frm_MA_VA_Schnellauswahl | Haupt | 0 | 3 | 0 | 0 | 0 |  |
| frm_VA_Auftragstamm | Haupt | 136 | 4 | 45 | 19 | 13 | qry_Auftrag_Sort (query) |
| sub_MA_VA_Planung_Absage | Sub | 0 | 0 | 0 | 0 | 0 | qry_MA_Plan_Absage |
| sub_MA_VA_Planung_Status | Sub | 0 | 0 | 0 | 0 | 0 | qry_MA_Plan |
| sub_MA_VA_Zuordnung | Sub | 0 | 0 | 0 | 0 | 0 | tbl_MA_VA_Zuordnung (oder tbl_MA_VA_Planung) |
| sub_VA_Einsatztage | Sub | 0 | 0 | 0 | 0 | 0 | tbl_VA_AnzTage oder qry_VA_Einsatztage |
| sub_VA_Schichten | Sub | 0 | 0 | 0 | 0 | 0 | SELECT tbl_VA_Start.* FROM tbl_VA_Start ORDER BY t... |

**Summe:** 136 Controls, 9 Events, 45 Buttons

### Dienstplan (4 Formulare: 2 Haupt + 2 Sub)

| Formular | Typ | Controls | Events | Buttons | TextBoxen | ComboBoxen | RecordSource |
|----------|-----|----------|--------|---------|-----------|------------|--------------|
| frm_DP_Dienstplan_MA | Haupt | 30 | 0 | 12 | 10 | 1 | (keine) |
| frm_DP_Dienstplan_Objekt | Haupt | 17 | 3 | 0 | 10 | 0 | Keine (ungebunden) |
| sub_DP_Grund | Sub | 0 | 0 | 0 | 0 | 0 | qry_DP_Grund oder tbl_DP_Gruende |
| sub_DP_Grund_MA | Sub | 0 | 0 | 0 | 0 | 0 | qry_DP_Grund_MA |

**Summe:** 47 Controls, 3 Events, 12 Buttons

### Dokumente (4 Formulare: 3 Haupt + 1 Sub)

| Formular | Typ | Controls | Events | Buttons | TextBoxen | ComboBoxen | RecordSource |
|----------|-----|----------|--------|---------|-----------|------------|--------------|
| frmTop_RechnungsStamm | Haupt | 127 | 2 | 15 | 42 | 9 | tbl_Rch_Kopf |
| frm_Ausweis_Create | Haupt | 7 | 2 | 0 | 0 | 0 | Keine (ungebunden) |
| zfrm_Lohnabrechnungen | Haupt | 21 | 1 | 2 | 6 | 3 | SELECT * FROM zqry_Lohnabrechnungen WHERE Jahr = 2... |
| sub_rch_Pos | Sub | 0 | 0 | 0 | 0 | 0 | tbl_Rch_Pos oder qry_Rch_Pos_Auftrag |

**Summe:** 155 Controls, 5 Events, 17 Buttons

### Kunden (2 Formulare: 2 Haupt + 0 Sub)

| Formular | Typ | Controls | Events | Buttons | TextBoxen | ComboBoxen | RecordSource |
|----------|-----|----------|--------|---------|-----------|------------|--------------|
| frmTop_KD_Adressart | Haupt | 9 | 0 | 0 | 0 | 0 |  |
| frm_KD_Kundenstamm | Haupt | 187 | 4 | 17 | 70 | 9 | SELECT tbl_KD_Kundenstamm.* FROM tbl_KD_Kundenstam... |

**Summe:** 196 Controls, 4 Events, 17 Buttons

### Mitarbeiter (15 Formulare: 9 Haupt + 6 Sub)

| Formular | Typ | Controls | Events | Buttons | TextBoxen | ComboBoxen | RecordSource |
|----------|-----|----------|--------|---------|-----------|------------|--------------|
| frmTop_DP_MA_Auftrag_Zuo | Haupt | 0 | 0 | 0 | 0 | 0 |  |
| frmTop_MA_Abwesenheitsplanung | Haupt | 0 | 0 | 0 | 0 | 0 |  |
| frm_MA_Abwesenheiten_Urlaub_Gueni | Haupt | 0 | 0 | 0 | 0 | 0 |  |
| frm_MA_Maintainance | Haupt | 30 | 2 | 11 | 2 | 3 | - |
| frm_MA_Mitarbeiterstamm | Haupt | 290 | 5 | 41 | 70 | 17 | tbl_MA_Mitarbeiterstamm (table) |
| frm_MA_Offene_Anfragen | Haupt | 0 | 0 | 0 | 0 | 0 |  |
| frm_MA_Serien_eMail_Auftrag | Haupt | 0 | 2 | 0 | 0 | 0 |  |
| frm_MA_Serien_eMail_dienstplan | Haupt | 0 | 2 | 0 | 0 | 0 |  |
| zfrm_MA_Stunden_Lexware | Haupt | 29 | 1 | 10 | 6 | 3 | SELECT tbl_MA_Mitarbeiterstamm.* FROM tbl_MA_Mitar... |
| sub_MA_Dienstplan | Sub | 0 | 0 | 0 | 0 | 0 | qry_MA_Dienstplan oder tbl_MA_VA_Planung |
| sub_MA_Jahresuebersicht | Sub | 0 | 0 | 0 | 0 | 0 | qry_MA_Jahresuebersicht |
| sub_MA_Offene_Anfragen | Sub | 0 | 0 | 0 | 0 | 0 | qry_MA_Offene_Anfragen |
| sub_MA_Rechnungen | Sub | 0 | 0 | 0 | 0 | 0 | qry_MA_Rechnungen oder tbl_MA_Rechnungen |
| sub_MA_Stundenuebersicht | Sub | 0 | 0 | 0 | 0 | 0 | qry_MA_Stundenuebersicht |
| sub_MA_Zeitkonto | Sub | 0 | 0 | 0 | 0 | 0 | tbl_MA_Zeitkonto oder qry_MA_Zeitkonto |

**Summe:** 349 Controls, 12 Events, 62 Buttons

### Objekte (2 Formulare: 1 Haupt + 1 Sub)

| Formular | Typ | Controls | Events | Buttons | TextBoxen | ComboBoxen | RecordSource |
|----------|-----|----------|--------|---------|-----------|------------|--------------|
| frm_OB_Objekt | Haupt | 49 | 3 | 15 | 15 | 0 | tbl_OB_Objekt (table) |
| sub_OB_Objekt_Positionen | Sub | 0 | 0 | 0 | 0 | 0 | SELECT tbl_OB_Objekt_Positionen.* FROM tbl_OB_Obje... |

**Summe:** 49 Controls, 3 Events, 15 Buttons

### Sonstiges (13 Formulare: 12 Haupt + 1 Sub)

| Formular | Typ | Controls | Events | Buttons | TextBoxen | ComboBoxen | RecordSource |
|----------|-----|----------|--------|---------|-----------|------------|--------------|
| frm_Abwesenheiten | Haupt | 18 | 0 | 0 | 13 | 0 | qry_MA_Abwesend Tag |
| frm_Einsatzuebersicht | Haupt | 24 | 0 | 0 | 0 | 0 | qry_Einsatzuebersicht_kpl |
| frm_Kundenpreise | Haupt | 5 | 1 | 1 | 3 | 0 | _Auswertung_Sub_Kundenpreise |
| frm_Kundenpreise_gueni | Haupt | 20 | 0 | 0 | 11 | 0 | qry_Kundenpreise_gueni2 |
| frm_Menuefuehrung1 | Haupt | 1 | 0 | 0 | 0 | 0 | Keine (ungebunden) |
| frm_MitarbeiterstammTabelle | Haupt | 0 | 0 | 0 | 0 | 0 |  |
| frm_Rueckmeldestatistik | Haupt | 14 | 2 | 0 | 8 | 0 | zqry_Rueckmeldungen |
| frm_Startmenue | Haupt | 4 | 0 | 4 | 0 | 0 | - |
| frm_Systeminfo | Haupt | 34 | 2 | 0 | 20 | 0 | Keine (ungebunden) |
| frm_Umsatzuebersicht_2 | Haupt | 30 | 0 | 0 | 15 | 0 | _Umsatz_Gesamt |
| frm_Zeiterfassung | Haupt | 18 | 1 | 7 | 2 | 1 | - |
| frm_abwesenheitsuebersicht | Haupt | 43 | 0 | 0 | 30 | 0 | qry_DP_MA_NVerfueg |
| sub_ZusatzDateien | Sub | 0 | 0 | 0 | 0 | 0 | tbl_ZusatzDateien |

**Summe:** 211 Controls, 6 Events, 12 Buttons

### System (4 Formulare: 4 Haupt + 0 Sub)

| Formular | Typ | Controls | Events | Buttons | TextBoxen | ComboBoxen | RecordSource |
|----------|-----|----------|--------|---------|-----------|------------|--------------|
| frmOff_Outlook_aufrufen | Haupt | 51 | 2 | 10 | 7 | 6 | - |
| frmTop_Geo_Verwaltung | Haupt | 5 | 0 | 5 | 0 | 0 | - |
| zfrm_Rueckmeldungen | Haupt | 10 | 2 | 0 | 4 | 0 | zqry_Rueckmeldungen |
| zfrm_SyncError | Haupt | 0 | 0 | 0 | 0 | 0 |  |

**Summe:** 66 Controls, 4 Events, 15 Buttons

## Control-Statistik

| Control-Typ | Anzahl Gesamt | Mit Events | Durchschnitt pro Formular |
|-------------|---------------|------------|---------------------------|
| CommandButton | 195 | 11 | 3.7 |
| TextBox | 363 | - | 6.8 |
| ComboBox | 65 | - | 1.2 |
| Label | 465 | - | 8.8 |
| SubForm | 0 | - | 0.0 |
| ListBox | 9 | - | 0.2 |
| TabControl | 4 | - | 0.1 |

## Event-Statistik

| Event-Typ | Anzahl | Häufigste Formulare |
|-----------|--------|---------------------|
| OnLoad | 14 | frmOff_Outlook_aufrufen (1), frmTop_RechnungsStamm (1), frm_Ausweis_Create (1) |
| OnOpen | 9 | frmOff_Outlook_aufrufen (1), frm_Ausweis_Create (1), frm_DP_Dienstplan_Objekt (1) |
| OnCurrent | 5 | frmTop_RechnungsStamm (1), frm_KD_Kundenstamm (1), frm_MA_Mitarbeiterstamm (1) |
| BeforeUpdate | 4 | frm_KD_Kundenstamm (1), frm_MA_Mitarbeiterstamm (1), frm_OB_Objekt (1) |
| **OnLoad** | 4 | frm_MA_Serien_eMail_Auftrag (1), frm_MA_Serien_eMail_dienstplan (1), frm_MA_VA_Positionszuordnung (1) |
| OnClose | 3 | frm_DP_Dienstplan_Objekt (1), frm_Rueckmeldestatistik (1), zfrm_Rueckmeldungen (1) |
| **OnOpen** | 3 | frm_MA_Serien_eMail_Auftrag (1), frm_MA_Serien_eMail_dienstplan (1), frm_MA_VA_Schnellauswahl (1) |
| AfterUpdate | 2 | frm_KD_Kundenstamm (1), frm_MA_Mitarbeiterstamm (1) |
| **OnCurrent** | 1 | frm_MA_VA_Positionszuordnung (1) |
| **OnClose** | 1 | frm_MA_VA_Schnellauswahl (1) |

## Top 10 Größte Formulare

| Rang | Formular | Typ | Controls | Events | Buttons | VBA-Zeilen (geschätzt) |
|------|----------|-----|----------|--------|---------|------------------------|
| 1 | frm_MA_Mitarbeiterstamm | Haupt | 290 | 5 | 41 | 250 |
| 2 | frm_KD_Kundenstamm | Haupt | 187 | 4 | 17 | 200 |
| 3 | frm_VA_Auftragstamm | Haupt | 136 | 4 | 45 | 200 |
| 4 | frmTop_RechnungsStamm | Haupt | 127 | 2 | 15 | 100 |
| 5 | frmOff_Outlook_aufrufen | Haupt | 51 | 2 | 10 | 100 |
| 6 | frm_OB_Objekt | Haupt | 49 | 3 | 15 | 150 |
| 7 | frm_abwesenheitsuebersicht | Haupt | 43 | 0 | 0 | 0 |
| 8 | frm_Systeminfo | Haupt | 34 | 2 | 0 | 100 |
| 9 | frm_DP_Dienstplan_MA | Haupt | 30 | 0 | 12 | 0 |
| 10 | frm_MA_Maintainance | Haupt | 30 | 2 | 11 | 100 |

## Top 10 Komplexeste Formulare (nach Events)

| Rang | Formular | Typ | Events | VBA-Zeilen (geschätzt) | Controls | Event-Typen |
|------|----------|-----|--------|------------------------|----------|-------------|
| 1 | frm_MA_Mitarbeiterstamm | Haupt | 5 | 250 | 290 | OnOpen, OnLoad, OnCurrent, BeforeUpdate,... |
| 2 | frm_KD_Kundenstamm | Haupt | 4 | 200 | 187 | OnLoad, OnCurrent, BeforeUpdate, AfterUp... |
| 3 | frm_VA_Auftragstamm | Haupt | 4 | 200 | 136 | OnOpen, OnLoad, OnCurrent, BeforeUpdate |
| 4 | frm_DP_Dienstplan_Objekt | Haupt | 3 | 150 | 17 | OnOpen, OnLoad, OnClose |
| 5 | frm_MA_VA_Schnellauswahl | Haupt | 3 | 150 | 0 | **OnOpen**, **OnLoad**, **OnClose** |
| 6 | frm_OB_Objekt | Haupt | 3 | 150 | 49 | OnOpen, OnLoad, BeforeUpdate |
| 7 | frmOff_Outlook_aufrufen | Haupt | 2 | 100 | 51 | OnOpen, OnLoad |
| 8 | frmTop_RechnungsStamm | Haupt | 2 | 100 | 127 | OnLoad, OnCurrent |
| 9 | frm_Ausweis_Create | Haupt | 2 | 100 | 7 | OnOpen, OnLoad |
| 10 | frm_MA_Maintainance | Haupt | 2 | 100 | 30 | OnOpen, OnLoad |

## Top 10 Button-reichste Formulare

| Rang | Formular | Typ | Buttons | Controls Gesamt | Button-Anteil |
|------|----------|-----|---------|-----------------|---------------|
| 1 | frm_VA_Auftragstamm | Haupt | 45 | 136 | 33.1% |
| 2 | frm_MA_Mitarbeiterstamm | Haupt | 41 | 290 | 14.1% |
| 3 | frm_KD_Kundenstamm | Haupt | 17 | 187 | 9.1% |
| 4 | frmTop_RechnungsStamm | Haupt | 15 | 127 | 11.8% |
| 5 | frm_OB_Objekt | Haupt | 15 | 49 | 30.6% |
| 6 | frm_DP_Dienstplan_MA | Haupt | 12 | 30 | 40.0% |
| 7 | frm_MA_Maintainance | Haupt | 11 | 30 | 36.7% |
| 8 | frmOff_Outlook_aufrufen | Haupt | 10 | 51 | 19.6% |
| 9 | zfrm_MA_Stunden_Lexware | Haupt | 10 | 29 | 34.5% |
| 10 | frm_Zeiterfassung | Haupt | 7 | 18 | 38.9% |

## Zusammenfassung

- **Gesamtzahl Formulare:** 53 (37 Hauptformulare, 16 Subformulare)
- **Gesamtzahl Controls:** 1,209
- **Gesamtzahl Events:** 46
- **Gesamtzahl Buttons:** 195
- **Durchschnitt Controls pro Formular:** 22.8
- **Durchschnitt Events pro Formular:** 0.9
- **Geschätzte VBA-Zeilen gesamt:** 2,300

**Kategorien:**
- **Auftraege:** 9 Formulare, 136 Controls, 9 Events
- **Dienstplan:** 4 Formulare, 47 Controls, 3 Events
- **Dokumente:** 4 Formulare, 155 Controls, 5 Events
- **Kunden:** 2 Formulare, 196 Controls, 4 Events
- **Mitarbeiter:** 15 Formulare, 349 Controls, 12 Events
- **Objekte:** 2 Formulare, 49 Controls, 3 Events
- **Sonstiges:** 13 Formulare, 211 Controls, 6 Events
- **System:** 4 Formulare, 66 Controls, 4 Events

---

*Generiert aus Access-Export JSON-Dateien*