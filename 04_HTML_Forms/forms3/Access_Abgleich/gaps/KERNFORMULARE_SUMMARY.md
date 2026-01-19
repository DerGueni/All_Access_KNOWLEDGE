# Gap-Analyse: Kernformulare - Zusammenfassung

**Datum:** 2026-01-12
**Analysierte Formulare:** 4 (Auftragstamm, Mitarbeiterstamm, Kundenstamm, Objektstamm)

---

## GESAMTBEWERTUNG

| Formular | Controls Access | Controls HTML | Completion | Kritische Gaps | Aufwand |
|----------|----------------|---------------|------------|----------------|---------|
| **frm_va_Auftragstamm** | 136 | ~110 | **68%** | 8 | 70-104h |
| **frm_MA_Mitarbeiterstamm** | 290 | ~180 | **60%** | 12 | 80-120h |
| **frm_KD_Kundenstamm** | 187 | ~160 | **70%** | 6 | 20-30h |
| **frm_OB_Objekt** | 49 | ~45 | **70%** | 3 | 3-4h |
| **Durchschnitt** | **166** | **~124** | **67%** | **7.25** | **~50h** |

---

## KRITISCHE GAPS (BLOCKER)

### 1. frm_va_Auftragstamm 🔴
- ❌ **Unterformulare: 0%** (0/10 implementiert) - **40-60h**
  - Einsatzliste (`sub_MA_VA_Zuordnung`) fehlt komplett
  - Schichten nicht sichtbar
  - Rechnungsdaten nicht abrufbar
- ❌ **ComboBoxen: 31%** (4/13) - 9 Filter-Dropdowns fehlen - **6-10h**
- ❌ **CheckBox IstVerfuegbar** fehlt - **1h**

### 2. frm_MA_Mitarbeiterstamm 🔴
- ❌ **ListBoxen: 14%** (1/7) - **lst_Zuo** mit DblClick fehlt (KRITISCH!) - **8-12h**
- ❌ **ComboBoxen: 41%** (7/17) - Monat/Jahr-Filter fehlen - **6-8h**
- ❌ **Subforms: 54%** (7/13) - 6 Subforms fehlen - **12-16h**
- ❌ **Jahreswechsel-Button** (btnUpdJahr) - **4-6h**

### 3. frm_KD_Kundenstamm 🔴
- ❌ **Sidebar fehlt komplett** - **2h**
- ❌ **4 Tabs versteckt** (hidden-Attribut) - **1h**
- ❌ **7 Unterformulare nur Stubs** (30%) - **8-12h**
- ❌ **10+ API-Endpoints fehlen** - **6-10h**

### 4. frm_OB_Objekt 🔴
- ❌ **Control-ID Mismatch** (Logic.js vs HTML) - **BLOCKER!** - **1h**
- ❌ **Attachments-Body-ID falsch** - **30min**
- ❌ **Positionen-API fehlt** (CRUD) - **2-3h**

---

## SOFORT-MASSNAHMEN (Diese Woche)

### Auftragstamm (20h)
1. ✅ Einsatzliste `sub_MA_VA_Zuordnung` als iframe (10h)
2. ✅ Schichten `sub_VA_Start` sichtbar (8h)
3. ✅ Filter-ComboBoxen (6h)
4. ✅ CheckBox IstVerfuegbar (1h)

### Mitarbeiterstamm (18h)
5. ✅ ListBox `lst_Zuo` mit DblClick (8h)
6. ✅ ComboBoxen Monat/Jahr-Filter (6h)
7. ✅ AU-Felder + Import-Button (4h)

### Kundenstamm (5h)
8. ✅ Sidebar hinzufügen (2h)
9. ✅ Tab-Sichtbarkeit korrigieren (1h)
10. ✅ Auftrags-API implementieren (2h)

### Objektstamm (3h)
11. ✅ Control-IDs angleichen (1h)
12. ✅ Attachments-Body-ID fix (30min)
13. ✅ Positionen-API (2h)

**Gesamt: 46h für kritische Gaps** → Completion steigt von 67% auf ~85%

---

## STÄRKEN DER HTML-IMPLEMENTIERUNG

### ✅ Was sehr gut läuft (90-100%)

#### Alle 4 Formulare:
- **CRUD-Basis:** Neu/Speichern/Löschen funktioniert
- **Navigation:** Erster/Letzter/Vor/Zurück vollständig
- **REST-API:** Stabile Datenschicht mit 8-12 Endpoints pro Formular
- **TextBoxen:** 77-100% Abdeckung (fast alle Felder vorhanden)
- **WebView2-Integration:** Voll funktionsfähig

#### Auftragstamm:
- 78% aller Buttons (35/45)
- Stammdaten-Felder 100%
- Veranstalter-Regeln funktionieren
- Bedingte Formatierung (Überbuchung/Unterbuchung)

#### Mitarbeiterstamm:
- Excel-Export alle 6 Buttons
- DblClick Events (Einsätze → Auftrag)
- Bedingte Formatierung (inaktive MAs rot)
- Quick Info Tab komplett implementiert

#### Kundenstamm:
- Alle 70 Stammdaten-Felder
- 10 Tabs strukturell vorhanden
- Kundenliste mit Suche/Filter

#### Objektstamm:
- Geocoding-Integration (OSM)
- Tastatur-Shortcuts (Strg+S, Esc)
- Modernes Layout mit 4 Tabs

---

## SCHWÄCHEN DER HTML-IMPLEMENTIERUNG

### ❌ Was fehlt oder schlecht läuft

#### Subformulare (ALLE Formulare!)
- **Auftragstamm:** 0% (0/10) - Kritischste Lücke!
- **Mitarbeiterstamm:** 54% (7/13)
- **Kundenstamm:** 30% (2/7)
- **Objektstamm:** 100% (1/1 implementiert als Stub)

**Problem:** Master-Detail-Beziehungen nicht konsistent umgesetzt

#### Filter/Dropdowns
- **Auftragstamm:** 31% ComboBoxen (9 fehlen)
- **Mitarbeiterstamm:** 41% ComboBoxen (10 fehlen), 14% ListBoxen (6 fehlen)
- **Kundenstamm:** 100% (alle da)
- **Objektstamm:** 100% (alle da)

**Problem:** Zeitfilter (Monat/Jahr), Status-Filter fehlen

#### API-Endpoints
- **Auftragstamm:** 4 Endpoints fehlen (Anhänge, Rechnung, Positionen)
- **Mitarbeiterstamm:** 6 Endpoints fehlen (AU-Import, Jahreswechsel, Subrechnungen)
- **Kundenstamm:** 10+ Endpoints fehlen (Ansprechpartner, Preise, Statistik)
- **Objektstamm:** 3 Endpoints fehlen (Positionen-CRUD, Geo-API)

**Problem:** Backend-Anbindung unvollständig

#### Control-ID Konsistenz
- **Objektstamm:** Logic.js verwendet andere IDs als HTML (BLOCKER!)

**Problem:** Externe Logic-Dateien können nicht auf Controls zugreifen

---

## ROADMAP

### Phase 1: Kritische Gaps (4-6 Wochen, 46h)
**Ziel:** Completion 67% → 85%
- Einsatzliste Auftragstamm
- Filter/ComboBoxen
- ListBox lst_Zuo Mitarbeiterstamm
- Sidebar Kundenstamm
- Control-IDs Objektstamm

### Phase 2: Wichtige Gaps (6-8 Wochen, 60h)
**Ziel:** Completion 85% → 92%
- Restliche Subforms (6 Stück)
- API-Endpoints (20+ Stück)
- Jahreswechsel Mitarbeiterstamm
- Statistik Kundenstamm

### Phase 3: Nice-to-have (8-10 Wochen, 40h)
**Ziel:** Completion 92% → 95%
- Tooltips
- Keyboard-Shortcuts
- UI-Buttons (Ribbon, DaBa)
- Optische Anpassungen

**Gesamt: 146h Entwicklung für 95% Feature-Parity**

---

## METRIKEN

### Control-Abdeckung (Durchschnitt)
| Typ | Access | HTML | Status |
|-----|--------|------|--------|
| Buttons | 28 | 23 | 82% ✅ |
| TextBoxen | 44 | 38 | 86% ✅ |
| ComboBoxen | 13 | 7 | 54% ⚠️ |
| Unterformulare | 8 | 2.5 | **31%** ❌ |
| CheckBoxen | 5 | 4 | 80% ✅ |
| ListBoxen | 2 | 0.5 | 25% ❌ |

### Event-Abdeckung
| Event | Access | HTML | Status |
|-------|--------|------|--------|
| OnClick | 45 | 35 | 78% ✅ |
| AfterUpdate | 18 | 8 | 44% ⚠️ |
| OnLoad | 4 | 4 | 100% ✅ |
| DblClick | 8 | 3 | 38% ⚠️ |
| BeforeUpdate | 5 | 0 | 0% ❌ |

### API-Endpoints
| Formular | Vorhanden | Fehlend | Status |
|----------|-----------|---------|--------|
| Auftragstamm | 8 | 4 | 67% ⚠️ |
| Mitarbeiterstamm | 12 | 6 | 67% ⚠️ |
| Kundenstamm | 8 | 10+ | 44% ❌ |
| Objektstamm | 6 | 3 | 67% ⚠️ |

---

## ZUSAMMENFASSUNG

### 👍 Was gut ist:
- **Grundfunktionalität:** 80-90% aller CRUD-Operationen funktionieren
- **Daten-Anzeige:** Stammdaten-Felder fast vollständig (86%)
- **Navigation:** Vollständig implementiert
- **API-Stabilität:** REST-API läuft stabil mit 34 Endpoints

### 👎 Was fehlt:
- **Subformulare:** Nur 31% implementiert (KRITISCH!)
- **Filter/Dropdowns:** 54% ComboBoxen, 25% ListBoxen
- **API-Endpoints:** 44% fehlen für erweiterte Funktionen
- **Events:** 44% AfterUpdate, 38% DblClick, 0% BeforeUpdate

### 🎯 Nächste Schritte:
1. **Sofort:** 4 kritische Formulare fixen (46h)
2. **Diese Woche:** Subforms implementieren (60h)
3. **Diesen Monat:** API-Endpoints nachholen (40h)

**Mit 146h Entwicklung: 67% → 95% Feature-Parity erreicht**

---

*Zusammenfassung erstellt: 2026-01-12*
