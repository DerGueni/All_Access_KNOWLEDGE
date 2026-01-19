# frm_N_Dienstplanuebersicht.html vs frm_DP_Dienstplan_MA

Quelle:
- HTML: `C:\Users\guenther.siegert\Documents\Screenshots\frm_DP_Dienstplan_MA.html.jpg`
- Access: `C:\Users\guenther.siegert\Documents\Screenshots\frm_DP_Dienstplan_MA.jpg`

## Optik
- HTML: Nur Header/Filter sichtbar; Hauptflaeche leer.
- Access: Vollstaendige Kalender-Tabelle mit Tagen/Zeiten und Einsaetzen.

## Aufbau/Struktur
- Kalender-/Grid-Layout fehlt im HTML (tbody/rows nicht gerendert).
- Access-Menue links sichtbar; HTML verwendet eigenes Sidebar-Layout.

## Funktionen
- Datenbindung nicht aktiv (Bridge-Pfad war falsch; Fix umgesetzt).
- Kalender-Interaktionen (Woche wechseln/Filter) nicht verifiziert.

## Ergebnis
- MISMATCH

## Empfehlungen
- Nach Bridge-Pfad-Fix: pruefen, ob Kalenderstruktur gerendert wird.
- Grid-Header/Zeitraster wie Access einfaerben (tuerkise Kopfzeile, Wochenstruktur).
- Filter/Buttons an Access-Position anpassen.
