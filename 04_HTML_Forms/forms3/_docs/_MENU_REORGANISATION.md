# Menu-Reorganisation Analyse und Vorschlag

## Erstellt: 2026-01-05

---

## 1. BESTANDSANALYSE

### 1.1 Hauptmenu (shell.html - Sidebar)

Die permanente Sidebar enthaelt folgende Menuepunkte:

| # | Menuepunkt | data-form | Kategorie |
|---|------------|-----------|-----------|
| 1 | Dienstplanuebersicht | frm_N_Dienstplanuebersicht | Planung |
| 2 | Planungsuebersicht | frm_VA_Planungsuebersicht | Planung |
| - | *Separator* | - | - |
| 3 | Auftragsverwaltung | frm_va_Auftragstamm | Stammdaten |
| 4 | Mitarbeiterverwaltung | frm_MA_Mitarbeiterstamm | Stammdaten |
| 5 | Kundenverwaltung | frm_KD_Kundenstamm | Stammdaten |
| 6 | Objektverwaltung | frm_OB_Objekt | Stammdaten |
| - | *Separator* | - | - |
| 7 | Zeitkonten | frm_MA_Zeitkonten | Personal/Auswertung |
| 8 | Stundenauswertung | frm_N_Stundenauswertung | Personal/Auswertung |
| 9 | Abwesenheiten | frm_MA_Abwesenheit | Personal |
| 10 | Lohnabrechnungen | frm_N_Lohnabrechnungen | Personal/Lohn |
| - | *Separator* | - | - |
| 11 | Schnellauswahl | frm_MA_VA_Schnellauswahl | Extras |
| 12 | Einsatzuebersicht | frm_Einsatzuebersicht | Planung |
| 13 | Menu 2 | (oeffnet Popup) | Meta-Navigation |

**Gesamt: 12 Menuepunkte + 1 Popup-Button**

---

### 1.2 Menu 2 (frm_Menuefuehrung1.html - Popup)

Das Popup-Menu ist in Sektionen unterteilt:

#### Sektion: Navigation (6 Eintraege)
| Menuepunkt | Formular/Aktion | Duplikat zu Hauptmenu? |
|------------|-----------------|------------------------|
| Dienstplanuebersicht | frm_N_Dienstplanuebersicht | JA (Hauptmenu #1) |
| Planungsuebersicht | frm_VA_Planungsuebersicht | JA (Hauptmenu #2) |
| Auftragsverwaltung | frm_va_Auftragstamm | JA (Hauptmenu #3) |
| Mitarbeiterverwaltung | frm_MA_Mitarbeiterstamm | JA (Hauptmenu #4) |
| Kundenverwaltung | frm_KD_Kundenstamm | JA (Hauptmenu #5) |
| Objektverwaltung | frm_OB_Objekt | JA (Hauptmenu #6) |

#### Sektion: Personal (5 Eintraege)
| Menuepunkt | Formular/Aktion | Duplikat zu Hauptmenu? |
|------------|-----------------|------------------------|
| Zeitkonten | frm_MA_Zeitkonten | JA (Hauptmenu #7) |
| Abwesenheiten | frm_Abwesenheiten | JA (Hauptmenu #9) |
| Stundenauswertung | frm_N_Stundenauswertung | JA (Hauptmenu #8) |
| Lohnabrechnungen | frm_N_Lohnabrechnungen | JA (Hauptmenu #10) |
| Dienstausweis | frm_Dienstausweis | NEU |

#### Sektion: Extras & Tools (11 Eintraege)
| Menuepunkt | Formular/Aktion | Typ |
|------------|-----------------|-----|
| Schnellauswahl / Mail-Anfragen | frm_MA_VA_Schnellauswahl | Duplikat (Hauptmenu #11) |
| Verrechnungssaetze | frm_Verrechnungssaetze | NEU |
| Sub Rechnungen | frm_SubRechnungen | NEU |
| E-Mail | frm_Email | NEU |
| E-Mail Vorlagen | frm_ma_serien_email_vorlage | NEU |
| Mitarbeiterstamm Excel | Export-Funktion | NEU |
| Telefonliste drucken | Report | NEU |
| Monatsstunden drucken | Report | NEU |
| Jahresuebersicht MA | Report | NEU |
| Stunden MA Kreuztabelle | Query | NEU |
| Stunden Sub Export | Export-Funktion | NEU |

#### Sektion: Automatisierung (7 Eintraege)
| Menuepunkt | Aktion |
|------------|--------|
| Loewensaal Sync (Excel) | VBA: RunLoewensaalSync_WithWebScan |
| Loewensaal Sync (Homepage) | VBA: mod_N_Loewensaal_HP.SyncLoewensaalEventsFromHomepage |
| Auto-Zuordnung Minijobber | VBA: Auto_MA_Zuordnung_Sport_Venues |
| Festangestellte zuordnen | VBA: Auto_Festangestellte_Zuordnen |
| E-Mail zu Auftrag | VBA: Email_Zu_Auftrag |
| Hirsch Import | VBA: HirschImport_Starten |
| BOS Mail-Import | VBA: MailToAuftrag_FromMailText |

#### Sektion: Spezial (7 Eintraege)
| Menuepunkt | Formular/Aktion |
|------------|-----------------|
| Namensliste Fuerth | VBA-Funktion |
| FCN Meldeliste | VBA-Funktion |
| Weitere Masken | Access-Formular: __frmHlpMenu_Weitere_Masken |
| Lohnarten / Zuschlaege | zfrm_ZK_Lohnarten_Zuschlag |
| Abwesenheiten (Urlaub/Krank) | frm_MA_Abwesenheiten_Urlaub_Gueni |
| Letzter Einsatz MA | Query-Ansicht |
| Positionslisten (Objekte) | frm_OB_Objekt |

#### Sektion: System (3 Eintraege)
| Menuepunkt | Formular/Aktion |
|------------|-----------------|
| System Info | frm_SystemInfo |
| Datenbank wechseln | frm_DBWechseln |
| Auswahl-Master | frm_N_AuswahlMaster |

**Menu 2 Gesamt: 39 Menuepunkte**

---

## 2. ANALYSE DER PROBLEME

### 2.1 Duplikate
**12 von 39 Menuepunkten** in Menu 2 sind bereits im Hauptmenu vorhanden:
- Alle 6 Navigation-Eintraege
- Alle 4 Personal-Eintraege (ausser Dienstausweis)
- Schnellauswahl (teilweise)

**Problem:** Unnoetige Redundanz, Verwirrung fuer Benutzer

### 2.2 Inkonsistente Gruppierung
- "Einsatzuebersicht" ist im Hauptmenu unter "Extras", gehoert aber logisch zu "Planung"
- "Abwesenheiten" erscheint in Menu 2 zweimal (Personal + Spezial)
- "Positionslisten (Objekte)" oeffnet einfach die Objektverwaltung

### 2.3 Versteckte wichtige Funktionen
Haeufig genutzte Funktionen sind nur ueber Menu 2 erreichbar:
- E-Mail
- Dienstausweis
- Verrechnungssaetze

### 2.4 Zu viele Menuepunkte ohne Hierarchie
Menu 2 hat 39 Eintraege - zu viele fuer einen schnellen Ueberblick

---

## 3. REORGANISATIONSVORSCHLAG

### 3.1 Design-Konzept: Einheitliche Sidebar mit ausklappbaren Kategorien

```
+----------------------------------+
| CONSYS HAUPTMENU                 |
+----------------------------------+
|                                  |
| [v] PLANUNG                      |
|     Dienstplanuebersicht         |
|     Planungsuebersicht           |
|     Einsatzuebersicht            |
|     Schnellauswahl               |
|                                  |
| [v] STAMMDATEN                   |
|     Auftragsverwaltung           |
|     Mitarbeiterverwaltung        |
|     Kundenverwaltung             |
|     Objektverwaltung             |
|                                  |
| [v] PERSONAL                     |
|     Zeitkonten                   |
|     Abwesenheiten                |
|     Dienstausweis                |
|                                  |
| [v] AUSWERTUNGEN                 |
|     Stundenauswertung            |
|     Lohnabrechnungen             |
|     Monatsstunden                |
|     Jahresuebersicht             |
|                                  |
| [>] KOMMUNIKATION                |
|                                  |
| [>] AUTOMATISIERUNG              |
|                                  |
| [>] SYSTEM                       |
|                                  |
+----------------------------------+
| Browser Mode | Bereit            |
+----------------------------------+
```

Legende:
- `[v]` = Kategorie ausgeklappt (Standard fuer haeufig genutzte)
- `[>]` = Kategorie eingeklappt (klick zum Ausklappen)

---

### 3.2 Detaillierte Menustruktur

#### KATEGORIE 1: PLANUNG (Standard ausgeklappt)
*Taegliche Planungsaufgaben*

| Menuepunkt | Formular | Prioritaet |
|------------|----------|------------|
| Dienstplanuebersicht | frm_N_Dienstplanuebersicht | HOCH |
| Planungsuebersicht | frm_VA_Planungsuebersicht | HOCH |
| Einsatzuebersicht | frm_Einsatzuebersicht | MITTEL |
| Schnellauswahl | frm_MA_VA_Schnellauswahl | MITTEL |

#### KATEGORIE 2: STAMMDATEN (Standard ausgeklappt)
*Grunddaten verwalten*

| Menuepunkt | Formular | Prioritaet |
|------------|----------|------------|
| Auftragsverwaltung | frm_va_Auftragstamm | HOCH |
| Mitarbeiterverwaltung | frm_MA_Mitarbeiterstamm | HOCH |
| Kundenverwaltung | frm_KD_Kundenstamm | MITTEL |
| Objektverwaltung | frm_OB_Objekt | MITTEL |
| Verrechnungssaetze | frm_Verrechnungssaetze | NIEDRIG |

#### KATEGORIE 3: PERSONAL (Standard ausgeklappt)
*Mitarbeiterbezogene Funktionen*

| Menuepunkt | Formular | Prioritaet |
|------------|----------|------------|
| Zeitkonten | frm_MA_Zeitkonten | HOCH |
| Abwesenheiten | frm_MA_Abwesenheit | HOCH |
| Dienstausweis | frm_Dienstausweis | MITTEL |
| Lohnarten/Zuschlaege | zfrm_ZK_Lohnarten_Zuschlag | NIEDRIG |

#### KATEGORIE 4: AUSWERTUNGEN (Standard ausgeklappt)
*Berichte und Analysen*

| Menuepunkt | Formular/Report | Prioritaet |
|------------|-----------------|------------|
| Stundenauswertung | frm_N_Stundenauswertung | HOCH |
| Lohnabrechnungen | frm_N_Lohnabrechnungen | HOCH |
| Monatsstunden drucken | rpt_monatsstunden | MITTEL |
| Jahresuebersicht MA | rpt_jahresuebersicht_mitarbeiter | MITTEL |
| Stunden MA Kreuztabelle | Query | NIEDRIG |
| Telefonliste | rpt_telefonliste | NIEDRIG |
| Letzter Einsatz MA | Query | NIEDRIG |

#### KATEGORIE 5: KOMMUNIKATION (Standard eingeklappt)
*E-Mail und Listen*

| Menuepunkt | Formular/Aktion | Prioritaet |
|------------|-----------------|------------|
| E-Mail | frm_Email | MITTEL |
| E-Mail Vorlagen | frm_ma_serien_email_vorlage | MITTEL |
| Namensliste Fuerth | VBA-Export | NIEDRIG |
| FCN Meldeliste | VBA-Export | NIEDRIG |

#### KATEGORIE 6: AUTOMATISIERUNG (Standard eingeklappt)
*Import/Export und Sync*

| Menuepunkt | Aktion | Prioritaet |
|------------|--------|------------|
| Loewensaal Sync (Excel) | VBA | MITTEL |
| Loewensaal Sync (Homepage) | VBA | MITTEL |
| Auto-Zuordnung Minijobber | VBA | NIEDRIG |
| Festangestellte zuordnen | VBA | NIEDRIG |
| E-Mail zu Auftrag | VBA | NIEDRIG |
| Hirsch Import | VBA | NIEDRIG |
| BOS Mail-Import | VBA | NIEDRIG |
| Mitarbeiterstamm Excel | Export | NIEDRIG |
| Stunden Sub Export | Export | NIEDRIG |

#### KATEGORIE 7: SYSTEM (Standard eingeklappt)
*Administration*

| Menuepunkt | Formular | Prioritaet |
|------------|----------|------------|
| Auswahl-Master | frm_N_AuswahlMaster | NIEDRIG |
| System Info | frm_SystemInfo | NIEDRIG |
| Datenbank wechseln | frm_DBWechseln | NIEDRIG |
| Sub Rechnungen | frm_SubRechnungen | NIEDRIG |
| Weitere Masken | __frmHlpMenu_Weitere_Masken | NIEDRIG |

---

### 3.3 Entfernte/Zusammengefuehrte Eintraege

| Alter Eintrag | Aktion | Begruendung |
|---------------|--------|-------------|
| Menu 2 Button | ENTFERNT | Nicht mehr noetig da alles in einer Sidebar |
| Positionslisten (Objekte) | ENTFERNT | Oeffnet nur Objektverwaltung (Duplikat) |
| Alle Duplikate aus Menu 2 | ENTFERNT | Bereits in Hauptmenu |
| Abwesenheiten (Spezial) | ZUSAMMENGEFUEHRT | Eine Abwesenheiten-Funktion reicht |

---

## 4. TECHNISCHE UMSETZUNG

### 4.1 CSS fuer ausklappbare Kategorien

```css
/* Kategorie-Header */
.menu-category {
    background: linear-gradient(to bottom, #000080, #4040a0);
    color: white;
    padding: 5px 8px;
    font-weight: bold;
    font-size: 10px;
    cursor: pointer;
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 4px;
    user-select: none;
}

.menu-category:first-child {
    margin-top: 0;
}

.menu-category:hover {
    background: linear-gradient(to bottom, #1010a0, #5050b0);
}

.menu-category .arrow {
    transition: transform 0.2s ease;
}

.menu-category.collapsed .arrow {
    transform: rotate(-90deg);
}

/* Kategorie-Inhalt */
.menu-category-items {
    overflow: hidden;
    transition: max-height 0.3s ease;
    max-height: 500px;
}

.menu-category-items.collapsed {
    max-height: 0;
}

/* Menuepunkt innerhalb Kategorie */
.menu-category-items .menu-btn {
    padding-left: 16px;
    font-size: 9px;
}
```

### 4.2 HTML-Struktur

```html
<div class="menu-buttons">
    <!-- PLANUNG -->
    <div class="menu-category" onclick="toggleCategory(this)">
        <span>PLANUNG</span>
        <span class="arrow">v</span>
    </div>
    <div class="menu-category-items">
        <button class="menu-btn" data-form="frm_N_Dienstplanuebersicht">Dienstplanuebersicht</button>
        <button class="menu-btn" data-form="frm_VA_Planungsuebersicht">Planungsuebersicht</button>
        <button class="menu-btn" data-form="frm_Einsatzuebersicht">Einsatzuebersicht</button>
        <button class="menu-btn" data-form="frm_MA_VA_Schnellauswahl">Schnellauswahl</button>
    </div>

    <!-- STAMMDATEN -->
    <div class="menu-category" onclick="toggleCategory(this)">
        <span>STAMMDATEN</span>
        <span class="arrow">v</span>
    </div>
    <div class="menu-category-items">
        <button class="menu-btn active" data-form="frm_va_Auftragstamm">Auftragsverwaltung</button>
        <button class="menu-btn" data-form="frm_MA_Mitarbeiterstamm">Mitarbeiterverwaltung</button>
        <button class="menu-btn" data-form="frm_KD_Kundenstamm">Kundenverwaltung</button>
        <button class="menu-btn" data-form="frm_OB_Objekt">Objektverwaltung</button>
        <button class="menu-btn" data-form="frm_Verrechnungssaetze">Verrechnungssaetze</button>
    </div>

    <!-- PERSONAL -->
    <div class="menu-category" onclick="toggleCategory(this)">
        <span>PERSONAL</span>
        <span class="arrow">v</span>
    </div>
    <div class="menu-category-items">
        <button class="menu-btn" data-form="frm_MA_Zeitkonten">Zeitkonten</button>
        <button class="menu-btn" data-form="frm_MA_Abwesenheit">Abwesenheiten</button>
        <button class="menu-btn" data-form="frm_Dienstausweis">Dienstausweis</button>
        <button class="menu-btn" data-form="zfrm_ZK_Lohnarten_Zuschlag">Lohnarten/Zuschlaege</button>
    </div>

    <!-- AUSWERTUNGEN -->
    <div class="menu-category" onclick="toggleCategory(this)">
        <span>AUSWERTUNGEN</span>
        <span class="arrow">v</span>
    </div>
    <div class="menu-category-items">
        <button class="menu-btn" data-form="frm_N_Stundenauswertung">Stundenauswertung</button>
        <button class="menu-btn" data-form="frm_N_Lohnabrechnungen">Lohnabrechnungen</button>
        <button class="menu-btn" data-report="rpt_monatsstunden">Monatsstunden</button>
        <button class="menu-btn" data-report="rpt_jahresuebersicht_mitarbeiter">Jahresuebersicht</button>
        <button class="menu-btn" data-query="zqry_MA_VA_Stunden_Plan_Ist_aktJahr_Kreuztabelle">Stunden Kreuztabelle</button>
        <button class="menu-btn" data-report="rpt_telefonliste">Telefonliste</button>
    </div>

    <!-- KOMMUNIKATION (eingeklappt) -->
    <div class="menu-category collapsed" onclick="toggleCategory(this)">
        <span>KOMMUNIKATION</span>
        <span class="arrow">v</span>
    </div>
    <div class="menu-category-items collapsed">
        <button class="menu-btn" data-form="frm_Email">E-Mail</button>
        <button class="menu-btn" data-form="frm_ma_serien_email_vorlage">E-Mail Vorlagen</button>
        <button class="menu-btn" data-action="btnNamensliste_Click">Namensliste Fuerth</button>
        <button class="menu-btn" data-action="btnFCN_Meldeliste_Click">FCN Meldeliste</button>
    </div>

    <!-- AUTOMATISIERUNG (eingeklappt) -->
    <div class="menu-category collapsed" onclick="toggleCategory(this)">
        <span>AUTOMATISIERUNG</span>
        <span class="arrow">v</span>
    </div>
    <div class="menu-category-items collapsed">
        <button class="menu-btn" data-action="btn_LoewensaalSync_Click">Loewensaal Sync (Excel)</button>
        <button class="menu-btn" data-action="btn_Loewensaal_Sync_HP_Click">Loewensaal Sync (HP)</button>
        <button class="menu-btn" data-action="btnAutoZuordnungSport_Click">Auto-Zuordnung Minijob</button>
        <button class="menu-btn" data-action="btn_FA_eintragen_Click">Festangestellte zuordnen</button>
        <button class="menu-btn" data-action="btn_Stawa_Click">E-Mail zu Auftrag</button>
        <button class="menu-btn" data-action="btn_Hirsch_Click">Hirsch Import</button>
        <button class="menu-btn" data-action="btn_BOS_Click">BOS Mail-Import</button>
        <button class="menu-btn" data-action="exportMAStamm">MA-Stamm Excel</button>
        <button class="menu-btn" data-action="btn_stunden_sub_Click">Stunden Sub Export</button>
    </div>

    <!-- SYSTEM (eingeklappt) -->
    <div class="menu-category collapsed" onclick="toggleCategory(this)">
        <span>SYSTEM</span>
        <span class="arrow">v</span>
    </div>
    <div class="menu-category-items collapsed">
        <button class="menu-btn" data-form="frm_N_AuswahlMaster">Auswahl-Master</button>
        <button class="menu-btn" data-form="frm_SystemInfo">System Info</button>
        <button class="menu-btn" data-form="frm_DBWechseln">Datenbank wechseln</button>
        <button class="menu-btn" data-form="frm_SubRechnungen">Sub Rechnungen</button>
        <button class="menu-btn" data-action="btn_weitere_Masken_Click">Weitere Masken</button>
    </div>
</div>
```

### 4.3 JavaScript fuer Toggle-Funktion

```javascript
function toggleCategory(header) {
    header.classList.toggle('collapsed');
    const items = header.nextElementSibling;
    items.classList.toggle('collapsed');

    // Zustand in localStorage speichern
    saveMenuState();
}

function saveMenuState() {
    const categories = document.querySelectorAll('.menu-category');
    const state = {};
    categories.forEach((cat, index) => {
        state[index] = cat.classList.contains('collapsed');
    });
    localStorage.setItem('menuState', JSON.stringify(state));
}

function loadMenuState() {
    const saved = localStorage.getItem('menuState');
    if (saved) {
        const state = JSON.parse(saved);
        const categories = document.querySelectorAll('.menu-category');
        categories.forEach((cat, index) => {
            if (state[index]) {
                cat.classList.add('collapsed');
                cat.nextElementSibling.classList.add('collapsed');
            } else {
                cat.classList.remove('collapsed');
                cat.nextElementSibling.classList.remove('collapsed');
            }
        });
    }
}

// Beim Laden ausfuehren
document.addEventListener('DOMContentLoaded', loadMenuState);
```

---

## 5. VORTEILE DER REORGANISATION

| Aspekt | Vorher | Nachher |
|--------|--------|---------|
| Menuepunkte (unique) | 12 + 27 = 39 | 36 (ohne Duplikate) |
| Duplikate | 12 | 0 |
| Klicks zum Erreichen | Bis zu 2 (Menu 2 oeffnen) | Maximal 1 (Kategorie aufklappen) |
| Uebersichtlichkeit | 2 separate Menus | 1 strukturiertes Menu |
| Lernkurve | Hoch (wo ist was?) | Niedrig (logische Gruppierung) |
| Platzverbrauch | 185px + 200px Popup | 185px (nur Sidebar) |

---

## 6. MIGRATIONSPLAN

### Phase 1: Vorbereitung
1. [ ] Neue shell_v2.html mit Kategorien-Struktur erstellen
2. [ ] Alle VBA-Funktionen aus frm_Menuefuehrung1.html uebernehmen
3. [ ] CSS fuer Kategorien hinzufuegen

### Phase 2: Test
1. [ ] shell_v2.html parallel zu shell.html betreiben
2. [ ] Alle Menuepunkte testen
3. [ ] Benutzer-Feedback einholen

### Phase 3: Rollout
1. [ ] shell.html durch shell_v2.html ersetzen
2. [ ] frm_Menuefuehrung1.html als Backup behalten (nicht mehr verlinkt)
3. [ ] Dokumentation aktualisieren

---

## 7. OFFENE FRAGEN

1. **Sollen alle Kategorien beim Start ausgeklappt sein?**
   - Vorschlag: Die ersten 4 (PLANUNG, STAMMDATEN, PERSONAL, AUSWERTUNGEN) ausgeklappt, Rest eingeklappt

2. **Soll der Zustand (ein/ausgeklappt) gespeichert werden?**
   - Vorschlag: Ja, via localStorage

3. **Sollen Reports/Queries direkt im Browser angezeigt werden oder an Access weitergeleitet?**
   - Vorschlag: An Access weiterleiten via Bridge.sendEvent

4. **Sidebar-Breite anpassen?**
   - Vorschlag: Von 185px auf 200px erhoehen fuer bessere Lesbarkeit der Kategorien

---

*Dokumentation erstellt mit Claude Code*
