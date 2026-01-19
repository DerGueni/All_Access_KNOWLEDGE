# Preload-System - Quick Start Guide

**Erstellt:** 2025-12-23
**Instanz:** 3 - Preload & Integration Spezialist

---

## 🚀 In 5 Minuten einsatzbereit

### Was ist das Preload-System?

Das Preload-System lädt alle HTML-Formulare im Hintergrund vor, **bevor** der User sie öffnet. Dadurch reduziert sich die Ladezeit von **3-4 Sekunden** auf **< 500ms**.

**10-20x schneller!** 🚀

---

## ✅ Schritt 1: Server + Frontend starten (bereits läuft)

```bash
# Terminal 1: Backend
cd C:\Users\guenther.siegert\Documents\01_ClaudeCode_HTML\server
npm start
# → http://localhost:3000

# Terminal 2: Frontend
cd C:\Users\guenther.siegert\Documents\01_ClaudeCode_HTML\web
npm run dev
# → http://localhost:5173
```

**Prüfen:**
- Backend-Console zeigt: `✅ Server-Warmup abgeschlossen`
- Frontend-Console zeigt: `✅ Preload abgeschlossen`

---

## ✅ Schritt 2: VBA-Modul installieren (5 Minuten)

### 2.1 Modul erstellen

1. Access öffnen
2. VBA-Editor öffnen (Taste: **ALT+F11**)
3. Menü: **Einfügen → Modul**
4. Datei öffnen: `docs\VBA_PRELOAD_MODULE.txt`
5. Kompletten Inhalt **kopieren** (STRG+A, STRG+C)
6. In VBA-Editor **einfügen** (STRG+V)
7. Speichern (STRG+S), Name: **mod_WebHost_Preload**

### 2.2 Testen

Im **VBA-Direktfenster** (STRG+G):

```vba
Test_HealthCheck
```

**Erwartete Ausgabe:**
```
✅ Server ist erreichbar
```

Falls Server nicht erreichbar:
- Backend starten: `cd server && npm start`

---

## ✅ Schritt 3: Preload beim Access-Start aktivieren (2 Minuten)

### 3.1 Timer im Startup-Formular

1. Formular **frm_va_Auftragstamm** im **Design-Modus** öffnen
2. VBA-Code öffnen (F7 oder Doppelklick auf Formular)
3. Suche `Private Sub Form_Load()`
4. Am **Ende** der Funktion hinzufügen:

```vba
    ' === PRELOAD-TIMER SETZEN ===
    Me.TimerInterval = 500
```

5. Neue Funktion **unter** `Form_Load()` einfügen:

```vba
Private Sub Form_Timer()
    ' Timer deaktivieren (nur einmal ausführen)
    Me.TimerInterval = 0

    ' Preload starten (asynchron)
    On Error Resume Next
    Call PreloadWebForms
End Sub
```

6. Speichern (STRG+S)

### 3.2 Testen

1. Access **schließen**
2. Access **neu öffnen**
3. VBA-Direktfenster öffnen (STRG+G)

**Erwartete Ausgabe:**
```
🔥 Preload: Starte Backend-Warmup...
🔥 Preload: Starte Frontend-Preload...
✅ Preload: Requests gesendet (asynchron)
```

**Erfolg!** Das Preload-System läuft jetzt automatisch beim Access-Start.

---

## ✅ Schritt 4: HTML-Formulare öffnen (Optional)

### Option A: Im Browser testen

```
http://localhost:5173/mitarbeiter/707
http://localhost:5173/kunden/20727
http://localhost:5173/preload
```

**Erwartung:** Formulare laden in < 500ms

### Option B: WebHost-Formular in Access (Optional)

Siehe: `docs\VBA_FRM_WEBHOST.txt` für vollständige Anleitung.

**Quick-Test:**

```vba
' In VBA-Direktfenster:
Test_OpenMitarbeiter
```

→ Öffnet Mitarbeiter 707 im Browser

---

## 🎯 Fertig!

Das Preload-System ist jetzt aktiv. Beim nächsten Access-Start werden alle HTML-Formulare automatisch vorgeladen.

---

## 🧪 Performance testen

### Ohne Preload (Vergleich)

1. Server + Frontend stoppen
2. Access schließen
3. Server + Frontend neu starten
4. Access öffnen (ohne Preload-Code)
5. HTML-Formular öffnen
6. **Zeit messen:** ~3-4 Sekunden

### Mit Preload

1. Server + Frontend laufen
2. Access öffnen (mit Preload-Code)
3. 2 Sekunden warten (Preload läuft im Hintergrund)
4. HTML-Formular öffnen
5. **Zeit messen:** ~300-500ms

**Speedup: 10x schneller!** 🚀

---

## 🔧 Troubleshooting

### Problem: "Server nicht erreichbar"

**Lösung:**
```bash
cd C:\Users\guenther.siegert\Documents\01_ClaudeCode_HTML\server
npm start
```

Prüfen: `http://localhost:3000/api/health`

### Problem: "Preload läuft nicht"

**Prüfungen:**
1. Modul `mod_WebHost_Preload` existiert?
2. Timer-Code in `frm_va_Auftragstamm` eingefügt?
3. VBA-Direktfenster zeigt Meldungen?

**Test:**
```vba
Test_Preload
```

### Problem: "VBA-Fehler"

**Typische Fehler:**
- `WinHttp nicht gefunden` → Windows-Update
- `Compile Error` → Option-Zeilen entfernen
- `Timer nicht gefunden` → TimerInterval-Property prüfen

---

## 📖 Weitere Dokumentation

| Datei | Beschreibung |
|-------|--------------|
| `docs\VBA_PRELOAD_MODULE.txt` | Vollständiges VBA-Modul |
| `docs\VBA_STARTUP_INTEGRATION.txt` | 3 Integrations-Optionen |
| `docs\VBA_FRM_WEBHOST.txt` | WebHost-Formular Template |
| `docs\WEBHOST_INTEGRATION.md` | Technische Details |
| `docs\PRELOAD_PERFORMANCE.md` | Performance-Messungen |
| `docs\INSTANZ_3_ABSCHLUSSBERICHT.md` | Vollständiger Bericht |

---

## ❓ Fragen?

**VBA-Tests:**
```vba
' Health-Check
Test_HealthCheck

' Preload testen
Test_Preload

' Formular öffnen
Test_OpenMitarbeiter
```

**Backend-Endpoints:**
```
GET http://localhost:3000/api/health
GET http://localhost:3000/api/preload
```

**Frontend-Routes:**
```
http://localhost:5173/preload
http://localhost:5173/mitarbeiter/707
http://localhost:5173/kunden/20727
```

---

**Happy Preloading! 🚀**
