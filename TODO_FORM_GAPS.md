# TODO: Access -> HTML/WPF Parity

## 1. Aktuelle Gap-Übersicht
Basierend auf `GAP_LIST.csv` ergeben sich folgende Prioritäten:

- **frm_va_Auftragstamm**: Violetter Header mit Buttonleiste, strukturierte Tabs (Einsatzliste/Antworten/Rechnung) sowie rechts die Auftragsliste mitsamt Spalten (Optik & Struktur).
- **frm_MA_Mitarbeiterstamm**: Fehlende Header-Buttons (z. B. Löschen, Transfer, Listen drucken) und abweichende Such-/Filterzeile.
- **frm_KD_Kundenstamm**: Listen mit Kontakt-/Vorname-Spalten, korrekte Abstände und Buttons (Verrechnungssätze, Umsatzauswertung, Speichern).
- **frm_MA_VA_Schnellauswahl**: Nebenmenü, gridartige Listen (geplante Erfassungen, Zusagen) gehen noch nicht, Filter und Aktionen unvollständig.
- **frm_N_Dienstplanuebersicht** & **frm_DP_Dienstplan_MA**: Kalender/Planungsdaten leer, Reports/Tabelle fehlen; der Access-Import steht noch aus.
- **frm_VA_Planungsuebersicht**: Planungstabelle bleibt leer; Report/Plan-Logik muss mit Backend synchronisiert werden.
- **frm_all_backend**: Bridge-Importpfad (API) sorgte bisher für fehlende Datenbindung.

## 2. Weiteres Vorgehen
1. **Priorisieren**: Start bei `frm_va_Auftragstamm` (Critical) → `frm_MA_VA_Schnellauswahl` → Dienstplan/Planung/Geräte.
2. **Funktionalität auflisten**: Für jedes Formular genau dokumentieren, welche Buttons/Ereignisse reportspezifisch sind (z. B. Auftrag Zusage, Dienstplan-Mitarbeiter-Report).
3. **DOM + Logic**: Sicherstellen, dass HTML die IDs/DOM-Struktur für die Logikmodule (`logic/*.js`) bietet; ggf. vorhandene Inline-Skripte durch Module ersetzen.
4. **Backend**: API-Endpunkte (Bridge) abstimmen und testen; ggf. neue Endpoints für Reports hinzufügen.
5. **Test & Dokumentation**: Jeder Punkt ergänzt `WORKLOG.md` und `HTML_FUNCTIONALITY_STATUS.md`.

## 3. Nächste Schritte
- Inventar vervollständigen (s. `GAP_LIST.csv`) und z. B. Buttons für Auftrag Zusage, Dienstplan MA-Reports identifizieren.
- Nach Bestandsaufnahme mit Schritt-für-Schritt Umsetzung beginnen (erste Umsetzung: Auftragstamm-Header/Tabs).
