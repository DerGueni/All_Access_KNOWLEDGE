# Etappe B Quick-Start (5 Minuten)

## Ziel
VBA-Modul importieren → Bridge testen → Live gehen

---

## TL;DR (Schnelleinstieg)

### 1. VBA-Modul importieren (2 Min)

```bash
cd C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\generated\forms\frm_ma_Mitarbeiterstamm

# Starte Dialog-Killer (falls nicht aktiv)
cd ..\..\..\Access\ Bridge
python dialog_killer.py &

# Zurück zum Form-Verzeichnis
cd ..\..\..\0006_All_Access_KNOWLEDGE\generated\forms\frm_ma_Mitarbeiterstamm

# Importiere Modul
python import_webform_module.py
```

**Erwartet:** `✓ IMPORT COMPLETED SUCCESSFULLY`

---

### 2. Access öffnen & VBA prüfen (1 Min)

```
1. Öffne Access:
   S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (9) - Kopie.accdb

2. Drücke: Alt+F11 (VBA-Editor)

3. Suche: mod_N_WebForm_Handler
   ✓ Sollte unter "Modules" sichtbar sein
```

---

### 3. Test 1: VBA lädt Daten (1 Min)

Im VBA-Editor **Immediate Window** (View → Immediate Window):

```vba
Test_LoadForm
```

**Erwartet:** Keine Fehlermeldung, Form lädt silently

---

### 4. Test 2: Browser Console (1 Min)

Öffne HTML-Formular (lokal oder WebView2):
```
http://localhost:3000  (wenn API-Server läuft)
oder
frm_WebHost in Access-Frontend
```

Öffne Browser-Console: `F12` → Console-Tab

**Erwartet Logs:**
```
✓ Initializing frm_MA_Mitarbeiterstamm WebForm...
✓ LoadForm call sent to Access...
✓ loadForm event received from mod_N_WebForm_Handler
✓ Form populated with record ID: XXX
✓ Employee list populated with XX records
```

---

## Checkliste für Live-Go

- [ ] `python import_webform_module.py` → erfolgreich
- [ ] VBA-Editor zeigt `mod_N_WebForm_Handler`
- [ ] `Test_LoadForm` in VBA-Editor keine Fehler
- [ ] Browser-Console zeigt "loadForm event received"
- [ ] Formulardaten sind sichtbar
- [ ] Navigation (Buttons) ändern Datensätze
- [ ] Field-Change Events im Console-Log sichtbar

---

## Wenn was nicht funktioniert

### Problem: "VBA-Modul nicht importiert"

```bash
# 1. Dialog-Killer starten
cd C:\Users\guenther.siegert\Documents\Access\ Bridge
python dialog_killer.py

# 2. Warte 5 Sekunden
# 3. Versuche erneut zu importieren
python ..\..\..\0006_All_Access_KNOWLEDGE\generated\forms\frm_ma_Mitarbeiterstamm\import_webform_module.py
```

---

### Problem: "Browser-Console zeigt keine Logs"

```javascript
// Browser-Console (F12):

// 1. Prüfe Bridge verfügbar:
typeof window.Bridge
// Erwartet: "object"

// 2. Wenn undefined: nutze API-Server statt WebView2
// python C:\Users\guenther.siegert\Documents\Access\ Bridge\api_server.py

// 3. Öffne dann: http://localhost:5000/webform
```

---

### Problem: "Datensätze nicht sichtbar"

```sql
-- In Access Backend-Datei öffnen:
SELECT COUNT(*) FROM tbl_MA_Mitarbeiterstamm
-- Sollte > 0 sein

-- Mit Filter für Active:
SELECT COUNT(*) FROM tbl_MA_Mitarbeiterstamm
WHERE Anstellungsart_ID IN (3, 5)
-- Sollte auch > 0 sein
```

---

## Nächste Schritte

Nach erfolgreichem Import:

1. **ETAPPE_B_ANLEITUNG.md lesen** (detaillierte Tests)
2. **Etappe C starten** (SaveRecord + SubForms)
3. **ETAPPE_B_STATUS.md** für Architektur-Übersicht

---

## Datei-Referenzen

| Datei | Zweck |
|---|---|
| `mod_N_WebForm_Handler.bas` | VBA-Modul |
| `import_webform_module.py` | Import-Script |
| `form.js` | HTML-Bridge-Logic |
| `ETAPPE_B_ANLEITUNG.md` | Vollständige Dokumentation |
| `ETAPPE_B_STATUS.md` | Technische Details |

---

## Support

- **Bridge nicht verfügbar?** → Nutze API-Server
- **VBA-Fehler?** → Siehe ETAPPE_B_ANLEITUNG.md
- **Logs nicht sichtbar?** → Konsole mit F12 öffnen
