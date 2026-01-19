# Shell Refactoring - Abschlussbericht

**Datum:** 2026-01-03
**Status:** ERFOLGREICH ABGESCHLOSSEN

## Zusammenfassung

Die Umstellung auf eine zentrale Shell-Architektur mit API-gesteuertem Menu wurde erfolgreich durchgefuehrt.

## Erstellte Dateien

### Neue Shell
- `02_web/shell_v2.html` - Zentrale Shell mit nav#menu und main#content

### API-Endpoints
- `02_web/api/menu_endpoints.py` - Python-Modul fuer /api/me und /api/menu

### Automations-Tool
- `tools/convert_to_views.py` - Konvertierungs-Skript fuer HTML-Formulare

### Views (Sidebar-frei)
- `02_web/views/` - 52 HTML-Dateien ohne Navigation-Sidebars

### Backup
- `02_web/forms_backup_2026-01-03/` - Originale Formulare
- Git-Branch: `feature/shell-refactoring`

## Statistiken

| Metrik | Wert |
|--------|------|
| Formulare analysiert | 38 |
| Sidebars entfernt | 28 |
| Content-Sidebars erhalten | 7 |
| Subformulare kopiert | 14 |
| Fehler | 0 |

## Architektur

### Vorher
```
forms/
  frm_*.html (mit eigener Sidebar)
  sidebar.js (injiziert Menu)
shell.html (iframe-basiert, keine zentrale Navigation)
```

### Nachher
```
shell_v2.html
  nav#menu (API-gesteuert)
  main#content (View-Container)
    views/frm_*.html (ohne Sidebar)

api/
  menu_endpoints.py
    GET /api/me
    GET /api/menu
```

## Integration in bestehenden API-Server

Fuege in `api_server.py` hinzu:

```python
# Am Anfang der Datei
from api.menu_endpoints import register_menu_routes

# Nach app = Flask(__name__)
register_menu_routes(app)
```

## Routing

Die Shell nutzt Hash-Routing (`#route-id`):
- `shell_v2.html#mitarbeiter` -> laedt `views/frm_MA_Mitarbeiterstamm.html`
- `shell_v2.html#dashboard` -> laedt `views/frm_Menuefuehrung1.html`

## Rechte-basiertes Menu

Die API liefert nur Menu-Punkte, die der Benutzer sehen darf:

| Rolle | Bereiche |
|-------|----------|
| admin | Alle |
| planer | stammdaten, planung, personal |
| personal | stammdaten, personal, lohn |
| standard | stammdaten, planung |
| readonly | stammdaten |

## Naechste Schritte

1. **API-Server erweitern:** menu_endpoints.py in api_server.py integrieren
2. **Shell testen:** `shell_v2.html` im Browser oeffnen
3. **Views pruefen:** Alle Views auf Funktionalitaet testen
4. **Alte Dateien bereinigen:** forms_backup entfernen wenn alles funktioniert

## Rollback

Falls erforderlich:
```bash
# Backup wiederherstellen
Copy-Item -Path "02_web\forms_backup_2026-01-03\*" -Destination "02_web\forms\" -Force

# Oder Git verwenden
git checkout master
```

## Validierung

- [x] Keine `<aside class="app-sidebar">` in views/
- [x] Keine `<aside class="*-menu">` in views/
- [x] Keine sidebar.js Referenzen in views/
- [x] Content-Sidebars erhalten (7 Dateien)
- [x] Subformulare unverändert kopiert
