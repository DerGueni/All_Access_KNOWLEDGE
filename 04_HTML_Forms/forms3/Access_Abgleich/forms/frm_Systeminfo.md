# _frmHlp_SysInfo (Systeminfo)

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | _frmHlp_SysInfo |
| **Datensatzquelle** | Keine (ungebunden) |
| **Datenquellentyp** | None |
| **Default View** | Other |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |
| **Data Entry** | Nein |
| **Navigation Buttons** | Nein |
| **Dividing Lines** | Ja |

## Controls

### Labels (Bezeichnungsfelder)

| Name | Position (L/T) | Groesse (W/H) | Beschreibung |
|------|----------------|---------------|--------------|
| Auto_Kopfzeile0 | 165 / 135 | 3930 x 465 | Formular-Titel |
| lbl_Datum | 7848 / 159 | 930 x 240 | Datum-Anzeige |
| Text80 | 2693 / 70 | 720 x 240 | Windows-Info Label |
| Text81 | 283 / 35 | 390 x 240 | PC-Info Label |
| Label165 | 3632 / 105 | 1635 x 240 | - |
| Text63 | 5746 / 35 | 1575 x 240 | Hardware-Info Label |
| Text92 | 5732 / 3054 | 1680 x 225 | Bildschirm-Info Label |
| Text153 | 2852 / 1311 | 1665 x 210 | Festplatten-Label |
| Label172 | 141 / 2214 | 1665 x 210 | Access-Info Label |
| lbl_64bit | 7410 / 124 | 1405 x 265 | 64-bit Anzeige |
| lbl_DB | 110 / 6165 | 8744 x 586 | Datenbank-Pfad |
| Bezeichnungsfeld218 | 106 / 6909 | 1875 x 240 | SQL BE Label |
| Bezeichnungsfeld219 | 124 / 5864 | 900 x 240 | Backend-Label |
| Bezeichnungsfeld221 | 106 / 8154 | 1575 x 240 | Access BE Label |

### CommandButtons

| Name | Position (L/T) | Groesse (W/H) | Funktion |
|------|----------------|---------------|----------|
| cmdOK | 6625 / 106 | 771 x 396 | OK/Schliessen |
| btnHelp | 5917 / 0 | 576 x 576 | Hilfe |
| btnMSInfo | 5702 / 5394 | 771 x 336 | MS Info (unsichtbar) |

### ComboBox

| Name | Row Source | Position (L/T) | Groesse (W/H) | Default |
|------|------------|----------------|---------------|---------|
| Drive | A-Z Laufwerke | 321 / 1588 | 540 x 255 | "C" |

### TextBoxen (Systeminformationen)

| Name | Control Source | Beschreibung |
|------|----------------|--------------|
| NUMCOLORS | =atGetColourCap() | Farbtiefe |
| HORZRES | =atgetdevcaps(8) | Horizontale Aufloesung |
| VERTRES | =atgetdevcaps(10) | Vertikale Aufloesung |
| VERTSIZE | =atgetdevcaps(6) | Vertikale Groesse (mm) |
| HORZSIZE | =atgetdevcaps(4) | Horizontale Groesse (mm) |
| Field122 | =atWinVer(0) & "." & atWinver(1) & " / " & atWinver(2) | Windows-Version |
| WinV | =atWinVer(3) | Windows-Variante |
| Text202 | =atWinver(4) | Windows-Edition |
| Free | =atDiskfreespaceEx(Form!Drive) | Freier Speicherplatz |
| Field132 | =AccessInfo() | Access-Informationen |
| Text192 | =atCNames(1) | Computer-Name |
| Text194 | =atCNames(2) | Benutzername |
| GetIP | =GetIPAddress() | Lokale IP-Adresse |
| PublicIP | - | Oeffentliche IP |
| Text156 | =atGetSysStatus(2) | System-Status 1 |
| Text158 | =atGetSysStatus(1) | System-Status 2 |
| TotMemP | =CLng((atGetMemEx(1)/1048576)) & " MB" | Gesamtspeicher |
| Text205 | =GetCPUSpeedName(1) | CPU-Geschwindigkeit |
| Text207 | =GetCPUSpeedName(2) | CPU-Name |
| Text198 | =Date() | Aktuelles Datum |

### ListBoxen

| Name | Row Source | Position (L/T) | Groesse (W/H) | Beschreibung |
|------|------------|----------------|---------------|--------------|
| ListeBESQL | qrymdbTable2sql_DB | 128 / 7206 | 8727 x 846 | SQL-Backend-Tabellen |
| ListeBEAcc | qrymdbTable2mdb_DB | 128 / 8454 | 8727 x 846 | Access-Backend-Tabellen |

### Images

| Name | Position (L/T) | Groesse (W/H) | Sichtbar |
|------|----------------|---------------|----------|
| Image196 | 5897 / 3324 | 2115 x 1875 | Ja |
| FixD | 906 / 1588 | 555 x 255 | Ja |
| FlopD | 891 / 1573 | 555 x 270 | Nein |
| NoD | 876 / 1558 | 555 x 300 | Nein |
| NetD | 891 / 1588 | 540 x 255 | Nein |
| CDD | 891 / 1513 | 555 x 345 | Nein |
| OLEUngebunden201 | 8082 / 3357 | 600 x 1560 | Ja |

### Rectangles (Rahmen/Bereiche)

| Name | Position (L/T) | Groesse (W/H) | Beschreibung |
|------|----------------|---------------|--------------|
| Box180 | 141 / 1523 | 4605 x 600 | Laufwerks-Bereich |
| Box21 | 8072 / 3339 | 630 x 1800 | Farb-Anzeige |
| Box190 | 2616 / 73 | 2850 x 1155 | Windows-Info |
| Box191 | 141 / 73 | 2385 x 1365 | PC-Info |
| Box173 | 5687 / 3174 | 3165 x 2175 | Bildschirm-Info |
| Box175 | 5728 / 81 | 3165 x 2910 | Hardware-Info |

## Events

### Formular-Events
- **OnOpen**: Procedure Handler
- **OnLoad**: Procedure Handler
- OnClose: Keine
- **OnTimer**: =api_UpdateSysResInfo() (Expression)

### ComboBox-Events
- Drive.AfterUpdate: Procedure Handler (Laufwerk wechseln)

## Funktionalitaet

Umfassendes System-Informationsformular:

### PC-Informationen:
- Computername
- Benutzername
- IP-Adresse (lokal und oeffentlich)

### Windows-Informationen:
- Windows-Version (Major.Minor / Build)
- Windows-Variante
- Windows-Edition
- 64-bit Anzeige

### Hardware-Informationen:
- CPU-Name und Geschwindigkeit
- Gesamtspeicher (RAM in MB)
- System-Status

### Bildschirm-Informationen:
- Aufloesung (HORZRES x VERTRES)
- Physische Groesse (mm)
- Farbtiefe

### Laufwerks-Informationen:
- Laufwerksauswahl (A-Z)
- Freier Speicherplatz
- Laufwerkstyp-Icons (Fest, Floppy, CD, Netzwerk)

### Access/Datenbank-Informationen:
- Access-Version und Details
- Backend-Pfad
- SQL-Backend-Tabellen (Liste)
- Access-Backend-Tabellen (Liste)

### Timer-Funktion:
- Automatische Aktualisierung der System-Ressourcen
