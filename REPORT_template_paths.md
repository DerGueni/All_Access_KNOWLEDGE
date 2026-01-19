# REPORT: Template-Pfade und Dateien

**Erstellt:** 2026-01-08
**Status:** DOKUMENTIERT

---

## 1. VBA-Pfade (Access)

### Basis-Pfade

| Property/Konstante | Wert/Beschreibung |
|-------------------|-------------------|
| `CONSYS` | Netzwerkpfad zu CONSYS-Verzeichnis |
| `prp_CONSYS_GrundPfad` | Property mit Basis-Pfad |
| `_tblEigeneFirma_Pfade.ID=9` | Pfad fuer "Allgemein" |

### Volle Pfade

```vba
' Haupt-Arbeitsverzeichnis
CONSYS & "\CONSEC\CONSEC PLANUNG AKTUELL\"

' Allgemein-Unterordner (fuer PDFs etc.)
CONSYS & "\CONSEC\CONSEC PLANUNG AKTUELL\Allgemein\"

' UNC-Pfad (Netzwerk)
"\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\"
```

---

## 2. Report-Templates (Access)

| Report | Verwendung | Button |
|--------|-----------|--------|
| `rpt_Auftrag_Zusage` | PDF fuer E-Mail-Anhang | btnMailEins |
| `rpt_Bewachungsnachweis` | BWN-Druck (geplant) | btn_BWN_Druck |

### Report-Ausgabe
```vba
DoCmd.OutputTo acOutputReport, "rpt_Auftrag_Zusage", "PDF", PDF_Datei
```

---

## 3. Excel-Templates

| Property | Beschreibung | Button |
|----------|-------------|--------|
| `prp_XL_DocVorlage` | Excel-Template fuer Auftrag-Export | btnDruckZusage |

### Dateinamen-Konventionen
```
Auftrag-Export:   [TT-MM-JJ] [Auftrag] [Objekt].xlsm
PDF-Einsatzliste: [Auftrag] [Objekt] am [Dat_VA_Von].pdf
```

---

## 4. E-Mail-Templates (Properties)

| Property | Inhalt | Button |
|----------|--------|--------|
| `prp_Std_Versammlungsinfo` | HTML-Template fuer MA-Einsatzliste | btnMailEins |
| `prp_Std_Einsatzliste_KD` | HTML-Template fuer Kunden/BOS | btn_Autosend_BOS |

### Template-Struktur (typisch)
```html
<!-- prp_Std_Versammlungsinfo -->
<html>
<body>
Sehr geehrte/r [Anrede] [Name],<br><br>
anbei erhalten Sie Ihre Einsatzinformationen fuer:<br>
<b>[Auftrag]</b> am <b>[Datum]</b><br><br>
Treffpunkt: [Treffpunkt]<br>
Dienstbeginn: [Uhrzeit]<br>
...
</body>
</html>
```

---

## 5. BWN-PDFs (Bewachungsnachweise)

### Suchlogik
```vba
Function FindePDF_NachDatumUndStand(datArbeitsdatum, strStandnummer)
    ' Sucht PDF-Dateien nach:
    ' - Datum (im Dateinamen)
    ' - Standnummer (im Dateinamen oder Ordner)
End Function
```

### Typische Dateinamen
```
BWN_2026-01-08_Stand123.pdf
Bewachungsnachweis_[Datum]_[Stand].pdf
```

---

## 6. Feste E-Mail-Adressen (BOS)

| Empfaenger | E-Mail |
|-----------|--------|
| Marcus Wuest | marcus.wuest@bos-franken.de |
| SB Dispo | sb-dispo@bos-franken.de |
| Frank Fischer | frank.fischer@bos-franken.de |

### Verwendung
Nur fuer Veranstalter_ID: 10720, 20770, 20771 (BOS-Franken)

---

## 7. HTML-Frontend Pfade

### Formular-Pfad
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\
```

### API-Server
```
http://localhost:5000/api/...
```

### Bridge-Endpoints
```javascript
Bridge.execute('sendEinsatzliste', { va_id, typ })
Bridge.execute('exportAuftragExcel', { va_id })  // NEU ERFORDERLICH
Bridge.execute('sendBWN', { va_id, vadatum, vadatum_id })
Bridge.execute('copyAuftrag', { id, inkl_ma_zuordnungen })
Bridge.execute('copyToNextDay', { va_id, datum_id })  // NEU ERFORDERLICH
```

---

## 8. Erforderliche API-Endpoints

### Fuer volle Paritaet muessen folgende Endpoints existieren:

| Endpoint | Beschreibung | Rueckgabe |
|----------|-------------|-----------|
| `POST /api/einsatzliste/send` | E-Mail mit PDF versenden | { success, message } |
| `POST /api/auftrag/{id}/excel` | Excel-Export erstellen | { success, download_url } |
| `POST /api/bwn/send` | BWN per E-Mail | { success, sent_count } |
| `POST /api/auftrag/{id}/copy-day` | Folgetag kopieren | { success, next_datum_id } |

### Erforderliche Template-Konfiguration im Backend

```python
# api_server.py - Template-Konfiguration
TEMPLATES = {
    'einsatzliste_ma': 'templates/einsatzliste_mitarbeiter.html',
    'einsatzliste_kd': 'templates/einsatzliste_kunde.html',
    'excel_auftrag': 'templates/auftrag_export.xlsm'
}

REPORT_PATH = '\\\\vConSYS01-NBG\\Consys\\CONSEC\\CONSEC PLANUNG AKTUELL\\Allgemein\\'
```

---

## 9. Synchronisations-Checkliste

| Template | Access-Pfad | HTML-Equivalent | Status |
|----------|------------|-----------------|--------|
| rpt_Auftrag_Zusage | Report in DB | API muss generieren | PRUFEN |
| prp_XL_DocVorlage | Property-Pfad | API muss nutzen | PRUFEN |
| prp_Std_Versammlungsinfo | Property-Text | API muss verwenden | PRUFEN |
| prp_Std_Einsatzliste_KD | Property-Text | API muss verwenden | PRUFEN |

---

*Erstellt von Claude Code*
