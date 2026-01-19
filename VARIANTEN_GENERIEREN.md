# Anleitung: Farbvarianten Generieren

Diese Anleitung erklärt, wie Sie die Farbvarianten 9 und 10 des Formulars `frm_va_Auftragstamm.html` generieren.

## Schnellstart

### Option 1: Node.js (EMPFOHLEN)

1. Öffnen Sie eine Kommandozeile
2. Navigieren Sie zum Projekt:
   ```bash
   cd C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE
   ```
3. Führen Sie aus:
   ```bash
   node create_variants.js
   ```

### Option 2: Python

1. Öffnen Sie eine Kommandozeile
2. Navigieren Sie zum Projekt:
   ```bash
   cd C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE
   ```
3. Führen Sie aus:
   ```bash
   python create_variants.py
   ```

### Option 3: Windows Batch (Doppelklick)

Navigieren Sie im Explorer zu:
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\
```

Und führen Sie per Doppelklick aus:
- **create_variants.bat**

### Option 4: PowerShell

Rechtsklick auf `run_variants.ps1` → "Mit PowerShell ausführen"

### Option 5: Browser-Tool

1. Navigieren Sie zu:
   ```
   C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\varianten_auftragstamm\
   ```
2. Öffnen Sie `create_variants.html` im Browser
3. Klicken Sie auf "Varianten Generieren"
4. Speichern Sie die beiden Downloads

## Was wird erstellt?

Nach erfolgreicher Ausführung finden Sie zwei neue Dateien im Ordner:
```
04_HTML_Forms/forms/varianten_auftragstamm/
├── variante_09_teal.html       (Teal Refresh - Türkis-Design)
└── variante_10_ocean_blue.html (Ocean Blue - Blaues Design)
```

## Details zu den Varianten

### Variante 9: Teal Refresh
- **Hauptfarbe**: #00796B (Teal / Dunkelgrün-Türkis)
- **Charakter**: Frisch, modern, beruhigend
- **Einsatz**: Lange Arbeitssitzungen, kreative Arbeit

### Variante 10: Ocean Blue
- **Hauptfarbe**: #1976D2 (Ocean Blue / Kräftiges Blau)
- **Charakter**: Professionell, klar, konzentrationsförderd
- **Einsatz**: Analytische Arbeit, konzentrierte Tätigkeiten

## Was wird NICHT geändert?

- HTML-Struktur
- JavaScript-Funktionalität
- Layout und Abstände
- Schriftarten und -größen
- API-Anbindung

## Fehlerbehebung

### "node: command not found" oder "python: command not found"

Installieren Sie Node.js oder Python:
- **Node.js**: https://nodejs.org/
- **Python**: https://www.python.org/

### "Datei nicht gefunden"

Stellen Sie sicher, dass Sie sich im richtigen Verzeichnis befinden:
```bash
cd C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE
```

### Bash ist gesperrt

Verwenden Sie eine der alternativen Methoden (Browser-Tool, Batch-File, PowerShell)

## Technische Details

Die Generator-Scripts führen folgende Schritte aus:

1. Lesen der Original-Datei `frm_va_Auftragstamm.html`
2. Ersetzen von 30+ Farbwerten (Hex-Codes)
3. Anpassen des Titels und Hinzufügen eines Kommentars
4. Speichern der neuen Varianten

**Farbmapping-Beispiele**:
- `#8080c0` (Original Body) → `#00796B` (Teal) / `#1976D2` (Ocean)
- `#6060a0` (Original Sidebar) → `#004D40` (Dark Teal) / `#0D47A1` (Dark Blue)
- `#000080` (Original Header) → `#00695C` (Medium Teal) / `#1565C0` (Medium Blue)

Weitere Details siehe `04_HTML_Forms/forms/varianten_auftragstamm/README.md`

---

Erstellt: 2026-01-02
