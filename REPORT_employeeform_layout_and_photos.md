# REPORT: Mitarbeiterformular Layout und Fotos

**Erstellt:** 2026-01-08
**Status:** ABGESCHLOSSEN

---

## 1. Layout-Anpassung

### Aktuelle Struktur (beibehalten):

```
+------------------+------------------+------------------+--Photo--+
|    Spalte 1      |    Spalte 2      |    Spalte 3      |  [Foto] |
|  Persoenliche    |  Beschaeftigung  |  Bankdaten/Lohn  |   90px  |
|  Daten + Adresse |  Ausweise        |  Arbeitszeit     |  115px  |
+------------------+------------------+------------------+---------+
```

### Implementierte Loesung:

Das Layout verwendet `padding-right: 120px` um Platz fuer das Foto zu reservieren:

```css
.form-columns {
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
    padding-right: 120px; /* Platz fuer Photo-Section rechts */
}

.photo-section {
    position: absolute;
    right: 10px;
    top: 10px;
}
```

### Vorteile:
- Foto ueberlappt keine Felder mehr
- 3-Spalten-Layout bleibt erhalten
- Responsive durch flex-wrap

---

## 2. Mitarbeiterfotos automatisch laden

### UNC-Pfad fuer Fotos:
```
\\vConSYS01-Nbg\Consys\Bilder\Mitarbeiter\
```

### Implementierte Logik (frm_MA_Mitarbeiterstamm.html):

**Konstante (Zeile 1946-1947):**
```javascript
const MA_FOTO_UNC_BASE = '//vConSYS01-Nbg/Consys/Bilder/Mitarbeiter/';
```

**resolvePhotoPath() Funktion (Zeilen 1949-1967):**
```javascript
function resolvePhotoPath(value) {
    if (!value) return '';
    // HTTP/HTTPS URLs
    if (/^https?:/i.test(value) || /^file:/i.test(value)) return value;
    // UNC-Pfad (\\server\share\...)
    if (/^\\\\/.test(value)) {
        return 'file:' + value.replace(/\\/g, '/');
    }
    // Lokaler Windows-Pfad (C:\...)
    if (/^[A-Za-z]:[\\/]/.test(value)) {
        return `file:///${value.replace(/\\/g, '/')}`;
    }
    // Nur Dateiname -> UNC-Server-Pfad verwenden
    if (value && !value.includes('/') && !value.includes('\\')) {
        return `file:${MA_FOTO_UNC_BASE}${value}`;
    }
    // Fallback: relativer Pfad
    return `../media/mitarbeiter/${value}`;
}
```

### Unterstuetzte Pfad-Formate:
| Eingabe | Ausgabe |
|---------|---------|
| `707.jpg` | `file://vConSYS01-Nbg/Consys/Bilder/Mitarbeiter/707.jpg` |
| `\\server\share\bild.jpg` | `file://server/share/bild.jpg` |
| `C:\Bilder\foto.jpg` | `file:///C:/Bilder/foto.jpg` |
| `http://server/bild.jpg` | `http://server/bild.jpg` |

---

## 3. Fehlerbehandlung

### Fehlende Bilder:
```javascript
function updatePhoto(value) {
    // ...
    photoEl.onerror = () => {
        photoEl.removeAttribute('src');
        photoEl.alt = 'Foto nicht gefunden';
        console.warn('Mitarbeiterfoto nicht gefunden:', src);
    };
}
```

### Verhalten:
- Kein Bild vorhanden: Zeigt "Kein Foto" im alt-Text
- Bild nicht gefunden: Zeigt "Foto nicht gefunden"
- Warnung in Console fuer Debugging

---

## 4. Datenquelle

Das Foto wird aus dem Mitarbeiter-Datensatz geladen:
```javascript
// Im loadMitarbeiter()
updatePhoto(ma.Lichtbild || ma.MA_Lichtbild);
```

### Erwartete Felder:
- `Lichtbild` - Primaeres Foto-Feld
- `MA_Lichtbild` - Fallback
- `tblBilddatei` - Alternative (in Logic.js)

---

## 5. Namenskonvention fuer Fotos

Basierend auf der Implementierung werden folgende Konventionen unterstuetzt:
- Mitarbeiter-ID: `707.jpg`
- Vollstaendiger Name: `Mueller_Hans.jpg`
- Beliebiger Dateiname aus DB-Feld

---

## 6. Definition of Done

- [x] Foto-Bereich ueberlappt keine Felder
- [x] UNC-Pfad wird unterstuetzt
- [x] Nur Dateiname wird automatisch vervollstaendigt
- [x] Fehlerbehandlung bei fehlenden Bildern
- [x] Platzhalterbild/-text bei fehlendem Foto
- [x] Keine Formularfehler bei fehlendem Bild

---

## 7. Hinweise

### Browser-Einschraenkungen:
- Manche Browser blockieren `file://`-URLs aus Sicherheitsgruenden
- WebView2 sollte UNC-Pfade unterstuetzen
- Fallback: API-Proxy-Endpoint fuer Foto-Zugriff empfohlen

### Empfehlung fuer produktiven Einsatz:
Falls Browser-Zugriff auf UNC-Pfade nicht funktioniert:
```javascript
// API-Proxy verwenden
photoEl.src = `http://localhost:5000/api/mitarbeiter/${maId}/foto`;
```

---

*Erstellt von Claude Code*
