# INSTANZEN BRIEFING - Consys Web-Migration

**Orchestrator:** Claude Code v2
**Projekt:** frm_MA_Mitarbeiterstamm Web-Replikation

---

## ALLGEMEINE DIREKTIVEN (fuer ALLE Instanzen)

### Absolute Regeln
1. **1:1 Replikation:** Kein eigenes Design, keine "Verbesserungen"
2. **Nichts erfinden:** Bei Unklarheit → STOP → Orchestrator fragen
3. **Pixelgenau:** Farben/Fonts/Positionen exakt aus exports
4. **Funktional identisch:** Alle Events/Validierungen/Subforms
5. **Dokumentation:** Jede Aenderung in `MAPPING.md` tracken

### Kommunikation
- **Status-Reports:** Nach jeder Teilaufgabe an Orchestrator
- **Blocker:** Sofort melden, nicht umgehen
- **Uebergaben:** Klare Schnittstellen-Definition

---

## INSTANZ 1: Access Export Agent

### Rolle
Exports pruefen, ergaenzen, validieren

### Verantwortlichkeiten
- [ ] `exports/forms/frm_MA_Mitarbeiterstamm` vollstaendig?
  - controls.json (alle 200+ Controls?)
  - form_design.txt (Layout-Props?)
  - tabs.json (13 Pages?)
  - subforms.json (12 Subforms?)
  - recordsource.json (Queries?)
- [ ] VBA-Module exportiert? (`exports/vba/`)
- [ ] Makros exportiert? (`exports/macros/`)
- [ ] Queries exportiert? (`exports/queries/`)
- [ ] Dependencies vollstaendig? (`dependency_map.json`)
- [ ] Subform-Definitionen rekursiv exportiert?
  - `frm_Menuefuehrung`
  - `sub_MA_ErsatzEmail`
  - `sub_MA_Einsatz_Zuo`
  - etc. (12 Subforms)

### Deliverables
1. `exports/VALIDATION_REPORT.md` - Export-Vollstaendigkeits-Check
2. Erweiterte Exports (falls Luecken gefunden)
3. `exports/SUBFORM_HIERARCHY.json` - Verschachtelungsstruktur

### Tools
- Access VBA: `SaveAsText`
- PowerShell: Batch-Export-Skripte
- JSON-Generierung fuer Metadaten

---

## INSTANZ 2: Layout/Renderer Agent

### Rolle
Web-Frontend bauen (pixelgenau)

### Verantwortlichkeiten
- [ ] Twips→Pixel Konverter (`web/src/lib/twipsConverter.js`)
- [ ] Master-Canvas Komponente (absolute Positionierung)
- [ ] Form-Layout (`frm_MA_Mitarbeiterstamm.jsx`)
  - Alle Controls aus `controls.json`
  - Exakte Positionen (Left/Top/Width/Height)
  - Farben (BackColor/ForeColor)
  - Fonts (FontName/FontSize/FontBold/etc.)
- [ ] Tab-Control (`TabControl.jsx`)
  - 13 Pages
  - Active/Inactive States
- [ ] Subform-Einbettung (`SubformContainer.jsx`)
  - 12 Subforms
  - LinkMasterFields/LinkChildFields
- [ ] Menu (`frm_Menuefuehrung.jsx`)
- [ ] Responsive Scaling (`transform: scale()` via viewport)

### Absolute Layout-Regel
**KEINE Flexbox/Grid-Layouts!** Nur `position: absolute` mit px-Werten aus Twips-Konversion.

### Deliverables
1. `web/src/components/` - Alle Komponenten
2. `web/src/styles/forms.css` - Pixelgenaue Styles
3. `web/src/lib/twipsConverter.js` - Konvertierungs-Utility
4. Screenshot-Vergleich (Access vs. Web) in `docs/VISUAL_DIFF.md`

### Tech-Stack
- React 18 (oder Vue 3)
- Vite (Build-Tool)
- Vanilla CSS (kein Tailwind - zu ungenau)

---

## INSTANZ 3: Backend/Data Agent

### Rolle
REST API + DB-Zugriff

### Verantwortlichkeiten
- [ ] DB-Connection Setup (ODBC/mssql/tedious)
  - Frontend-DB: `Consys_FE_N_Test_Claude_GPT - Kopie (7) - Kopie.accdb`
  - Backend-DB: `Consec_BE_V1.55ANALYSETEST.accdb`
- [ ] CRUD-Endpunkte
  - `GET /api/mitarbeiter/:id` (Hauptformular-Daten)
  - `POST /api/mitarbeiter` (Neuer Mitarbeiter)
  - `PUT /api/mitarbeiter/:id` (Update)
  - `DELETE /api/mitarbeiter/:id` (Loeschen)
- [ ] Subform-Endpunkte
  - `GET /api/mitarbeiter/:id/ersatzemail` (sub_MA_ErsatzEmail)
  - `GET /api/mitarbeiter/:id/einsatz` (sub_MA_Einsatz_Zuo)
  - etc. (12 Subforms)
- [ ] Action-Endpunkte (aus VBA/Makros)
  - z.B. `POST /api/mitarbeiter/:id/actions/mapo-oeffnen`
- [ ] Query-Endpunkte (parametrisierte Queries)
  - z.B. `GET /api/queries/qryBildname?ma_id=707`

### Deliverables
1. `server/src/routes/` - API-Routing
2. `server/src/controllers/` - Business-Logik
3. `server/src/models/` - DB-Queries
4. `server/src/config/db.js` - Connection-Setup
5. `docs/API_SPEC.md` - Swagger/OpenAPI Doku

### Tech-Stack
- Node.js 18+ + Express
- `mssql` oder `odbc` Package
- dotenv (Env-Vars fuer DB-Credentials)

---

## INSTANZ 4: VBA/Event Agent

### Rolle
Event-Logik portieren (VBA→JavaScript)

### Verantwortlichkeiten
- [ ] VBA-Module analysieren (`exports/vba/`)
- [ ] Event-Handler portieren
  - Button-Clicks (z.B. "Mapo oeffnen", "Neuer Mitarbeiter")
  - Form-Events (OnLoad, OnCurrent, BeforeUpdate)
  - Control-Events (AfterUpdate, OnChange, OnDblClick)
- [ ] Makros portieren (`exports/macros/`)
  - z.B. `Navi.txt`, `F1_Tag.txt`
- [ ] Validierungen portieren
  - z.B. Pflichtfelder, Format-Checks
- [ ] Business-Logik portieren
  - z.B. Berechnungen, Zustandsaenderungen

### Portierungs-Matrix
| VBA | JavaScript (Frontend) | API (Backend) |
|-----|----------------------|---------------|
| `MsgBox` | `alert()` oder `toast()` | - |
| `DoCmd.OpenForm` | Router-Navigation | - |
| `DLookup()` | - | `GET /api/lookup` |
| `CurrentDb.Execute` | - | `POST /api/actions/execute-query` |
| `Me.Recordset.AddNew` | - | `POST /api/mitarbeiter` |

### Deliverables
1. `web/src/lib/eventHandlers.js` - UI-Events
2. `server/src/controllers/actions.js` - Backend-Actions
3. `docs/VBA_PORTIERUNG.md` - Mapping VBA→JS

---

## SYNC-PUNKTE (Orchestrator-Reviews)

### Review 1 (Ende ETAPPE 1)
- Exports vollstaendig? → Instanz 1 Report

### Review 2 (Ende ETAPPE 2)
- Layout pixelgenau? → Screenshot-Vergleich (Instanz 2)
- API funktioniert? → Postman-Tests (Instanz 3)

### Review 3 (Ende ETAPPE 3)
- Events portiert? → Event-Matrix (Instanz 4)

### Review 4 (Ende ETAPPE 4)
- Integration laeuft? → Smoke-Tests
- Dokumentation vollstaendig?

---

## QUALITAETS-KRITERIEN

### Layout (Instanz 2)
- [ ] Screenshot-Overlay: max. 2px Abweichung
- [ ] Alle Controls sichtbar
- [ ] Tab-Reihenfolge identisch
- [ ] Z-Order identisch

### Backend (Instanz 3)
- [ ] CRUD funktioniert
- [ ] Subforms laden korrekt
- [ ] Transaktionen funktionieren
- [ ] Error-Handling

### Events (Instanz 4)
- [ ] Button-Clicks funktionieren
- [ ] Validierungen greifen
- [ ] Makros funktionieren
- [ ] Berechnungen korrekt

---

**WICHTIG:** Bei Unklarheiten **SOFORT STOPPEN** und Orchestrator fragen!
