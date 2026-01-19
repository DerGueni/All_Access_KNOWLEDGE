# frm_Abwesenheiten – Datenmodell-Abgleich

## Ausgangslage
- **Access-Quelle:** Query `qry_MA_Abwesend Tag` liefert Tagesdatensaetze mit Feldern `Zeittyp_ID`, `AbwDat`, `Nachname`, `Vorname` ([exports/queries/qry_MA_Abwesend Tag.sql](../../../../exports/queries/qry_MA_Abwesend%20Tag.sql)).
- **Web/API:** Endpoint `/api/abwesenheiten` exponiert `tbl_MA_NVerfuegZeiten` inklusive Zusatzfelder wie `vonDat`, `bisDat`, `Grund`, `Bemerkung`, `Ganztaegig` (siehe [consys-codex-knowledge/08_Tools/python/api_server.py](../../../consys-codex-knowledge/08_Tools/python/api_server.py#L1244-L1354)).
- **Frontend (forms3):** Zeigt sowohl eine Liste mit Zeitraum und Grund als auch ein Detailformular mit CRUD-Feldern ([04_HTML_Forms/forms3/frm_Abwesenheiten.html](../frm_Abwesenheiten.html), [logic/frm_Abwesenheiten.logic.js](../logic/frm_Abwesenheiten.logic.js)).

## Feldmapping
| Access / Query | Backend-Quelle | API-Feld | Frontend-Feld | Status |
| --- | --- | --- | --- | --- |
| `Zeittyp_ID` | `tbl_MA_NVerfuegZeiten.Zeittyp_ID` | *(nicht exponiert)* | Dropdown `NV_Grund` (Fixliste) | **Fehlt** – API liefert `Grund` (Text), Query erwartet numerischen Zeittyp; Mapping oder Lookup nötig.
| `AbwDat` (Einzeltag) | `CDate(CLng([vonDat]))` | `vonDat` & `bisDat` (DateTime) | `NV_VonDat`, `NV_BisDat` | **Abweichung** – Query gruppiert auf Tagesebene, Web speichert Zeitraume.
| `Nachname` | `tbl_MA_Mitarbeiterstamm.Nachname` | `Nachname` | Liste/Dropdown (`cboMitarbeiter`, `NV_MA_ID`) | **Erfüllt**.
| `Vorname` | `tbl_MA_Mitarbeiterstamm.Vorname` | `Vorname` | Liste/Dropdown | **Erfüllt**.
| *(—)* | `tbl_MA_NVerfuegZeiten.ID` | `ID` | `NV_ID`, Tabellenspalte | **Neu** im Web (für CRUD erforderlich).
| *(—)* | `tbl_MA_NVerfuegZeiten.Grund` | `Grund` | Dropdown `NV_Grund` | **Neu** – textuelle Gründe ersetzen `Zeittyp_ID`.
| *(—)* | `tbl_MA_NVerfuegZeiten.Ganztaegig` | `Ganztaegig` | Checkbox `NV_Ganztaegig` | **Neu**.
| *(—)* | `tbl_MA_NVerfuegZeiten.Bemerkung` | `Bemerkung` | Textarea `NV_Bemerkung` | **Neu**.

## Identifizierte Luecken
1. **Zeittyp vs. Grund:** Frontend nutzt statische Grund-Liste, Query erwartet `Zeittyp_ID`. Ohne Mapping gehen historische Codierungen verloren.
2. **Tagessicht:** Query aggregiert Einzeltage. Wenn API Eintraege mit mehrtaegigem Zeitraum liefert, entspricht nur `vonDat` dem `AbwDat`. Access-Reports, die pro Tag abrechnen, koennen dadurch falsche Werte erhalten.
3. **Ganztaegig/Bemerkung:** Zusätzliche Felder stehen in Access-Query nicht bereit. Müssen bei eventuellen Access-Roundtrips berücksichtigt werden (z. B. neue Query erstellen oder bestehende erweitern).

## Vorschlag zur Angleichung
1. **Lookup-Tabelle `tbl_Zeittypen`:** API sollte `Zeittyp_ID` mitsenden, Frontend zeigt freundlichen Text (Grund) über Lookup. Alternativ legt Frontend Grund → Zeittyp Mapping fest.
2. **Tages-View Endpoint:** Zusätzliche Route `/api/abwesenheiten/tage` die alle Tage zwischen `vonDat` und `bisDat` expands und identisch zu `qry_MA_Abwesend Tag` antwortet.
3. **Synchronisationspfad:** Beim Speichern weiterhin Zeitraume schreiben, aber ergänzend `Zeittyp_ID` mitgeben (auch bei POST/PUT), damit Access-Umgebung konsistent bleibt.

## ToDos
- [ ] Backend erweitern, damit `/api/abwesenheiten` sowohl `Zeittyp_ID` liefert als auch optional Tagesprojektion anbietet.
- [ ] Frontend-Felder um echtes Zeittyp-Feld ergänzen oder Dropdown-Liste dynamisch über `/api/dienstplan/gruende` füllen.
- [ ] Reporting-/Sync-Skripte prüfen, ob Einzel-Tagesdaten weiterhin benötigt werden und ggf. neue Query oder API-Route konsumieren.
