# frm_KD_Kundenstamm.html vs frm_KD_Kundenstamm

Quelle:
- HTML: `C:\Users\guenther.siegert\Documents\Screenshots\frm_KD_Kundenstamm.html.jpg`
- Access: `C:\Users\guenther.siegert\Documents\Screenshots\frm_KD_Kundenstamm.jpg`

## Optik
- Grundlayout und Farbthema ähnlich; Abweichungen bei Abständen/Tab-Höhen.

## Aufbau/Struktur
- Access-Liste rechts zeigt zusätzliche Spalten (Kontaktname/Vorname); HTML listet nur Firma/Ort.
- Access-Feldgruppe links enthält zusätzliche Felder (z. B. Ansprechpartner/Mobil) in anderer Anordnung.
- Header-Buttons (Verrechnungssätze/Umsatzauswertung) wirken im HTML abweichend positioniert.

## Funktionen
- Such-/Filterlogik und "Nur Aktive anzeigen" nicht verifiziert.
- Bridge-Pfad war falsch; Fix umgesetzt, Funktionstest nötig.

## Ergebnis
- PARTIAL

## Empfehlungen
- Listen-Spalten im HTML auf Access-Spalten erweitern.
- Feldgruppe "Anspr.Partner/Mobil" wie Access positionieren.
- Header-Buttons und Kunden-Nr.-Anordnung angleichen.
