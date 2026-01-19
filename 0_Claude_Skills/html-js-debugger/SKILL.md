---
name: HTML/JS Debugger
description: Debuggt HTML Formulare und JavaScript, findet Frontend-Fehler
when_to_use: JavaScript Error, Console Error, fetch failed, Formular funktioniert nicht, Event Listener, DOM Error
version: 1.0.0
---

# HTML/JS Debugger für CONSYS

## Browser DevTools (F12)

### Console-Tab
- Zeigt JavaScript Fehler
- `console.log()` Ausgaben
- Rot = Error, Gelb = Warning

### Network-Tab
- API-Calls überwachen
- Status-Codes prüfen (200=OK, 404=Not Found, 500=Server Error)
- Response-Body ansehen

## Häufige JS Fehler

| Fehler | Ursache | Lösung |
|--------|---------|--------|
| `undefined is not a function` | Funktion existiert nicht | Funktionsname prüfen |
| `Cannot read property of null` | Element nicht gefunden | ID prüfen, DOM geladen? |
| `CORS error` | API blockiert | Server CORS-Header |
| `Failed to fetch` | Server nicht erreichbar | Server läuft? URL korrekt? |
| `SyntaxError` | JS-Syntax falsch | Klammern, Semikolon prüfen |

## Event Listener Debug

```html
<!-- FALSCH: onclick als String -->
<button onclick="saveData">Speichern</button>

<!-- RICHTIG: onclick mit Klammern -->
<button onclick="saveData()">Speichern</button>

<!-- RICHTIG: Event Listener in JS -->
<button id="btnSave">Speichern</button>
<script>
document.getElementById('btnSave').addEventListener('click', saveData);
</script>
```

## Fetch/API-Call Debug

```javascript
async function loadData() {
    try {
        console.log('Lade Daten...');
        const response = await fetch('http://localhost:5000/api/data');
        console.log('Response Status:', response.status);
        
        if (!response.ok) {
            throw new Error('HTTP Error: ' + response.status);
        }
        
        const data = await response.json();
        console.log('Daten:', data);
        return data;
    } catch (error) {
        console.error('Fetch Error:', error);
        alert('Fehler beim Laden: ' + error.message);
    }
}
```

## DOM-Element prüfen

```javascript
// Element existiert?
const btn = document.getElementById('btnSave');
if (!btn) {
    console.error('Button btnSave nicht gefunden!');
    return;
}

// Alle Buttons auflisten
document.querySelectorAll('button').forEach(b => {
    console.log('Button:', b.id, b.innerText);
});
```

## Form-Daten auslesen

```javascript
function getFormData() {
    const form = document.getElementById('myForm');
    const formData = new FormData(form);
    
    // Debug: Alle Felder ausgeben
    for (let [key, value] of formData.entries()) {
        console.log(key + ': ' + value);
    }
    
    // Als JSON
    const data = Object.fromEntries(formData);
    console.log('Form Data:', data);
    return data;
}
```

## Inline-Debug hinzufügen

```html
<button onclick="console.log('Klick!'); saveData();">Speichern</button>

<!-- Oder mit Breakpoint -->
<button onclick="debugger; saveData();">Speichern</button>
```

## API-Aufruf testen

```javascript
// In Browser Console (F12) eingeben:
fetch('http://localhost:5000/api/health')
    .then(r => r.json())
    .then(console.log)
    .catch(console.error);
```

## Netzwerk-Fehler-Checkliste

1. ✓ Server läuft? (`python api_server.py`)
2. ✓ URL korrekt? (http://localhost:5000/api/...)
3. ✓ CORS aktiviert?
4. ✓ Methode korrekt? (GET vs POST)
5. ✓ Content-Type Header bei POST?

## POST Request mit JSON

```javascript
async function sendData(data) {
    const response = await fetch('http://localhost:5000/api/save', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    });
    return response.json();
}
```

## Dateipfade
- HTML: `04_HTML_Forms/forms3/*.html`
- JS: `04_HTML_Forms/forms3/js/`
