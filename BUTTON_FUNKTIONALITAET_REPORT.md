# Button-Funktionalitäts-Report

Stand: 2026-01-01

## Executive Summary

Vollständige Prüfung aller Button-Handler in HTML-Hauptformularen gegen ihre Logic.js Implementierungen.

---

## 1. frm_N_MA_Mitarbeiterstamm_V2.html

### Buttons im HTML (Sidebar)
| Button | onclick | Ziel |
|--------|---------|------|
| Dienstplanübersicht | `openMenu('dienstplan')` | frm_N_Dienstplanuebersicht |
| Planungsübersicht | `openMenu('planung')` | frm_VA_Planungsuebersicht |
| Auftragsverwaltung | `openMenu('auftrag')` | frm_N_VA_Auftragstamm |
| Offene Mail Anfragen | `openMenu('mail')` | ? |
| Excel Zeitkonten | `openMenu('excel')` | ? |
| Zeitkonten | `openMenu('zeitkonten')` | frm_MA_Zeitkonten |
| Abwesenheitsplanung | `openMenu('abwesenheit')` | frm_MA_Abwesenheit |
| Dienstausweis erstellen | `openMenu('ausweis')` | ? |
| Stundenabgleich | `openMenu('stunden')` | frm_N_Stundenauswertung |
| Kundenverwaltung | `openMenu('kunden')` | frm_N_KD_Kundenstamm |

**Status:** ⚠️ FEHLT - `openMenu()` Funktion nicht in logic.js vorhanden

### Buttons im HTML (Header - Navigation)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| Erster | `navFirst()` | ❌ FEHLT | FEHLT |
| Zurück | `navPrev()` | ❌ FEHLT | FEHLT |
| Weiter | `navNext()` | ❌ FEHLT | FEHLT |
| Letzter | `navLast()` | ❌ FEHLT | FEHLT |

**Status:** ❌ FEHLT - Navigation-Funktionen nicht implementiert

### Buttons im HTML (Header - Aktionen)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| MA Adressen | `showAdressen()` | ❌ FEHLT | FEHLT |
| Mitarbeiter löschen | `deleteMA()` | ❌ FEHLT | FEHLT |
| Zeitkonto | `showZeitkonto()` | ✅ `openZeitkonto()` | FALSCH |
| ZK Fest | `showZKFest()` | ❌ FEHLT | FEHLT |
| ZK Mini | `showZKMini()` | ❌ FEHLT | FEHLT |
| Neuer Mitarbeiter | `newMA()` | ✅ `newRecord()` | FALSCH |
| Einsätze übertragen | `sendEinsaetze()` | ❌ FEHLT | FEHLT |

**Status:** ⚠️ INKONSISTENT - Funktionsnamen stimmen nicht überein

### Buttons im HTML (Tabs)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| Stammdaten | `showTab('stammdaten',this)` | ❌ FEHLT | FEHLT |
| Einsatz Monat | `showTab('einsatzmonat',this)` | ❌ FEHLT | FEHLT |
| (alle weiteren Tabs) | `showTab(...)` | ❌ FEHLT | FEHLT |

**Status:** ❌ FEHLT - `showTab()` Funktion nicht implementiert

### Buttons in Tab-Content
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| Koordinaten | `openKoordinaten()` | ✅ `getKoordinaten()` | FALSCH |
| Laden (Einsatz Monat) | `loadEinsatzMonat()` | ❌ FEHLT | FEHLT |
| Excel Export | `exportXLEinsatz()` | ❌ FEHLT | FEHLT |
| + Neu (Nicht Verfügbar) | `addNichtVerfuegbar()` | ❌ FEHLT | FEHLT |
| Löschen (Nicht Verfügbar) | `deleteNichtVerfuegbar()` | ❌ FEHLT | FEHLT |
| Brief erstellen | `createBrief()` | ❌ FEHLT | FEHLT |
| Maps öffnen | `openMaps()` | ✅ `openMaps()` | OK |

**Zusammenfassung frm_N_MA_Mitarbeiterstamm_V2:**
- Gesamt Buttons: ~50
- Mit korrektem Handler: ~5
- Mit falschem Handler: ~10
- Ohne Handler: ~35
- **Status:** 🔴 KRITISCH - Massive Lücken

---

## 2. frm_N_KD_Kundenstamm_V2.html

### Buttons (Sidebar)
| Button | onclick | Status |
|--------|---------|--------|
| (wie bei MA) | `openMenu(...)` | FEHLT |

### Buttons (Header - Navigation)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| Erster | `navFirst()` | ❌ FEHLT | FEHLT |
| Zurück | `navPrev()` | ❌ FEHLT | FEHLT |
| Weiter | `navNext()` | ❌ FEHLT | FEHLT |
| Letzter | `navLast()` | ❌ FEHLT | FEHLT |

### Buttons (Header - Aktionen)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| Verrechnungssätze | `showVerrechnungssaetze()` | ✅ `openVerrechnungssaetze()` | FALSCH |
| Umsatzauswertung | `showUmsatzauswertung()` | ✅ `openUmsatzauswertung()` | FALSCH |
| Kunden löschen | `deleteKunde()` | ✅ `deleteRecord()` | FALSCH |
| Neuer Kunde | `newKunde()` | ✅ `newRecord()` | FALSCH |

### Buttons (Tabs)
| Button | onclick | Status |
|--------|---------|--------|
| Stammdaten, Konditionen, etc. | `showTab(...)` | FEHLT |

### Buttons (Tab-Content)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| Laden (Aufträge) | `loadKdAuftraege()` | ❌ FEHLT | FEHLT |
| Auftrags-Rch PDF | `exportRchPDF()` | ❌ FEHLT | FEHLT |
| Position PDF | `exportRchPosPDF()` | ❌ FEHLT | FEHLT |
| Neues Angebot | `newAngebot()` | ❌ FEHLT | FEHLT |
| + Anhang hinzufügen | `addAttachment()` | ✅ `dateiHinzufuegen()` | FALSCH |
| + Ansprechpartner | `addAnsprechpartner()` | ❌ FEHLT | FEHLT |

**Zusammenfassung frm_N_KD_Kundenstamm_V2:**
- Gesamt Buttons: ~25
- Mit korrektem Handler: ~0
- Mit falschem Handler: ~8
- Ohne Handler: ~17
- **Status:** 🔴 KRITISCH

---

## 3. frm_N_VA_Auftragstamm_V2.html

### Buttons (Sidebar)
| Button | onclick | Status |
|--------|---------|--------|
| (wie oben) | `openMenu(...)` | FEHLT |

### Buttons (Header - Row 1)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| Rückmelde-Statistik | `showRueckmeldeStatistik()` | ❌ FEHLT | FEHLT |
| Syncfehler | `showSyncfehler()` | ❌ FEHLT | FEHLT |

### Buttons (Header - Navigation)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| Erster | `navFirst()` | ✅ bindButton('Befehl43') | FALSCH |
| Zurück | `navPrev()` | ✅ bindButton('Befehl41') | FALSCH |
| Weiter | `navNext()` | ✅ bindButton('Befehl40') | FALSCH |
| Letzter | `navLast()` | ✅ bindButton('btn_letzer_Datensatz') | FALSCH |

**Note:** Logic.js verwendet Access-IDs, aber HTML hat andere onclick-Namen

### Buttons (Header - Aktionen)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| Aktualisieren | `aktualisieren()` | ✅ `requeryAll()` | FALSCH |
| Mitarbeiterauswahl | `openMitarbeiterauswahl()` | ✅ `openMitarbeiterauswahl()` | OK |
| Positionen | `showPositionen()` | ✅ `openPositionen()` | FALSCH |
| Auftrag kopieren | `auftragKopieren()` | ✅ `kopierenAuftrag()` | FALSCH |
| Auftrag löschen | `auftragLoeschen()` | ✅ `loeschenAuftrag()` | FALSCH |
| Einsatzliste senden MA | `sendEinsatzlisteMA()` | ✅ `sendeEinsatzliste('MA')` | FALSCH |
| Einsatzliste senden BOS | `sendEinsatzlisteBOS()` | ✅ `sendeEinsatzliste('BOS')` | FALSCH |
| Einsatzliste senden SUB | `sendEinsatzlisteSUB()` | ✅ `sendeEinsatzliste('SUB')` | FALSCH |

### Buttons (Header - Row 2)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| Neuer Auftrag | `neuerAuftrag()` | ✅ `neuerAuftrag()` | OK |
| Namensliste ESS | `showNamenslisteESS()` | ✅ `druckeNamenlisteESS()` | FALSCH |
| Einsatzliste drucken | `druckEinsatzliste()` | ✅ `druckeEinsatzliste()` | FALSCH |

### Buttons (Datum-Navigation)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| ◄ (Datum) | `prevDay()` | ❌ FEHLT | FEHLT |
| ► (Datum) | `nextDay()` | ❌ FEHLT | FEHLT |

### Buttons (Tabs)
| Button | onclick | Status |
|--------|---------|--------|
| Einsatzliste, Antworten, etc. | `showTab(...)` | FEHLT |

### Buttons (Tab-Content)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| BWN drucken | `druckBWN()` | ❌ FEHLT | FEHLT |
| + Anhang hinzufügen | `addAttachment()` | ❌ FEHLT | FEHLT |
| PDF Kopf | `openPDFKopf()` | ❌ FEHLT | FEHLT |
| Positionen | `openPDFPos()` | ❌ FEHLT | FEHLT |

### Buttons (Auftrags-Liste)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| Go | `goAuftraege()` | ❌ FEHLT | FEHLT |
| << | `prevAuftraege()` | ❌ FEHLT | FEHLT |
| >> | `nextAuftraege()` | ❌ FEHLT | FEHLT |

**Zusammenfassung frm_N_VA_Auftragstamm_V2:**
- Gesamt Buttons: ~40
- Mit korrektem Handler: ~3
- Mit falschem Handler: ~20
- Ohne Handler: ~17
- **Status:** 🟡 INKONSISTENT - Funktionen vorhanden, aber Namen passen nicht

---

## 4. frm_OB_Objekt.html

### Buttons (Navigation - Header)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| Erster | `goFirst()` | ✅ addEventListener(btnErster) | FALSCH |
| Zurück | `goPrev()` | ✅ addEventListener(btnVorheriger) | FALSCH |
| Weiter | `goNext()` | ✅ addEventListener(btnNaechster) | FALSCH |
| Letzter | `goLast()` | ✅ addEventListener(btnLetzter) | FALSCH |

### Buttons (Aktionen - Header)
| Button | onclick | Logic.js Funktion | Status |
|--------|---------|------------------|--------|
| + Neu | `newRecord()` | ✅ `newRecord()` | OK |
| Speichern | `saveRecord()` | ✅ `saveRecord()` | OK |
| Löschen | `deleteRecord()` | ✅ `deleteRecord()` | OK |

### Buttons (Header-Links)
| Element | onclick | Status |
|---------|---------|--------|
| Auftraege zu Objekt | `openAuftraege()` | FEHLT |
| Positionen | `openPositionen()` | FEHLT |

### Buttons (Tabs)
| Button | onclick | Status |
|--------|---------|--------|
| Positionen, Zusatzdateien, etc. | `switchTab(...)` | FEHLT |

### Buttons (Tab-Content)
| Button | onclick | Status |
|--------|---------|--------|
| + Neue Position | `newPosition()` | FEHLT |
| Position löschen | `deletePosition()` | FEHLT |
| + Datei hinzufügen | `addAttachment()` | FEHLT |
| Datei löschen | `deleteAttachment()` | FEHLT |

**Zusammenfassung frm_OB_Objekt:**
- Gesamt Buttons: ~15
- Mit korrektem Handler: ~3
- Mit falschem Handler: ~4
- Ohne Handler: ~8
- **Status:** 🟡 TEILWEISE - Basis-CRUD OK, Rest fehlt

---

## Globale Probleme

### 1. Inkonsistente Funktionsnamen
**Problem:** HTML verwendet andere Namen als Logic.js

**Beispiele:**
- HTML: `navFirst()` vs Logic.js: `gotoRecord(0)`
- HTML: `deleteMA()` vs Logic.js: `deleteRecord()`
- HTML: `newKunde()` vs Logic.js: `newRecord()`

**Ursache:** Kein einheitliches Naming-Pattern

### 2. Fehlende globale Funktionen
**Betrifft alle Formulare:**

| Funktion | Verwendet in | Status |
|----------|--------------|--------|
| `openMenu(target)` | Alle Sidebars | ❌ FEHLT ÜBERALL |
| `showTab(tabId, btn)` | Alle Tab-Formulare | ❌ FEHLT ÜBERALL |
| `switchTab(tabId, btn)` | frm_OB_Objekt | ❌ FEHLT |

**Impact:** Sidebar und Tabs funktionieren nicht

### 3. Navigation-Buttons
**Problem:** Jedes Formular hat eigene onclick-Namen, aber Logic.js verwendet Event-Listener auf Button-IDs

**HTML hat:**
```javascript
onclick="navFirst()"
onclick="navPrev()"
onclick="navNext()"
onclick="navLast()"
```

**Logic.js erwartet:**
```javascript
document.getElementById('btnErster').addEventListener('click', ...)
```

**Lösung:** Entweder HTML anpassen ODER globale Wrapper-Funktionen erstellen

### 4. Formular-übergreifende Navigation
**Problem:** Buttons wie "Mitarbeiterauswahl", "Positionen öffnen" sollen andere Formulare öffnen

**Aktuell:** onclick ruft Funktion auf, aber Ziel-Formular unklar

**Benötigt:** Bridge.sendEvent('navigate', {form: '...', id: ...})

---

## Detaillierte Korrekturen erforderlich

### Priorität 1: KRITISCH (Basis-Funktionen)
1. **Navigation-Buttons** - Alle Formulare
   - navFirst, navPrev, navNext, navLast nicht implementiert
   - Lösung: Globale Funktionen erstellen ODER HTML onclick anpassen

2. **openMenu()** - Alle Sidebars
   - Keine Navigation zwischen Formularen möglich
   - Lösung: Globale openMenu() mit Bridge.sendEvent('navigate')

3. **showTab() / switchTab()** - Alle Tab-Formulare
   - Tabs nicht umschaltbar
   - Lösung: Globale Tab-Funktion (bereits in einigen HTMLs inline)

### Priorität 2: WICHTIG (Formular-spezifisch)
4. **frm_MA_Mitarbeiterstamm** - Action-Buttons
   - deleteMA, newMA, showAdressen, etc. fehlen
   - Lösung: Funktionen hinzufügen oder HTML-onclick umbenennen

5. **frm_KD_Kundenstamm** - Action-Buttons
   - Gleiche Problem wie MA

6. **frm_VA_Auftragstamm** - Datum-Navigation
   - prevDay, nextDay fehlen
   - Lösung: Implementieren

### Priorität 3: OPTIONAL (Erweiterte Features)
7. **Tab-Content Buttons**
   - loadEinsatzMonat, exportXLEinsatz, etc.
   - Lösung: Nach Bedarf implementieren

8. **Subform-Buttons**
   - addPosition, deletePosition, etc.
   - Lösung: Subform-spezifische Logic

---

## Empfohlene Lösungsstrategie

### Ansatz A: HTML-onclick anpassen (SCHNELL)
**Pro:** Minimale Code-Änderungen
**Contra:** Viele Dateien ändern

**Beispiel:**
```html
<!-- Vorher -->
<button onclick="navFirst()">|◄</button>

<!-- Nachher -->
<button id="btnErster">|◄</button>
```

**Logic.js bleibt:**
```javascript
document.getElementById('btnErster').addEventListener('click', ...)
```

### Ansatz B: Globale Wrapper-Funktionen (FLEXIBEL)
**Pro:** HTML bleibt unverändert
**Contra:** Zusätzliche Abstraktionsschicht

**Neue Datei:** `global-handlers.js`
```javascript
// Navigation (generisch)
function navFirst() { window.appState.gotoRecord(0); }
function navPrev() { window.appState.gotoRecord(window.appState.currentIndex - 1); }
function navNext() { window.appState.gotoRecord(window.appState.currentIndex + 1); }
function navLast() { window.appState.gotoRecord(window.appState.records.length - 1); }

// CRUD (generisch)
function newRecord() { window.appState.newRecord(); }
function saveRecord() { window.appState.saveRecord(); }
function deleteRecord() { window.appState.deleteRecord(); }

// Navigation zwischen Formularen
function openMenu(target) {
    const formMap = {
        'dienstplan': 'frm_N_DP_Dienstplan_MA',
        'planung': 'frm_VA_Planungsuebersicht',
        'auftrag': 'frm_N_VA_Auftragstamm_V2',
        'mitarbeiter': 'frm_N_MA_Mitarbeiterstamm_V2',
        'kunden': 'frm_N_KD_Kundenstamm_V2',
        // ...
    };
    const formName = formMap[target];
    if (formName) {
        Bridge.sendEvent('navigate', { form: formName });
    }
}

// Tabs (generisch)
function showTab(tabId, btnElement) {
    document.querySelectorAll('.tab-content').forEach(t => {
        t.style.display = 'none';
        t.classList.remove('active');
    });
    document.querySelectorAll('.tab-btn').forEach(b => {
        b.classList.remove('active');
    });
    const tab = document.getElementById('tab-' + tabId);
    if (tab) {
        tab.style.display = 'block';
        tab.classList.add('active');
    }
    if (btnElement) btnElement.classList.add('active');
}
```

**In jeder Logic.js:**
```javascript
window.appState = {
    gotoRecord,
    newRecord,
    saveRecord,
    deleteRecord,
    records: state.records,
    currentIndex: state.currentIndex
};
```

### Ansatz C: Hybrid (EMPFOHLEN)
1. **Globale Funktionen** für Navigation, Tabs, openMenu
2. **Formular-spezifische onclick** anpassen für CRUD (newMA → newRecord)
3. **Bridge-Integration** für Formular-Navigation

---

## Nächste Schritte

### Phase 1: Basis-Funktionalität (1-2h)
1. ✅ Erstelle `global-handlers.js` mit:
   - navFirst, navPrev, navNext, navLast
   - showTab, switchTab
   - openMenu mit Bridge.sendEvent
2. ✅ Binde in alle HTML-Formulare ein
3. ✅ Teste Navigation und Tabs

### Phase 2: Formular-spezifische Anpassungen (2-4h)
4. ⬜ MA-Stamm: Funktionsnamen anpassen
5. ⬜ KD-Stamm: Funktionsnamen anpassen
6. ⬜ VA-Stamm: prevDay/nextDay implementieren
7. ⬜ OB-Objekt: Subform-Funktionen

### Phase 3: Erweiterte Features (optional)
8. ⬜ Excel-Exporte
9. ⬜ PDF-Generierung
10. ⬜ E-Mail-Funktionen

---

## Status-Legende
- ✅ OK - Funktion vorhanden und korrekt
- ⚠️ FALSCH - Funktion vorhanden, aber Name stimmt nicht
- ❌ FEHLT - Funktion nicht implementiert
- 🔴 KRITISCH - Formular nicht funktionsfähig
- 🟡 TEILWEISE - Einige Funktionen OK
- 🟢 GUT - Meiste Funktionen OK

---

**Fazit:**
Alle HTML-Formulare haben **massive Button-Inkonsistenzen**. Ohne die empfohlenen Korrekturen sind Navigation, Tabs und Formular-übergreifende Aktionen **nicht funktionsfähig**.

**Empfehlung:** Sofortige Implementierung von Ansatz C (Hybrid) mit Fokus auf Phase 1.
