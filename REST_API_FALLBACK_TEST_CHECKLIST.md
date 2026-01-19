# REST-API Fallback - Test Checklist

## Vorbereitung

- [ ] API Server starten: `python api_server.py` (Port 5000)
- [ ] Access Frontend öffnen: `0_Consys_FE_Test.accdb`
- [ ] Browser DevTools öffnen (F12)
- [ ] Console Filter setzen: "sub_DP_Grund" / "sub_DP_Grund_MA" etc.

## Test 1: sub_DP_Grund (Abwesenheitsgründe)

### Mit API Server:
- [ ] Formular öffnen das sub_DP_Grund enthält
- [ ] Console: `[sub_DP_Grund] Verwende REST-API Modus (erzwungen)`
- [ ] Console: `[sub_DP_Grund] API Daten geladen: X Eintraege`
- [ ] Tabelle zeigt Gründe an (Grund_ID, Grund_Bez, Grund_Kuerzel)
- [ ] Row-Klick funktioniert (Zeile wird markiert)
- [ ] Double-Klick funktioniert (postMessage an Parent)

### Ohne API Server:
- [ ] API Server stoppen (`Ctrl+C`)
- [ ] Formular Refresh (F5)
- [ ] Console: `[sub_DP_Grund] API Fehler: ...`
- [ ] Console: `[sub_DP_Grund] Fallback zu Bridge...`
- [ ] Tabelle zeigt weiterhin Daten (via Bridge)

## Test 2: sub_DP_Grund_MA (Abwesenheitsgründe pro MA)

### Mit API Server:
- [ ] Dienstplan-Formular mit Grund-MA Subform öffnen
- [ ] MA auswählen
- [ ] Console: `[sub_DP_Grund_MA] Verwende REST-API Modus (erzwungen) fuer MA_ID: {ID}`
- [ ] Console: `[sub_DP_Grund_MA] API Daten geladen: X Eintraege fuer MA: {ID}`
- [ ] Tabelle zeigt Einträge (Datum, Grund, Bemerkung)
- [ ] Filter funktioniert (cboGrund Dropdown)

### Ohne API Server:
- [ ] API Server stoppen
- [ ] MA neu auswählen
- [ ] Console: Fallback-Meldung und Bridge-Aufruf

## Test 3: sub_MA_Offene_Anfragen (Offene Anfragen mit Buttons)

### Mit API Server:
- [ ] MA-Formular mit Anfragen-Subform öffnen
- [ ] Console: `[sub_MA_Offene_Anfragen] Verwende REST-API Modus (erzwungen)`
- [ ] Console: `[sub_MA_Offene_Anfragen] API Daten geladen: X Eintraege`
- [ ] Tabelle zeigt Anfragen mit Zusagen/Absagen Buttons
- [ ] Zusagen-Button funktioniert → postMessage an Parent
- [ ] Absagen-Button funktioniert → postMessage an Parent

### Ohne API Server:
- [ ] API Server stoppen
- [ ] Formular Refresh
- [ ] Console: Fallback-Meldung und Bridge-Aufruf

## Test 4: sub_MA_VA_Planung_Absage (Absagen-Liste)

### Mit API Server:
- [ ] Auftragstamm-Formular mit Absagen-Subform öffnen
- [ ] Auftrag auswählen
- [ ] Console: `[sub_MA_VA_Planung_Absage] Verwende REST-API Modus (erzwungen) fuer VA_ID: {ID}`
- [ ] Console: `[sub_MA_VA_Planung_Absage] API Daten geladen: X Absagen fuer VA: {ID}`
- [ ] Tabelle zeigt Absagen (MA-Name, Zeiten, Bemerkungen)
- [ ] Row-Klick funktioniert
- [ ] Double-Klick zeigt MA-Details

### Ohne API Server:
- [ ] API Server stoppen
- [ ] Auftrag neu auswählen
- [ ] Console: Fallback-Meldung und Bridge-Aufruf

## Performance Tests

- [ ] Subforms laden schnell (< 500ms)
- [ ] Keine Timeout-Fehler in Console
- [ ] Bei mehreren Subforms gleichzeitig: kein Deadlock
- [ ] Refresh (F5) funktioniert zuverlässig

## Fehler-Szenarien

### Szenario 1: API Server crashed während Nutzung
- [ ] API Server stoppen
- [ ] Subform neu laden (Formular / Refresh)
- [ ] Fallback zu Bridge funktioniert
- [ ] Server neu starten → Subform funktioniert wieder

### Szenario 2: Netzwerk-Fehler
- [ ] Firewall blockiert localhost:5000 (wenn möglich)
- [ ] Console zeigt Fehler
- [ ] Fallback zu Bridge versucht zu greifen
- [ ] Firewall freigeben → funktioniert wieder

### Szenario 3: Falscher Port
- [ ] API Server auf anderen Port (z.B. 5001)
- [ ] Subform lädt (Fehler 404)
- [ ] Console: API Fehler
- [ ] Fallback funktioniert

## Endergebnis

✅ Alle 4 Subforms verwenden REST-API mit Fallback
✅ Timeout-Probleme behoben
✅ Keine Änderungen am WebView2-Code nötig
✅ Zuverlässiges Fallback-System

---

**Test-Datum:** TBD
**Tester:** TBD
**Status:** NICHT GETESTET
