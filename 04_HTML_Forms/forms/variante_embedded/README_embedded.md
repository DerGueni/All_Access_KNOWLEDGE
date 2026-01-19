# Embedded-Sidebar-Variante - Dokumentation

## Konzept

Die **Embedded-Sidebar-Variante** verwendet eine **zentrale, eigenständige Sidebar-HTML-Datei**, die in alle Formulare per **iframe** eingebettet wird. Dies ermöglicht eine zentrale Wartung der Navigation, während jedes Formular seine eigene HTML-Datei behält.

---

## Architektur

### Struktur

```
variante_embedded/
├── sub_sidebar.html                        # Standalone Sidebar (einmalig definiert)
├── frm_va_Auftragstamm_embedded.html      # Formular mit eingebetteter Sidebar
├── frm_MA_Mitarbeiterstamm_embedded.html  # Formular mit eingebetteter Sidebar
└── README_embedded.md                      # Diese Dokumentation
```

### Komponenten

#### 1. **sub_sidebar.html** (Zentrale Sidebar)
- **Eigenständige HTML-Datei** mit vollständiger Menüstruktur
- **Keine Abhängigkeiten** von Parent-Formularen
- **postMessage-Kommunikation** mit Parent für Navigation
- **Event Delegation** für alle Menü-Klicks (Performance-Optimierung)
- **Aktives Menüelement** wird vom Parent gesetzt

**Technische Details:**
```html
<!-- Sidebar wird als iframe eingebettet -->
<iframe src="sub_sidebar.html" id="sidebarFrame"></iframe>
```

**JavaScript-Kommunikation:**
```javascript
// Sidebar sendet Navigation an Parent
window.parent.postMessage({
    type: 'NAVIGATE',
    form: 'auftrag',
    file: 'frm_va_Auftragstamm_embedded.html'
}, '*');

// Parent setzt aktives Menüelement
sidebarFrame.contentWindow.postMessage({
    type: 'SET_ACTIVE',
    form: 'auftrag'
}, '*');
```

#### 2. **Formular-HTML-Dateien** (z.B. frm_va_Auftragstamm_embedded.html)
- Betten die Sidebar per **iframe** ein
- **Empfangen postMessage** von Sidebar für Navigation
- **Senden postMessage** an Sidebar für aktives Menü
- Behalten **eigenes Routing** und **Deep-Link-Fähigkeit**

**Einbettung:**
```html
<aside class="app-sidebar">
    <iframe src="sub_sidebar.html" id="sidebarFrame"></iframe>
</aside>
```

**CSS für iframe:**
```css
.app-sidebar {
    width: 250px;
    background-color: #2c3e50;
    flex-shrink: 0;
    overflow: hidden;
}

.app-sidebar iframe {
    width: 100%;
    height: 100%;
    border: none;
    display: block;
}
```

---

## Vorteile

### 1. **Zentrale Wartung**
- Sidebar-Änderungen nur in **einer Datei** (sub_sidebar.html)
- Automatische Propagierung an **alle Formulare**
- Keine Code-Duplizierung

### 2. **Einfacher als Shell**
- Kein "Shell-Container" mit Main-Content-iframe nötig
- Formulare behalten **eigenes HTML**
- **Deep-Links** funktionieren direkt (z.B. `frm_va_Auftragstamm_embedded.html?id=123`)

### 3. **Flexible Integration**
- Jedes Formular kann **individuell angepasst** werden
- Sidebar bleibt **einheitlich**
- Einfaches **A/B-Testing** verschiedener Layouts

### 4. **Browser-History funktioniert**
- Normale URL-Navigation zwischen Formularen
- Zurück/Vor-Buttons funktionieren
- Bookmarks möglich

---

## Nachteile

### 1. **iframe-Overhead**
- Sidebar wird bei jedem Formular-Wechsel **neu geladen**
- Höherer **Memory-Footprint** (jedes iframe = eigener Kontext)
- **Layout-Reflow** beim Laden

**Mitigation:**
- Browser-Caching der sub_sidebar.html
- Minimiertes CSS/JS in Sidebar
- Lazy-Loading für nicht-kritische Elemente

### 2. **postMessage-Kommunikation**
- Overhead für **bidirektionale Kommunikation**
- **Asynchrone** Kommunikation (Race-Conditions möglich)
- **Debugging** komplexer (zwei Kontexte)

**Best Practices:**
```javascript
// Immer auf SIDEBAR_READY warten
window.addEventListener('message', (e) => {
    if (e.data.type === 'SIDEBAR_READY') {
        // Jetzt sicher zu kommunizieren
        sidebarFrame.contentWindow.postMessage({...}, '*');
    }
});
```

### 3. **Same-Origin-Policy**
- Sidebar und Formulare müssen **gleichen Origin** haben
- Keine Cross-Domain-Szenarien möglich
- File:// Protokoll kann Probleme machen

### 4. **Leichte Performance-Einbußen**
- Sidebar-iframe = zusätzlicher **DOM-Baum**
- **Render-Zeit** höher als bei inline-Sidebar
- Mehr **HTTP-Requests** (jedes Formular = +1 Request für Sidebar)

---

## Kommunikationsprotokoll

### Parent → Sidebar (SET_ACTIVE)
Setzt das aktive Menüelement in der Sidebar.

```javascript
sidebarFrame.contentWindow.postMessage({
    type: 'SET_ACTIVE',
    form: 'auftrag'  // Key aus FORM_MAP
}, '*');
```

**Sidebar-Reaktion:**
```javascript
window.addEventListener('message', (e) => {
    if (e.data.type === 'SET_ACTIVE') {
        setActiveMenuItem(e.data.form);
    }
});
```

### Sidebar → Parent (NAVIGATE)
Löst Navigation zu einem anderen Formular aus.

```javascript
window.parent.postMessage({
    type: 'NAVIGATE',
    form: 'auftrag',
    file: 'frm_va_Auftragstamm_embedded.html'
}, '*');
```

**Parent-Reaktion:**
```javascript
window.addEventListener('message', (e) => {
    if (e.data.type === 'NAVIGATE' && e.data.file) {
        window.location.href = e.data.file;
    }
});
```

### Sidebar → Parent (SIDEBAR_READY)
Signalisiert, dass die Sidebar vollständig geladen ist.

```javascript
window.addEventListener('DOMContentLoaded', () => {
    window.parent.postMessage({
        type: 'SIDEBAR_READY'
    }, '*');
});
```

**Parent-Reaktion:**
```javascript
// Jetzt sicher, aktives Menü zu setzen
if (e.data.type === 'SIDEBAR_READY') {
    sidebarFrame.contentWindow.postMessage({
        type: 'SET_ACTIVE',
        form: activeMenu
    }, '*');
}
```

---

## Sidebar-Änderungen propagieren

### Szenario: Neues Menüelement hinzufügen

**1. sub_sidebar.html bearbeiten:**
```html
<div class="menu-section">Neu</div>
<a href="#" data-form="neues_modul">Neues Modul</a>
```

**2. FORM_MAP in sub_sidebar.html erweitern:**
```javascript
const FORM_MAP = {
    ...
    'neues_modul': 'frm_Neues_Modul_embedded.html'
};
```

**3. Formular erstellen:**
`frm_Neues_Modul_embedded.html` mit:
```html
<body data-active-menu="neues_modul">
    <aside class="app-sidebar">
        <iframe src="sub_sidebar.html" id="sidebarFrame"></iframe>
    </aside>
    ...
</body>
```

**4. Fertig!**
- Alle Formulare haben **automatisch** das neue Menüelement
- Keine weiteren Änderungen nötig

---

## Vergleich mit anderen Varianten

| Feature                  | Embedded     | Shell       | Inline      |
|--------------------------|--------------|-------------|-------------|
| Zentrale Sidebar         | ✅ (iframe)  | ✅ (HTML)   | ❌          |
| Deep-Links               | ✅           | ⚠️ (Hash)   | ✅          |
| Performance              | ⚠️ (iframe)  | ✅          | ✅          |
| Wartbarkeit              | ✅           | ✅          | ❌          |
| Komplexität              | ⚠️ (postMsg) | ⚠️ (Shell)  | ✅          |
| Browser-History          | ✅           | ⚠️ (Hash)   | ✅          |
| Sidebar-Reload           | ❌ (jedes Mal)| ✅ (einmal) | ❌ (jedes Mal)|

**Empfehlung:**
- **Embedded**: Wenn zentrale Wartung wichtiger als Performance
- **Shell**: Wenn Performance wichtiger als einfache URLs
- **Inline**: Wenn maximale Einfachheit gewünscht

---

## Migration von Inline → Embedded

### Schritt 1: Sidebar extrahieren
Kopiere die Sidebar aus einem bestehenden Formular nach `sub_sidebar.html`.

### Schritt 2: Formular anpassen
```html
<!-- Alt: Inline Sidebar -->
<aside class="app-sidebar">
    <nav class="sidebar-menu">
        <!-- Menüpunkte direkt hier -->
    </nav>
</aside>

<!-- Neu: Embedded Sidebar -->
<aside class="app-sidebar">
    <iframe src="sub_sidebar.html" id="sidebarFrame"></iframe>
</aside>
```

### Schritt 3: JavaScript anpassen
```javascript
// Alt: Direkter Zugriff
document.querySelector('.sidebar-menu a[data-form="auftrag"]').classList.add('active');

// Neu: postMessage
const sidebarFrame = document.getElementById('sidebarFrame');
window.addEventListener('message', (e) => {
    if (e.data.type === 'NAVIGATE') {
        window.location.href = e.data.file;
    } else if (e.data.type === 'SIDEBAR_READY') {
        sidebarFrame.contentWindow.postMessage({
            type: 'SET_ACTIVE',
            form: document.body.dataset.activeMenu
        }, '*');
    }
});
```

---

## Best Practices

### 1. **Immer auf SIDEBAR_READY warten**
```javascript
let sidebarReady = false;

window.addEventListener('message', (e) => {
    if (e.data.type === 'SIDEBAR_READY') {
        sidebarReady = true;
        initializeSidebar();
    }
});
```

### 2. **data-active-menu im body setzen**
```html
<body data-active-menu="auftrag">
```
- Ermöglicht zentrale Steuerung
- Einfaches Debugging (sichtbar im HTML)

### 3. **FORM_MAP zentral halten**
- Nur in `sub_sidebar.html` definieren
- Formulare referenzieren nur ihren eigenen Key

### 4. **CSS-Isolation beachten**
- iframe hat eigenen CSS-Scope
- Globale Styles müssen in sub_sidebar.html dupliziert werden

### 5. **Error-Handling für postMessage**
```javascript
window.addEventListener('message', (e) => {
    try {
        if (typeof e.data !== 'object') return;
        // Verarbeitung...
    } catch (err) {
        console.error('postMessage Error:', err);
    }
});
```

---

## Troubleshooting

### Problem: Sidebar bleibt leer
**Ursache:** iframe src falsch oder CORS-Problem
**Lösung:**
```javascript
// Pfad prüfen
console.log(document.getElementById('sidebarFrame').src);

// Fehler im iframe prüfen
sidebarFrame.addEventListener('error', (e) => {
    console.error('iframe load error:', e);
});
```

### Problem: Navigation funktioniert nicht
**Ursache:** postMessage wird nicht empfangen
**Lösung:**
```javascript
// Debugging aktivieren
window.addEventListener('message', (e) => {
    console.log('Received message:', e.data);
});
```

### Problem: Aktives Menü wird nicht gesetzt
**Ursache:** SIDEBAR_READY vor Listener registriert
**Lösung:**
```javascript
// Listener VOR DOMContentLoaded registrieren
window.addEventListener('message', handleMessage);
```

---

## Performance-Optimierungen

### 1. **Sidebar cachen**
```html
<!-- Cache-Control Header setzen (Server-seitig) -->
Cache-Control: public, max-age=3600
```

### 2. **Lazy Loading für iframe**
```html
<iframe src="sub_sidebar.html" loading="lazy"></iframe>
```
**Achtung:** Kann SIDEBAR_READY verzögern!

### 3. **CSS minimieren**
- Nur kritische Styles in sub_sidebar.html
- Externe Stylesheets vermeiden

### 4. **Event Delegation nutzen**
- Bereits implementiert in sub_sidebar.html
- Ein Listener für alle Menüpunkte

---

## Fazit

Die **Embedded-Sidebar-Variante** ist ideal für Projekte, die:
- **Zentrale Wartung** der Navigation benötigen
- **Einfache URLs** ohne Hash-Routing bevorzugen
- **Moderate Performance-Anforderungen** haben
- **Same-Origin-Kontext** garantieren können

Sie kombiniert die **Wartbarkeit der Shell-Variante** mit der **Einfachheit der Inline-Variante**, hat aber einen **höheren Performance-Overhead** durch das iframe-Laden bei jedem Formular-Wechsel.

---

## Beispiel-Workflow: Neues Formular hinzufügen

1. **Formular erstellen:** `frm_Neues_Formular_embedded.html`
2. **FORM_MAP erweitern:** In `sub_sidebar.html`
3. **Menüpunkt hinzufügen:** In `sub_sidebar.html`
4. **data-active-menu setzen:** In neuem Formular
5. **Fertig!** Navigation funktioniert automatisch

**Keine Änderungen an bestehenden Formularen nötig!**
