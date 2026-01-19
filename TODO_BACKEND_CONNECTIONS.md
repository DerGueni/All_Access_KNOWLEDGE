# TODO: Backend-Verbindungen & fehlende APIs

## 1. Bestehende Bridge-Endpunkte (vgl. `04_HTML_Forms/api/bridgeClient.js`)
- `GET /auftraege`, `POST /auftraege`, `PUT /auftraege/:id`, `DELETE /auftraege/:id` → Auftragstamm und diverse Listen/Reports.
- `GET /mitarbeiter`, `/mitarbeiter/:id`, `POST/PUT/DELETE /mitarbeiter` → Mitarbeiterstamm, Dienstplan-MA, Schnellauswahl.
- `GET /kunden`, `/kunden/:id`, CRUD → Kundenstamm.
- `GET /episatztage`, `/dienstplan/ma/:id`, `/dienstplan/objekt/:id`, `/dienstplan/gruende`, `/dienstplan/schichten` → Dienstplan-Views.
- `GET /zuordnungen`, `/anfragen`, `/verfuegbarkeit`, `/dashboard`, `/tables`, `/query` sowie Utility-Aufrufe für E-Mail-Reports (`Bridge.execute('versendeDienstplanEmail')`, `versendeAuftragsEmail` etc.).

## 2. Kritische Reports/Aktionen noch zu bestätigen
- **Auftrag Zusage / Planungen**: `Bridge.execute('createAnfrage')`, `versendeAuftragsEmail`, `planungen.*` müssen echte Daten aus `api_server` liefern; prüfen ob `api_server.py` die [Bridge]-Handler besitzt (z. B. `createAnfrage`, `updateAnfrage`, `versendeDienstplanEmail`).
- **Dienstplan MA-Report**: `Bridge.dienstplan.getByMA` und `Bridge.execute('getDienstplanMA')` müssen auf `api_server` und Access-Daten zugreifen; bisher beim `curl /api/mitarbeiter?aktiv=true` Access-Treiber-Fehler (`'Microsoft Access Driver (*'`). Klärung: fehlerhafte ODBC/Einstellungen -> Treiber-Installation nötig.
- **Dienstplaneinträge & Zig Reports**: `Bridge.execute('getSchichten')`, `Bridge.zuordnungen.*`, `Bridge.query` (subforms) müssen alle SQL-Queries aus Access abbilden; bei Lücken (z. B. `sub_VA_Start`, `sub_MA_VA_Zuordnung`) sind zusätzliche API-Endpunkte notwendig.

## 3. Offene Backend-Aufgaben
1. **Access-ODBC/Treiber sicherstellen** (Fehler beim `curl /api/mitarbeiter` signalisiert fehlende Access-ODBC-Verbindung; `api_server.out.log` & `KOMPLETT_BERICHT_DATENBANKANBINDUNG_2025-12-29.txt` lesen, dann ggf. Umgebung fixen).
2. **Ride `api_server.py` vs `bridgeClient`**: Dateien abgleichen (z. B. `api_server.py` muss die Endpunkte `dienstplan/ma`, `dienstplan/objekt`, `zuordnungen`, `anfragen`, `versendeDienstplanEmail`, `versendeAuftragsEmail` implementieren; falls nicht, TODO definieren).
3. **Reports**: `Bridge.rueckmeldungen`, `Bridge.lohn`, `Bridge.zeitkonten` etc. müssen im Backend existieren und Data-Export/Email-Trigger besitzen; ggf. bestehende Access-VBA/SQL als Grundlage extrahieren.
4. **Status/Cache-Management**: Logging/Cache-Invalidierung (z. B. `Bridge.cache.clear`) sollte testweise ausgelöst werden, sobald Buttons wie „Aktualisieren“ klicken.

## 4. Nächste konkrete Maßnahmen
- Dokumentieren, welche Buttons/Reiter (Auftrag kopieren/löschen, Einsatzliste senden/drucken, Dienstplan-Kalender, Reports, Schnellauswahl Actions) welche API-Aufrufe benötigen.
- Für jeden API-Aufruf prüfen, ob der Access-Server die entsprechende URI/Logik bereitstellt; ggf. `api_server.py` anpassen oder `Bridge.execute`-Fallbacks erzeugen.
- Sobald der Backend-Fehler behoben ist, mit `curl` oder Postman die kritischen Endpunkte testen (Aufträge, Mitarbeiter, Dienstplan, Zuordnungen).
