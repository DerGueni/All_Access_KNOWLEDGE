# Kundenpreise Verwaltung - Dokumentation

## Übersicht
HTML-Formular zur Verwaltung von Kundenpreisen basierend auf dem Access-Formular `frm_Kundenpreise_gueni`.

## Dateien
- **frm_Kundenpreise_gueni.html** - Hauptformular
- **logic/frm_Kundenpreise_gueni.logic.js** - Business Logic
- **css/app-layout.css** - Layout-Framework
- **js/sidebar.js** - Sidebar-Navigation

## Funktionen

### 1. Datenverwaltung
- **Laden**: Alle Kundenpreise aus API laden (`GET /api/kundenpreise`)
- **Inline-Editing**: Direkte Bearbeitung in der Tabelle
- **Speichern**: Einzelne Zeilen oder alle Änderungen speichern (`PUT /api/kundenpreise/:id`)
- **Validierung**: Eingabevalidierung für Zahlen und Prozentsätze

### 2. Filter
- **Firma**: Textsuche nach Firmenname
- **Nur Aktive**: Checkbox für Filterung nach aktiven Kunden

### 3. Export
- **Excel Export**: CSV-Export aller gefilterten Daten

## Felder

| Feld | Typ | Beschreibung | Tab-Index |
|------|-----|--------------|-----------|
| kun_Firma | Text | Firmenname (readonly) | 5 |
| Sicherheitspersonal | Number | Preis für Sicherheitspersonal | 0 |
| Leitungspersonal | Number | Preis für Leitungspersonal | 1 |
| Nachtzuschlag | Number | Prozentsatz Nachtzuschlag | 2 |
| Sonntagszuschlag | Number | Prozentsatz Sonntagszuschlag | 3 |
| Feiertagszuschlag | Number | Prozentsatz Feiertagszuschlag | 4 |
| Fahrtkosten | Number | Fahrtkosten | 6 |
| Sonstiges | Number | Sonstige Kosten | 7 |

## API-Endpunkte

### GET /api/kundenpreise
**Beschreibung**: Lädt alle Kundenpreise mit Kundendaten

**Response**:
```json
{
  "data": [
    {
      "kun_Id": 123,
      "kun_Firma": "Firma GmbH",
      "kun_IstAktiv": true,
      "Sicherheitspersonal": 25.50,
      "Leitungspersonal": 35.00,
      "Nachtzuschlag": 20.0,
      "Sonntagszuschlag": 25.0,
      "Feiertagszuschlag": 50.0,
      "Fahrtkosten": 0.50,
      "Sonstiges": 0.00
    }
  ]
}
```

### PUT /api/kundenpreise/:id
**Beschreibung**: Aktualisiert Kundenpreise

**Request Body**:
```json
{
  "Sicherheitspersonal": 26.00,
  "Leitungspersonal": 36.00,
  "Nachtzuschlag": 22.0,
  "Sonntagszuschlag": 27.0,
  "Feiertagszuschlag": 52.0,
  "Fahrtkosten": 0.60,
  "Sonstiges": 5.00
}
```

**Response**:
```json
{
  "success": true,
  "message": "Kundenpreis aktualisiert"
}
```

## Verwendung

### Initialisierung
```javascript
// Automatisch beim DOM-Load
document.addEventListener('DOMContentLoaded', () => {
    KundenpreiseLogic.init();
});
```

### Öffnen des Formulars
```html
<!-- Direkt im Browser -->
file:///C:/Users/.../forms/frm_Kundenpreise_gueni.html

<!-- Aus anderem Formular navigieren -->
<script>
window.location.href = 'frm_Kundenpreise_gueni.html';
</script>
```

### Programmatische Nutzung
```javascript
// Daten aktualisieren
KundenpreiseLogic.refreshData();

// Einzelne Zeile speichern
KundenpreiseLogic.saveRow(kundenId);

// Alle Änderungen speichern
KundenpreiseLogic.saveAll();

// Tabelle filtern
KundenpreiseLogic.filterTable();

// Excel Export
KundenpreiseLogic.exportToExcel();
```

## State Management

### Change Tracking
- Geänderte Zeilen werden automatisch markiert
- Speichern-Button wird aktiviert/deaktiviert
- `state.changedRows` Set speichert kun_Id der geänderten Zeilen

### Validierung
- Numerische Felder: min="0"
- Prozentsätze: min="0", max="100"
- Schrittweite: 0.01 für Preise, 0.1 für Prozentsätze

## Styling

### CONSYS Theme
- Hintergrund: `#8080c0`
- Sidebar: Gradient `#6060a0` → `#49477f`
- Buttons: Access-Style mit Gradient
- Tabelle: Sticky Header, Hover-Effekte

### Responsive
- Min-width für Firma-Spalte: 250px (1024px+)
- Min-width für Firma-Spalte: 200px (<1024px)
- Scrollbare Tabelle mit Fixed Header

## Events

### Input Events
- `input`: Sofortige Änderungserkennung
- `change`: Finalisierung der Änderung
- `focus`: Highlight mit gelbem Hintergrund

### Button Events
- **Aktualisieren**: Daten neu laden
- **Alle speichern**: Batch-Speicherung
- **Excel Export**: CSV-Download
- **Speichern** (pro Zeile): Einzelne Zeile speichern

## Fehlerbehandlung

### API-Fehler
- Toast-Notification mit Fehlermeldung
- Console-Logging für Debugging
- Status-Bar Anzeige

### Validierung
- HTML5 Validierung für Zahlenfelder
- Min/Max Constraints
- Required-Attribute (falls nötig)

## Performance

### Optimierungen
- Lazy Rendering (nur sichtbare Zeilen)
- Debounced Filter (300ms)
- Batch-Save für mehrere Zeilen
- Event Delegation für Inputs

## Browser-Kompatibilität
- Chrome/Edge: ✓
- Firefox: ✓
- Safari: ✓
- IE11: ✗ (nicht unterstützt)

## Changelog

### Version 1.0 (2026-01-02)
- Initiale Version
- Inline-Editing
- Filter-Funktionen
- Excel Export
- Change Tracking
- Batch-Save

## TODO / Erweiterungen
- [ ] Bulk-Edit (mehrere Zeilen gleichzeitig)
- [ ] Undo/Redo Funktionalität
- [ ] Sortierung nach Spalten
- [ ] Erweiterte Filter (Preisbereich, etc.)
- [ ] Import aus Excel
- [ ] Historien-Ansicht (Änderungsprotokoll)
- [ ] Keyboard Shortcuts (Strg+S für Speichern)
