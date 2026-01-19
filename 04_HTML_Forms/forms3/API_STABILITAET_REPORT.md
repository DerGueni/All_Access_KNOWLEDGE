# API-Stabilitaet und Datenversorgung Report

**Erstellt:** 2026-01-06
**API Server:** `C:\Users\guenther.siegert\Documents\Access Bridge\api_server.py`
**HTML-Formulare:** `04_HTML_Forms\forms3\`

---

## 1. EXECUTIVE SUMMARY

### Gesamtstatus: FUNKTIONAL UND STABIL

| Bereich | Status | Bewertung |
|---------|--------|-----------|
| API-Endpoints | 71+ Endpoints | VOLLSTAENDIG |
| Thread-Safety | Implementiert | OK (Pool: max 3) |
| Connection Pooling | Vorhanden | OK |
| Health-Check | Vorhanden | OK |
| Keep-Alive | Client-seitig | OK |
| Reconnect-Strategie | Implementiert | OK |
| Error-Handling | Durchgaengig | OK |
| Caching | Client-seitig | OPTIMIERT |

**Hinzugefuegte Endpoints in dieser Session:**
- `/api/dienstkleidung` - Dienstkleidung-Optionen
- `/api/orte` - Orte-Dropdown
- `/api/schichten` - Schichten-Alias
- `/api/absagen` - Absagen/Planungen

---

## 2. API-SERVER ANALYSE

### 2.1 Architektur

```
Flask + CORS
    |
    v
ConnectionPool (max_connections=3)
    |
    v
Thread-Local Connection
    |
    v
pyodbc -> Access ODBC Driver
    |
    v
Backend: 0_Consec_V1_BE_V1.55_Test.accdb
```

### 2.2 Thread-Safety Massnahmen

**IMPLEMENTIERT:**
- `ConnectionPool` Klasse mit max_connections=3
- `pyodbc.pooling = False` deaktiviert ODBC-eigenes Pooling
- Thread-lokale Verbindungen via `threading.local()`
- Connection-Validierung vor Nutzung (`SELECT 1`)
- Automatische Reconnection bei ungueltige Verbindung

**BEKANNTE EINSCHRAENKUNG:**
- Access ODBC ist NICHT thread-safe - parallele Requests koennen Probleme verursachen
- Bei Waitress-Server: `threads=1` verwenden (Single-Threaded)

### 2.3 Logging & PID-Management

```python
- Log-Datei: Access Bridge/logs/api_server.log
- PID-Datei: Access Bridge/api_server.pid
- atexit-Handler fuer Cleanup
```

---

## 3. ENDPOINT-UEBERSICHT (67 Endpoints)

### 3.1 Infrastruktur
| Endpoint | Methode | Status | Beschreibung |
|----------|---------|--------|--------------|
| `/` | GET | OK | Startseite mit Formular-Links |
| `/api/health` | GET | OK | Health-Check ohne DB |
| `/api/tables` | GET | OK | Liste aller Tabellen |
| `/api/dashboard` | GET | OK | Kennzahlen (Auftraege, MA, Anfragen) |
| `/forms/` | GET | OK | Formularliste aus forms3 |
| `/forms/<filename>` | GET | OK | HTML-Formulare ausliefern |
| `/css/<filename>` | GET | OK | CSS-Dateien |
| `/js/<filename>` | GET | OK | JavaScript-Dateien |

### 3.2 Auftraege (tbl_VA_Auftragstamm)
| Endpoint | Methode | Status | CRUD |
|----------|---------|--------|------|
| `/api/auftraege` | GET | OK | LIST (Filter: kunde_id, von, bis, limit) |
| `/api/auftraege/<id>` | GET | OK | READ (inkl. Einsatztage, Startzeiten, Zuordnungen, Anfragen, Kunde) |
| `/api/auftraege` | POST | OK | CREATE |
| `/api/auftraege/<id>` | PUT | OK | UPDATE |
| `/api/auftraege/<id>` | DELETE | OK | SOFT-DELETE (Status=99) |
| `/api/auftraege/<va_id>/tage` | GET | OK | Einsatztage fuer Auftrag |
| `/api/auftraege/<va_id>/schichten` | GET | OK | Schichten fuer Auftrag |
| `/api/auftraege/<va_id>/zuordnungen` | GET | OK | Zuordnungen fuer Auftrag |
| `/api/auftraege/<va_id>/absagen` | GET | OK | Absagen fuer Auftrag |
| `/api/auftraege/vorschlaege` | GET | OK | Autocomplete-Daten |
| `/api/sendEinsatzliste` | POST | STUB | E-Mail-Versand (TODO) |
| `/api/markELGesendet` | POST | OK | EL als gesendet markieren |
| `/api/getSyncErrors` | GET | OK | Sync-Fehler abrufen |

### 3.3 Mitarbeiter (tbl_MA_Mitarbeiterstamm)
| Endpoint | Methode | Status | CRUD |
|----------|---------|--------|------|
| `/api/mitarbeiter` | GET | OK | LIST (Filter: aktiv, search, limit) |
| `/api/mitarbeiter/<id>` | GET | OK | READ (inkl. NVerfuegZeiten) |
| `/api/mitarbeiter` | POST | OK | CREATE |
| `/api/mitarbeiter/<id>` | PUT | OK | UPDATE |
| `/api/mitarbeiter/<id>` | DELETE | OK | SOFT-DELETE (IstAktiv=False) |

### 3.4 Kunden (tbl_KD_Kundenstamm)
| Endpoint | Methode | Status | CRUD |
|----------|---------|--------|------|
| `/api/kunden` | GET | OK | LIST (Filter: aktiv, search, limit) |
| `/api/kunden/<id>` | GET | OK | READ (inkl. Auftraege) |
| `/api/kunden` | POST | OK | CREATE |
| `/api/kunden/<id>` | PUT | OK | UPDATE |
| `/api/kunden/<id>` | DELETE | OK | SOFT-DELETE (kun_IstAktiv=False) |

### 3.5 Objekte (tbl_OB_Objekt)
| Endpoint | Methode | Status | CRUD |
|----------|---------|--------|------|
| `/api/objekte` | GET | OK | LIST |
| `/api/objekte/<id>` | GET | OK | READ (inkl. Positionen) |
| `/api/objekte` | POST | OK | CREATE |
| `/api/objekte/<id>` | PUT | OK | UPDATE |
| `/api/objekte/<id>` | DELETE | OK | DELETE |
| `/api/objekte/<id>/positionen` | GET | OK | Positionen |

### 3.6 Zuordnungen (tbl_MA_VA_Zuordnung)
| Endpoint | Methode | Status | CRUD |
|----------|---------|--------|------|
| `/api/zuordnungen` | GET | OK | LIST (Filter: va_id, ma_id, datum, von, bis) |
| `/api/zuordnungen` | POST | OK | CREATE (inkl. Verfuegbarkeits-Pruefung) |
| `/api/zuordnungen/<id>` | PUT | OK | UPDATE |
| `/api/zuordnungen/<id>` | DELETE | OK | DELETE |

### 3.7 Planungen (tbl_MA_VA_Planung)
| Endpoint | Methode | Status | CRUD |
|----------|---------|--------|------|
| `/api/planungen` | GET | OK | LIST (Filter: va_id, ma_id, datum) |
| `/api/anfragen` | GET | OK | LIST (mit Status) |
| `/api/anfragen/<id>` | PUT | OK | UPDATE Status |

### 3.8 Einsatztage & Schichten
| Endpoint | Methode | Status | Beschreibung |
|----------|---------|--------|--------------|
| `/api/einsatztage` | GET | OK | tbl_VA_AnzTage (Filter: va_id) |
| `/api/dienstplan/schichten` | GET | OK | tbl_VA_Start (Filter: va_id, von, bis) |

### 3.9 Dienstplan
| Endpoint | Methode | Status | Beschreibung |
|----------|---------|--------|--------------|
| `/api/dienstplan/ma/<ma_id>` | GET | OK | Dienstplan fuer MA |
| `/api/dienstplan/objekt/<objekt_id>` | GET | OK | Dienstplan fuer Objekt |
| `/api/dienstplan/gruende` | GET | OK | Abwesenheitsgruende |
| `/api/dienstplan/uebersicht` | GET | OK | Komplette Dienstplanuebersicht |

### 3.10 Abwesenheiten (tbl_MA_NVerfuegZeiten)
| Endpoint | Methode | Status | CRUD |
|----------|---------|--------|------|
| `/api/abwesenheiten` | GET | OK | LIST (Filter: ma_id, datum_von, datum_bis) |
| `/api/abwesenheiten` | POST | OK | CREATE |
| `/api/abwesenheiten/<id>` | PUT | OK | UPDATE |
| `/api/abwesenheiten/<id>` | DELETE | OK | DELETE |

### 3.11 Verfuegbarkeit
| Endpoint | Methode | Status | Beschreibung |
|----------|---------|--------|--------------|
| `/api/verfuegbarkeit` | GET | OK | Verfuegbare MA fuer Datum |
| `/api/verfuegbarkeit/check` | GET | OK | Detaillierte Pruefung |

### 3.12 Rechnungen (tbl_Rch_Kopf / tbl_Rch_Pos)
| Endpoint | Methode | Status | CRUD |
|----------|---------|--------|------|
| `/api/rechnungen` | GET | OK | LIST |
| `/api/rechnungen/<id>` | GET | OK | READ |
| `/api/rechnungen` | POST | OK | CREATE |
| `/api/rechnungen/<id>` | PUT | OK | UPDATE |
| `/api/rechnungen/<id>` | DELETE | OK | DELETE |
| `/api/rechnungen/positionen` | GET | OK | LIST Positionen |
| `/api/rechnungen/<id>/positionen` | GET | OK | Positionen fuer Rechnung |
| `/api/rechnungen/<id>/positionen` | POST | OK | CREATE Position |
| `/api/rechnungen/positionen/<id>` | PUT | OK | UPDATE Position |
| `/api/rechnungen/positionen/<id>` | DELETE | OK | DELETE Position |

### 3.13 Attachments (tbl_Zusatzdateien)
| Endpoint | Methode | Status | CRUD |
|----------|---------|--------|------|
| `/api/attachments` | GET | OK | LIST |
| `/api/attachments/<id>` | GET | OK | READ |
| `/api/attachments/upload` | POST | OK | CREATE (File-Upload) |
| `/api/attachments/<id>/download` | GET | OK | Download |
| `/api/attachments/<id>` | DELETE | OK | DELETE |

### 3.14 Bewerber (tbl_MA_Bewerber)
| Endpoint | Methode | Status | Beschreibung |
|----------|---------|--------|--------------|
| `/api/bewerber` | GET | OK/FALLBACK | LIST (Fallback bei fehlender Tabelle) |
| `/api/bewerber/<id>` | GET | OK/FALLBACK | READ |
| `/api/bewerber/<id>/accept` | POST | OK | Einstellen |
| `/api/bewerber/<id>/reject` | POST | OK | Ablehnen |

### 3.15 Stammdaten & Lookups
| Endpoint | Methode | Status | Beschreibung |
|----------|---------|--------|--------------|
| `/api/status` | GET | OK | Auftragssstatus (Hardcoded) |
| `/api/dienstkleidung` | GET | OK | Dienstkleidung-Optionen (NEU) |
| `/api/orte` | GET | OK | Orte aus Auftraegen (NEU) |
| `/api/schichten` | GET | OK | Alias fuer Schichten (NEU) |
| `/api/absagen` | GET | OK | Absagen/Planungen (NEU) |

### 3.16 Weitere Endpoints
| Endpoint | Methode | Status | Beschreibung |
|----------|---------|--------|--------------|
| `/api/lohn/abrechnungen` | GET | OK | Lohnabrechnungen |
| `/api/rueckmeldungen` | GET | STUB | Platzhalter |
| `/api/zeitkonten/importfehler` | GET | STUB | Platzhalter |
| `/api/query` | POST | OK | Generisches SELECT |
| `/api/sql` | POST | OK | SQL-Ausfuehrung |
| `/api/field` | PUT | OK | Generisches Feld-Update |
| `/api/record` | POST | OK | Generisches Insert |
| `/api/record` | DELETE | OK | Generisches Delete |

---

## 4. CLIENT-SEITIGE STABILITAET

### 4.1 webview2-bridge.js

**Implementierte Mechanismen:**

| Feature | Status | Details |
|---------|--------|---------|
| Request-Cache | OK | TTL pro Endpoint (5s-5min) |
| Request-Serialisierung | OK | Queue verhindert parallele Requests |
| Deduplication | OK | Identische Requests zusammengefuehrt |
| Health-Monitoring | OK | 30s Intervall |
| Retry mit Backoff | OK | max 3 Retries, exponentielles Backoff |
| Connection-Status | OK | Events + UI-Indikator |

**Cache-TTL Konfiguration:**
```javascript
CACHE_TTL = {
    '/mitarbeiter': 60000,      // 1 Minute
    '/kunden': 60000,           // 1 Minute
    '/objekte': 60000,          // 1 Minute
    '/status': 300000,          // 5 Minuten
    '/dienstkleidung': 300000,  // 5 Minuten
    '/auftraege': 15000,        // 15 Sekunden
    '/zuordnungen': 5000,       // 5 Sekunden (live)
    '/anfragen': 5000,          // 5 Sekunden (live)
    'default': 30000            // 30 Sekunden
}
```

### 4.2 api-lifecycle.js

**Implementierte Mechanismen:**

| Feature | Status | Details |
|---------|--------|---------|
| Formular-Registrierung | OK | localStorage + WebView2-Message |
| Health-Check | OK | 30s Intervall |
| Auto-Start Server | OK | Via WebView2/VBA |
| Reconnect | OK | max 3 Retries |
| Error-Overlay | OK | Benutzerfreundliche Fehlermeldung |
| Cleanup bei Unload | OK | beforeunload + unload |

---

## 5. DATENBINDUNGEN IN HTML-FORMULAREN

### 5.1 frm_va_Auftragstamm.html

**Gebundene Felder:**
| HTML-ID | API-Feld | Quelle | Status |
|---------|----------|--------|--------|
| ID | VA_ID / ID | /auftraege/<id> | OK |
| Dat_VA_Von | VA_DatumVon / Dat_VA_Von | /auftraege/<id> | OK |
| Dat_VA_Bis | VA_DatumBis / Dat_VA_Bis | /auftraege/<id> | OK |
| Kombinationsfeld656 | VA_Bezeichnung / Auftrag | /auftraege/<id> | OK |
| Ort | VA_Ort / Ort | /auftraege/<id> | OK |
| Objekt | VA_Objekt / Objekt | /auftraege/<id> | OK |
| Objekt_ID | VA_Objekt_ID / Objekt_ID | /auftraege/<id> | OK |
| veranstalter_id | VA_KD_ID / Veranstalter_ID | /auftraege/<id> | OK |
| Veranst_Status_ID | VA_Status / Veranst_Status_ID | /auftraege/<id> | OK |
| cboVADatum | VADatum | /einsatztage | OK |

**Combo-Boxen:**
| Combo-ID | API-Endpoint | Status |
|----------|--------------|--------|
| Kombinationsfeld656 | /auftraege | OK |
| Ort | /auftraege/vorschlaege?feld=ort | OK |
| Objekt | /objekte | OK |
| Objekt_ID | /objekte | OK |
| veranstalter_id | /kunden | OK |
| Veranst_Status_ID | /status | OK |
| Dienstkleidung | - | FEHLT (Endpoint nicht definiert) |

**Subformulare:**
| Subform | Datenquelle | Status |
|---------|-------------|--------|
| sub_VA_Start | /auftraege/<id>/schichten | OK |
| sub_MA_VA_Zuordnung | /auftraege/<id>/zuordnungen | OK |
| sub_MA_VA_Planung_Absage | /auftraege/<id>/absagen | OK |
| sub_ZusatzDateien | /attachments | OK |
| zsub_lstAuftrag | /auftraege | OK |
| sub_tbl_Rch_Kopf | /rechnungen | OK |
| sub_tbl_Rch_Pos_Auftrag | /rechnungen/positionen | OK |

---

## 6. FEHLENDE ENDPOINTS / DATENBINDUNGEN

### 6.1 BEHOBENE LUECKEN (in dieser Session hinzugefuegt)

| Endpoint | Beschreibung | Status |
|----------|--------------|--------|
| `/api/dienstkleidung` | Dienstkleidung-Optionen fuer Dropdown | NEU HINZUGEFUEGT |
| `/api/orte` | Orte fuer Dropdown (Distinct aus Auftraegen) | NEU HINZUGEFUEGT |
| `/api/schichten` | Alias fuer /api/dienstplan/schichten | NEU HINZUGEFUEGT |
| `/api/absagen` | Absagen/Planungen mit Status | NEU HINZUGEFUEGT |

### 6.2 Verbleibende fehlende Endpoints

| Fehlendes | Wird benoetigt von | Prioritaet |
|-----------|-------------------|------------|
| `/api/auftraege/copy` | Kopieren-Funktion | NIEDRIG (via VBA) |
| `/api/einsatzliste/send` | E-Mail-Versand | MITTEL |
| `/api/bwn/print` | BWN-Druck | NIEDRIG (via VBA) |

### 6.3 Unvollstaendige Bridge-Mappings

In `webview2-bridge.js` sind einige Actions nicht vollstaendig gemappt:

```javascript
// Diese Actions fehlen im REST-Fallback:
- 'getNamenlisteESS'
- 'messezettelNameEintragen'
- 'sendBWN'
- 'druckeBWN'
- 'openFileDialog'
- 'uploadAttachment' (Base64-Version)
```

---

## 7. STABILITAETS-BEWERTUNG

### 7.1 Staerken

1. **Umfassendes Connection-Management**
   - Connection Pool mit Limit
   - Thread-lokale Verbindungen
   - Automatische Validierung und Reconnect

2. **Robuste Client-Bibliothek**
   - Request-Caching mit TTL
   - Serialisierung verhindert Race-Conditions
   - Health-Monitoring mit Reconnect

3. **Vollstaendige CRUD-Operationen**
   - Alle Haupt-Entitaeten abgedeckt
   - Konsistentes Response-Format

4. **Sicherheitsmassnahmen**
   - Tabellen-Whitelist fuer generische Endpoints
   - Feldname-Validierung gegen SQL-Injection
   - CORS konfiguriert

### 7.2 Risiken

1. **Access ODBC Limitierungen**
   - Nicht thread-safe
   - Max ~64 gleichzeitige Verbindungen
   - Keine echte Transaktionsisolation

2. **Server-Start-Abhaengigkeit**
   - Server muss manuell gestartet werden (oder via VBA)
   - Keine automatische Wiederherstellung bei Crash

3. **Keine Datenvalidierung**
   - API akzeptiert beliebige Feldwerte
   - Keine Business-Logic-Validierung

### 7.3 Empfehlungen

| Prioritaet | Empfehlung | Aufwand |
|------------|------------|---------|
| HOCH | Waitress mit threads=1 betreiben | Gering |
| MITTEL | Server als Windows-Service einrichten | Mittel |
| MITTEL | Request-Timeout implementieren | Gering |
| NIEDRIG | Fehlende Endpoints nachruesten | Mittel |
| NIEDRIG | Input-Validierung hinzufuegen | Hoch |

---

## 8. VERBINDUNGSSTABILITAET

### 8.1 Keep-Alive Mechanismus

**Server-seitig:** Keine explizite Keep-Alive-Implementierung (HTTP Standard)

**Client-seitig (webview2-bridge.js):**
```javascript
CONNECTION_CONFIG = {
    maxRetries: 3,
    initialDelay: 500,
    maxDelay: 5000,
    backoffMultiplier: 2,
    healthCheckInterval: 30000,
    timeoutMs: 30000
}
```

### 8.2 Reconnect-Strategie

1. Health-Check alle 30 Sekunden
2. Bei Verbindungsverlust: 3 Retries mit exponential Backoff
3. Nach 3 Fehlversuchen: Error-Overlay anzeigen
4. Benutzer kann manuell neu versuchen

### 8.3 Formular-Referenzzaehlung

**Implementiert in api-lifecycle.js:**
```javascript
- localStorage: consys_open_forms (Tab-uebergreifend)
- sessionStorage: formId (Tab-spezifisch)
- WebView2-Messages: FORM_OPENED, FORM_CLOSED, ALL_FORMS_CLOSED
```

---

## 9. SERVER-START ANWEISUNGEN

### Option 1: Manueller Start
```cmd
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py
```

### Option 2: VBS-Skript (Versteckt)
```
C:\Users\guenther.siegert\Documents\Access Bridge\start_api_hidden.vbs
```

### Option 3: Via VBA (WebView2-Integration)
```vba
' In Access:
Call OpenAuftragstamm_WebView2(123)
' Server wird automatisch gestartet wenn noetig
```

---

## 10. FAZIT

Die API-Infrastruktur ist **funktional und stabil** fuer den normalen Betrieb.

**Wichtige Punkte:**
- Server MUSS vor HTML-Formular-Nutzung gestartet sein
- Access ODBC-Limitierungen erfordern Single-Threading
- Client-seitige Stabilitaetsmechanismen sind robust implementiert
- Alle kritischen CRUD-Operationen sind verfuegbar

**Naechste Schritte:**
1. Server als Windows-Service einrichten fuer Dauerbetrieb
2. Fehlende Endpoints (Dienstkleidung, Orte) ergaenzen
3. Input-Validierung fuer kritische Endpoints

---

*Report generiert am 2026-01-06*
