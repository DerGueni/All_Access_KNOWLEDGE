# Gap-Analyse: frm_Systeminfo (Systeminfo)

**Formular-Typ:** System-Formular (Diagnostics/Info)
**Priorität:** Niedrig (System-Support, nicht geschäftskritisch)
**Access-Name:** `_frmHlp_SysInfo`
**HTML-Name:** `frm_Systeminfo.html`

---

## Executive Summary

Das Systeminfo-Formular zeigt umfassende System-, Hardware- und Datenbank-Informationen an. Die HTML-Version ist stark vereinfacht und zeigt nur minimale Browser-Informationen plus API-Server-Status. Viele Access-spezifische Features (Windows-APIs, Hardware-Details, Excel-Interop) sind in HTML nicht umsetzbar oder nicht relevant.

**Gesamtbewertung:** 25% umgesetzt (nur grundlegende Infos)

---

## 1. Struktureller Vergleich

### Access-Original

| Kategorie | Anzahl Controls | Beschreibung |
|-----------|----------------|--------------|
| **System-TextBoxen** | 17 | Windows-Version, RAM, CPU, IP-Adresse |
| **Bildschirm-Info** | 5 | Auflösung, Größe (mm), Farbtiefe |
| **Laufwerks-Info** | 1 ComboBox + 5 Images | A-Z Auswahl, Speicherplatz, Typ-Icons |
| **DB-Info** | 2 ListBoxen | SQL/Access Backend-Tabellen |
| **Labels** | 13 | Beschriftungen |
| **Buttons** | 3 | OK, Help, MSInfo (unsichtbar) |

**Gesamt:** 39 Controls + 7 Rechtecke + 6 Images = 52 Elemente

### HTML-Version

| Kategorie | Anzahl | Beschreibung |
|-----------|--------|--------------|
| **Info-Sektionen** | 3 | System, API Server, Anwendung |
| **Info-Zeilen** | 7 | Browser, Plattform, Screen, Language, API-Status, Version, Forms-Pfad |
| **Buttons** | 1 | Schließen |

**Gesamt:** 8 Elemente

---

## 2. Fehlende Features (Access → HTML)

### 2.1 Windows-spezifische APIs (NICHT UMSETZBAR in Web)

| Feature | Access VBA | HTML Alternative | Umsetzbar? |
|---------|-----------|------------------|------------|
| **Windows-Version** | `atWinVer(0..4)` über API | `navigator.userAgent` (begrenzt) | ⚠️ Teilweise |
| **CPU-Name/Speed** | `GetCPUSpeedName()` über Registry | Nicht verfügbar | ❌ Nein |
| **RAM-Größe** | `atGetMemEx()` über Windows API | `navigator.deviceMemory` (nur grob) | ⚠️ Teilweise |
| **IP-Adresse (lokal)** | `GetIPAddress()` | `RTCPeerConnection` (Workaround) | ⚠️ Möglich |
| **IP-Adresse (öffentlich)** | Externes API-Call | `ipify.org` API | ✅ Ja |
| **Laufwerke (A-Z)** | Windows API | Nicht verfügbar | ❌ Nein |
| **Freier Speicherplatz** | `atDiskfreespaceEx()` | Nicht verfügbar | ❌ Nein |
| **Bildschirm-Größe (mm)** | `atgetdevcaps()` über GDI | Nicht verfügbar | ❌ Nein |

### 2.2 Access/Datenbank-spezifische Features

| Feature | Access | HTML | Umsetzbar? |
|---------|--------|------|------------|
| **Access-Version** | `AccessInfo()` | API-Endpoint `/api/version` | ✅ Ja |
| **Backend-Pfad** | `CurrentDb.Name` | API-Endpoint `/api/database/info` | ✅ Ja |
| **SQL-Backend-Tabellen** | `qrymdbTable2sql_DB` | API-Endpoint `/api/tables?type=sql` | ✅ Ja |
| **Access-Backend-Tabellen** | `qrymdbTable2mdb_DB` | API-Endpoint `/api/tables?type=access` | ✅ Ja |

### 2.3 Timer-Funktion

| Feature | Access | HTML | Umsetzbar? |
|---------|--------|------|------------|
| **Auto-Update System-Ressourcen** | `OnTimer: api_UpdateSysResInfo()` | `setInterval()` | ✅ Ja |

---

## 3. Funktionale Gaps

### ❌ NICHT vorhanden in HTML

1. **Windows-Informationen:**
   - Exakte Windows-Version (Major.Minor.Build)
   - Windows-Variante (Home/Pro/Enterprise)
   - Windows-Edition
   - 64-bit Anzeige

2. **Hardware-Informationen:**
   - CPU-Name und -Geschwindigkeit
   - RAM-Größe (exakt in MB)
   - Bildschirm physische Größe (mm)
   - Farbtiefe (Bits)

3. **Laufwerks-Informationen:**
   - Laufwerksauswahl (A-Z)
   - Freier Speicherplatz
   - Laufwerkstyp-Icons (Fest, CD, Netzwerk, Floppy)

4. **Datenbank-Informationen:**
   - Access-Version
   - Backend-Pfad
   - Liste der Backend-Tabellen (SQL + Access)

5. **Interaktive Features:**
   - Laufwerk wechseln (Drive.AfterUpdate)
   - MS Info öffnen (btnMSInfo)
   - Help-Button

### ⚠️ TEILWEISE vorhanden

1. **Browser-Informationen:**
   - ✅ User-Agent (grobe Browser-Info)
   - ✅ Plattform (OS-Name)
   - ✅ Bildschirmauflösung (Pixel)
   - ✅ Sprache

2. **API-Status:**
   - ✅ API-Server erreichbar (localhost:5000)
   - ❌ Keine Details zu Backend-Verbindung

---

## 4. UI/UX Unterschiede

### Access-Original

- **Layout:** Strukturiert in 4 Bereichen (PC, Windows, Hardware, Bildschirm, Laufwerke, Datenbank)
- **Rahmen:** 7 Rechtecke zur visuellen Gruppierung
- **Icons:** 5 Laufwerks-Icons (Fest, CD, Floppy, Netz)
- **Farb-Box:** Farbtiefe-Anzeige als visuelles Element
- **ListBoxen:** 2 scrollbare Listen für Backend-Tabellen
- **ComboBox:** Laufwerksauswahl mit Dropdown

### HTML-Version

- **Layout:** 3 einfache Info-Sektionen (weiße Boxen)
- **Stil:** Minimalistisch, keine Icons, keine visuellen Extras
- **Farben:** Blauer Hintergrund (#8080c0), weiße Boxen
- **Buttons:** 1 Schließen-Button (kein Help)
- **Keine Listen:** Keine Backend-Tabellen-Anzeige

---

## 5. Technische Machbarkeit

### Was kann umgesetzt werden?

| Feature | Methode | Aufwand |
|---------|---------|---------|
| **Computername** | API-Endpoint `/api/system/info` | Niedrig |
| **Benutzername** | API-Endpoint `/api/system/user` | Niedrig |
| **IP-Adresse (öffentlich)** | `fetch('https://api.ipify.org?format=json')` | Niedrig |
| **Access-Version** | API-Endpoint `/api/version` | Niedrig |
| **Backend-Pfad** | API-Endpoint `/api/database/path` | Niedrig |
| **Backend-Tabellen** | API-Endpoint `/api/tables` | Niedrig |
| **Bildschirmauflösung** | `screen.width/height` | Bereits vorhanden |
| **Browser-Info** | `navigator.userAgent` | Bereits vorhanden |

### Was ist NICHT umsetzbar?

| Feature | Grund |
|---------|-------|
| **Windows-Version (exakt)** | Keine Browser-API, User-Agent unzuverlässig |
| **CPU-Name/Speed** | Keine Browser-API (aus Sicherheitsgründen) |
| **RAM-Größe (exakt)** | `navigator.deviceMemory` nur grob (2/4/8 GB) |
| **Laufwerke/Speicherplatz** | Keine Browser-API (Sicherheit) |
| **Bildschirmgröße (mm)** | Keine Browser-API |
| **Farbtiefe** | `screen.colorDepth` vorhanden, aber nicht angezeigt |

---

## 6. Empfohlene Maßnahmen

### Phase 1: Erweiterte Browser-Infos (SOFORT)

```javascript
// Zusätzliche Browser-APIs nutzen
document.getElementById('colorDepth').textContent = `${screen.colorDepth} Bit`;
document.getElementById('pixelRatio').textContent = window.devicePixelRatio;
document.getElementById('online').textContent = navigator.onLine ? 'Online' : 'Offline';
document.getElementById('memory').textContent = navigator.deviceMemory
    ? `${navigator.deviceMemory} GB (ca.)` : 'Unbekannt';
```

**Aufwand:** 1 Stunde
**Nutzen:** Mehr System-Infos ohne API-Calls

### Phase 2: Backend-Infos via API (WICHTIG)

**Neuer API-Endpoint:** `/api/system/diagnostics`

```python
@app.route('/api/system/diagnostics', methods=['GET'])
def get_system_diagnostics():
    import platform
    import psutil  # pip install psutil

    return jsonify({
        'os': {
            'name': platform.system(),
            'version': platform.version(),
            'architecture': platform.architecture()[0]
        },
        'computer_name': platform.node(),
        'user': os.environ.get('USERNAME', 'Unbekannt'),
        'access_version': 'Access 2016',  # aus Access-Verbindung
        'backend_path': get_backend_path(),
        'backend_tables': get_backend_tables()
    })
```

**Aufwand:** 4 Stunden
**Nutzen:** Zeigt relevante System-Infos (OS, User, DB-Pfade)

### Phase 3: Backend-Tabellen-Liste (OPTIONAL)

```html
<div class="info-section">
    <h3>📊 Backend-Tabellen</h3>
    <div class="table-list" id="sqlTables">
        <h4>SQL-Backend:</h4>
        <ul id="sqlTablesList"></ul>
    </div>
    <div class="table-list" id="accessTables">
        <h4>Access-Backend:</h4>
        <ul id="accessTablesList"></ul>
    </div>
</div>
```

**Aufwand:** 3 Stunden
**Nutzen:** Vollständige DB-Übersicht wie in Access

### Phase 4: Öffentliche IP via API (OPTIONAL)

```javascript
fetch('https://api.ipify.org?format=json')
    .then(r => r.json())
    .then(data => {
        document.getElementById('publicIP').textContent = data.ip;
    });
```

**Aufwand:** 0.5 Stunden
**Nutzen:** Zeigt öffentliche IP (wie Access)

---

## 7. Priorisierung

| Phase | Feature | Umsetzbar? | Aufwand | Nutzen | Priorität |
|-------|---------|------------|---------|--------|-----------|
| **1** | Browser-Infos erweitern | ✅ Ja | 1h | Mittel | ⭐⭐ |
| **2** | Backend-Infos (API) | ✅ Ja | 4h | Hoch | ⭐⭐⭐ |
| **3** | Backend-Tabellen-Liste | ✅ Ja | 3h | Mittel | ⭐⭐ |
| **4** | Öffentliche IP | ✅ Ja | 0.5h | Niedrig | ⭐ |
| **-** | Windows-APIs | ❌ Nein | - | - | - |
| **-** | Hardware-Details | ❌ Nein | - | - | - |
| **-** | Laufwerks-Info | ❌ Nein | - | - | - |

**Gesamtaufwand (Phase 1-4):** 8.5 Stunden
**Erwarteter Umsetzungsgrad nach allen Phasen:** 60-70% (web-relevante Features)

---

## 8. Besonderheiten

### Access-spezifische Einschränkungen

- **Windows-APIs:** Das Formular nutzt extensive Windows-APIs (atWinVer, atGetMemEx, atDiskfreespaceEx, atgetdevcaps) über VBA Declares. Diese sind in Web-Browsern aus Sicherheitsgründen **nicht verfügbar**.

- **Timer-Funktion:** Access nutzt `OnTimer` Event mit `api_UpdateSysResInfo()` für Live-Updates. In HTML via `setInterval()` umsetzbar.

- **Help-Button:** Zeigt Access-Hilfe an - in HTML nicht relevant.

- **MSInfo-Button:** Startet Windows System-Info (`msinfo32.exe`) - in Web nicht möglich.

### Web-Browser-Limitierungen

- **Keine Filesystem-Zugriffe:** Laufwerke, Speicherplatz nicht lesbar
- **Keine Hardware-APIs:** CPU, RAM nur eingeschränkt verfügbar
- **User-Agent unzuverlässig:** Browser/OS-Erkennung nicht präzise
- **Keine System-Calls:** Externe Programme (msinfo32) nicht aufrufbar

---

## 9. Fazit

**Status:** ⚠️ **Teilweise umgesetzt (25%)**

Das Systeminfo-Formular ist ein **Sonderfall**, da es primär Windows-spezifische System-Informationen über VBA-APIs abruft. Viele dieser Features sind in Web-Browsern **aus Sicherheitsgründen nicht verfügbar**.

### Was KANN umgesetzt werden (Web-relevante Features):

✅ Browser-Informationen (User-Agent, Plattform, Sprache)
✅ Bildschirmauflösung und Farbtiefe
✅ API-Server-Status
✅ Backend-Datenbank-Informationen (via API)
✅ Computername, Benutzername (via API)
✅ Öffentliche IP-Adresse (via externe API)

### Was NICHT umgesetzt werden kann:

❌ Windows-Version (exakt)
❌ CPU-Details (Name, Geschwindigkeit)
❌ RAM-Größe (exakt)
❌ Laufwerks-Informationen (Liste, Speicherplatz, Typen)
❌ Bildschirmgröße in mm
❌ Windows System-Info öffnen (msinfo32.exe)
❌ Access-spezifische Hilfe

### Empfehlung:

1. **Phase 1+2 umsetzen** (5h) → Backend-Infos und erweiterte Browser-Infos zeigen
2. **Rest als "Web-Limitierung" dokumentieren** → Hinweistext: "Einige Hardware-Infos nur in Access-Version verfügbar"
3. **Als Low-Priority behandeln** → Systeminfo ist kein geschäftskritisches Formular

**Endgültiger Umsetzungsgrad realistisch:** 60% (alle web-relevanten Features)
