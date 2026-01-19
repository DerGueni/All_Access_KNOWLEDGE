# Varianten-Vergleich: Embedded vs. Shell vs. Inline

## Übersicht

Dieses Dokument vergleicht die drei Hauptvarianten der Sidebar-Integration im CONSYS HTML Frontend.

---

## Architektur-Übersicht

### 1. **Inline-Variante** (Original)
```
frm_va_Auftragstamm.html
├── <aside class="app-sidebar">
│   ├── <nav class="sidebar-menu">
│   │   ├── <a>Mitarbeiterstamm</a>
│   │   ├── <a>Auftragstamm</a>
│   │   └── ...
│   └── </nav>
├── <main class="app-content">
└── <script src="sidebar.js">
```

**Charakteristik:**
- Sidebar-HTML **direkt im Formular**
- Sidebar-JavaScript **extern** (sidebar.js)
- **Jedes Formular** enthält vollständige Sidebar

---

### 2. **Embedded-Variante** (Diese Implementierung)
```
frm_va_Auftragstamm_embedded.html
├── <aside class="app-sidebar">
│   └── <iframe src="sub_sidebar.html">
└── <main class="app-content">

sub_sidebar.html
├── <nav class="sidebar-menu">
│   ├── <a data-form="mitarbeiter">
│   ├── <a data-form="auftrag">
│   └── ...
└── <script>postMessage to parent</script>
```

**Charakteristik:**
- Sidebar als **eigenständiges HTML** (sub_sidebar.html)
- Einbettung per **iframe** in jedes Formular
- **postMessage-Kommunikation** zwischen iframe und Parent

---

### 3. **Shell-Variante** (Alternative Architektur)
```
shell.html
├── <aside class="app-sidebar">
│   └── <nav class="sidebar-menu">
└── <main>
    └── <iframe id="contentFrame" src="frm_va_Auftragstamm_content.html">

frm_va_Auftragstamm_content.html
└── <div class="form-content">
    └── <!-- Nur Formular-Inhalt, KEINE Sidebar -->
```

**Charakteristik:**
- **Ein zentraler Shell-Container** (shell.html) mit Sidebar
- Formulare als **Content-iframes** ohne Sidebar
- Navigation lädt neue Formulare in Main-iframe

---

## Detaillierter Vergleich

| Feature                       | Inline                | Embedded              | Shell                 |
|-------------------------------|----------------------|-----------------------|-----------------------|
| **Sidebar-Definition**        | Jedes Formular       | sub_sidebar.html (1x) | shell.html (1x)       |
| **Wartbarkeit**               | ❌ Schlecht          | ✅ Gut                | ✅ Sehr gut           |
| **Code-Duplizierung**         | ❌ Hoch              | ✅ Minimal            | ✅ Keine              |
| **Performance**               | ✅ Gut               | ⚠️ Mittel (iframe)    | ✅ Sehr gut           |
| **Sidebar-Reload**            | ❌ Bei jedem Wechsel | ❌ Bei jedem Wechsel  | ✅ Nur einmal         |
| **Deep-Links**                | ✅ Direkt            | ✅ Direkt             | ⚠️ Hash-basiert       |
| **Browser-History**           | ✅ Ja                | ✅ Ja                 | ⚠️ Hash-Navigation    |
| **Bookmarks**                 | ✅ Funktioniert      | ✅ Funktioniert       | ⚠️ Nur Hash           |
| **Komplexität**               | ✅ Einfach           | ⚠️ postMessage        | ⚠️ Shell-Logik        |
| **Debugging**                 | ✅ Einfach           | ⚠️ Zwei Kontexte      | ⚠️ Zwei Kontexte      |
| **Memory-Footprint**          | ✅ Niedrig           | ⚠️ Mittel (iframe)    | ⚠️ Mittel (iframe)    |
| **Änderung propagieren**      | ❌ Alle Formulare    | ✅ Nur sub_sidebar    | ✅ Nur shell.html     |
| **SEO/Indexing**              | ✅ Optimal           | ✅ Optimal            | ⚠️ iframe-Probleme    |
| **Formular-Isolation**        | ❌ Geteilt           | ✅ Eigener Scope      | ✅ Eigener Scope      |
| **CSS-Isolation**             | ❌ Geteilt           | ✅ iframe-Isolation   | ✅ iframe-Isolation   |
| **Subform-Integration**       | ✅ Einfach           | ✅ Einfach            | ⚠️ Nested iframes     |

---

## Performance-Messungen (Theoretisch)

### Ladezeit beim Formular-Wechsel

#### Inline-Variante
```
1. Neues HTML laden (15-30 KB)        ~50ms
2. Sidebar-HTML parsen (5 KB)         ~10ms
3. sidebar.js laden (3 KB, cached)    ~5ms
4. Event-Listener binden              ~5ms
TOTAL:                                ~70ms
```

#### Embedded-Variante
```
1. Neues HTML laden (10-20 KB)        ~40ms
2. sub_sidebar.html laden (6 KB)      ~30ms
3. iframe erstellen                   ~20ms
4. postMessage etablieren             ~10ms
TOTAL:                                ~100ms
```

#### Shell-Variante
```
1. Content-HTML laden (8-15 KB)       ~30ms
2. iframe aktualisieren               ~10ms
3. Sidebar bleibt erhalten            0ms
TOTAL:                                ~40ms
```

**Gewinner:** Shell (nur Content lädt) > Inline > Embedded

---

## Use-Cases: Wann welche Variante?

### Inline-Variante: WENN
- ✅ **Prototyping/MVP** - Schnell starten
- ✅ **Kleine Anwendung** - Wenige Formulare (< 5)
- ✅ **Performance kritisch** - Keine iframe-Overhead
- ❌ **NICHT für:** Große Anwendungen mit häufigen Sidebar-Änderungen

### Embedded-Variante: WENN
- ✅ **Zentrale Wartung** - Sidebar ändert sich oft
- ✅ **Moderate Größe** - 10-20 Formulare
- ✅ **Deep-Links wichtig** - Direkte URLs bevorzugt
- ✅ **Formular-Isolation** - Jedes Formular eigenständig
- ❌ **NICHT für:** Performance-kritische Anwendungen

### Shell-Variante: WENN
- ✅ **Große Anwendung** - 20+ Formulare
- ✅ **Performance kritisch** - Minimale Ladezeiten
- ✅ **Einmalige Sidebar** - Sidebar lädt nur beim Start
- ✅ **Konsistente Navigation** - Sidebar bleibt immer sichtbar
- ❌ **NICHT für:** Wenn Deep-Links essentiell sind

---

## Code-Beispiele

### Sidebar-Änderung: Neues Menüelement hinzufügen

#### Inline-Variante (❌ Aufwendig)
**Änderungen in JEDEM Formular:**
```html
<!-- frm_va_Auftragstamm.html -->
<a href="frm_Neues_Modul.html" data-form="neues_modul">Neues Modul</a>

<!-- frm_MA_Mitarbeiterstamm.html -->
<a href="frm_Neues_Modul.html" data-form="neues_modul">Neues Modul</a>

<!-- frm_KD_Kundenstamm.html -->
<a href="frm_Neues_Modul.html" data-form="neues_modul">Neues Modul</a>

... (15 weitere Formulare)
```

#### Embedded-Variante (✅ Einfach)
**Änderung nur in sub_sidebar.html:**
```html
<!-- sub_sidebar.html -->
<div class="menu-section">Neu</div>
<a href="#" data-form="neues_modul">Neues Modul</a>

<script>
const FORM_MAP = {
    ...
    'neues_modul': 'frm_Neues_Modul_embedded.html'
};
</script>
```

#### Shell-Variante (✅ Einfach)
**Änderung nur in shell.html:**
```html
<!-- shell.html -->
<a href="#" data-form="neues_modul">Neues Modul</a>

<script>
const FORM_MAP = {
    ...
    'neues_modul': 'frm_Neues_Modul_content.html'
};
</script>
```

---

## Migration-Paths

### Inline → Embedded
**Aufwand:** 🟡 Mittel
1. sub_sidebar.html erstellen (Sidebar extrahieren)
2. Formulare anpassen (Sidebar durch iframe ersetzen)
3. postMessage-Logik hinzufügen

**Dauer:** ~2-4 Stunden für 10 Formulare

### Inline → Shell
**Aufwand:** 🔴 Hoch
1. shell.html erstellen
2. ALLE Formulare umbauen (Sidebar entfernen)
3. Routing-Logik implementieren
4. Hash-Navigation einrichten
5. Umfangreiche Tests

**Dauer:** ~1-2 Tage für 10 Formulare

### Embedded → Shell
**Aufwand:** 🟡 Mittel
1. shell.html aus sub_sidebar.html ableiten
2. _embedded.html → _content.html umbenennen
3. iframe-Einbettung entfernen
4. Routing anpassen

**Dauer:** ~4-6 Stunden für 10 Formulare

---

## Empfehlungen

### Für CONSYS Projekt (aktuell)
**Empfohlen: Embedded-Variante**

**Begründung:**
- ✅ **15+ Formulare** - Zentrale Wartung wichtig
- ✅ **Häufige Sidebar-Änderungen** - Menüstruktur evoliert
- ✅ **Deep-Links gewünscht** - Direkter Zugriff auf Formulare
- ⚠️ **Performance akzeptabel** - iframe-Overhead tolerierbar
- ✅ **Einfache Migration** - Von Inline-Variante

### Wenn Performance kritisch wird
**Erwägen: Shell-Variante**

**Trigger:**
- Formular-Wechsel > 100ms
- Memory-Probleme durch viele iframes
- Nutzer beschweren sich über Ladezeiten

### Für neue Projekte
**Klein (< 5 Formulare):** Inline
**Mittel (5-20 Formulare):** Embedded
**Groß (> 20 Formulare):** Shell

---

## Technische Details

### postMessage-Overhead (Embedded)

**Worst-Case Szenario:**
```
1. User klickt auf Menü              (Sidebar iframe)
2. postMessage NAVIGATE              ~1ms
3. Parent empfängt Event             ~1ms
4. window.location.href =            ~40ms (HTML laden)
5. Neues Formular lädt sub_sidebar   ~30ms (iframe laden)
6. sub_sidebar sendet READY          ~1ms
7. Parent sendet SET_ACTIVE          ~1ms
8. Sidebar aktualisiert UI           ~5ms
TOTAL:                               ~79ms (+ 40ms HTML)
```

**Optimiert:**
```
1-4. (wie oben)                      ~42ms
5. Browser cached sub_sidebar.html   ~5ms (Cache-Hit)
6-8. (wie oben)                      ~7ms
TOTAL:                               ~54ms (+ 40ms HTML)
```

### Shell-Routing (Hash-basiert)

**Beispiel:**
```javascript
// shell.html
window.addEventListener('hashchange', () => {
    const hash = window.location.hash.slice(1); // z.B. "auftrag"
    const file = FORM_MAP[hash];
    if (file) {
        contentFrame.src = file;
    }
});

// Navigation via:
window.location.hash = 'auftrag';
// URL: http://localhost:5000/shell.html#auftrag
```

**Problem:** Deep-Link ist nicht intuitiv
- Erwartet: `auftragstamm.html?id=123`
- Tatsächlich: `shell.html#auftrag&id=123`

---

## Fazit

| Variante  | Wartbarkeit | Performance | Komplexität | Empfehlung        |
|-----------|-------------|-------------|-------------|-------------------|
| Inline    | ❌          | ✅          | ✅          | Nur für MVP       |
| Embedded  | ✅          | ⚠️          | ⚠️          | ✅ **Standard**   |
| Shell     | ✅          | ✅          | ⚠️          | Für große Apps    |

**Für CONSYS: Embedded-Variante ist der beste Kompromiss zwischen Wartbarkeit, Performance und Komplexität.**
