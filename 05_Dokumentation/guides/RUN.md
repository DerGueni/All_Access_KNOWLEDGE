# RUN - Consys Mitarbeiterstamm Web-Migration

## ORCHESTRATOR: Multi-Instanz Projekt

**Ziel:** 1:1 Replikation von `frm_MA_Mitarbeiterstamm` + `frm_Menuefuehrung` als Web-App

---

## Quick Start

### 1. Backend starten
```bash
cd server
npm install
npm start
# Laeuft auf http://localhost:3000
```

### 2. Frontend starten
```bash
cd web
npm install
npm run dev
# Laeuft auf http://localhost:5173
```

### 3. Access-DBs
- **Frontend:** `\\vConsys01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (7) - Kopie.accdb`
- **Backend:** `S:\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb`

---

## Projekt-Struktur

```
01_ClaudeCode_HTML/
├── exports/              # Access-Exports (forms, queries, vba, macros)
├── web/                  # Frontend (React/Vue + Vite)
│   ├── src/
│   │   ├── components/   # Form-Komponenten
│   │   ├── lib/          # Utils (twips-converter, api-client)
│   │   └── styles/       # CSS (pixelgenaue Nachbildung)
│   └── public/           # Statische Assets
├── server/               # Backend (Node.js + Express)
│   └── src/
│       ├── controllers/  # API-Endpunkte
│       ├── models/       # DB-Zugriff
│       ├── routes/       # Routing
│       └── config/       # DB-Connection (ODBC/SQL)
└── docs/                 # Dokumentation
    ├── MAPPING.md        # Access→Web Mapping
    ├── TESTPLAN.md       # Test-Checkliste
    └── INSTANZEN_BRIEF.md # Sub-Instanz Briefings
```

---

## ETAPPEN-Status

- [x] **ETAPPE 0:** Repo scaffold + RUN.md + Instanzen briefen
- [ ] **ETAPPE 1:** Exports review (Vollstaendigkeit pruefen)
- [ ] **ETAPPE 2:** Instanz 2 (Layout/Renderer) + Instanz 3 (Backend/Data) parallel
- [ ] **ETAPPE 3:** Instanz 4 (VBA/Event) portiert Logik
- [ ] **ETAPPE 4:** Integration + Smoke Tests + Docs

---

## Absolute Regeln

1. **Pixelgenau identisch:** Farben/Fonts/Positionen/Groessen/Z-Order
2. **Funktion identisch:** Alle Buttons/Events/Validierungen/Subforms
3. **Responsive:** Nur via `transform: scale()` - KEINE Neuanordnung
4. **NICHTS erfinden:** Unklar → STOP → Export erweitern

---

## Instanzen

| Instanz | Rolle | Verantwortlich fuer |
|---------|-------|---------------------|
| **Orchestrator** | Koordination | Etappen-Freigabe, Merge, Quality Gate |
| **Instanz 1** | Access Export Agent | Exports pruefen/ergaenzen (SaveAsText, VBA, Queries, Dependencies) |
| **Instanz 2** | Layout/Renderer Agent | Web-Frontend (Twips→px, Master-Canvas, Tabs, Subforms, Menu) |
| **Instanz 3** | Backend/Data Agent | REST API (CRUD, Subform-Endpoints, Action-Endpoints, ODBC) |
| **Instanz 4** | VBA/Event Agent | Event-Logik portieren (UI→JS, DB/Batch→API) |

---

## Fallbacks

- **A. Unklarheit:** STOP → Export erweitern (niemals raten)
- **B. Optik drift:** Screenshot-Overlay Debug aktivieren
- **C. Daten inkonsistent:** Backend-Logs pruefen, Transaktion rollback

---

## Kontakt

**Orchestrator:** Claude Code v2
**Projektordner:** `C:\users\guenther.siegert\Documents\01_ClaudeCode_HTML`

---

**Stand:** 2025-12-23
**Version:** 1.0.0
