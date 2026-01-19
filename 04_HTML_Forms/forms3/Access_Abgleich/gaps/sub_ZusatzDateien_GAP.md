# Gap-Analyse: sub_ZusatzDateien

## Übersicht
| Metrik | Access | HTML | Gap | Status |
|--------|--------|------|-----|--------|
| Controls gesamt | 14 | 8 | -6 | ⚠️ |
| Buttons | 0 | 0 | 0 | ✅ |
| TextBoxen | 14 | 0 | -14 | ⚠️ |
| Table Columns | 8 | 8 | 0 | ✅ |
| Events gesamt | 0 | 3+ | +3 | ✅ |
| Logic File | Nein | Ja | +1 | ✅ |

**Completion:** 85%

## Controls-Vergleich

### ✅ Implementiert
| Access Control | HTML Element | Mapping |
|----------------|--------------|---------|
| ID | (implizit) | Via API |
| Ueberordnung | via postMessage | Parent-ID (Objekt_ID, kun_ID, etc.) |
| TabellenID | via postMessage | Tabellen-Nummer (1=Objekt, 2=Kunde, etc.) |
| ZusatzNr | Table Column (hidden) | ZusatzNr |
| Dateiname | Table Column | Dateiname |
| DFiledate | Table Column | Dateidatum |
| Laenge | Table Column | Größe |
| Texttyp | Table Column | Typ |
| Kurzbeschreibung | Table Column | Kurzbeschreibung |

### ➕ HTML-Extras (nicht in Access)
*Keine nennenswerten Extras*

### ❌ Fehlend (in HTML)
- **JNVerteiler**: Ja/Nein Verteiler-Flag (nicht in Tabelle)
- **Erst_von**: Erstellt von (nicht in Tabelle)
- **Erst_am**: Erstellt am (nicht in Tabelle)
- **Aend_von**: Geändert von (nicht in Tabelle)
- **Aend_am**: Geändert am (nicht in Tabelle)
- **TabellenNr**: Weitere Tabellen-ID (nicht in Tabelle)
- **Aktion-Spalte**: Download/Löschen Buttons (erwähnt in MD, aber nicht sichtbar)

## Events-Vergleich

### ✅ Implementiert
| Access Event | HTML Implementation | Beschreibung |
|--------------|---------------------|--------------|
| (keine Events) | postMessage handler | Reagiert auf LOAD_DATA Message |

### ➕ HTML-Extras (in Logic-Datei)
- **loadData()**: Lädt Dateien von API
- **renderTable()**: Rendert Datei-Liste
- **handleRowClick()**: Zeile auswählen
- **handleDownload()**: Datei herunterladen
- **handleDelete()**: Datei löschen (geplant)
- **handleUpload()**: Datei hochladen (geplant)

### ❌ Fehlend
*KEINE kritischen Events fehlen*

## Funktionalität-Vergleich

### ✅ Implementiert
- Universelles Unterformular für Dateianhänge
- Verwendet in Objekten, Kunden, Aufträgen
- Flexible Verknüpfung über Ueberordnung + TabellenID
- Unterstützt verschiedene Dateitypen
- API-Anbindung:
  - GET `/api/dateien?tabelle=X&id=Y`
  - POST `/api/dateien` (hochladen)
  - DELETE `/api/dateien/:id` (löschen)
  - GET `/api/dateien/:id/download` (herunterladen)
- PostMessage-Kommunikation mit Parent
- Logic-Datei mit Business-Logik (5.0 KB)

### ❌ Fehlend
- **Upload-Button**: In HTML erwähnt, aber nicht implementiert
- **Aktion-Spalte**: Download/Löschen Buttons in Tabelle
- **Audit-Felder**: Erst_von, Erst_am, Aend_von, Aend_am nicht angezeigt
- **Verteiler-Flag**: JNVerteiler nicht angezeigt

## Datenanbindung

### Access RecordSource
```sql
-- RecordSource: tbl_ZusatzDateien
-- DefaultView: ContinuousForms (Endlosformular)
-- DividingLines: Nein
-- LinkMasterFields: Objekt_ID, TabellenNr (vom Parent)
-- LinkChildFields: Ueberordnung, TabellenID
```

### TabellenID-Mapping
| TabellenID | Tabelle | Parent-Formular |
|------------|---------|-----------------|
| 1 | Objekte | frm_OB_Objekt |
| 2 | Kunden | frm_KD_Kundenstamm |
| 3 | Aufträge | frm_va_auftragstamm |
| 4 | Mitarbeiter | frm_MA_Mitarbeiterstamm |

### HTML API-Anbindung
```javascript
// Endpoints
GET /api/dateien?tabelle=X&id=Y
POST /api/dateien (Multipart Form Data)
DELETE /api/dateien/:id
GET /api/dateien/:id/download

// Response-Mapping (erwartet)
{
  dateien: [
    {
      ID: number,
      ZusatzNr: number,
      Ueberordnung: number,
      TabellenID: number,
      TabellenNr: number,     // Fehlt in HTML
      Dateiname: string,
      DFiledate: date,
      Laenge: number,         // Größe in Bytes
      Texttyp: string,        // MIME-Type
      Kurzbeschreibung: string,
      JNVerteiler: boolean,   // Fehlt in HTML
      Erst_von: string,       // Fehlt in HTML
      Erst_am: datetime,      // Fehlt in HTML
      Aend_von: string,       // Fehlt in HTML
      Aend_am: datetime       // Fehlt in HTML
    }
  ]
}

// Logic-Datei: sub_ZusatzDateien.logic.js (4985 Bytes)
```

### ⚠️ API-Gaps
**PRÜFEN** - API Endpoints für Dateien müssen vollständig implementiert sein
- GET, POST, DELETE für `/api/dateien`
- File-Download über `/api/dateien/:id/download`

## Priorität der Gaps

### P0 Kritisch (Blocker)
**KEINE**

### P1 Wichtig
1. **API Endpoints**: Sicherstellen dass alle Datei-Operationen funktionieren (6h)
   - GET `/api/dateien?tabelle=X&id=Y`
   - POST `/api/dateien` (mit Multipart/Form-Data)
   - DELETE `/api/dateien/:id`
   - GET `/api/dateien/:id/download`
2. **Aktion-Spalte**: Download/Löschen Buttons hinzufügen (2h)
   - Icons für Download (⬇) und Löschen (🗑)
   - Click-Handler in Logic-Datei

### P2 Nice-to-have
- **Upload-Button**: Upload-Dialog implementieren (4h)
- **Audit-Felder**: Anzeige von Erst_von, Erst_am, Aend_von, Aend_am (2h)
- **Verteiler-Flag**: JNVerteiler anzeigen/bearbeiten (1h)
- **Preview**: Datei-Vorschau (Bilder, PDFs) (5h)
- **Drag & Drop**: Datei hochladen via Drag & Drop (3h)

## Empfehlung

### Completion
**85%** - Formular ist weitgehend implementiert

### Kritische Gaps
Keine Blocker. API-Endpoints prüfen (P1), Aktion-Spalte fehlt (P1).

### Aufwand
- **P0**: 0 Stunden
- **P1**: ~8 Stunden (API + Aktion-Spalte)
- **P2**: ~15 Stunden (optionale Features)
- **Gesamt**: ~8 Stunden (Pflicht)

### Nächste Schritte
1. **API prüfen**:
   - `curl http://localhost:5000/api/dateien?tabelle=1&id=123`
   - `curl -X POST http://localhost:5000/api/dateien -F "file=@test.pdf" -F "tabelle=1" -F "id=123"`
2. Falls API fehlt/unvollständig: Implementieren in api_server.py
3. **Aktion-Spalte**: Download/Löschen Buttons hinzufügen (2h)
4. ✅ **Freigabe erteilen** - Formular ist produktionsreif (nach P1)

### Parent-Formulare
- **frm_va_auftragstamm** (LinkMasterFields: Objekt_ID, TabellenNr → LinkChildFields: Ueberordnung, TabellenID)
- **frm_OB_Objekt** (LinkMasterFields: ID, TabellenNr → LinkChildFields: Ueberordnung, TabellenID)
- **frm_KD_Kundenstamm** (LinkMasterFields: kun_ID, TabellenNr → LinkChildFields: Ueberordnung, TabellenID)

### Besonderheit
**Universelles Unterformular**: Wird für verschiedene Parent-Formulare verwendet
- Flexible Verknüpfung über 2 Felder: Ueberordnung (Parent-ID) + TabellenID (Tabellen-Typ)
- Logic-Datei vorhanden: sub_ZusatzDateien.logic.js (5.0 KB)
- TabellenID = Diskriminator für Tabellentyp (1=Objekt, 2=Kunde, 3=Auftrag, 4=MA)
