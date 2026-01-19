# Formular: zfrm_SyncError

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Name** | zfrm_Syncerror |
| **Typ** | Z-Formular (zfrm_) - Zusatz/Fehler |
| **Record Source** | ztbl_sync (Tabelle) |
| **Default View** | Other |
| **Navigation Buttons** | Nein |
| **Dividing Lines** | Nein |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |

## Beschreibung

Dieses Z-Formular zeigt Synchronisationsfehler an. Es dient der Anzeige und Verwaltung von Fehlern, die bei der Datensynchronisation aufgetreten sind.

## Controls

### Label: Bezeichnungsfeld10 (Titel)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 60, Top: 60, Width: 11370, Height: 570 |
| **ForeColor** | 8355711 (#7F7F7F - grau) |
| **BackColor** | 16777215 (#FFFFFF - weiss) |
| **Border Style** | 0 (keine) |

### CommandButton: Befehl29 (Aktion/Loeschen)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 12812, Top: 226, Width: 576, Height: 576 |
| **BackColor** | 14136213 (#D7B5D5 - rosa) |
| **BorderColor** | 14136213 |
| **ForeColor** | 4210752 (#404040 - dunkelgrau) |
| **Tab Index** | 0 |

**Events:**
- OnClick: Eingebettetes Makro

### SubForm: Untergeordnet19 (Sync-Error Liste)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 0, Top: 0, Width: 22686, Height: 11406 |
| **Source Object** | zsub_syncerror |
| **Tab Index** | 0 |
| **BorderColor** | 10921638 (#A6A6A6) |
| **Border Style** | 1 |

**Link Fields:** Keine (ungebunden)

## Farben

| Element | Farbe (Dezimal) | HEX | Beschreibung |
|---------|-----------------|-----|--------------|
| Button BackColor | 14136213 | #D7B5D5 | Rosa/Violett |
| Standard BackColor | 16777215 | #FFFFFF | Weiss |
| BorderColor | 10921638 | #A6A6A6 | Grau |
| Label ForeColor | 8355711 | #7F7F7F | Grau |
| Button ForeColor | 4210752 | #404040 | Dunkelgrau |

## Datenstruktur / Tabellen

- `ztbl_sync` - Haupttabelle fuer Sync-Daten (Record Source)
- `zsub_syncerror` - Subformular fuer Fehleranzeige

## Verwendungszweck

1. Zeigt Synchronisationsfehler in einer Liste an
2. Das SubFormular zsub_syncerror enthaelt die detaillierte Fehlerliste
3. Button Befehl29 ermoeglicht wahrscheinlich das Loeschen oder Bearbeiten von Fehlern
4. Wird typischerweise aufgerufen, wenn Sync-Probleme analysiert werden muessen

## Struktur

Das Formular ist sehr einfach aufgebaut:
- Ein Titel-Label oben
- Ein grosses Subformular, das fast den gesamten Bereich einnimmt
- Ein Aktions-Button fuer Fehlerbehebung/Loeschen

## Hinweis

Der Button verwendet ein eingebettetes Makro (kein VBA), was auf eine einfache Standardaktion wie "Datensatz loeschen" oder "Formular aktualisieren" hindeutet.
