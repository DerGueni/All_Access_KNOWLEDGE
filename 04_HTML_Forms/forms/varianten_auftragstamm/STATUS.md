# Status: Design-Varianten Erstellung

## Übersicht

**Datum**: 2026-01-02
**Ziel**: Erstellung von 2 Design-Varianten für `frm_va_Auftragstamm.html`
**Status**: ⚠️ SCRIPTS BEREIT - AUSFÜHRUNG ERFORDERLICH

## Zu erstellende Varianten

### ✅ Variante 5: Elegant Dark Mode
- **Dateiname**: `variante_05_dark_mode.html`
- **Farbschema**: Dunkle Töne (#1E1E1E, #2D2D2D, #BB86FC)
- **Zweck**: Augen-Schonung, moderne Optik

### ✅ Variante 6: Corporate Enterprise Gray
- **Dateiname**: `variante_06_enterprise.html`
- **Farbschema**: Blaugrau-Töne (#37474F, #0288D1, #ECEFF1)
- **Zweck**: Professionelles Business-Design

## Erstellte Dateien

### Scripts (bereit zur Ausführung)
1. ✅ `create_variants.py` - Python-Script
2. ✅ `create_variants.ps1` - PowerShell-Script
3. ✅ `VARIANTEN_ERSTELLEN.cmd` - Windows Batch (Doppelklick-fähig)

### Dokumentation
1. ✅ `README.md` - Vollständige Dokumentation
2. ✅ `ANLEITUNG.md` - Schritt-für-Schritt Anleitung
3. ✅ `FARBPALETTEN.html` - Visuelle Übersicht der Farbpaletten

## Nächste Schritte

Um die Varianten zu erstellen, führen Sie **EINEN** der folgenden Schritte aus:

### Option 1: Doppelklick (Einfachste Methode)
```
Doppelklick auf: VARIANTEN_ERSTELLEN.cmd
```

### Option 2: PowerShell
```powershell
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\varianten_auftragstamm"
.\create_variants.ps1
```

### Option 3: Python
```bash
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\varianten_auftragstamm"
python create_variants.py
```

## Erwartetes Ergebnis

Nach Ausführung sollten folgende Dateien existieren:
- ✅ `variante_05_dark_mode.html` (~97KB)
- ✅ `variante_06_enterprise.html` (~97KB)

## Testen der Varianten

### Im Browser (direkt)
```
file:///C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms/varianten_auftragstamm/variante_05_dark_mode.html
```

### Mit API-Server (für echte Daten)
```bash
# Terminal 1: API-Server starten
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py

# Terminal 2: Formular öffnen
start "" "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\varianten_auftragstamm\variante_05_dark_mode.html"
```

## Technische Details

### Was wird geändert?
- **NUR CSS**: Farben und Gradienten
- **NICHT geändert**: HTML-Struktur, JavaScript, Funktionalität

### Änderungs-Methode
- Regex-basierte String-Ersetzung
- Präzise Farbcode-Ersetzung
- Beibehaltung aller funktionalen Elemente

### Datei-Größe
- Original: ~97KB
- Varianten: ~97KB (identisch)
- Differenz: Nur CSS-Werte

## Bekannte Einschränkungen

1. **Claude konnte die Dateien nicht direkt erstellen**
   - Grund: Datei zu groß für Edit-Tools
   - Lösung: Scripts bereitgestellt für lokale Ausführung

2. **API-Server erforderlich für echte Daten**
   - Ohne Server: Formulare sind leer
   - Mit Server: Volle Funktionalität

3. **Farbpaletten sind fixiert**
   - Anpassungen: Editieren Sie die Scripts
   - Suchen Sie nach den HEX-Werten und ändern Sie diese

## Fehlerbehebung

### "Datei nicht gefunden"
- Prüfen Sie den Pfad in den Scripts (Zeile 11 in Python, Zeile 6 in PowerShell)
- Stellen Sie sicher, dass `frm_va_Auftragstamm.html` existiert

### "Python nicht gefunden"
- Verwenden Sie PowerShell-Script oder Batch-Datei
- Oder installieren Sie Python 3.x von python.org

### "Execution Policy Error" (PowerShell)
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
```

## Visuelle Vorschau

Öffnen Sie `FARBPALETTEN.html` im Browser für eine visuelle Übersicht der Farbpaletten.

---

**Hinweis**: Die Varianten-Dateien existieren noch nicht und müssen durch Ausführung eines der Scripts erstellt werden.
