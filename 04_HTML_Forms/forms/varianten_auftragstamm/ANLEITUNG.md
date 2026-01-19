# Anleitung: Design-Varianten erstellen

## Problem
Die Original-Datei `frm_va_Auftragstamm.html` ist ~97KB groß und kann nicht direkt über die Edit-Tools bearbeitet werden.

## Lösung
Verwenden Sie das bereitgestellte Python-Script `create_variants.py`.

## Schritt-für-Schritt Anleitung

### 1. Terminal öffnen
```cmd
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\varianten_auftragstamm"
```

### 2. Script ausführen
```cmd
python create_variants.py
```

### 3. Ausgabe prüfen
Das Script sollte folgende Ausgabe zeigen:
```
✓ Variante 5 (Dark Mode) erstellt: ...
✓ Variante 6 (Enterprise) erstellt: ...

=== FERTIG ===
Beide Varianten wurden erstellt:
- variante_05_dark_mode.html
- variante_06_enterprise.html
```

### 4. Varianten testen

#### Im Browser (ohne API-Server):
```
file:///C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms/varianten_auftragstamm/variante_05_dark_mode.html
```

#### Mit API-Server (für echte Daten):
```cmd
# Terminal 1: API-Server starten
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py

# Terminal 2: Browser öffnen
start "" "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\varianten_auftragstamm\variante_05_dark_mode.html"
```

## Was macht das Script?

Das Script `create_variants.py`:

1. **Liest** die Original-Datei `frm_va_Auftragstamm.html`
2. **Ersetzt** NUR CSS-Farben und Gradienten (via Regex)
3. **Behält** HTML-Struktur und JavaScript bei
4. **Erstellt** zwei neue Dateien:
   - `variante_05_dark_mode.html` - Dunkles Design
   - `variante_06_enterprise.html` - Enterprise-Design

## Manuelle Anpassung (falls gewünscht)

Falls Sie eigene Farben verwenden möchten:

1. Öffnen Sie `create_variants.py` in einem Editor
2. Finden Sie den Abschnitt mit den Farben (z.B. `dark_mode_replacements`)
3. Ändern Sie die HEX-Werte nach Ihren Wünschen
4. Führen Sie das Script erneut aus

### Beispiel - Akzentfarbe ändern:
```python
# Vorher (Lila):
(r'background-color: #000080;', 'background-color: #BB86FC;'),

# Nachher (Grün):
(r'background-color: #000080;', 'background-color: #4CAF50;'),
```

## Fehlerbehebung

### "Python nicht gefunden"
```cmd
# Python-Version prüfen
python --version

# Falls nicht installiert: Python 3.x installieren von python.org
```

### "Datei nicht gefunden"
```cmd
# Pfad prüfen
dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\frm_va_Auftragstamm.html"

# Falls nicht vorhanden: Pfad in create_variants.py anpassen (Zeile 11)
```

### "Encoding-Fehler"
Das Script verwendet UTF-8. Falls Probleme auftreten:
```python
# In create_variants.py Zeile 14/15 ändern:
with open(ORIGINAL_FILE, 'r', encoding='utf-8', errors='ignore') as f:
```

## Nächste Schritte

Nach erfolgreicher Erstellung können Sie:

1. Die Varianten im Browser öffnen und testen
2. Screenshots erstellen zum Vergleich
3. Weitere Varianten durch Kopieren und Anpassen erstellen
4. Die Varianten in Ihr Deployment-System integrieren

---

Bei Fragen oder Problemen: Siehe `README.md` für weitere Details.
