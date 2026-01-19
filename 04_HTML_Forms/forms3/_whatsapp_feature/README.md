# WhatsApp Business Integration Feature

**Datum:** 2026-01-10
**Zweck:** Mitarbeiter-Anfragen per WhatsApp statt E-Mail versenden

## Übersicht

Dieses Feature ersetzt die E-Mail-Benachrichtigung für Einsatzanfragen durch WhatsApp Business (Meta Cloud API).

### Workflow

1. Disponent klickt "Alle Mitarbeiter anfragen" oder "Nur Selektierte anfragen" in `frm_MA_VA_Schnellauswahl`
2. Anfragen werden in `tbl_MA_VA_Planung` erstellt (Status_ID = 1)
3. WhatsApp-Nachricht wird an alle MA gesendet:
   > "Hi [Vorname], Du hast neue Nachrichten in Deiner Consec App.
   > Öffne die App, um Deine Einsatzanfragen zu sehen: [Link]"
4. Status wird auf 2 (Benachrichtigt) gesetzt
5. MA öffnet Web-App, sieht Anfrage, klickt JA oder NEIN
6. Bei JA: MA wird in `tbl_MA_VA_Zuordnung` eingetragen
7. Bei NEIN: Status_ID wird auf 4 (Abgesagt) gesetzt
8. Dashboard aktualisiert automatisch (30s Auto-Sync)

## Geänderte Dateien

### 1. api_server.py
**Pfad:** `C:\Users\guenther.siegert\Documents\Access Bridge\api_server.py`

Neue Endpoints:
- `POST /api/whatsapp/send` - Einzelne Nachricht senden
- `POST /api/whatsapp/anfragen` - Massenversand an alle offenen Anfragen
- `GET /api/whatsapp/status` - Konfigurationsstatus
- `POST /api/planungen/{id}/zusage` - Zusage verarbeiten (MA → Zuordnung)
- `POST /api/planungen/{id}/absage` - Absage verarbeiten (Status = 4)

### 2. frm_MA_VA_Schnellauswahl.html
**Pfad:** `04_HTML_Forms/forms3/frm_MA_VA_Schnellauswahl.html`

Geänderte Funktion: `show_requestlog(selectedOnly)`
- Ruft jetzt `/api/whatsapp/anfragen` statt mailto:
- Fallback auf E-Mail wenn WhatsApp nicht konfiguriert

### 3. dashboard.js (Web-App)
**Pfad:** `04_HTML_Forms/forms3/App/js/dashboard.js`

Geänderte Funktion: `handleAntwort(anfrageId, istZusage)`
- Nutzt neue `/zusage` und `/absage` Endpoints
- Automatische Aktualisierung nach Antwort

## Konfiguration

### Meta Cloud API Credentials

Setze folgende Umgebungsvariablen vor dem Start des API-Servers:

```batch
set WA_PHONE_NUMBER_ID=<Deine Meta Phone Number ID>
set WA_ACCESS_TOKEN=<Dein Meta Graph API Access Token>
```

Oder in PowerShell:
```powershell
$env:WA_PHONE_NUMBER_ID = "<Deine Meta Phone Number ID>"
$env:WA_ACCESS_TOKEN = "<Dein Meta Graph API Access Token>"
```

### Absender-Nummer
Die Absender-Nummer ist fest konfiguriert: `+4991140997799`

### Web-App URL
Die Web-App URL ist fest konfiguriert:
`https://webapp.consec-security.selfhost.eu/index.php?page=dashboard`

## API Endpunkte im Detail

### POST /api/whatsapp/send
Sendet eine einzelne WhatsApp-Nachricht.

**Request:**
```json
{
  "phone": "+491234567890",
  "message": "Deine Nachricht hier"
}
```

**Response:**
```json
{
  "success": true,
  "message_id": "wamid.xxx..."
}
```

### POST /api/whatsapp/anfragen
Sendet WhatsApp an alle MA mit offenen Anfragen.

**Request:**
```json
{
  "va_id": 123,
  "ma_ids": [1, 2, 3]
}
```

**Response:**
```json
{
  "success": true,
  "sent": 3,
  "total": 3,
  "errors": null
}
```

### GET /api/whatsapp/status
Zeigt Konfigurationsstatus.

**Response:**
```json
{
  "configured": true,
  "sender_number": "+4991140997799",
  "webapp_url": "https://webapp.consec-security.selfhost.eu/...",
  "hint": null
}
```

### POST /api/planungen/{id}/zusage
Verarbeitet eine Zusage: MA wird von Planung in Zuordnung verschoben.

**Response:**
```json
{
  "success": true,
  "message": "Zusage erfolgreich! Einsatz wurde in den Dienstplan eingetragen."
}
```

### POST /api/planungen/{id}/absage
Verarbeitet eine Absage: Status_ID wird auf 4 gesetzt.

**Request (optional):**
```json
{
  "grund": "Terminkonflikt"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Absage erfolgreich gespeichert."
}
```

## Datenbank-Tabellen

### tbl_MA_VA_Planung (Anfragen)
- Status_ID = 1: Geplant (neu erstellt)
- Status_ID = 2: Benachrichtigt (WhatsApp gesendet)
- Status_ID = 3: Zusage
- Status_ID = 4: Absage

### tbl_MA_VA_Zuordnung (Dienstplan)
- Enthält bestätigte Einsätze
- Nach Zusage wird MA hier eingetragen

## Test

1. API-Server starten:
   ```
   cd "C:\Users\guenther.siegert\Documents\Access Bridge"
   python api_server.py
   ```

2. WhatsApp-Status prüfen:
   ```
   curl http://localhost:5000/api/whatsapp/status
   ```

3. Formular im Browser öffnen:
   ```
   04_HTML_Forms/forms3/frm_MA_VA_Schnellauswahl.html
   ```

4. Auftrag und Datum wählen, dann "Alle Mitarbeiter anfragen" klicken

## Fallback

Wenn WhatsApp nicht konfiguriert ist (keine Umgebungsvariablen):
- Der Benutzer wird gefragt ob E-Mail verwendet werden soll
- Bei Ja: Öffnet mailto: mit allen E-Mail-Adressen
