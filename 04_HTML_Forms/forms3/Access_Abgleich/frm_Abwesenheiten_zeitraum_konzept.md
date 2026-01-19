# frm_Abwesenheiten – Zeitraum vs. Tag

## Beobachtungen
- Access-Query `qry_MA_Abwesend Tag` erzeugt **ein Datensatz pro Kalendertag** und Zeittyp. Mehrtaegige Abwesenheiten werden also bereits in Access als Tagesliste dargestellt.
- Web-Frontend (`forms3`) und `/api/abwesenheiten` arbeiten dagegen nativ mit **Zeitraeumen (vonDat/bisDat)** sowie optionalem Flag `Ganztaegig`.
- Folge: Wenn das Web-Frontend einen Zeitraum 10.–12.01. speichert, existiert zwar ein Eintrag in `tbl_MA_NVerfuegZeiten`, aber kein tagesbasierter Datensatz wie ihn Access-Reports erwarten.

## Anwendungsfaelle
1. **Planung/Anzeige** – Zeitraumdarstellung ist benutzerfreundlich und soll beibehalten werden.
2. **Reporting/Legacy** – Access-Reports, Makros und ggf. VBA-Module rechnen mit `qry_MA_Abwesend Tag` (Tagesebene). Ohne Expansion koennen dort Luecken entstehen.

## Optionen
| Option | Beschreibung | Vor-/Nachteile |
| --- | --- | --- |
| A. Server-seitige Expansion | API liefert zweiten Endpoint `/api/abwesenheiten/tage` der jeden Zeitraum in Tageszeilen expandiert. | + Keine Aenderung im Frontend; + Access kann direkt via REST migrieren; − Leichte Mehrbelastung im Backend. |
| B. Client-seitige Expansion | Frontend erzeugt Tagesliste fuer Filter und Reports. | + Schnell; − Fuehrt zu doppelter Logik, Access-Clients profitieren nicht. |
| C. Tabelle duplizieren | Beim Speichern wird neben `tbl_MA_NVerfuegZeiten` eine FE-Tabelle mit Tagesdatensaetzen befuellt. | + Voll kompatibel zu Legacy; − Synchronisations- und Konsistenzrisiken. |

## Vorschlag
- **Kurzfristig:** Option A implementieren. Ergänze `/api/abwesenheiten` um Query-Parameter `view=tagesliste`. Bei Aktivierung wird jeder Zeitraum in einzelne Tage expanded (unter Nutzung von Access SQL `SELECT DateAdd('d', n, vonDat)` via Hilfstabelle oder Python-Loop vor JSON-Rueckgabe).
- **Frontend:** Filter/Anzeige bleiben unveraendert. Nur Export/Reporting-Buttons verwenden die Tagesansicht.
- **Langfristig:** Datenmodell so erweitern, dass `Zeittyp_ID` und `Ganztaegig` gemeinsam gepflegt werden (Mapping siehe [frm_Abwesenheiten_data_map.md](frm_Abwesenheiten_data_map.md)).

## Umsetzungsschritte
1. Backend-Funktion `get_abwesenheiten()` anpassen: falls Query-Flag gesetzt, expandiere Zeitraeume in Tageszeilen (`AbwDat`, `Zeittyp_ID`, Name).
2. Tests fuer beide Modi erstellen (siehe API-Testplan).
3. Optional: Access-Query `qry_MA_Abwesend Tag` durch REST-Aufruf ersetzen oder um Felder `vonDat/bisDat` erweitern, sobald Tagesendpoint verifiziert ist.
