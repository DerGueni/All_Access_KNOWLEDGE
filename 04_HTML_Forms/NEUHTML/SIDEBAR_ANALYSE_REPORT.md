# Sidebar-Analyse Report

**Erstellt:** 2026-01-03
**Projektpfad:** `04_HTML_Forms\NEUHTML\02_web\forms`

## Identifizierte Sidebar-Varianten

### Variante A: Leeres `<aside class="app-sidebar"></aside>` (sidebar.js)
Sidebar wird dynamisch durch sidebar.js gefuellt.

| Datei | Status |
|-------|--------|
| frm_abwesenheitsuebersicht.html | app-sidebar |
| frm_Abwesenheiten.html | app-sidebar |
| frm_DP_Dienstplan_MA.html | app-sidebar |
| frm_DP_Dienstplan_Objekt.html | app-sidebar |
| frm_MA_Serien_eMail_dienstplan.html | app-sidebar |
| frm_MA_Serien_eMail_Auftrag.html | app-sidebar |
| frm_MA_VA_Positionszuordnung.html | app-sidebar |
| frm_MA_VA_Schnellauswahl.html | app-sidebar |
| frm_Menuefuehrung1.html | app-sidebar |
| frm_N_AuswahlMaster.html | app-sidebar |
| frm_N_Lohnabrechnungen.html | app-sidebar |
| frm_N_MA_Bewerber_Verarbeitung.html | app-sidebar |
| frm_N_Stundenauswertung.html | app-sidebar |
| zfrm_Lohnabrechnungen.html | app-sidebar |
| zfrm_MA_Stunden_Lexware.html | app-sidebar |
| zfrm_Rueckmeldungen.html | app-sidebar |

### Variante B: Custom Sidebar mit eigenem Menue

| Datei | Class-Name | Struktur |
|-------|-----------|----------|
| frm_Ausweis_Create.html | aw-menu | `<nav class="menu-buttons">` |
| frm_Einsatzuebersicht.html | eu-menu | `<nav class="menu-buttons">` |
| frm_KD_Kundenstamm.html | kd-menu | `<nav class="menu-buttons">` |
| frm_MA_Abwesenheit.html | abw-menu | `<nav class="menu-buttons">` |
| frm_MA_Mitarbeiterstamm.html | ma-menu | `<nav class="menu-buttons">` |
| frm_MA_Zeitkonten.html | zk-menu | `<nav class="menu-buttons">` |
| frm_N_Email_versenden.html | email-menu | `<nav class="menu-buttons">` |
| frm_N_Mitarbeiterauswahl.html | maw-menu | `<nav class="menu-buttons">` |
| frm_OB_Objekt.html | ob-menu | `<nav class="menu-buttons">` |
| frm_va_Auftragstamm.html | va-menu | `<nav class="menu-buttons">` |

### Variante C: Ohne Sidebar (no-menu)
Diese Formulare haben bereits keine Sidebar.

| Datei | Struktur |
|-------|----------|
| frm_N_Dienstplanuebersicht.html | `<div class="dp-container no-menu">` |
| frm_VA_Planungsuebersicht.html | `<div class="dp-container no-menu">` |

### Variante D: Inline-definierte Sidebar

| Datei | Class-Name | Beschreibung |
|-------|-----------|--------------|
| index.html | app-sidebar | Vollstaendige Sidebar mit Inhalt |
| frm_N_Dashboard.html | db-sidebar | Eigene Dashboard-Sidebar |

### Variante E: Content-Sidebar (Sekundaer, BEHALTEN!)
Diese Sidebars sind Teil des Content-Bereichs, nicht Navigation.

| Datei | Beschreibung |
|-------|--------------|
| frm_Abwesenheiten.html | `<div class="content-sidebar">` |
| frm_MA_Serien_eMail_dienstplan.html | `<div class="content-sidebar">` |
| frm_MA_Serien_eMail_Auftrag.html | `<div class="content-sidebar">` |
| frm_MA_VA_Schnellauswahl.html | `<div class="content-sidebar">` |
| frm_N_MA_Bewerber_Verarbeitung.html | `<div class="content-sidebar">` |
| zfrm_Lohnabrechnungen.html | `<div class="content-sidebar">` |
| zfrm_Rueckmeldungen.html | `<div class="content-sidebar">` |

## Subformulare (KEINE Sidebar)
Subformulare haben keine eigene Navigation und werden nicht geaendert:
- sub_*.html
- zsub_*.html

## Bestehende Infrastruktur

### shell.html
- Preload-Manager mit iframes
- Keine zentrale nav#menu
- Formulare werden vollstaendig geladen (inkl. Sidebar)

### sidebar.js
- FORM_MAP mit Routing-Definitionen
- Shell-Integration (isInShell, navigateTo)
- Event Delegation optimiert

## Refactoring-Strategie

1. **Zu entfernen:**
   - `<aside class="app-sidebar"></aside>`
   - `<aside class="*-menu">` mit `<nav class="menu-buttons">`
   - sidebar.js Einbindung in Formularen

2. **Beizubehalten:**
   - `<div class="content-sidebar">` (Formular-interne Sidebar)
   - `<div class="*-container no-menu">` (bereits ohne Sidebar)
   - Subformulare (sub_*, zsub_*)

3. **Neue Struktur:**
   - Zentrale Shell mit `<nav id="menu">` und `<main id="content">`
   - API-gesteuertes Menue (/api/menu)
   - Hash-Routing fuer Navigation
