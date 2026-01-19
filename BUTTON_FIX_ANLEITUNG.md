# Button-Funktionalität Fix - Implementierungs-Anleitung

Stand: 2026-01-01

## Übersicht

Diese Anleitung beschreibt die Schritte zur Behebung der Button-Inkonsistenzen in allen HTML-Formularen.

---

## Problem-Zusammenfassung

**Hauptprobleme:**
1. ❌ HTML-onclick-Namen ≠ Logic.js-Funktionsnamen
2. ❌ Globale Funktionen (openMenu, showTab) fehlen komplett
3. ❌ Navigation-Buttons nicht funktionsfähig
4. ❌ Formular-übergreifende Navigation nicht implementiert

**Impact:**
- Sidebar-Navigation funktioniert nicht
- Tab-Umschaltung funktioniert nicht
- Datensatz-Navigation funktioniert nicht
- Kein Wechsel zwischen Formularen möglich

---

## Lösung: Global-Handlers.js

**Datei:** `04_HTML_Forms/forms/js/global-handlers.js` ✅ ERSTELLT

**Inhalt:**
- Navigation: navFirst, navPrev, navNext, navLast
- CRUD: newRecord, saveRecord, deleteRecord
- Formular-Navigation: openMenu(target)
- Tab-Handling: showTab, switchTab
- Formular-spezifische Aliase (newMA, deleteKunde, etc.)
- Platzhalter für erweiterte Funktionen (TODO)

---

## Schritt 1: Global-Handlers einbinden

### 1.1 In ALLEN HTML-Formularen einfügen

**Pfad:** Jede frm_*.html Datei

**Einfügen VOR dem schließenden `</body>` Tag:**

```html
    <!-- Global Handlers für Button-Funktionalität -->
    <script src="../js/global-handlers.js"></script>

    <!-- Formular-spezifische Logic -->
    <script type="module" src="../logic/frm_XXX.logic.js"></script>
</body>
```

**WICHTIG:** `global-handlers.js` MUSS VOR der formular-spezifischen logic.js geladen werden!

### 1.2 Betroffene Dateien

Alle Dateien in:
- `04_HTML_Forms/forms/*.html`
- `04_HTML_Forms/forms/mitarbeiterverwaltung/*.html`
- `04_HTML_Forms/forms/kundenverwaltung/*.html`
- `04_HTML_Forms/forms/auftragsverwaltung/*.html`

**Liste (Priorität):**
1. ✅ frm_N_MA_Mitarbeiterstamm_V2.html
2. ✅ frm_N_KD_Kundenstamm_V2.html
3. ✅ frm_N_VA_Auftragstamm_V2.html
4. ✅ frm_OB_Objekt.html
5. ⬜ frm_MA_Abwesenheit.html
6. ⬜ frm_MA_Zeitkonten.html
7. ⬜ frm_N_Lohnabrechnungen_V2.html
8. ⬜ frm_N_Stundenauswertung.html
9. ⬜ frm_N_DP_Dienstplan_MA.html
10. ⬜ frm_N_DP_Dienstplan_Objekt.html
11. ⬜ frm_VA_Planungsuebersicht.html
12. ⬜ frm_Menuefuehrung1.html
13. ⬜ (Alle weiteren frm_*.html)

---

## Schritt 2: appState in Logic.js registrieren

### 2.1 Am Ende jeder Logic.js init()-Funktion

**Beispiel frm_MA_Mitarbeiterstamm.logic.js:**

```javascript
async function init() {
    console.log('[frm_MA_Mitarbeiterstamm] Initialisierung...');

    // ... bestehender Code ...

    await loadList();
    setStatus('Bereit');

    // NEU: appState für global-handlers registrieren
    if (typeof registerAppState === 'function') {
        registerAppState({
            gotoRecord,
            newRecord,
            saveRecord,
            deleteRecord,
            currentRecord: state.currentRecord,
            currentIndex: state.currentIndex,
            records: state.records,
            // Formular-spezifische Funktionen
            openZeitkonto,
            openMAAdresse,
            openMaps,
            getKoordinaten
        });
    }
}
```

### 2.2 Betroffene Logic.js Dateien

Alle Dateien in `04_HTML_Forms/forms/logic/`:

1. ✅ frm_MA_Mitarbeiterstamm.logic.js
2. ✅ frm_KD_Kundenstamm.logic.js
3. ✅ frm_va_Auftragstamm.logic.js
4. ✅ frm_OB_Objekt.logic.js
5. ⬜ frm_MA_Abwesenheit.logic.js
6. ⬜ frm_MA_Zeitkonten.logic.js
7. ⬜ (Alle weiteren .logic.js)

---

## Schritt 3: Formular-spezifische Anpassungen

### 3.1 frm_va_Auftragstamm.logic.js

**HINZUFÜGEN:**

```javascript
// Datum-Navigation (für prevDay/nextDay Buttons)
function navigateDay(direction) {
    const datumInput = document.getElementById('datTag');
    if (!datumInput) return;

    const currentDate = new Date(datumInput.value || new Date());
    currentDate.setDate(currentDate.getDate() + direction);

    datumInput.value = currentDate.toISOString().split('T')[0];

    // Daten neu laden
    loadDatenFuerDatum(datumInput.value);
}

// In appState registrieren
registerAppState({
    // ... bestehende Funktionen ...
    navigateDay,
    sendeEinsatzliste,
    druckeEinsatzliste,
    druckeNamenlisteESS,
    kopierenAuftrag,
    requeryAll,
    openMitarbeiterauswahl
});
```

### 3.2 frm_MA_Mitarbeiterstamm.logic.js

**Tab-Change Handler hinzufügen:**

```javascript
function onTabChange(tabId) {
    console.log('[MA] Tab gewechselt:', tabId);

    switch(tabId) {
        case 'einsatzmonat':
            // Einsatzdaten laden wenn nötig
            break;
        case 'dienstplan':
            // Dienstplan laden
            break;
        // ... weitere Tabs
    }
}

// In appState registrieren
registerAppState({
    // ... bestehende Funktionen ...
    onTabChange
});
```

---

## Schritt 4: HTML-Anpassungen (Optional)

### 4.1 Inline-showTab entfernen

**Einige HTML-Dateien haben bereits inline-JavaScript für showTab.**

**Beispiel in frm_N_MA_Mitarbeiterstamm_V2.html:**

```html
<script>
    // Global showTab function (wird vor den Tabs geladen)
    function showTab(tabId) {
        console.log('showTab:', tabId);
        // ...
    }
</script>
```

**AKTION:** Diese KANN entfernt werden, da global-handlers.js bereits showTab bereitstellt.

**ABER:** Wenn die inline-Version zusätzliche Logik hat, behalten und global-handlers nicht überschreiben!

### 4.2 Button-IDs hinzufügen (falls benötigt)

**Manche Buttons haben nur onclick, aber keine ID:**

```html
<!-- Vorher -->
<button class="nav-btn" onclick="navFirst()">|◄</button>

<!-- Optional: ID hinzufügen für EventListener -->
<button id="btnErster" class="nav-btn" onclick="navFirst()">|◄</button>
```

**VORTEIL:** Ermöglicht sowohl onclick ALS AUCH addEventListener-Ansatz.

---

## Schritt 5: Testing

### 5.1 Test-Checklist pro Formular

**Formular öffnen und testen:**

- [ ] Sidebar-Buttons (openMenu) funktionieren
- [ ] Navigation-Buttons (Erster, Zurück, Weiter, Letzter)
- [ ] Tab-Buttons (Stammdaten, etc.)
- [ ] CRUD-Buttons (Neu, Speichern, Löschen)
- [ ] Formular-spezifische Buttons (je nach Formular)

### 5.2 Browser-Console überprüfen

**Erwartete Meldungen:**

```
[Global] global-handlers.js geladen
[frm_MA_Mitarbeiterstamm] Initialisierung...
[Global] appState registriert: gotoRecord, newRecord, saveRecord, ...
```

**Fehler beheben:**

```
[Global] navFirst: appState.gotoRecord nicht verfügbar
→ appState nicht korrekt registriert in Logic.js
```

### 5.3 Funktionalitäts-Test

**Für jedes Formular:**

1. **Navigation testen:**
   - Erster Datensatz laden
   - Vor/Zurück navigieren
   - Letzter Datensatz laden

2. **CRUD testen:**
   - Neuen Datensatz erstellen
   - Änderungen speichern
   - Datensatz löschen (mit Bestätigung)

3. **Sidebar testen:**
   - Verschiedene Menü-Punkte anklicken
   - Prüfen ob Formular wechselt

4. **Tabs testen:**
   - Alle Tabs durchklicken
   - Prüfen ob Inhalt wechselt

---

## Schritt 6: Erweiterte Funktionen implementieren (Phase 2)

### 6.1 TODO-Liste aus global-handlers.js

**Aktuell als Platzhalter:**

```javascript
function loadEinsatzMonat() {
    console.log('[Global] loadEinsatzMonat - TODO: Implementieren');
}
```

**Implementieren in formular-spezifischer Logic.js:**

```javascript
// In frm_MA_Mitarbeiterstamm.logic.js
async function loadEinsatzMonat() {
    const monat = document.getElementById('cboEinsatzMonat').value;
    const jahr = document.getElementById('cboEinsatzJahr').value;

    if (!monat || !jahr) {
        setStatus('Bitte Monat und Jahr auswählen');
        return;
    }

    setStatus('Lade Einsätze...');

    try {
        const result = await Bridge.execute('getMAEinsaetze', {
            ma_id: state.currentRecord.MA_ID,
            monat: monat,
            jahr: jahr
        });

        renderEinsatzMonat(result.data);
        setStatus(`${result.data.length} Einsätze geladen`);
    } catch (error) {
        console.error('[MA] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// In appState registrieren
registerAppState({
    // ...
    loadEinsatzMonat
});
```

**Dann in global-handlers.js ersetzen:**

```javascript
function loadEinsatzMonat() {
    if (window.appState && typeof window.appState.loadEinsatzMonat === 'function') {
        window.appState.loadEinsatzMonat();
    } else {
        console.warn('[Global] loadEinsatzMonat: Funktion nicht verfügbar');
    }
}
```

### 6.2 Priorisierung

**Priorität 1 (sofort):**
- Navigation (navFirst, etc.) ✅ DONE
- Tabs (showTab) ✅ DONE
- openMenu ✅ DONE
- CRUD (newRecord, etc.) ✅ DONE

**Priorität 2 (wichtig):**
- loadEinsatzMonat, loadEinsatzJahr
- exportXL* Funktionen
- Datum-Navigation (prevDay, nextDay)
- Mitarbeiterauswahl, Positionen

**Priorität 3 (optional):**
- PDF-Exporte
- E-Mail-Funktionen
- Brief-Erstellung
- Maps-Integration

---

## Schritt 7: Integration mit WebView2 Bridge

### 7.1 Formular-Navigation testen

**Im Access VBA:**

```vba
' Mitarbeiter öffnen
Call OpenMitarbeiterstammHTML(123)
```

**Im HTML (Sidebar-Click):**

```javascript
// User klickt "Auftragsverwaltung"
openMenu('auftrag')

// global-handlers.js sendet:
Bridge.sendEvent('navigate', {
    form: 'frm_N_VA_Auftragstamm_V2',
    id: null
});

// VBA empfängt Event und öffnet Formular
```

### 7.2 Daten zwischen Formularen übergeben

**Beispiel: Von Mitarbeiter zu Zeitkonto:**

```javascript
// In frm_MA_Mitarbeiterstamm.logic.js
function showZeitkonto() {
    const maId = state.currentRecord?.MA_ID;

    if (!maId) {
        alert('Kein Mitarbeiter ausgewählt');
        return;
    }

    // Navigiere zu Zeitkonto-Formular mit MA_ID
    Bridge.sendEvent('navigate', {
        form: 'frm_MA_Zeitkonten',
        id: maId
    });
}
```

**Im VBA (mdl_N_WebView2Bridge.bas):**

```vba
' Event-Handler
Select Case eventType
    Case "navigate"
        Dim targetForm As String
        Dim targetID As Long

        targetForm = parsed("form")
        targetID = parsed("id")

        ' Formular öffnen
        Select Case targetForm
            Case "frm_MA_Zeitkonten"
                Call OpenZeitkontenHTML(targetID)
            Case "frm_N_VA_Auftragstamm_V2"
                Call OpenAuftragstammHTML(targetID)
            ' ...
        End Select
End Select
```

---

## Schritt 8: Dokumentation aktualisieren

### 8.1 README für Entwickler

**Datei:** `04_HTML_Forms/README_BUTTONS.md` (NEU)

**Inhalt:**
- Übersicht über global-handlers.js
- Naming-Conventions für Buttons
- Wie neue Funktionen hinzufügen
- Testing-Guide

### 8.2 Inline-Kommentare

**In jeder Logic.js:**

```javascript
/**
 * Initialisierung
 * WICHTIG: registerAppState() aufrufen für global-handlers.js!
 */
async function init() {
    // ...

    // appState exportieren für globale Button-Handler
    registerAppState({
        gotoRecord,
        newRecord,
        // ...
    });
}
```

---

## Zusammenfassung

### Was wurde erstellt?
1. ✅ **BUTTON_FUNKTIONALITAET_REPORT.md** - Vollständige Analyse
2. ✅ **global-handlers.js** - Globale Button-Funktionen
3. ✅ **BUTTON_FIX_ANLEITUNG.md** - Diese Anleitung

### Nächste Schritte?
1. ⬜ global-handlers.js in alle HTML-Formulare einbinden
2. ⬜ registerAppState() in alle Logic.js einbauen
3. ⬜ Formular-spezifische Funktionen implementieren (navigateDay, etc.)
4. ⬜ Testing durchführen
5. ⬜ Erweiterte Funktionen nach Bedarf implementieren

### Zeitaufwand (Schätzung)
- Phase 1 (Basis): 1-2 Stunden
- Phase 2 (Formular-spezifisch): 2-4 Stunden
- Phase 3 (Erweitert): 4-8 Stunden

**Gesamt:** 7-14 Stunden für vollständige Implementierung

---

## Support / Fragen

**Bei Problemen:**
1. Browser-Console prüfen (F12)
2. Prüfen ob global-handlers.js geladen wurde
3. Prüfen ob appState registriert wurde
4. Einzelne Funktion in Console testen: `navFirst()`

**Typische Fehler:**

```javascript
// Fehler: navFirst is not defined
→ global-handlers.js nicht geladen

// Fehler: appState.gotoRecord nicht verfügbar
→ registerAppState() nicht aufgerufen in Logic.js

// Fehler: Cannot read property 'MA_ID' of null
→ Kein Datensatz geladen, state.currentRecord ist null
```

---

**Stand:** 2026-01-01
**Autor:** Claude (Sonnet 4.5)
**Version:** 1.0
