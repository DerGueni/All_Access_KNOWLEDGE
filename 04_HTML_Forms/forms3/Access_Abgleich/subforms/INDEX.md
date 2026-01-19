# Unterformulare - Index

## Uebersicht

Diese Dokumentation enthaelt alle 16 HTML-Unterformulare mit Abgleich zu den Access-Originalformularen.

| Nr | Unterformular | Access-Name | Hauptverwendung |
|----|---------------|-------------|-----------------|
| 1 | [sub_DP_Grund](sub_DP_Grund.md) | sub_DP_Grund | Dienstplan-Gruende (Urlaub, Krank, etc.) |
| 2 | [sub_DP_Grund_MA](sub_DP_Grund_MA.md) | sub_DP_Grund_MA | MA-spezifische Dienstplan-Gruende |
| 3 | [sub_MA_Dienstplan](sub_MA_Dienstplan.md) | sub_MA_Dienstplan | Dienstplan eines Mitarbeiters |
| 4 | [sub_MA_Jahresuebersicht](sub_MA_Jahresuebersicht.md) | sub_MA_Jahresuebersicht | Jahresuebersicht Stunden |
| 5 | [sub_MA_Offene_Anfragen](sub_MA_Offene_Anfragen.md) | sub_MA_Offene_Anfragen | Offene Planungsanfragen |
| 6 | [sub_MA_Rechnungen](sub_MA_Rechnungen.md) | sub_MA_Rechnungen | MA-Lohnabrechnungen |
| 7 | [sub_MA_Stundenuebersicht](sub_MA_Stundenuebersicht.md) | sub_MA_Stundenuebersicht | Stunden pro Tag |
| 8 | [sub_MA_VA_Planung_Absage](sub_MA_VA_Planung_Absage.md) | sub_MA_VA_Planung_Absage | Absagen fuer Auftrag |
| 9 | [sub_MA_VA_Planung_Status](sub_MA_VA_Planung_Status.md) | sub_MA_VA_Planung_Status | Planungsstatus MA |
| 10 | [sub_MA_VA_Zuordnung](sub_MA_VA_Zuordnung.md) | sub_MA_VA_Zuordnung | MA-Zuordnung zu Auftraegen |
| 11 | [sub_MA_Zeitkonto](sub_MA_Zeitkonto.md) | sub_tbl_MA_Zeitkonto | Zeitkonto-Salden |
| 12 | [sub_OB_Objekt_Positionen](sub_OB_Objekt_Positionen.md) | sub_OB_Objekt_Positionen | Objekt-Positionen |
| 13 | [sub_rch_Pos](sub_rch_Pos.md) | sub_Rch_Pos_Auftrag | Rechnungspositionen |
| 14 | [sub_VA_Einsatztage](sub_VA_Einsatztage.md) | tbl_VA_AnzTage | Einsatztage eines Auftrags |
| 15 | [sub_VA_Schichten](sub_VA_Schichten.md) | sub_VA_Start | Schichten pro Tag |
| 16 | [sub_ZusatzDateien](sub_ZusatzDateien.md) | sub_ZusatzDateien | Dateianhange |

## Einbettungs-Matrix

### frm_va_auftragstamm (Auftragsformular)

| Control-Name | SourceObject | LinkMasterFields | LinkChildFields |
|--------------|--------------|------------------|-----------------|
| sub_MA_VA_Zuordnung | sub_MA_VA_Zuordnung | ID, cboVADatum | VA_ID, VADatum_ID |
| sub_VA_Start | sub_VA_Start | ID, cboVADatum | VA_ID, VADatum_ID |
| sub_MA_VA_Planung_Absage | sub_MA_VA_Planung_Absage | ID, cboVADatum | VA_ID, VADatum_ID |
| sub_MA_VA_Zuordnung_Status | sub_MA_VA_Planung_Status | ID, cboVADatum | VA_ID, VADatum_ID |
| sub_ZusatzDateien | sub_ZusatzDateien | Objekt_ID, TabellenNr | Ueberordnung, TabellenID |
| sub_tbl_Rch_Kopf | sub_tbl_Rch_Kopf | ID | VA_ID |
| sub_tbl_Rch_Pos_Auftrag | sub_tbl_Rch_Pos_Auftrag | ID | VA_ID |

### frm_OB_Objekt (Objektformular)

| Control-Name | SourceObject | LinkMasterFields | LinkChildFields |
|--------------|--------------|------------------|-----------------|
| sub_OB_Objekt_Positionen | sub_OB_Objekt_Positionen | ID | OB_Objekt_Kopf_ID |
| sub_ZusatzDateien | sub_ZusatzDateien | ID, TabellenNr | Ueberordnung, TabellenID |

### frm_DP_Dienstplan_Objekt (Dienstplan Objekt)

| Control-Name | SourceObject | LinkMasterFields | LinkChildFields |
|--------------|--------------|------------------|-----------------|
| sub_DP_Grund | sub_DP_Grund | - | - |

### frm_DP_Dienstplan_MA (Dienstplan MA)

| Control-Name | SourceObject | LinkMasterFields | LinkChildFields |
|--------------|--------------|------------------|-----------------|
| sub_DP_Grund | sub_DP_Grund_MA | - | - |

### frm_MA_Offene_Anfragen

| Control-Name | SourceObject | LinkMasterFields | LinkChildFields |
|--------------|--------------|------------------|-----------------|
| sub_MA_Offene_Anfragen | sub_MA_Offene_Anfragen | - | - |

## JSON-Quellen

Die Dokumentation basiert auf folgenden JSON-Export-Dateien:

- **30_forms/**: FRM_sub_*.json - Formular-Definitionen
- **35_subforms/**: FRM_*__subcontrols.json - Einbettungs-Informationen
- **Export_seit_08Nov*/Forms/**: sub_*.txt - Access-Textexporte

Pfad: `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\11_json_Export\000_Consys_Eport_11_25\`

## Namenskonventionen

| Access | HTML | Bemerkung |
|--------|------|-----------|
| sub_VA_Start | sub_VA_Schichten | Umbenannt fuer Klarheit |
| sub_tbl_MA_Zeitkonto | sub_MA_Zeitkonto | Vereinfacht |
| sub_Rch_Pos_Auftrag | sub_rch_Pos | Vereinfacht |

## Erstellt

Datum: 2026-01-12
Quelle: JSON-Export November 2025
