# Bridge API Regeln

## Standard
- Basis: `http://localhost:5000/api`
- Verwende bevorzugt `04_HTML_Forms/api/bridgeClient.js`

## Do
- Requests zentral über BridgeClient bündeln (Cache/Dedup)
- Nur whitelisted Tables/Queries verwenden (wenn vorhanden)

## Don't
- Keine freien SQLs im Frontend
- Keine hardcodierten DB-Pfade im Browser
