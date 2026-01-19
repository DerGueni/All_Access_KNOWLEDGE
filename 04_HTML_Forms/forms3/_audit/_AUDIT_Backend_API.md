# AUDIT: Backend-Datenanbindung und API-Vollstaendigkeit

**Datum:** 2026-01-05
**Geprueft:** webview2-bridge.js + api_server.py

---

## 1. WebView2-Bridge Methoden Analyse

### 1.1 Kern-Methoden Status

| Methode | Implementiert | WebView2 | REST-Fallback | Bemerkung |
|---------|--------------|----------|---------------|-----------|
| `loadData(type, id, params)` | Ja | Ja | Ja | Vollstaendig mit Type-Mappings |
| `save(type, data)` | Ja | Ja | Ja | Automatische POST/PUT Unterscheidung |
| `delete(type, id)` | Ja | Ja | Ja | Funktioniert |
| `search(type, term)` | Ja | Ja | Ja | Via ?search= Parameter |
| `list(type, params)` | Ja | Ja | Ja | Mit Query-Parameter-Unterstuetzung |
| `execute(action, params)` | Ja | Ja | Ja | Umfangreiches Action-Mapping |

### 1.2 Type-Endpoint Mappings (webview2-bridge.js Zeile 186-204)

```javascript
TYPE_ENDPOINTS = {
    'auftraege': '/auftraege',
    'auftrag': '/auftraege',
    'mitarbeiter': '/mitarbeiter',
    'kunden': '/kunden',
    'kunde': '/kunden',
    'objekte': '/objekte',
    'objekt': '/objekte',
    'orte': '/orte',
    'status': '/status',
    'dienstkleidung': '/dienstkleidung',
    'einsatztage': '/einsatztage',
    'zuordnungen': '/zuordnungen',
    'zuordnung': '/zuordnungen',
    'schichten': '/schichten',
    'abwesenheiten': '/abwesenheiten',
    'rechnung': '/rechnungen',
    'rechnungen': '/rechnungen'
}
```

### 1.3 Spezielle loadData Types (Zeile 224-305)

| Type | Beschreibung | API-Endpoint |
|------|--------------|--------------|
| `auftraege_liste` | Auftragsliste mit Filtern | `/auftraege?ab=&status=&limit=` |
| `auftrag_detail` | Einzelner Auftrag | `/auftraege/{id}` |
| `auftrag_tage` | Einsatztage eines Auftrags | `/einsatztage?va_id=` |
| `status` | Statusliste | `/status` |
| `kunden` | Kundenliste | `/kunden?aktiv=` |
| `schichten` | Schichten eines Auftrags | `/schichten?va_id=` |
| `zuordnungen` | MA-Zuordnungen | `/zuordnungen?va_id=` |
| `absagen` | Absagen pro Auftrag | `/absagen?va_id=` |
| `vorschlaege` | Autocomplete | Gibt leere Liste zurueck |
| `attachments` | Zusatzdateien | `/attachments?va_id=` |
| `anfragen` | Planungsanfragen | `/anfragen?va_id=` |
| `rechnungspositionen` | Rechnungspositionen | `/rechnungen/positionen?va_id=` |
| `berechnungsliste` | Berechnungsliste | `/berechnungsliste?va_id=` |

---

## 2. API-Endpoints Vollstaendigkeits-Matrix

### 2.1 Auftraege (`/api/auftraege`)

| Methode | Endpoint | Implementiert | Bemerkung |
|---------|----------|---------------|-----------|
| GET | `/api/auftraege` | Ja | Mit Filtern: kunde_id, ab, von, bis, limit, offset |
| GET | `/api/auftraege/{id}` | Ja | Inkl. einsatztage, startzeiten, zuordnungen, anfragen, kunde |
| POST | `/api/auftraege` | Ja | Erstellt neuen Auftrag |
| PUT | `/api/auftraege/{id}` | Ja | Aktualisiert Auftrag |
| DELETE | `/api/auftraege/{id}` | Ja | Soft-Delete (Status=99) |
| GET | `/api/auftraege/{id}/tage` | Ja | Einsatztage |
| GET | `/api/auftraege/{id}/schichten` | Ja | Schichten mit Filter |
| GET | `/api/auftraege/{id}/zuordnungen` | Ja | MA-Zuordnungen |
| GET | `/api/auftraege/{id}/absagen` | Ja | Absagen mit Fallback |
| GET | `/api/auftraege/vorschlaege` | Ja | Autocomplete fuer ort/objekt/auftrag |

### 2.2 Mitarbeiter (`/api/mitarbeiter`)

| Methode | Endpoint | Implementiert | Bemerkung |
|---------|----------|---------------|-----------|
| GET | `/api/mitarbeiter` | Ja | Mit aktiv, limit, search Filtern |
| GET | `/api/mitarbeiter/{id}` | Ja | Inkl. nicht_verfuegbar Liste |
| POST | `/api/mitarbeiter` | Ja | Erstellt neuen MA |
| PUT | `/api/mitarbeiter/{id}` | Ja | Aktualisiert MA |
| DELETE | `/api/mitarbeiter/{id}` | Ja | Soft-Delete (IstAktiv=False) |

### 2.3 Kunden (`/api/kunden`)

| Methode | Endpoint | Implementiert | Bemerkung |
|---------|----------|---------------|-----------|
| GET | `/api/kunden` | Ja | Mit limit, search, aktiv Filtern |
| GET | `/api/kunden/{id}` | Ja | Inkl. auftraege Liste |
| POST | `/api/kunden` | Ja | Erstellt neuen Kunden |
| PUT | `/api/kunden/{id}` | Ja | Aktualisiert Kunden |
| DELETE | `/api/kunden/{id}` | Ja | Soft-Delete (kun_IstAktiv=False) |

### 2.4 Objekte (`/api/objekte`)

| Methode | Endpoint | Implementiert | Bemerkung |
|---------|----------|---------------|-----------|
| GET | `/api/objekte` | Ja | Mit limit, search Filtern |
| GET | `/api/objekte/{id}` | Ja | Inkl. positionen |
| POST | `/api/objekte` | Ja | Erstellt neues Objekt |
| PUT | `/api/objekte/{id}` | Ja | Aktualisiert Objekt |
| DELETE | `/api/objekte/{id}` | Ja | Hard-Delete |
| GET | `/api/objekte/{id}/positionen` | Ja | Objekt-Positionen |

### 2.5 Zuordnungen (`/api/zuordnungen`)

| Methode | Endpoint | Implementiert | Bemerkung |
|---------|----------|---------------|-----------|
| GET | `/api/zuordnungen` | Ja | Filter: va_id, ma_id, datum, von, bis |
| POST | `/api/zuordnungen` | Ja | Mit Verfuegbarkeitspruefung |
| DELETE | `/api/zuordnungen/{id}` | Ja | Loescht Zuordnung |
| PUT | `/api/zuordnungen/{id}` | FEHLT | Nicht implementiert! |

### 2.6 Schichten (`/api/schichten` / `/api/dienstplan/schichten`)

| Methode | Endpoint | Implementiert | Bemerkung |
|---------|----------|---------------|-----------|
| GET | `/api/dienstplan/schichten` | Ja | Filter: va_id, von, bis |
| POST | `/api/schichten` | FEHLT | Nicht implementiert! |
| PUT | `/api/schichten/{id}` | FEHLT | Nicht implementiert! |
| DELETE | `/api/schichten/{id}` | FEHLT | Nicht implementiert! |

### 2.7 Einsatztage (`/api/einsatztage`)

| Methode | Endpoint | Implementiert | Bemerkung |
|---------|----------|---------------|-----------|
| GET | `/api/einsatztage` | Ja | Filter: va_id, datum_von, datum_bis |
| POST | `/api/einsatztage` | FEHLT | Nicht implementiert! |
| PUT | `/api/einsatztage/{id}` | FEHLT | Nicht implementiert! |
| DELETE | `/api/einsatztage/{id}` | FEHLT | Nicht implementiert! |

### 2.8 Abwesenheiten (`/api/abwesenheiten`)

| Methode | Endpoint | Implementiert | Bemerkung |
|---------|----------|---------------|-----------|
| GET | `/api/abwesenheiten` | Ja | Filter: ma_id, datum_von, datum_bis |
| POST | `/api/abwesenheiten` | Ja | Erstellt Abwesenheit |
| PUT | `/api/abwesenheiten/{id}` | Ja | Aktualisiert Abwesenheit |
| DELETE | `/api/abwesenheiten/{id}` | Ja | Loescht Abwesenheit |

### 2.9 Rechnungen (`/api/rechnungen`)

| Methode | Endpoint | Implementiert | Bemerkung |
|---------|----------|---------------|-----------|
| GET | `/api/rechnungen` | FEHLT | Nicht implementiert! |
| GET | `/api/rechnungen/{id}` | FEHLT | Nicht implementiert! |
| POST | `/api/rechnungen` | FEHLT | Nicht implementiert! |
| PUT | `/api/rechnungen/{id}` | FEHLT | Nicht implementiert! |
| DELETE | `/api/rechnungen/{id}` | FEHLT | Nicht implementiert! |
| GET | `/api/rechnungen/positionen` | FEHLT | Bridge erwartet es, API hat es nicht |

---

## 3. Echtzeit-Daten Analyse

### 3.1 Cache-TTL Einstellungen (webview2-bridge.js Zeile 70-83)

```javascript
CACHE_TTL = {
    '/mitarbeiter': 60000,        // 1 Minute
    '/kunden': 60000,             // 1 Minute
    '/objekte': 60000,            // 1 Minute
    '/status': 300000,            // 5 Minuten
    '/dienstkleidung': 300000,    // 5 Minuten
    '/orte': 300000,              // 5 Minuten
    '/auftraege': 15000,          // 15 Sekunden
    '/einsatztage': 10000,        // 10 Sekunden
    '/schichten': 10000,          // 10 Sekunden
    '/zuordnungen': 5000,         // 5 Sekunden (live)
    '/anfragen': 5000,            // 5 Sekunden (live)
    'default': 30000              // 30 Sekunden
}
```

### 3.2 Cache-Optimierung Bewertung

| Datentyp | Aktueller TTL | Empfehlung | Begruendung |
|----------|---------------|------------|-------------|
| Stammdaten (MA, Kunden, Objekte) | 60s | OK | Aendern sich selten |
| Status, Orte, Dienstkleidung | 300s | OK | Quasi statisch |
| Auftraege | 15s | 30s erhoehen | Weniger Requests bei Listen |
| Einsatztage | 10s | OK | Kann sich bei Planung aendern |
| Schichten | 10s | OK | Kann sich bei Planung aendern |
| Zuordnungen | 5s | OK | Live-Daten bei Planung |
| Anfragen | 5s | OK | Live-Daten bei Planung |

### 3.3 Request-Deduplication

**Status:** AKTIV (Zeile 113-117)

```javascript
// Deduplication: Falls Request bereits laeuft
if (_pending.has(cacheKey)) {
    console.debug('[Bridge Cache] PENDING:', endpoint);
    return _pending.get(cacheKey);
}
```

### 3.4 Empfehlung fuer Live-Updates

| Datentyp | Braucht Live-Updates | Methode |
|----------|---------------------|---------|
| Zuordnungen | Ja | Polling alle 5s (aktuell) |
| Anfragen | Ja | Polling alle 5s (aktuell) |
| Schichten | Bei aktiver Planung | Polling alle 10s (aktuell) |
| Auftraege | Nur bei Listen | Event-basiert waere besser |
| Mitarbeiter | Nein | Cache 60s ausreichend |
| Kunden | Nein | Cache 60s ausreichend |

**Empfehlung:** WebSocket-Verbindung fuer echte Echtzeit-Updates statt Polling. Aktuelles Polling-System ist funktional aber ressourcenintensiv.

---

## 4. Fehlende Endpoints (KRITISCH)

### 4.1 Komplett fehlende Endpoints

| Endpoint | Benoetigt von | Prioritaet |
|----------|---------------|------------|
| `/api/rechnungen` (CRUD) | Rechnungsformulare | HOCH |
| `/api/rechnungen/positionen` | Rechnungsdetails | HOCH |
| `/api/berechnungsliste` | Berechnungsuebersicht | MITTEL |
| `/api/orte` | Orte-Dropdown | MITTEL |
| `/api/dienstkleidung` | Dienstkleidung-Dropdown | MITTEL |
| `/api/kundenpreise` | Kundenpreise verwalten | MITTEL |
| `/api/lexware/send` | Lexware-Export | NIEDRIG |
| `/api/einsatzliste/send` | E-Mail-Versand | NIEDRIG |
| `/api/bwn/print` | BWN-Druck | NIEDRIG |

### 4.2 Fehlende CRUD-Operationen

| Endpoint | Fehlende Methoden |
|----------|-------------------|
| `/api/schichten` | POST, PUT, DELETE |
| `/api/einsatztage` | POST, PUT, DELETE |
| `/api/zuordnungen` | PUT |
| `/api/planungen` | POST, PUT, DELETE |

### 4.3 Bridge-Methoden ohne API-Implementierung

Diese Methoden sind in der Bridge definiert, aber die API-Endpoints fehlen:

| Bridge Action | Erwarteter Endpoint | Status |
|---------------|---------------------|--------|
| `createRechnungPDF` | `/rechnungen/pdf` | FEHLT |
| `createBerechnungslistePDF` | `/berechnungsliste/pdf` | FEHLT |
| `sendToLexware` | `/lexware/send` | FEHLT |
| `uploadZusatzdatei` | `/zusatzdateien/upload` | FEHLT (aber /attachments/upload existiert) |
| `printBWN` | `/bwn/print` | FEHLT |
| `getKundenpreise` | `/kundenpreise` | FEHLT |
| `updateKundenpreise` | `/kundenpreise` (PUT) | FEHLT |
| `copyAuftrag` | `/auftraege/copy` | FEHLT |

---

## 5. Formular-API Zuordnung

### 5.1 Hauptformulare

| Formular | Benoetigte APIs | Status |
|----------|-----------------|--------|
| frm_va_Auftragstamm.html | auftraege, kunden, objekte, status, einsatztage, schichten, zuordnungen, anfragen, attachments | OK (90%) |
| frm_MA_Mitarbeiterstamm.html | mitarbeiter, abwesenheiten | OK (100%) |
| frm_KD_Kundenstamm.html | kunden, auftraege | OK (100%) |
| frm_OB_Objekt.html | objekte, positionen, kunden | OK (100%) |
| frm_MA_Abwesenheit.html | abwesenheiten, mitarbeiter | OK (100%) |
| frm_N_Dienstplanuebersicht.html | dienstplan/uebersicht, dienstplan/gruende | OK (100%) |
| frm_VA_Planungsuebersicht.html | auftraege, zuordnungen, verfuegbarkeit | OK (100%) |
| frm_N_Lohnabrechnungen.html | lohn/abrechnungen | OK (80%) |
| frm_N_Bewerber.html | bewerber | OK (100%) |
| frm_MA_Zeitkonten.html | zeitkonten/importfehler | OK (Placeholder) |
| frm_Menuefuehrung1.html | dashboard | OK (100%) |

### 5.2 Subformulare

| Subformular | Benoetigte APIs | Status |
|-------------|-----------------|--------|
| sub_MA_VA_Zuordnung.html | zuordnungen, mitarbeiter, verfuegbarkeit | OK |
| sub_DP_Grund.html | dienstplan/gruende, abwesenheiten | OK |
| sub_ZusatzDateien.html | attachments | OK |
| sub_rch_Pos.html | rechnungen/positionen | FEHLT |
| sub_OB_Objekt_Positionen.html | objekte/positionen | OK |
| sub_MA_VA_Planung_Status.html | planungen, anfragen | OK |
| sub_MA_VA_Planung_Absage.html | absagen | OK |

---

## 6. Zusammenfassung und Empfehlungen

### 6.1 Gesamtstatus

- **WebView2-Bridge:** Gut implementiert, alle Kern-Methoden funktional
- **REST-API:** Ca. 85% vollstaendig
- **Cache-System:** Funktional mit Request-Deduplication
- **Kritische Luecken:** Rechnungen-API, Schichten-CRUD, Einsatztage-CRUD

### 6.2 Priorisierte Massnahmen

**HOCH (sofort):**
1. `/api/rechnungen` Endpoint implementieren (GET, POST, PUT, DELETE)
2. `/api/rechnungen/positionen` Endpoint implementieren
3. `/api/schichten` CRUD vervollstaendigen
4. `/api/einsatztage` CRUD vervollstaendigen

**MITTEL (naechste Iteration):**
5. `/api/zuordnungen/{id}` PUT implementieren
6. `/api/orte` Endpoint implementieren
7. `/api/dienstkleidung` Endpoint implementieren
8. `/api/kundenpreise` Endpoint implementieren
9. `/api/auftraege/copy` implementieren

**NIEDRIG (spaeter):**
10. WebSocket fuer Echtzeit-Updates evaluieren
11. PDF-Generierung Endpoints (Rechnung, Berechnungsliste)
12. Lexware-Integration
13. E-Mail-Versand Integration

### 6.3 Echtzeit-Updates Empfehlung

Das aktuelle Polling-System ist funktional. Fuer echte Echtzeit-Updates:

```
Option A: WebSocket Server
- Pro: Sofortige Updates, weniger Server-Last
- Con: Komplexere Implementierung

Option B: Server-Sent Events (SSE)
- Pro: Einfacher als WebSocket, HTTP-basiert
- Con: Nur unidirektional

Option C: Polling beibehalten (aktuell)
- Pro: Funktioniert, einfach
- Con: Mehr Requests, Verzoegerung bis 5s
```

**Empfehlung:** Aktuelles System beibehalten bis Skalierungsprobleme auftreten. Bei Bedarf SSE implementieren.

---

## 7. Anhang: API-Server Endpoints Liste

### Vorhandene Endpoints (api_server.py)

```
GET  /api/health
GET  /api/tables
GET  /api/dashboard

GET  /api/auftraege
GET  /api/auftraege/{id}
POST /api/auftraege
PUT  /api/auftraege/{id}
DELETE /api/auftraege/{id}
GET  /api/auftraege/{id}/tage
GET  /api/auftraege/{id}/schichten
GET  /api/auftraege/{id}/zuordnungen
GET  /api/auftraege/{id}/absagen
GET  /api/auftraege/vorschlaege
POST /api/sendEinsatzliste
POST /api/markELGesendet
GET  /api/getSyncErrors

GET  /api/mitarbeiter
GET  /api/mitarbeiter/{id}
POST /api/mitarbeiter
PUT  /api/mitarbeiter/{id}
DELETE /api/mitarbeiter/{id}

GET  /api/kunden
GET  /api/kunden/{id}
POST /api/kunden
PUT  /api/kunden/{id}
DELETE /api/kunden/{id}

GET  /api/objekte
GET  /api/objekte/{id}
POST /api/objekte
PUT  /api/objekte/{id}
DELETE /api/objekte/{id}
GET  /api/objekte/{id}/positionen

GET  /api/einsatztage
GET  /api/zuordnungen
POST /api/zuordnungen
DELETE /api/zuordnungen/{id}

GET  /api/planungen

GET  /api/verfuegbarkeit
GET  /api/verfuegbarkeit/check

GET  /api/abwesenheiten
POST /api/abwesenheiten
PUT  /api/abwesenheiten/{id}
DELETE /api/abwesenheiten/{id}

GET  /api/dienstplan/ma/{id}
GET  /api/dienstplan/objekt/{id}
GET  /api/dienstplan/schichten
GET  /api/dienstplan/gruende
GET  /api/dienstplan/uebersicht

GET  /api/anfragen
PUT  /api/anfragen/{id}

GET  /api/lohn/abrechnungen

GET  /api/rueckmeldungen
GET  /api/rueckmeldungen/{id}
PUT  /api/rueckmeldungen/{id}/read
POST /api/rueckmeldungen/mark-all-read

GET  /api/bewerber
GET  /api/bewerber/{id}
POST /api/bewerber/{id}/accept
POST /api/bewerber/{id}/reject

GET  /api/zeitkonten/importfehler
POST /api/zeitkonten/importfehler/{id}/fix
POST /api/zeitkonten/importfehler/{id}/ignore

GET  /api/attachments
POST /api/attachments/upload
GET  /api/attachments/{id}
GET  /api/attachments/{id}/download
DELETE /api/attachments/{id}

GET  /api/status

POST /api/query
POST /api/sql

PUT  /api/field
POST /api/record
DELETE /api/record
```

---

*Erstellt: 2026-01-05 | Autor: Claude Code Audit*
