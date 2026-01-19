# Formulartitel Migration - Schnellanleitung

**Erstellt:** 2026-01-15
**Ziel:** Alle Formulare auf einheitliche Titelgröße (24px) migrieren

---

## 1. Was wurde geändert?

### ✅ NEU ERSTELLT:
1. **CSS Variable:** `--font-size-3xl: 24px` in `css/variables.css`
2. **CSS-Datei:** `css/form-titles.css` mit globalen Titel-Regeln
3. **Dokumentation:** `FORMULARTITEL_SCHRIFTGROESSE_SPEC.md`

### ✅ AKTUALISIERT:
- `css/variables.css` - Neue Font-Size Variable hinzugefügt

---

## 2. Migration für bestehende Formulare

### Schritt 1: CSS einbinden (ALLE Hauptformulare)

**Einfügen nach `<link rel="stylesheet" href="css/variables.css">`:**

```html
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="css/variables.css">
    <link rel="stylesheet" href="css/form-titles.css">  <!-- ⭐ NEU -->
    <!-- ... weitere CSS ... -->
</head>
```

---

### Schritt 2: Lokale Überschreibungen entfernen

**Formulare mit eigener --title-font-size Definition:**

#### Beispiel A: frm_va_Auftragstamm.html
```css
/* VORHER (ENTFERNEN): */
<style>
    :root {
        --title-font-size: 32px; /* ❌ ZU ENTFERNEN */
    }
    .app-title {
        font-size: var(--title-font-size); /* ✅ BEHALTEN (verwendet jetzt globale Variable) */
    }
</style>

/* NACHHER (NUR CSS-IMPORT): */
<link rel="stylesheet" href="css/form-titles.css">
<!-- Kein lokales :root { --title-font-size } mehr nötig! -->
```

#### Beispiel B: frm_MA_Zeitkonten.html
```css
/* VORHER (ENTFERNEN): */
.app-title {
    font-size: 23px !important; /* ❌ ZU ENTFERNEN */
}

/* NACHHER (NUR CSS-IMPORT): */
<link rel="stylesheet" href="css/form-titles.css">
<!-- Kein lokales .app-title mehr nötig! -->
```

#### Beispiel C: frm_MA_Adressen.html
```css
/* VORHER (ENTFERNEN): */
.placeholder h1 {
    font-size: 24px; /* ❌ ZU ENTFERNEN (auch wenn richtige Größe) */
}

/* NACHHER (NUR CSS-IMPORT): */
<link rel="stylesheet" href="css/form-titles.css">
<!-- Kein lokales .placeholder h1 mehr nötig! -->
```

---

### Schritt 3: Titel-Klassen verwenden

**Empfohlene HTML-Struktur für Formulartitel:**

```html
<!-- HAUPTFORMULARE (24px) -->
<div class="app-title">Auftragsverwaltung</div>
<!-- ODER -->
<h1 class="form-title">Mitarbeiterstamm</h1>
<!-- ODER -->
<div class="page-title">Dashboard</div>

<!-- SUBFORMS (14px) -->
<div class="subform-header">Einsatzliste</div>
<!-- ODER -->
<div class="form-header">Schichten</div>
```

---

## 3. Betroffene Formulare (Priorität)

### 🔴 Hohe Priorität (inkonsistente Größen)
- [ ] `frm_va_Auftragstamm.html` - aktuell **32px** → 24px
- [ ] `frm_MA_Zeitkonten.html` - aktuell **23px** → 24px
- [ ] `frm_KD_Verrechnungssaetze.html` - aktuell **23px** → 24px

### 🟡 Mittlere Priorität (zu klein)
- [ ] `frm_MA_Adressen.html` - aktuell **16px** → 24px
- [ ] `frm_KD_Umsatzauswertung.html` - aktuell **16px** → 24px
- [ ] `frmTop_VA_Akt_Objekt_Kopf.html` - aktuell **16px** → 24px
- [ ] `frmTop_KD_Adressart.html` - aktuell **16px** → 24px
- [ ] `zfrm_Rueckmeldungen.html` - aktuell **16px** → 24px
- [ ] `zfrm_SyncError.html` - aktuell **16px** → 24px

### 🟢 Niedrige Priorität (bereits 24px, nur Standardisierung)
- [ ] `frm_MA_Adressen.html` - bereits 24px, nur CSS-Import hinzufügen
- [ ] `frm_KD_Umsatzauswertung.html` - bereits 24px, nur CSS-Import hinzufügen

---

## 4. Testing nach Migration

**Nach JEDEM Formular prüfen:**

1. ✅ Titel ist **24px** groß (mit Browser DevTools messen)
2. ✅ Titel ist **deutlich größer** als Sidebar-Buttons (12px)
3. ✅ Titel ist **nicht zu dominant** (wie 32px war)
4. ✅ Subform-Header sind **kleiner** (14px)
5. ✅ Keine Console-Fehler (fehlende CSS-Datei)

**Browser DevTools:**
```
F12 → Elements → .app-title → Computed → font-size: 24px
```

---

## 5. Vor/Nach Vergleich

### Vorher (inkonsistent):
```
frm_va_Auftragstamm     → 32px ❌ zu groß
frm_MA_Zeitkonten       → 23px ❌ inkonsistent
frm_KD_Verrechnungssaetze → 23px ❌ inkonsistent
frm_MA_Adressen         → 24px ✅ korrekt (aber lokal)
frm_KD_Umsatzauswertung → 16px ❌ zu klein
```

### Nachher (einheitlich):
```
ALLE Hauptformulare     → 24px ✅ einheitlich
```

---

## 6. Batch-Migration (für Massenänderung)

**PowerShell-Script (optional):**

```powershell
# Fügt <link rel="stylesheet" href="css/form-titles.css"> nach variables.css ein
$forms = Get-ChildItem "forms3\frm_*.html"

foreach ($form in $forms) {
    $content = Get-Content $form.FullName -Raw

    # Prüfen ob form-titles.css bereits vorhanden
    if ($content -notmatch 'form-titles\.css') {
        # Nach variables.css einfügen
        $content = $content -replace '(<link rel="stylesheet" href="css/variables\.css">)', "`$1`n    <link rel=`"stylesheet`" href=`"css/form-titles.css`">"

        Set-Content $form.FullName -Value $content -Encoding UTF8
        Write-Host "Aktualisiert: $($form.Name)" -ForegroundColor Green
    }
}
```

---

## 7. Rollback (falls Probleme)

**Falls 24px zu groß/klein ist:**

1. In `css/variables.css` ändern:
```css
--font-size-3xl: 20px;  /* statt 24px */
```

2. Alle Formulare verwenden automatisch neue Größe (kein HTML ändern nötig!)

---

## 8. Support

**Bei Fragen/Problemen:**
- Siehe Dokumentation: `FORMULARTITEL_SCHRIFTGROESSE_SPEC.md`
- CSS-Datei: `css/form-titles.css`
- Variables: `css/variables.css` (Zeile 118)

---

**Status:** ✅ CSS-Infrastruktur fertig - Migration kann starten!
