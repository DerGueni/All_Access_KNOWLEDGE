# /checkpoint - Aktuellen Stand speichern

Erstelle einen Checkpoint mit dem aktuellen Arbeitsstand.

## Aktion

1. Ermittle die nächste Checkpoint-Nummer
2. Fasse den aktuellen Stand zusammen:
   - Was wurde erledigt?
   - Welche Dateien wurden geändert?
   - Was ist der nächste Schritt?
3. Schreibe Checkpoint in `checkpoints/CP[N]_[name].md`

## Format

```markdown
# Checkpoint [N] - [Name]
**Datum:** [YYYY-MM-DD]
**Status:** [IN_PROGRESS | ABGESCHLOSSEN]

## Erledigt
- [Liste der erledigten Aufgaben]

## Geänderte Dateien
- [Datei 1]
- [Datei 2]

## Nächster Schritt
[Beschreibung]
```

## Hinweis
Checkpoints ermöglichen das Fortsetzen nach Kontext-Verlust.
