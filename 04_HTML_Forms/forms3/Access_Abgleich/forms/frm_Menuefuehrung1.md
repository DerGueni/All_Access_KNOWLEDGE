# frm_Menuefuehrung1

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_Menuefuehrung1 |
| **Datensatzquelle** | Keine (ungebunden) |
| **Datenquellentyp** | None |
| **Default View** | Other |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |
| **Data Entry** | Nein |
| **Navigation Buttons** | Nein |

## Controls

### Labels (Bezeichnungsfelder)

| Name | Position (L/T) | Groesse (W/H) | Beschreibung |
|------|----------------|---------------|--------------|
| lbl_Menue2 | 683 / 56 | 1301 x 327 | Menue-Titel mit OnMouseMove Event |

### Rectangles (Rahmen)

| Name | Position (L/T) | Groesse (W/H) | Beschreibung |
|------|----------------|---------------|--------------|
| Rechteck18 | 60 / 0 | 2722 x 2834 | Rahmen Gruppe 1 |
| Rechteck19 | 60 / 1755 | 2721 x 4476 | Rahmen Gruppe 2 |
| Rechteck20 | 60 / 6120 | 2725 x 3510 | Rahmen Gruppe 3 |

### CommandButtons (Menue-Eintraege)

| Name | Position (L/T) | Groesse (W/H) | TabIndex | Sichtbar | OnClick |
|------|----------------|---------------|----------|----------|---------|
| btn_1 | 124 / 1291 | 2580 x 335 | 0 | Ja | Procedure |
| Befehl22 | 124 / 859 | 2580 x 335 | 1 | Ja | Procedure |
| Befehl24 | 120 / 5550 | 2580 x 335 | 2 | Nein | Procedure |
| btnLetzterEinsatz | 116 / 2400 | 2580 x 335 | 3 | Ja | Procedure |
| btn_Abwesenheiten | 120 / 7770 | 2580 x 335 | 4 | Ja | Procedure |
| btnLohnabrech | 120 / 1852 | 2580 x 335 | 5 | Ja | Procedure |
| btnFCN_Meldeliste | 120 / 2955 | 2580 x 335 | 6 | Ja | Procedure |
| btnNamensliste | 120 / 3516 | 2580 x 335 | 7 | Ja | Procedure |
| btnLohnarten | 120 / 7320 | 2580 x 335 | 8 | Ja | Procedure |
| btn_MAStamm_Excel | 113 / 4648 | 2580 x 335 | 9 | Ja | Procedure |
| btn_stunden_sub | 120 / 4095 | 2580 x 335 | 10 | Ja | Procedure |
| Befehl37 | 113 / 5102 | 2580 x 335 | 11 | Ja | Procedure |
| btn_LoewensaalSync | 120 / 6300 | 2580 x 335 | 12 | Ja | Procedure |
| Befehl40 | 390 / 10365 | 2100 x 335 | 13 | Ja | Procedure |
| btn_Loewensaal Sync HP | 120 / 6870 | 2580 x 335 | 14 | Ja | Procedure |
| Btn_Personalvorlagen | 120 / 8505 | 2580 x 335 | 0 | Nein | Procedure |
| btn_menue2_close | 60 / 10095 | 2655 x 405 | 1 | Ja | OnMouseMove |
| btnStundenMA | 120 / 8100 | 2580 x 335 | 2 | Ja | Procedure |

## Farben

| Element | ForeColor | BackColor | BorderColor |
|---------|-----------|-----------|-------------|
| Buttons | 0 (Schwarz) | 14277081 (Hellblau) | 14136213 (Gelb) |
| Close-Button | 0 (Schwarz) | 14277081 (Hellblau) | 14277081 |
| Rahmen | - | 16777215 (Weiss) | 10921638 (Hellgrau) |

## Menue-Struktur

### Gruppe 1 (Rechteck18) - Hauptfunktionen
- Befehl22 (Position 859)
- btn_1 (Position 1291)

### Gruppe 2 (Rechteck19) - Berichte & Listen
- btnLohnabrech (Position 1852) - Lohnabrechnungen
- btnLetzterEinsatz (Position 2400) - Letzter Einsatz
- btnFCN_Meldeliste (Position 2955) - FCN Meldeliste
- btnNamensliste (Position 3516) - Namensliste
- btn_stunden_sub (Position 4095) - Stunden
- btn_MAStamm_Excel (Position 4648) - MA-Stamm Excel
- Befehl37 (Position 5102)
- Befehl24 (Position 5550) - Unsichtbar

### Gruppe 3 (Rechteck20) - Sync & Abwesenheiten
- btn_LoewensaalSync (Position 6300) - Loewensaal Sync
- btn_Loewensaal Sync HP (Position 6870) - Loewensaal Sync HP
- btnLohnarten (Position 7320) - Lohnarten
- btn_Abwesenheiten (Position 7770) - Abwesenheiten
- btnStundenMA (Position 8100) - Stunden MA
- Btn_Personalvorlagen (Position 8505) - Unsichtbar

### Fussbereich
- btn_menue2_close (Position 10095) - Menue schliessen
- Befehl40 (Position 10365)

## Events

### Formular-Events
- OnOpen: Keine
- OnLoad: Keine
- OnClose: Keine
- OnCurrent: Keine

### Button-Events
Alle Buttons haben `OnClick: Procedure Handler` fuer ihre jeweilige Funktion.

### Spezielle Events
- lbl_Menue2: OnMouseMove Procedure
- btn_menue2_close: OnMouseMove Procedure

## Funktionalitaet

Seitenmenue/Navigation fuer das Hauptsystem mit folgenden Funktionen:

### Personal & Lohn:
- Lohnabrechnungen
- Lohnarten
- Stunden (Sub-Formulare)
- Stunden MA
- MA-Stamm Excel-Export

### Berichte:
- Letzter Einsatz
- FCN Meldeliste
- Namensliste

### Synchronisation:
- Loewensaal Sync
- Loewensaal Sync HP

### Zeiterfassung:
- Abwesenheiten
- Personalvorlagen (unsichtbar)

### Layout:
- 3 visuelle Gruppen durch Rechtecke
- Einheitliche Button-Groesse (2580 x 335)
- Hellblaue Hintergrundfarbe fuer Buttons
