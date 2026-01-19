# REPORT_OVERVIEW

Stand: 2025-12-29
Quelle: Screenshots in `C:\Users\guenther.siegert\Documents\Screenshots`

## Ergebnis (Kurz)
- frm_va_Auftragstamm: MISMATCH (Layout/Optik stark abweichend; Tabs/Subforms und Header fehlen).
- frm_MA_Mitarbeiterstamm: PARTIAL (Daten sichtbar, aber Header/Buttons/Optik abweichend).
- frm_KD_Kundenstamm: PARTIAL (Grundlayout ok, Listenspalten/Labels/Optik weichen ab).
- frm_MA_VA_Schnellauswahl: PARTIAL (Struktur vorhanden, jedoch Anordnung/Buttons/Listen abweichend).
- frm_N_Dienstplanuebersicht: MISMATCH (Kalender/Tabelle in HTML leer).
- frm_VA_Planungsuebersicht vs frm_DP_Dienstplan_Objekt: MISMATCH (Tabelle leer, Struktur abweichend).

## Hauptabweichungen (Top 6)
1) Bridge-Importpfad in `_Codes/logic` war falsch (keine Datenbindung/Events). Fix umgesetzt.
2) Dienstplanuebersicht: HTML rendert keine Kalender-Tabelle/Daten.
3) Planungsuebersicht: Tabelle bleibt leer, Access zeigt Daten.
4) Auftragstamm: fehlende Tab-Struktur (Einsatzliste/Antworten/Rechnung) und sichtbare Header-Buttons.
5) Mitarbeiterstamm: Header-Aktionsbuttons fehlen; Farb-/Header-Stil weicht stark ab.
6) Kundenstamm: Listen-Spalten (Kontaktfelder) fehlen; Such-/Filter-Layout abweichend.

## Naechste Schritte (kurz)
- Dienstplanuebersicht/Planungsuebersicht: Datenbindung nach Bridge-Fix neu testen.
- Auftragstamm/Mitarbeiterstamm: Header + Tabs + Buttons optisch/strukturell an Access angleichen.
- Schnellauswahl: E-Mail-Button-Funktion (nur Testadresse) pruefen und Layout angleichen.
