# EXPERIMENTS - Testbereich

## WICHTIG

Dieser Ordner ist fuer **Experimente und Tests**.

### Regeln

1. **Alle Aenderungen ZUERST hier testen**
2. **Keine Auswirkung auf Produktiv-Code**
3. **Nach erfolgreichem Test** - nach `stable/` kopieren
4. **Regelmaessig aufraeumen** - alte Experimente loeschen

### Workflow

```
1. Datei aus Projekt hierher kopieren
2. Aenderungen vornehmen
3. Testen (Browser, API, etc.)
4. Bei Erfolg:
   - Kopie nach stable/ mit Datum
   - Original im Projekt ersetzen
5. Bei Misserfolg:
   - Experiment loeschen
   - Von vorne beginnen
```

### Namenskonvention

```
experiments/
├── test_feature_name_2026-01-28/
│   ├── original.js
│   ├── modified.js
│   └── notes.txt
└── quick_fix_xyz.js
```

### Nach Abschluss

- Erfolgreiche Experimente: `stable/` + Produktiv
- Fehlgeschlagene: Loeschen oder archivieren
