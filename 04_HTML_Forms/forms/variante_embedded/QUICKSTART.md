# Quick Start - Embedded-Sidebar-Variante

## In 5 Minuten starten

### 1. API Server starten (WICHTIG!)

```bash
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py
```

**Warten bis:** `Running on http://127.0.0.1:5000`

---

### 2. Formular im Browser öffnen

**Option A: Auftragstamm**
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\variante_embedded\frm_va_Auftragstamm_embedded.html
```

**Option B: Mitarbeiterstamm**
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\variante_embedded\frm_MA_Mitarbeiterstamm_embedded.html
```

---

### 3. Testen

1. **Sidebar erscheint** auf der linken Seite
2. **Klick auf Menüpunkt** (z.B. "Mitarbeiterstamm")
3. **Navigation funktioniert** → neues Formular lädt
4. **Aktives Menü** ist hervorgehoben

---

## Wie es funktioniert

```
┌─────────────────────────────────────────┐
│  frm_va_Auftragstamm_embedded.html      │
│                                         │
│  ┌──────────┐  ┌──────────────────────┐│
│  │ Sidebar  │  │   Formular-Inhalt    ││
│  │ (iframe) │  │                      ││
│  │          │  │  ┌────────────────┐  ││
│  │ • MA     │  │  │ Auftrag: 123   │  ││
│  │ • Auftrag│  │  │ Status: Aktiv  │  ││
│  │ • Kunden │  │  │ ...            │  ││
│  │          │  │  └────────────────┘  ││
│  └──────────┘  └──────────────────────┘│
│       ↓ postMessage                    │
│  "NAVIGATE to mitarbeiter"             │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  frm_MA_Mitarbeiterstamm_embedded.html  │
│  (wird geladen)                         │
└─────────────────────────────────────────┘
```

---

## Neues Formular hinzufügen

### Schritt 1: Formular erstellen
Kopiere ein bestehendes Formular:
```bash
cp frm_va_Auftragstamm_embedded.html frm_Neues_Modul_embedded.html
```

### Schritt 2: data-active-menu setzen
```html
<!-- In frm_Neues_Modul_embedded.html -->
<body data-active-menu="neues_modul">
```

### Schritt 3: sub_sidebar.html erweitern
```html
<!-- FORM_MAP erweitern -->
<script>
const FORM_MAP = {
    ...
    'neues_modul': 'frm_Neues_Modul_embedded.html'
};
</script>

<!-- Menüpunkt hinzufügen -->
<div class="menu-section">Neu</div>
<a href="#" data-form="neues_modul">Neues Modul</a>
```

### Fertig!
Navigation funktioniert automatisch in allen Formularen.

---

## Sidebar ändern

### Menüpunkt umbenennen
**Nur in sub_sidebar.html:**
```html
<!-- Alt -->
<a href="#" data-form="auftrag">Auftragstamm</a>

<!-- Neu -->
<a href="#" data-form="auftrag">Aufträge verwalten</a>
```

**Alle Formulare aktualisieren sich automatisch!**

---

## Häufige Probleme

### Problem: Sidebar ist leer
**Ursache:** sub_sidebar.html nicht gefunden
**Lösung:**
```html
<!-- Prüfe Pfad im Formular -->
<iframe src="sub_sidebar.html" id="sidebarFrame"></iframe>

<!-- Falls in Unterordner, Pfad anpassen: -->
<iframe src="../sub_sidebar.html" id="sidebarFrame"></iframe>
```

### Problem: Navigation funktioniert nicht
**Ursache:** postMessage wird nicht empfangen
**Lösung:** Browser-Console öffnen (F12) und prüfen:
```javascript
// Console ausgeben sollte:
Received message: {type: "NAVIGATE", form: "auftrag", file: "..."}
```

Falls nicht: Cache leeren (Ctrl+F5)

### Problem: Keine Daten im Formular
**Ursache:** API Server nicht gestartet
**Lösung:**
```bash
# Server starten
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py

# Testen ob läuft
curl http://localhost:5000/api/mitarbeiter
```

---

## Next Steps

1. **Weitere Formulare erstellen** (siehe oben)
2. **Styling anpassen** (CSS in sub_sidebar.html)
3. **Performance messen** (Browser DevTools → Network)
4. **Migration planen** (siehe VERGLEICH_VARIANTEN.md)

---

## Nützliche Links

- **Vollständige Doku:** `README_embedded.md`
- **Varianten-Vergleich:** `VERGLEICH_VARIANTEN.md`
- **API-Endpoints:** `C:\Users\guenther.siegert\Documents\Access Bridge\api_server.py`

---

## Cheat Sheet

### postMessage senden (Sidebar → Parent)
```javascript
window.parent.postMessage({
    type: 'NAVIGATE',
    form: 'auftrag',
    file: 'frm_va_Auftragstamm_embedded.html'
}, '*');
```

### postMessage empfangen (Parent)
```javascript
window.addEventListener('message', (e) => {
    if (e.data.type === 'NAVIGATE') {
        window.location.href = e.data.file;
    }
});
```

### Aktives Menü setzen (Parent → Sidebar)
```javascript
sidebarFrame.contentWindow.postMessage({
    type: 'SET_ACTIVE',
    form: 'auftrag'
}, '*');
```

---

## Support

Bei Fragen: Siehe `README_embedded.md` → Abschnitt "Troubleshooting"
