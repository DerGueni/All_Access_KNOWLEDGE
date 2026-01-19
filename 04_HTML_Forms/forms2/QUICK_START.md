# Quick Start - Stammdaten-Formulare mit API

**Schnellstart-Anleitung für die drei API-verbundenen Formulare**

---

## 1. API-Server starten

**WICHTIG:** Der API-Server muss laufen, damit die Formulare funktionieren!

```powershell
# In PowerShell oder CMD
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py
```

**Erwartete Ausgabe:**
```
 * Running on http://localhost:5000
 * Debug mode: on
```

**Server-Test:**
Öffne Browser und navigiere zu: `http://localhost:5000/api/kunden`

Erwartete Antwort: JSON mit Kundendaten

---

## 2. Formulare öffnen

### Option A: Direkt im Browser

```
file:///C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms2/frm_KD_Kundenstamm.html

file:///C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms2/frm_MA_Mitarbeiterstamm.html

file:///C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms2/frm_lst_row_auftrag.html
```

### Option B: Über HTTP-Server (empfohlen)

```powershell
# In forms2 Verzeichnis
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms2"

# Python HTTP-Server starten
python -m http.server 8080
```

Dann im Browser:
```
http://localhost:8080/frm_KD_Kundenstamm.html
http://localhost:8080/frm_MA_Mitarbeiterstamm.html
http://localhost:8080/frm_lst_row_auftrag.html
```

---

## 3. Kundenstamm verwenden

### Beim Öffnen
1. Kundenliste lädt automatisch im rechten Panel
2. Erster Kunde wird automatisch geladen und angezeigt
3. Status-Leiste zeigt "Bereit"

### Kunden durchblättern
- **|◄** - Zum ersten Datensatz
- **◄** - Zum vorherigen Datensatz
- **►** - Zum nächsten Datensatz
- **►|** - Zum letzten Datensatz

Oder: Kunde in der Liste rechts anklicken

### Neuen Kunden anlegen
1. Klick auf **+ Neuer Kunde**
2. Formular wird geleert
3. Daten eingeben (Firma ist Pflichtfeld!)
4. Klick auf **Speichern**
5. Erfolg-Meldung erscheint
6. Liste wird aktualisiert

### Kunde bearbeiten
1. Kunde auswählen (Navigation oder Liste)
2. Felder ändern
3. Klick auf **Speichern**
4. Änderungen werden gespeichert

### Kunde löschen
1. Kunde auswählen
2. Klick auf **Löschen**
3. Bestätigung mit "OK"
4. Kunde wird gelöscht
5. Liste wird aktualisiert

### Kunde suchen
- **Suche-Feld:** Echtzeit-Filter über Firma und Ort
- **Nur Aktive:** Checkbox aktivieren/deaktivieren

### Tabs verwenden
- **Stammdaten:** Adresse, Kontaktdaten
- **Konditionen:** Rabatt, Skonto
- **Auftragsübersicht:** Aufträge des Kunden (wird noch implementiert)
- **Ansprechpartner:** Kontaktperson
- **Zusatzdateien:** Dokumente (wird noch implementiert)
- **Bemerkungen:** Freitexte

---

## 4. Mitarbeiterstamm verwenden

### Beim Öffnen
1. Mitarbeiterliste lädt automatisch
2. Erster Mitarbeiter wird geladen
3. Foto wird angezeigt (falls vorhanden)
4. Alle Tabs sind verfügbar

### Navigation
- **Pfeil-Buttons oben links:** Datensatz-Navigation
- **Liste rechts:** Mitarbeiter anklicken
- **Filter-Dropdown:** Alle / Nur Aktive / Inaktive
- **Suche:** Echtzeit-Filter über Name

### Daten bearbeiten
1. Mitarbeiter auswählen
2. Felder in beliebigem Tab ändern
3. Klick auf **Speichern** (oben rechts)

**WICHTIG:** Das eingebettete JavaScript im HTML verwaltet das Formular. Die neue `MitarbeiterAPI` in `logic/frm_MA_Mitarbeiterstamm_api.logic.js` stellt nur Helper-Funktionen bereit.

### Neuen Mitarbeiter anlegen
1. Klick auf **Neuer Mitarbeiter**
2. Formular wird geleert
3. Stammdaten eingeben
4. Klick auf **Speichern**

### Mitarbeiter löschen
1. Mitarbeiter auswählen
2. Klick auf **Mitarbeiter löschen**
3. Bestätigung mit "OK"

### Foto anzeigen
Das Foto-Feld (`Lichtbild`) unterstützt:
- Absolute Pfade: `C:\Fotos\max.jpg`
- UNC-Pfade: `\\server\share\fotos\max.jpg`
- Relative Pfade: `max.jpg` (sucht in `../media/mitarbeiter/`)
- URLs: `http://example.com/foto.jpg`

### Tabs
- **Stammdaten:** Persönliche Daten, Adresse, Foto
- **Einsatzübersicht:** Einsätze (wird noch implementiert)
- **Dienstplan:** Dienstplan-Ansicht
- **Nicht Verfügbar:** Abwesenheiten
- **Bestand Dienstkleidung:** Kleidungsverwaltung
- **Zeitkonto:** Arbeitszeiten
- **Jahresübersicht:** Jahres-Statistik
- **Stundenübersicht:** Stunden-Details
- **Vordrucke:** Dokumente
- **Briefkopf:** Brief-Einstellungen
- **Karte:** Map-Integration
- **Sub Rechnungen:** Rechnungen
- **Überhang Stunden:** Stunden-Überhang

---

## 5. Auftragsliste verwenden

### Beim Öffnen
1. Alle Aufträge werden geladen
2. Tabelle zeigt: ID, Datum, Auftrag, Objekt, Ort, Soll, Ist

### Zeile auswählen
- **Einfacher Klick:** Zeile wird markiert (blau)
- **Doppelklick:** Auftrag öffnen (Navigation)

### Als Subform einbetten
Die Auftragsliste kann in andere Formulare eingebettet werden:

```html
<iframe id="auftragslisteIframe" src="frm_lst_row_auftrag.html"></iframe>
```

**Aufträge für Kunde laden:**
```javascript
const iframe = document.getElementById('auftragslisteIframe');
iframe.contentWindow.postMessage({
    type: 'load_for_kunde',
    kunde_id: 123,
    von: '2025-01-01',
    bis: '2025-12-31'
}, '*');
```

**Event-Handler für Auswahl:**
```javascript
window.addEventListener('message', (event) => {
    if (event.data.type === 'subform_selection') {
        console.log('Auftrag selektiert:', event.data.record);
    }

    if (event.data.type === 'open_auftrag') {
        console.log('Auftrag öffnen:', event.data.id);
    }
});
```

### Soll/Ist-Ampel
Die "Ist"-Spalte zeigt Farben:
- **Grün (soll-ok):** Ist >= Soll (vollständig besetzt)
- **Gelb (soll-warn):** Ist > 0 aber < Soll (teilweise besetzt)
- **Rot (soll-err):** Ist = 0 (nicht besetzt)

### Programmatischer Zugriff
```javascript
// Von außen:
const api = iframe.contentWindow.LstRowAuftrag;

api.requery();                    // Neu laden
api.setFilter({ status: 'aktiv' }); // Filter setzen
api.gotoRecord(123);              // Zu Datensatz springen
const selected = api.getSelectedId(); // Selektierte ID
```

---

## 6. Debugging

### Browser Console öffnen
- **Chrome/Edge:** F12 → Tab "Console"
- **Firefox:** F12 → Tab "Konsole"

### Logs überprüfen
Alle Formulare loggen ausführlich:

```
[Kundenstamm] Initialisierung...
[Kundenstamm] Lade Kundenliste...
[Kundenstamm] 42 Kunden geladen
[Kundenstamm] Lade Kunde 123...
```

### Network-Tab
Überprüfe API-Requests:
1. F12 → Tab "Network" / "Netzwerkanalyse"
2. Formular neu laden
3. Filter auf "Fetch/XHR" setzen
4. API-Calls sehen (z.B. `kunden`, `mitarbeiter`)

**Erfolgreiche Requests:** Status 200 (grün)
**Fehler:** Status 4xx oder 5xx (rot)

### Häufige Probleme

#### API-Server läuft nicht
**Symptom:** "Failed to fetch" in Console
**Lösung:** API-Server starten (siehe oben)

#### CORS-Fehler
**Symptom:** "Access blocked by CORS policy"
**Lösung:**
- HTTP-Server für HTML-Files verwenden (statt file:///)
- Oder CORS im API-Server aktivieren

#### Leere Liste
**Symptom:** "Keine Kunden gefunden"
**Lösung:**
- Prüfe ob Datenbank Einträge hat
- Prüfe API-Antwort im Network-Tab
- Prüfe Filter-Einstellungen (Nur Aktive?)

#### Felder werden nicht befüllt
**Symptom:** Formular bleibt leer nach Laden
**Lösung:**
- Prüfe API-Antwort-Struktur (data.kun_Firma vs data.kunde.kun_Firma)
- Prüfe Console auf Fehler
- Prüfe HTML Element-IDs stimmen überein

---

## 7. Integration mit Access (WebView2)

### Access-Funktion aufrufen
```vba
' In Access VBA
Public Sub OpenKundenstammHTML(Optional kun_Id As Long = 0)
    Dim htmlPath As String
    htmlPath = "C:\...\forms2\frm_KD_Kundenstamm.html"

    ' WebView2 öffnen
    Dim webHost As Object
    Set webHost = CreateObject("ConsysWebView2.WebFormHost")

    ' Daten vorbereiten
    Dim jsonData As String
    If kun_Id > 0 Then
        jsonData = "{""kun_Id"":" & kun_Id & "}"
    End If

    ' Formular anzeigen
    webHost.ShowFormWithData htmlPath, "Kundenstamm", 1200, 800, jsonData
End Sub
```

### Bridge-Event empfangen (JavaScript)
```javascript
if (typeof Bridge !== 'undefined') {
    Bridge.on('onDataReceived', (data) => {
        if (data.kun_Id) {
            loadKunde(data.kun_Id);
        }
    });
}
```

---

## 8. Nächste Schritte

### Für Entwickler
1. **Weitere Formulare anbinden:**
   - frm_OB_Objekt.html
   - frm_va_Auftragstamm.html

2. **Validierung hinzufügen:**
   - Email-Format prüfen
   - IBAN-Prüfziffer
   - Pflichtfelder markieren

3. **Pagination implementieren:**
   - Bei Listen > 100 Einträgen
   - "Lade mehr" Button

4. **Offline-Support:**
   - LocalStorage-Caching
   - Service Worker

### Für Tester
1. **Funktionstest:**
   - Alle CRUD-Operationen durchführen
   - Alle Tabs aufrufen
   - Alle Filter testen

2. **Performance-Test:**
   - Große Listen laden (> 1000 Einträge)
   - Schnelle Navigation testen
   - Suche mit vielen Zeichen

3. **Fehlertest:**
   - API-Server während Nutzung stoppen
   - Ungültige Daten eingeben
   - Browser-Console auf Fehler prüfen

---

## 9. Cheat Sheet

### Kundenstamm
```javascript
// Im Browser Console
// Kunde 123 laden
window.location.href = 'frm_KD_Kundenstamm.html?id=123';

// Alle Kunden im State anzeigen
console.log(state.kundenListe);

// Aktuellen Kunden anzeigen
console.log(state.currentKunde);
```

### Mitarbeiterstamm
```javascript
// Mitarbeiter-API testen
await MitarbeiterAPI.getAll({ aktiv: true });

// Mitarbeiter 456 laden
const ma = await MitarbeiterAPI.getById(456);
MitarbeiterAPI.fillForm(ma);
```

### Auftragsliste
```javascript
// Liste neu laden
LstRowAuftrag.requery();

// Filter setzen
LstRowAuftrag.setFilter({ kunde_id: 123 });

// Alle Datensätze anzeigen
console.log(LstRowAuftrag.getRecords());
```

---

## Support

Bei Problemen:
1. Browser-Console prüfen (F12)
2. Network-Tab prüfen (F12)
3. API-Server-Log prüfen
4. Dokumentation lesen: `API_INTEGRATION_REPORT.md`

**Viel Erfolg!**
