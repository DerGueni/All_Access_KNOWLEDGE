# frm_va_Auftragstamm.html vs frm_va_Auftragstamm

Quelle:
- HTML: `C:\Users\guenther.siegert\Documents\Screenshots\frm_va_Auftragstamm.html.jpg`
- Access: `C:\Users\guenther.siegert\Documents\Screenshots\frm_va_Auftragstamm.jpg`

## Optik
- HTML: Kein klarer violetter Header/Toolbar sichtbar; Controls wirken überlagert.
- Access: Violette Kopfzeile mit klarer Button-Leiste und Tabs; strukturierte Bereiche.

## Aufbau/Struktur
- Access Tabs (Einsatzliste/Antworten ausstehend/Rechnung) fehlen in HTML.
- Linke Hauptmenü-Leiste in Access vorhanden; HTML zeigt nur reduzierte/abweichende Seitenleiste.
- Rechte Auftragsliste in Access klar gerastert; HTML zeigt eine abweichende Liste ohne gleiche Spalten/Anordnung.

## Funktionen
- Datenbindung nicht verifizierbar per Screenshot; zuvor falscher Bridge-Pfad in JS (Fix umgesetzt).
- Button-Aktionen (Auftrag kopieren/löschen, Einsatzliste senden etc.) sind in HTML nicht sichtbar.

## Ergebnis
- MISMATCH

## Empfehlungen
- Tab-Control für Einsatzliste/Antworten/Rechnung in HTML nachbilden.
- Header-Bar + Button-Layout gemäß Access (violett, klare Reihenfolge).
- Rechte Auftragsliste: Spalten/Filter/Buttons wie Access übernehmen.
- Nach Fix der Bridge-Pfade: Echt-Daten und Button-Aktionen neu testen.
