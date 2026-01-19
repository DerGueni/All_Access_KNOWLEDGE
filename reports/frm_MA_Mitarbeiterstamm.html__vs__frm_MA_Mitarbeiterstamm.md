# frm_MA_Mitarbeiterstamm.html vs frm_MA_Mitarbeiterstamm

Quelle:
- HTML: `C:\Users\guenther.siegert\Documents\Screenshots\frm_ma_Mitarbeiterstamm.html.jpg`
- Access: `C:\Users\guenther.siegert\Documents\Screenshots\frm_ma_Mitarbeiterstamm.jpg`

## Optik
- HTML: Graue Kopfzeile, reduzierte Button-Leiste.
- Access: Violette Kopfzeile, größere Aktionsbuttons (Mitarbeiter löschen, Einsätze übertragen, Listen drucken, Tabelle).

## Aufbau/Struktur
- Access-Header-Aktionen fehlen oder sind nicht sichtbar im HTML.
- HTML-Layout weicht ab (Feldgruppen, Foto-Bereich und Listenabstand).
- Such-/Filterzeile im Access (Suche/Filter/Zusatz) fehlt/abweicht im HTML.

## Funktionen
- Datenliste rechts ist vorhanden, aber Spalten/Filterlogik nicht verifiziert.
- Bridge-Pfad war falsch; Fix umgesetzt, erneuter Funktionstest nötig.

## Ergebnis
- PARTIAL

## Empfehlungen
- Header-Buttons und Layout in HTML an Access anpassen.
- Such-/Filterbereich oben rechts vollständig nachbilden.
- Foto/Signatur-Block und Koordinaten-Button positionsgleich nachziehen.
- Nach Fix: Listen-Scroll/Mousewheel und Button-Events prüfen.
