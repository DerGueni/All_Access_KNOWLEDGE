# STABLE - Stabile, getestete Dateien

## WARNUNG

Dieser Ordner enthaelt **stabile, getestete Versionen** von Dateien.

### Regeln

1. **NUR gepruefte Dateien** hierher kopieren
2. **KEINE direkten Aenderungen** - zuerst in `experiments/` testen
3. **Versionierung** - Dateiname mit Datum: `datei_2026-01-28.js`
4. **Rueckfall-Option** - Bei Problemen sofort hierher zurueckgreifen

### Workflow

```
1. Experimentieren in: experiments/
2. Testen und validieren
3. Bei Erfolg: Kopie nach stable/ mit Datum
4. Original ersetzen
5. Alte stable-Version behalten (min. 3 Versionen)
```

### Struktur

```
stable/
├── css/           # Stabile CSS-Versionen
├── js/            # Stabile JS-Versionen
├── html/          # Stabile HTML-Versionen
└── api/           # Stabile API-Versionen
```
