# TEST-ANLEITUNG: HTML Ansicht Buttons

## Status
✅ Wrapper-Funktionen wurden in `mod_N_WebView2_forms3.bas` hinzugefügt
✅ VBA-Code als `Function` deklariert (nicht `Sub`) - wichtig für Button OnClick!
✅ Modul wurde in Access importiert und kompiliert

## MANUELLER TEST (empfohlen)

### Schritt 1: Access neu starten
1. Schließen Sie Access komplett (alle Fenster)
2. Öffnen Sie: `0_Consys_FE_Test.accdb`
3. Warten Sie bis Access vollständig geladen ist

### Schritt 2: VBA-Editor öffnen und prüfen
1. Drücken Sie `Alt+F11` (öffnet VBA-Editor)
2. Suchen Sie im Projekt-Explorer:
   - `mod_N_WebView2_forms3`
3. Doppelklicken Sie das Modul
4. Scrollen Sie ans Ende (Zeile 333+)
5. Prüfen Sie ob folgende Funktionen vorhanden sind:
   ```vba
   Public Function HTMLAnsichtOeffnen()
   Public Function OpenHTMLMenu()
   Public Function OpenAuftragsverwaltungHTML(Optional VA_ID As Long = 0)
   Public Function OpenMitarbeiterstammHTML(Optional MA_ID As Long = 0)
   Public Function OpenKundenstammHTML(Optional KD_ID As Long = 0)
   Public Function OpenAuftragstammHTML(Optional VA_ID As Long = 0)
   ```

### Schritt 3: Test im Direktfenster (VBA-Editor)
1. Im VBA-Editor: Menü `Ansicht` → `Direktfenster` (oder `Strg+G`)
2. Testen Sie jede Funktion einzeln:
   ```vba
   ? HTMLAnsichtOeffnen()
   ```
3. Drücken Sie `Enter`
4. **Erwartetes Ergebnis:**
   - Browser öffnet `shell.html`
   - Rückgabewert im Direktfenster: `Wahr` oder `True`

5. Weitere Tests:
   ```vba
   ? OpenAuftragsverwaltungHTML(1)
   ? OpenMitarbeiterstammHTML(707)
   ? OpenKundenstammHTML(1)
   ? OpenHTMLMenu()
   ```

### Schritt 4: Test über Access-Formulare
1. Öffnen Sie das Formular: `frm_va_Auftragstamm`
2. Suchen Sie einen der folgenden Buttons:
   - `btn_N_HTMLAnsicht`
   - `btnHTMLAnsicht`
   - `btn_N_OpenHTMLMenu`
3. Klicken Sie den Button
4. **Erwartetes Ergebnis:**
   - Browser öffnet entsprechendes HTML-Formular
   - Keine Fehlermeldung

### Schritt 5: Weitere Formulare testen
Testen Sie auch diese Formulare:
- `frm_ma_Mitarbeiterstamm` → Button `btnHTMLAnsicht`
- `frm_KD_Kundenstamm` → Button `btnHTMLAnsicht`
- `frm_DP_Dienstplan_Objekt` → Button `btn_N_HTMLAnsicht`

---

## AUTOMATISCHER TEST (Python-Script)

Falls der manuelle Test funktioniert, können Sie dieses Script verwenden:

```python
# test_html_buttons.py
import win32com.client
import time

# Access verbinden
access = win32com.client.Dispatch("Access.Application")
access.Visible = True
access.OpenCurrentDatabase(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb")

# Tests
tests = [
    ("HTMLAnsichtOeffnen()", 0),
    ("OpenAuftragsverwaltungHTML(1)", 1),
    ("OpenMitarbeiterstammHTML(707)", 707),
    ("OpenKundenstammHTML(1)", 1),
    ("OpenHTMLMenu()", 0),
]

print("=" * 70)
print("HTML ANSICHT BUTTONS - TEST")
print("=" * 70)

for func_call, param in tests:
    print(f"\n[TEST] {func_call}")
    try:
        if param > 0:
            result = access.Run(func_call.split("(")[0], param)
        else:
            result = access.Run(func_call.split("(")[0])
        print(f"[✓] ERFOLG! Rückgabe: {result}")
        time.sleep(2)
    except Exception as e:
        print(f"[X] FEHLER: {e}")

print("\n" + "=" * 70)
print("[FERTIG] Bitte prüfen Sie die geöffneten Browser-Tabs")
print("=" * 70)

# Access offen lassen
# access.Quit()
```

Führen Sie aus mit: `python test_html_buttons.py`

---

## BEKANNTE PROBLEME & LÖSUNGEN

### Problem: "Prozedur wurde nicht gefunden"
**Lösung:**
1. Access komplett schließen und neu starten
2. VBA-Editor öffnen → Modul `mod_N_WebView2_forms3` prüfen
3. Im VBA-Editor: Menü `Debuggen` → `Kompilieren 0_Consys_FE_Test`
4. Wenn Fehler angezeigt werden: Fehler beheben und nochmal kompilieren

### Problem: Browser öffnet leere Seite
**Lösung:**
1. API-Server muss laufen auf Port 5000
2. Prüfen: `http://localhost:5000/shell.html` im Browser öffnen
3. Falls nicht erreichbar: API-Server starten
   ```bash
   cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\_scripts"
   python mini_api.py
   ```

### Problem: WebView2App.exe nicht gefunden
**Erwartetes Verhalten:**
- Falls `WebView2App.exe` fehlt, wird automatisch Browser-Fallback verwendet
- Debug.Print zeigt: "[WebView2] WebView2App.exe fehlt - Fallback zu Browser-Modus"

---

## ERFOLGSKRITERIEN

✅ **Alle Tests bestanden wenn:**
1. VBA-Direktfenster zeigt `True` nach Funktionsaufruf
2. Browser öffnet `shell.html` oder entsprechendes Formular
3. Keine VBA-Fehlermeldungen
4. HTML-Formular zeigt Daten (nicht leer)

❌ **Fehler wenn:**
- "Prozedur nicht gefunden" → Access neu starten
- "Sub oder Function nicht definiert" → Modul fehlt oder falsch
- Browser öffnet, aber leere Seite → API-Server nicht gestartet
- Gar nichts passiert → Button OnClick Property prüfen

---

## BUTTON ONCLICK EINSTELLUNGEN (Referenz)

**Für Stammdaten-Formulare:**
```vba
=OpenAuftragstamm_WebView2([ID])        ' Empfohlen (neu)
=OpenAuftragsverwaltungHTML([ID])       ' Funktioniert (Wrapper)
=OpenAuftragstammHTML([ID])             ' Funktioniert (Wrapper)
```

**Für Hauptmenü:**
```vba
=OpenHTMLAnsicht()                      ' Empfohlen (neu)
=HTMLAnsichtOeffnen()                   ' Funktioniert (Wrapper)
=OpenHTMLMenu()                         ' Funktioniert (Wrapper)
```

---

## SUPPORT

Bei Problemen bitte berichten:
1. Welcher Test schlägt fehl?
2. Genaue Fehlermeldung
3. Screenshot des VBA-Editors (mod_N_WebView2_forms3)
4. Output des Direktfensters nach `? HTMLAnsichtOeffnen()`
