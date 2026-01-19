# Quick Test Guide - REST-API Fallback

**Schneller Überblick zum Testen der 4 neuen Subforms**

---

## 5-Minuten Test

### Vorbereitung (1 min)
```bash
# Terminal öffnen
cd "C:\Users\guenther.siegert\Documents\Access Bridge"

# API Server starten (falls nicht läuft)
python api_server.py
# Output: "Server started on http://localhost:5000"
```

### Browser Test (2 min)
```
http://localhost:5000/api/dienstplan/gruende         # Test 1
http://localhost:5000/api/dienstplan/ma/1            # Test 2
http://localhost:5000/api/anfragen                   # Test 3
http://localhost:5000/api/auftraege/123/absagen      # Test 4
```

Alle sollten JSON mit Daten zurückgeben.

### Form Test (2 min)
1. Access öffnen: `0_Consys_FE_Test.accdb`
2. Formular mit sub_DP_Grund öffnen
3. Browser DevTools (F12) → Console
4. Sollte zeigen:
   ```
   [sub_DP_Grund] Verwende REST-API Modus (erzwungen)
   [sub_DP_Grund] API Daten geladen: X Eintraege
   ```
5. Tabelle sollte Daten zeigen ✅

---

## Detailliertere Tests

### Test 1: sub_DP_Grund (Abwesenheitsgründe)

**Welches Formular:** Dienstplan-Formular mit Grund-Liste
**API:** `http://localhost:5000/api/dienstplan/gruende`

**Checkliste:**
- [ ] Console: REST-API Modus aktiv
- [ ] Console: X Einträge geladen
- [ ] Tabelle zeigt Gründe (ID, Bezeichnung, Kürzel)
- [ ] Row-Klick markiert Zeile
- [ ] Double-Klick öffnet Details

**Fehlerbehandlung:**
- [ ] API Server stoppen → Fallback aktiv?
- [ ] Console: `API Fehler:` Meldung
- [ ] Console: `Fallback zu Bridge...`

---

### Test 2: sub_DP_Grund_MA (Gründe pro MA)

**Welches Formular:** Mitarbeiter auswählen → Abswesenheitsgründe pro MA
**API:** `http://localhost:5000/api/dienstplan/ma/{MA_ID}`

**Checkliste:**
- [ ] MA_ID in URL anzeigen
- [ ] Console: `fuer MA_ID: {123}` anzeigen
- [ ] Tabelle zeigt Einträge (Datum, Grund, Bemerkung)
- [ ] Filter-Dropdown funktioniert
- [ ] Filter zeigt nur gefilterte Einträge

**Fehlerbehandlung:**
- [ ] Filter zurücksetzen → alle Einträge wieder da?
- [ ] MA wechseln → neue Daten geladen?

---

### Test 3: sub_MA_Offene_Anfragen (Anfragen mit Buttons)

**Welches Formular:** MA-Formular → Offene Anfragen
**API:** `http://localhost:5000/api/anfragen` (+ Client-Filter)

**Checkliste:**
- [ ] Console: REST-API Modus aktiv
- [ ] Tabelle zeigt Anfragen mit Zusagen/Absagen Buttons
- [ ] Zusagen-Button funktioniert
- [ ] Absagen-Button funktioniert
- [ ] Console: `anfrage_beantwortet` postMessage
- [ ] Nach Zusagen: Tabelle aktualisiert?

**Fehlerbehandlung:**
- [ ] Button ohne Auswahl klicken → kein Fehler?
- [ ] Netzwerk-Fehler simulieren → Fallback?

---

### Test 4: sub_MA_VA_Planung_Absage (Absagen-Liste)

**Welches Formular:** Auftragstamm → Absagen-Liste
**API:** `http://localhost:5000/api/auftraege/{VA_ID}/absagen`

**Checkliste:**
- [ ] Auftrag auswählen
- [ ] Console: `fuer VA_ID: {456}` anzeigen
- [ ] Tabelle zeigt Absagen (MA, Zeiten, Bemerkungen)
- [ ] Row-Klick markiert Zeile
- [ ] Double-Klick zeigt MA-Details

**Fehlerbehandlung:**
- [ ] Auftrag wechseln → neue Daten geladen?

---

## Performance Monitoring

### Console-Filter aktivieren (F12):
```
[sub_DP_Grund]
[sub_DP_Grund_MA]
[sub_MA_Offene_Anfragen]
[sub_MA_VA_Planung_Absage]
```

### Was zu sehen sein sollte:
```
[sub_DP_Grund] Verwende REST-API Modus (erzwungen)           ← API aktiv
[sub_DP_Grund] API Daten geladen: 5 Eintraege               ← Erfolg
```

### Bei Problemen:
```
[sub_DP_Grund] API Fehler: TypeError: Failed to fetch       ← Server down?
[sub_DP_Grund] Fallback zu Bridge...                         ← Fallback aktiv
```

---

## Schnell-Debug Checklist

| Symptom | Ursache | Lösung |
|---------|---------|--------|
| Subform leer | API Server läuft nicht | `python api_server.py` starten |
| Tabelle zeigt Daten | ✅ REST-API funktioniert | Alles OK |
| Tabelle leer + Bridge-Log | API Server kaputt | Server neu starten |
| Timeout-Fehler | WebView2 zu langsam | Sollte nicht mehr vorkommen! |
| 404 Fehler | Falscher Endpoint | Console prüfen, URL prüfen |

---

## API Server Status prüfen

```powershell
# Port 5000 prüfen
netstat -ano | findstr :5000
# Output sollte zeigen: Python.exe lauscht auf 5000

# Oder curl:
curl http://localhost:5000/api/health
# Output: {"status": "ok"}
```

---

## Kompletter Test-Workflow (15 min)

1. **Vorbereitung (2 min)**
   ```bash
   # Terminal
   python api_server.py
   # Warten bis "Server started..."
   ```

2. **Browser-Schnell-Test (3 min)**
   ```
   Alle 4 Endpoints im Browser testen
   Sollten JSON + Daten zurückgeben
   ```

3. **Access-Formular Test (5 min)**
   - [ ] Test 1: sub_DP_Grund öffnen
   - [ ] Test 2: sub_DP_Grund_MA mit MA testen
   - [ ] Test 3: sub_MA_Offene_Anfragen mit Buttons
   - [ ] Test 4: sub_MA_VA_Planung_Absage öffnen

4. **Fallback-Test (3 min)**
   - [ ] API Server stoppen
   - [ ] Subform neu laden
   - [ ] Console: Fallback-Meldung?
   - [ ] Daten trotzdem da (via Bridge)?

5. **Cleanup (2 min)**
   - [ ] Server neu starten
   - [ ] Console bereinigen
   - [ ] Devtools schließen

---

## Bestanden / Nicht Bestanden Kriterium

### ✅ BESTANDEN:
- Alle 4 Subforms zeigen Daten über REST-API
- Console zeigt `[SubformName] API Daten geladen: X`
- Keine Timeout-Fehler
- Fallback zu Bridge funktioniert bei Fehler

### ❌ NICHT BESTANDEN:
- Irgendeine Subform zeigt keine Daten
- Timeout-Fehler in Console
- API Server nicht erreichbar
- Fallback funktioniert nicht

---

## Troubleshooting

### "API Fehler: Failed to fetch"
- Prüfe: Läuft API Server auf Port 5000?
- Lösung: `python api_server.py` starten

### "API Fehler: 404"
- Prüfe: Richtiger Endpoint in fetch()?
- Lösung: Console-Logs prüfen, Endpoint URL vergleichen

### "Tabelle zeigt alte Daten"
- Prüfe: Cached Browser-Daten?
- Lösung: `Ctrl+Shift+Delete` (Cache leeren) → Refresh

### "Subform zeigt überhaupt nichts"
- Prüfe: Ist state.MA_ID / state.VA_ID gesetzt?
- Prüfe: Wurde `loadData()` aufgerufen?
- Lösung: Console.log in loadData() hinzufügen

---

**Geschätzte Test-Dauer:** 15 Minuten
**Schwierigkeitsgrad:** Einfach (nur Browser + Formulare öffnen)
**Anforderungen:** API Server, Access, Browser DevTools

---

*Viel Erfolg beim Testen!* ✅
