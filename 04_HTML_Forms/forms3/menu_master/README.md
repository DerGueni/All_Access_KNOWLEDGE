# MenuMaster - Kombiniertes Hauptmenü

6 verschiedene Menü-Varianten, die Buttons aus beiden Access-Menüs zusammenführen.

## Quellen
- **Menü 1:** frm_Menuefuehrung (dynamisch via tbl_Menuefuehrung_Neu)
- **Menü 2:** frm_Menuefuehrung1 (statische Buttons)

## Varianten-Übersicht

| Variante | Fokus | Beschreibung |
|----------|-------|--------------|
| V01 | Klassisch | Access-nahe Struktur, wenige große Kategorien |
| V02 | Rollenorientiert | Kategorien nach Aufgaben (Disponent, Objekt, Personal, etc.) |
| V03 | Prozessorientiert | Workflow-Schritte (Anfrage → Abrechnung) |
| V04 | Objektzentriert | Objekt/Auftrag als Zentrum, Kachel-Layout |
| V05 | Dashboard | Quick Actions + Akkordeon + Suchfeld |
| V06 | Minimalistisch | Power-User, Keyboard-Shortcuts, Tabs |

---

## V01 - Klassisch / Access-nahe

**Datei:** `menu_master_V01.html`

### Kategorien
1. Navigation (6 Buttons)
2. Personal (5 Buttons)
3. Extras & Tools (11 Buttons)
4. Automatisierung (7 Buttons)
5. Spezial (7 Buttons)
6. System (3 Buttons)

### Merkmale
- Klassischer Access-Look (#6060a0 Hintergrund)
- Vertikale Sections mit Titel-Header
- Buttons in Access-Reihenfolge

---

## V02 - Rollenorientiert

**Datei:** `menu_master_V02.html`

### Kategorien (nach Rollen)
1. Disponent - Blau (#4a90d9)
2. Objektleitung - Grün (#5cb85c)
3. Personalbüro - Orange (#f0ad4e)
4. Abrechnung - Rot (#d9534f)
5. Management - Cyan (#5bc0de)

### Merkmale
- Farbcodierte Rollen
- Icons vor Kategorietiteln
- Nur relevante Buttons pro Rolle

---

## V03 - Prozessorientiert

**Datei:** `menu_master_V03.html`

### Prozessschritte
1. Anfrage
2. Angebot
3. Auftrag
4. Planung
5. Durchführung
6. Abrechnung
7. Reporting

### Merkmale
- Horizontale Prozess-Anzeige (1→2→3→...)
- Aktiver Schritt hervorgehoben
- Buttons entlang des Workflows

---

## V04 - Objektzentriert

**Datei:** `menu_master_V04.html`

### Kategorien
1. Objektstamm
2. Einsatzanweisung
3. Personalzuordnung
4. Dienstplan/Schichten
5. Dokumente/Exporte
6. Kommunikation

### Merkmale
- Grid-Layout 2x3
- Kachel-Design
- Objekt als zentrales Element

---

## V05 - Dashboard + Quick Actions

**Datei:** `menu_master_V05.html`

### Layout
1. **Suchfeld** (oben) - Live-Filter
2. **Quick Actions** - Top 10 Buttons als große Kacheln
3. **Akkordeon** - Weitere Kategorien klappbar

### Quick Actions
- Dienstplan, Planung, Aufträge, Mitarbeiter, Kunden
- Objekte, Zeitkonten, Schnellauswahl, Stunden, Email

### Merkmale
- Touch-freundlich
- Live-Suche über alle Einträge
- Klappbare Sections

---

## V06 - Minimalistisch / Power-User

**Datei:** `menu_master_V06.html`

### Layout
1. **Suchfeld** - Prominent, mit Keyboard-Focus
2. **Favoriten-Leiste** - 6 Buttons horizontal
3. **Tabs** - Kompakte Kategorien

### Keyboard-Shortcuts
| Shortcut | Aktion |
|----------|--------|
| Strg+1 | Dienstplan |
| Strg+2 | Aufträge |
| Strg+3 | Mitarbeiter |
| Strg+4 | Planung |
| Strg+5 | Stunden |
| Strg+6 | Email |
| Esc | Menü schließen |

### Merkmale
- Minimalistisches Design
- Keyboard-Navigation
- accesskey Attribute

---

## Button → Ziel Mapping

### Navigation
| Button | Ziel-HTML |
|--------|-----------|
| Dienstplanübersicht | frm_N_Dienstplanuebersicht.html |
| Planungsübersicht | frm_VA_Planungsuebersicht.html |
| Auftragsverwaltung | frm_va_Auftragstamm.html |
| Mitarbeiterverwaltung | frm_MA_Mitarbeiterstamm.html |
| Kundenverwaltung | frm_KD_Kundenstamm.html |
| Objektverwaltung | frm_OB_Objekt.html |

### Personal
| Button | Ziel-HTML |
|--------|-----------|
| Zeitkonten | frm_MA_Zeitkonten.html |
| Abwesenheiten | frm_MA_Abwesenheit.html |
| Stundenauswertung | frm_N_Stundenauswertung.html |
| Lohnabrechnungen | frm_N_Lohnabrechnungen.html |
| Dienstausweis | frm_Ausweis_Create.html |

### Tools
| Button | Ziel-HTML |
|--------|-----------|
| Schnellauswahl | frm_MA_VA_Schnellauswahl.html |
| E-Mail | frm_N_Email_versenden.html |
| Verrechnungssätze | frm_KD_Verrechnungssaetze.html |
| System Info | frm_Systeminfo.html |

---

## Missing Targets (fehlende HTML-Ziele)

Diese Buttons sind sichtbar, aber das Ziel-HTML existiert nicht:

| Button | Erwartetes Ziel | Status |
|--------|-----------------|--------|
| Sub Rechnungen | frm_SubRechnungen.html | FEHLT |
| Datenbank wechseln | frm_DBWechseln.html | FEHLT |
| Auswahl-Master | frm_N_AuswahlMaster.html | FEHLT |
| Lohnarten/Zuschläge | zfrm_ZK_Lohnarten_Zuschlag.html | FEHLT |

Bei Klick auf diese Buttons erscheint: `showToast('Ziel fehlt: ...', 'warning')`

---

## Technische Details

### Gemeinsame Funktionen (in jeder Variante)
```javascript
// Navigation zu Formular
function navigateTo(formName) {
    // PostMessage an Shell/Parent
    // WebView2 Bridge falls verfügbar
}

// Toast-Benachrichtigung
function showToast(message, type) {
    // type: 'success', 'error', 'warning', 'info'
}

// Menü schließen
function closeForm() {
    // PostMessage CLOSE_MENU
}
```

### Test-IDs
Jeder Button hat ein `data-testid` Attribut:
- V01: `data-testid="menu-v01-{buttonname}"`
- V02: `data-testid="menu-v02-{buttonname}"`
- etc.

### Integration
Die Menüs können als:
- Standalone HTML geöffnet werden
- In Shell/iframe eingebettet werden
- Via WebView2 aus Access gestartet werden

---

## Testen (Clickthrough)

### Voraussetzungen
1. API-Server starten: `python api_server.py`
2. HTML im Browser öffnen

### Testfälle pro Variante
- [ ] Alle Kategorien sichtbar
- [ ] Alle Buttons klickbar
- [ ] Navigation öffnet korrektes Formular
- [ ] Toast-Meldungen erscheinen
- [ ] Schließen-Button funktioniert
- [ ] (V05) Suchfeld filtert korrekt
- [ ] (V06) Keyboard-Shortcuts funktionieren

---

## Changelog

| Datum | Änderung |
|-------|----------|
| 2026-01-07 | Initiale Erstellung aller 6 Varianten |
