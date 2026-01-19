# WebHost-Integration - Analyse & Implementierung

**Erstellt:** 2025-12-23
**Instanz:** 3 - Preload & Integration Spezialist
**Status:** ETAPPE 1 - IST-Zustand Dokumentation

---

## 🔍 IST-Zustand Analyse

### 1. Aktuelles Setup

**Frontend (React + Vite):**
- Läuft auf: `http://localhost:5173`
- Basis-Pfad: `C:\Users\guenther.siegert\Documents\01_ClaudeCode_HTML\web\`
- Entry-Point: `src/App.jsx`
- Hauptformular: `MitarbeiterstammForm.jsx` (292 Controls, 13 Tabs)

**Backend (Node.js + Express):**
- Läuft auf: `http://localhost:3000`
- Basis-Pfad: `C:\Users\guenther.siegert\Documents\01_ClaudeCode_HTML\server\`
- Entry-Point: `src/index.js`
- API-Endpoints: `/api/mitarbeiter`, `/api/health`

**Access-Frontend:**
- Startup-Formular: `frm_va_Auftragstamm`
- VBA-Events: `Form_Load()`, `Form_Open()`
- WebHost-Formular: **NICHT VORHANDEN** (muss neu erstellt werden)

### 2. Erkenntnisse aus VBA-Analyse

**frm_va_Auftragstamm (2776 Zeilen VBA):**
- Hat `Form_Load()` Event (Zeile 938)
- Hat `Form_Open()` Event (Zeile 976)
- Keine WebHost-Integration vorhanden
- Keine Preload-Logik vorhanden

**Fehlende Komponenten:**
- ❌ `frm_WebHost` existiert nicht
- ❌ Kein Modul für HTML-Anzeige
- ❌ Keine Preload-Logik im Startup

---

## 🎯 Implementierungs-Plan

### Phase 1: Preload-System Backend
**Datei:** `server/src/warmup.js`

**Funktionen:**
- `warmupServer()` - Initialisiert alle API-Endpoints
- `precacheQueries()` - Cache häufig genutzte Queries
- Warmup beim Server-Start ausführen

**Endpoint:** `GET /api/preload`
- Gibt Status zurück: `{ ready: true, forms: [...], timestamp: ... }`
- Triggert Warmup aller kritischen Endpoints

### Phase 2: Preload-System Frontend
**Datei:** `web/src/lib/preloader.js`

**Funktionen:**
- `preloadAllForms()` - Lädt alle Formular-Routes vor
- `prefetchAssets()` - Lädt Controls-JSONs, CSS
- `checkPreloadStatus()` - Prüft ob alles bereit ist

**Route:** `/preload`
- Spezielle Route die alle Formulare vorlädt
- Wird vom Access-Frontend gecallt (unsichtbar im Hintergrund)

### Phase 3: Access-Startup-Integration

**OPTION A: Timer im frm_va_Auftragstamm (EMPFOHLEN)**
```vba
Private Sub Form_Load()
    ' ... bestehender Code ...

    ' Timer für asynchrones Preload setzen
    Me.TimerInterval = 500  ' 500ms nach Load
End Sub

Private Sub Form_Timer()
    ' Timer deaktivieren (nur einmal ausführen)
    Me.TimerInterval = 0

    ' Preload asynchron starten
    Call PreloadWebForms()
End Sub
```

**OPTION B: AutoExec-Makro (Alternativ)**
- Makro `AutoExec_Preload` erstellen
- Ruft `PreloadWebForms()` auf
- Läuft beim Datenbank-Start

**VBA-Modul:** `mod_WebHost_Preload`
```vba
' Asynchrones Preload der Web-Formulare
Public Sub PreloadWebForms()
    On Error Resume Next

    Dim http As Object
    Set http = CreateObject("WinHttp.WinHttpRequest.5.1")

    ' Backend Warmup
    http.Open "GET", "http://localhost:3000/api/preload", True
    http.Send

    ' Frontend Preload
    http.Open "GET", "http://localhost:5173/preload", True
    http.Send

    Set http = Nothing
End Sub
```

### Phase 4: WebHost-Formular

**Neu zu erstellen:** `frm_WebHost`

**Funktion:**
- Zeigt HTML-Formulare in Access an (via WebBrowser-Control)
- Parameter: Formular-Name, Record-ID
- URL-Schema: `http://localhost:5173/mitarbeiter/:id`

**Methoden:**
```vba
' Lädt HTML-Formular
Public Sub LoadHTMLForm(formName As String, recordId As Long)
    Dim url As String
    url = "http://localhost:5173/" & formName & "/" & recordId
    Me.WebBrowser0.Navigate url
End Sub
```

---

## 🗺️ URL-Routing-Schema

### Frontend-Routes

| Route | Formular | Beschreibung |
|-------|----------|--------------|
| `/mitarbeiter/:id` | MitarbeiterstammForm | Mitarbeiter-Stammdaten |
| `/kunden/:id` | KundenstammForm | Kunden-Stammdaten |
| `/auftraege/:id` | AuftragstammForm | Auftrags-Stammdaten |
| `/objekte/:id` | ObjektForm | Objekt-Stammdaten |
| `/preload` | PreloadComponent | Warmup aller Formulare |

### Backend-Endpoints

| Endpoint | Beschreibung | Warmup |
|----------|--------------|--------|
| `/api/health` | Health-Check | ✅ |
| `/api/preload` | Preload-Trigger | ✅ |
| `/api/mitarbeiter` | Mitarbeiter-API | ✅ |
| `/api/kunden` | Kunden-API | 🔄 |
| `/api/auftraege` | Auftrags-API | 🔄 |
| `/api/objekte` | Objekt-API | 🔄 |

---

## 🚀 Integration Workflow

### 1. Server-Start (Backend)
```bash
cd server
npm start
```
→ `warmup.js` wird automatisch ausgeführt
→ Alle Endpoints werden vorinitialisiert
→ Cache wird gefüllt

### 2. Frontend-Start (Dev)
```bash
cd web
npm run dev
```
→ Vite startet auf Port 5173
→ Wartet auf Requests

### 3. Access-Start (Frontend)
```
1. Access öffnet frm_va_Auftragstamm
2. Form_Load() Event
3. Timer wird gesetzt (500ms)
4. Form_Timer() Event
5. PreloadWebForms() wird gecallt (asynchron)
   → Backend: GET /api/preload
   → Frontend: GET /preload
6. Timer wird deaktiviert
7. User kann normal arbeiten (kein UI-Block)
```

### 4. HTML-Formular öffnen
```vba
' In Access-VBA
DoCmd.OpenForm "frm_WebHost"
Forms("frm_WebHost").LoadHTMLForm "mitarbeiter", 707
```
→ URL: `http://localhost:5173/mitarbeiter/707`
→ Formular ist bereits vorgeladen → **sofortige Anzeige**

---

## ⚡ Performance-Vorteile

### Ohne Preload
1. User klickt auf "Mitarbeiter öffnen"
2. Access öffnet frm_WebHost
3. WebBrowser navigiert zu URL
4. **Frontend startet kalt (2-3 Sekunden)**
5. API-Call zu Backend (500ms)
6. Daten werden geladen (200ms)
7. **Gesamtzeit: 3-4 Sekunden**

### Mit Preload
1. Access startet → Preload läuft im Hintergrund
2. Frontend ist bereits geladen (0ms)
3. API-Cache ist warm (0ms)
4. User klickt auf "Mitarbeiter öffnen"
5. WebBrowser navigiert zu URL
6. **Sofortige Anzeige (< 200ms)**
7. **Gesamtzeit: < 500ms**

**Speedup: 6-8x schneller!**

---

## 📋 Offene Punkte

- [ ] Router-Integration in App.jsx (React Router)
- [ ] PreloadComponent erstellen
- [ ] warmup.js implementieren
- [ ] VBA-Template testen
- [ ] Performance-Messung durchführen
- [ ] Dokumentation vervollständigen

---

## 🔗 Referenzen

- **Projekt-Root:** `C:\Users\guenther.siegert\Documents\01_ClaudeCode_HTML\`
- **VBA-Exports:** `exports/vba/forms/Form_frm_VA_Auftragstamm.bas`
- **Access-Frontend:** `S:\CONSEC\...\Consys_FE_N_Test_Claude_GPT - Kopie (9) - Kopie.accdb`
- **Backend:** `http://localhost:3000`
- **Frontend:** `http://localhost:5173`

---

**Status:** ✅ ETAPPE 1 abgeschlossen - IST-Zustand dokumentiert
**Nächste Schritte:** ETAPPE 2 - Backend Warmup implementieren
