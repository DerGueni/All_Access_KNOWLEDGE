# MAPPING - Access zu Web

**Projekt:** frm_MA_Mitarbeiterstamm Web-Migration
**Stand:** 2025-12-23 (ETAPPE 0)

---

## 1. Formular-Hierarchie

### Hauptformular
- **Access:** `frm_MA_Mitarbeiterstamm`
- **Web:** `web/src/components/MitarbeiterstammForm.jsx`
- **RecordSource:** (siehe `exports/forms/frm_MA_Mitarbeiterstamm/recordsource.json`)

### Subforms (12 Stueck)
| Access-Subform | Web-Komponente | LinkMasterFields | LinkChildFields |
|----------------|----------------|------------------|-----------------|
| frm_Menuefuehrung | MenuefuehrungSubform.jsx | - | - |
| sub_MA_ErsatzEmail | ErsatzEmailSubform.jsx | ID | MA_ID |
| sub_MA_Einsatz_Zuo | EinsatzZuoSubform.jsx | ID | MA_ID |
| sub_tbl_MA_Zeitkonto_Aktmon2 | ZeitkontoAktmon2Subform.jsx | - | - |
| sub_tbl_MA_Zeitkonto_Aktmon1 | ZeitkontoAktmon1Subform.jsx | - | - |
| frm_Stundenuebersicht2 | StundenuebersichtSubform.jsx | ID | MA_ID |
| sub_MA_tbl_MA_NVerfuegZeiten | NVerfuegZeitenSubform.jsx | - | - |
| sub_MA_Dienstkleidung | DienstkleidungSubform.jsx | ID | MA_ID |
| sub_tbltmp_MA_Ausgef_Vorlagen | AusgefVorlagenSubform.jsx | - | - |
| sub_tbl_MA_StundenFolgemonat | StundenFolgemonatSubform.jsx | ID;pgJahrStdVorMon | MA_ID;AktJahr |
| sub_Browser | BrowserSubform.jsx (Maps) | - | - |
| sub_Auftrag_Rechnung_Gueni | AuftragRechnungSubform.jsx | ID | MA_ID |
| zfrm_ZUO_Stunden_Sub_lb | ZuoStundenSubform.jsx | - | - |

---

## 2. Tab-Control (13 Pages)

| Access-Page | Caption | Web-Component | API-Endpoint |
|-------------|---------|---------------|--------------|
| pgAdresse | Stammdaten | StammdatenTab.jsx | - |
| pgMonat | Zeitkonto | ZeitkontoTab.jsx | GET /api/mitarbeiter/:id/zeitkonto |
| pgJahr | Jahresuebersicht | JahresuebersichtTab.jsx | GET /api/mitarbeiter/:id/jahresuebersicht |
| pgAuftrUeb | Einsatzuebersicht | EinsatzuebersichtTab.jsx | GET /api/mitarbeiter/:id/einsatzuebersicht |
| pgStundenuebersicht | Stundenuebersicht | StundenuebersichtTab.jsx | GET /api/mitarbeiter/:id/stundenuebersicht |
| pgPlan | Dienstplan | DienstplanTab.jsx | GET /api/mitarbeiter/:id/dienstplan |
| pgnVerfueg | Nicht Verfuegbar | NichtVerfuegbarTab.jsx | GET /api/mitarbeiter/:id/nichtverfuegbar |
| pgDienstKl | Bestand Dienstkleidung | DienstkleidungTab.jsx | GET /api/mitarbeiter/:id/dienstkleidung |
| pgVordr | Vordrucke | VordruckeTab.jsx | - |
| pgBrief | Briefkopf | BriefkopfTab.jsx | - |
| pgStdUeberlaufstd | Ueberhang Stunden | UeberhangStundenTab.jsx | GET /api/mitarbeiter/:id/ueberhangstunden |
| pgMaps | Karte | KarteTab.jsx | - |
| pgSubRech | Sub Rechnungen | SubRechnungenTab.jsx | GET /api/mitarbeiter/:id/subrechnungen |

---

## 3. Layout-Konvertierung

### Twips zu Pixel
- **Faktor:** 1 Twip = 1/1440 Zoll = 0.0006944 Zoll
- **96 DPI:** 1 Twip = 0.0666667 px (wird auf 0.067px gerundet)
- **Implementierung:** `web/src/lib/twipsConverter.js`

```javascript
export function twipsToPx(twips) {
  return Math.round(twips * 0.0666667);
}
```

### Access-Farben zu CSS
- **Access:** Long Integer (BGR-Format)
- **Konvertierung:**
  ```javascript
  function accessColorToRgb(accessColor) {
    const b = (accessColor >> 16) & 0xFF;
    const g = (accessColor >> 8) & 0xFF;
    const r = accessColor & 0xFF;
    return `rgb(${r}, ${g}, ${b})`;
  }
  ```

### Fonts
- **Access FontName → CSS font-family**
- **Access FontSize (pt) → CSS font-size (pt)**
- **Access FontBold/FontItalic → CSS font-weight/font-style**

---

## 4. API-Endpunkte (geplant)

### CRUD - Hauptformular
- `GET /api/mitarbeiter` - Liste aller Mitarbeiter
- `GET /api/mitarbeiter/:id` - Ein Mitarbeiter (inkl. Foto, Unterschrift)
- `POST /api/mitarbeiter` - Neuer Mitarbeiter
- `PUT /api/mitarbeiter/:id` - Update Mitarbeiter
- `DELETE /api/mitarbeiter/:id` - Loeschen

### Subform-Daten
- `GET /api/mitarbeiter/:id/ersatzemail` - Ersatz-Email-Adressen
- `POST /api/mitarbeiter/:id/ersatzemail` - Neue Email
- `DELETE /api/ersatzemail/:id` - Email loeschen
- *(analog fuer andere Subforms)*

### Actions (aus VBA/Makros)
- `POST /api/mitarbeiter/:id/actions/mapo-oeffnen` - Mapo oeffnen
- `POST /api/mitarbeiter/:id/actions/neuer-mitarbeiter` - Neuer Mitarbeiter
- *(weitere aus VBA-Analyse)*

### Queries
- `GET /api/queries/qryBildname?ma_id=707` - Parametrisierte Query
- *(weitere aus `exports/queries/`)*

---

## 5. VBA zu JavaScript (geplant in ETAPPE 3)

### Event-Mapping
| Access-Event | Web-Event | Handler |
|--------------|-----------|---------|
| Button_Click | onClick | eventHandlers.js |
| Form_Load | useEffect (mount) | - |
| Form_Current | useEffect (record change) | - |
| Control_AfterUpdate | onChange + onBlur | - |
| Control_DblClick | onDoubleClick | - |

### VBA-Funktionen zu API
| VBA-Funktion | API-Endpunkt | Beschreibung |
|--------------|--------------|--------------|
| DLookup() | GET /api/lookup | Datenbank-Lookup |
| DoCmd.OpenForm | Router (React) | Form oeffnen |
| CurrentDb.Execute | POST /api/actions/execute | SQL ausfuehren |
| Me.Recordset.AddNew | POST /api/mitarbeiter | Neuer Datensatz |

---

## 6. Dateistruktur-Mapping

### Frontend
```
web/src/components/
├── MitarbeiterstammForm.jsx      (Hauptformular)
├── TabControl.jsx                 (13 Tab-Pages)
├── SubformContainer.jsx           (Subform-Wrapper)
├── subforms/
│   ├── MenuefuehrungSubform.jsx
│   ├── ErsatzEmailSubform.jsx
│   └── ... (12 Subforms)
└── tabs/
    ├── StammdatenTab.jsx
    ├── ZeitkontoTab.jsx
    └── ... (13 Tabs)
```

### Backend
```
server/src/
├── routes/
│   ├── mitarbeiter.js
│   ├── subforms.js
│   ├── actions.js
│   └── queries.js
├── controllers/
│   ├── mitarbeiterController.js
│   ├── subformsController.js
│   └── actionsController.js
└── models/
    ├── Mitarbeiter.js
    └── SubformModels.js
```

---

## 7. Aenderungshistorie

| Datum | ETAPPE | Aenderung | Autor |
|-------|--------|-----------|-------|
| 2025-12-23 | 0 | Initiales Mapping erstellt | Orchestrator |

---

**WICHTIG:** Diese Datei wird kontinuierlich aktualisiert. Alle Instanzen muessen Aenderungen hier dokumentieren!
