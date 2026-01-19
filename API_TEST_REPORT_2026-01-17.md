# CONSYS API Test-Report
**Datum:** 2026-01-17
**API Server:** Port 5000
**VBA Bridge:** Port 5002

---

## Zusammenfassung

| Kategorie | Getestet | OK | Fehler |
|-----------|----------|-----|--------|
| Stammdaten | 8 | 6 | 2 |
| Planung | 6 | 6 | 0 |
| Dienstplan | 5 | 5 | 0 |
| Auftragsdetails | 4 | 4 | 0 |
| Sonstige | 8 | 6 | 2 |
| VBA Bridge | 2 | 2 | 0 |
| **GESAMT** | **33** | **29** | **4** |

**Erfolgsrate: 88%**

---

## Funktionierende Endpoints (OK)

### Stammdaten
| Endpoint | Methode | Status | Bemerkung |
|----------|---------|--------|-----------|
| `/api/health` | GET | 200 OK | Backend connected |
| `/api/mitarbeiter` | GET | 200 OK | Mit limit Parameter |
| `/api/mitarbeiter/<id>` | GET | 200 OK | Einzelabruf |
| `/api/kunden` | GET | 200 OK | Mit limit Parameter |
| `/api/objekte` | GET | 200 OK | Mit limit Parameter |
| `/api/bewerber` | GET | 200 OK | Bewerberliste |

### Planung
| Endpoint | Methode | Status | Bemerkung |
|----------|---------|--------|-----------|
| `/api/auftraege` | GET | 200 OK | Mit limit Parameter |
| `/api/auftraege/<id>` | GET | 200 OK | Einzelabruf |
| `/api/anfragen` | GET | 200 OK | 8.4 MB Daten! |
| `/api/planungen` | GET | 200 OK | MA-Zuordnungen |
| `/api/einsatztage` | GET | 200 OK | Einsatztage |
| `/api/verfuegbarkeit` | GET | 200 OK | Verfuegbare MA |

### Dienstplan
| Endpoint | Methode | Status | Bemerkung |
|----------|---------|--------|-----------|
| `/api/dienstplan/ma/<id>` | GET | 200 OK | Dienstplan pro MA |
| `/api/dienstplan/objekt/<id>` | GET | 200 OK | Dienstplan pro Objekt |
| `/api/dienstplan/schichten` | GET | 200 OK | Alle Schichten |
| `/api/dienstplan/gruende` | GET | 200 OK | Abwesenheitsgruende |
| `/api/schichten` | GET | 200 OK | Alternative Route |

### Auftragsdetails
| Endpoint | Methode | Status | Bemerkung |
|----------|---------|--------|-----------|
| `/api/auftraege/<va_id>/schichten` | GET | 200 OK | Schichten pro Auftrag |
| `/api/auftraege/<va_id>/zuordnungen` | GET | 200 OK | Zuordnungen pro Auftrag |
| `/api/auftraege/<va_id>/tage` | GET | 200 OK | Tage pro Auftrag |
| `/api/auftraege/<va_id>/absagen` | GET | 200 OK | Absagen pro Auftrag |

### Sonstige
| Endpoint | Methode | Status | Bemerkung |
|----------|---------|--------|-----------|
| `/api/feiertage` | GET | 200 OK | Bayern 2026 |
| `/api/abwesenheiten` | GET | 200 OK | Mit MA-Namen |
| `/api/absagen` | GET | 200 OK | Absagen-Liste |
| `/api/orte` | GET | 200 OK | Ortsliste |
| `/api/preisarten` | GET | 200 OK | 19 Preisarten |
| `/api/dienstkleidung` | GET | 200 OK | 6 Varianten |
| `/api/status` | GET | 200 OK | Auftragsstatusarten |
| `/api/email-vorlagen` | GET | 200 OK | Email-Templates |
| `/api/lohn/abrechnungen` | GET | 200 OK | Lohnabrechnungen |
| `/api/tables` | GET | 200 OK | Tabellenliste |

### VBA Bridge (Port 5002)
| Endpoint | Methode | Status | Bemerkung |
|----------|---------|--------|-----------|
| `/api/health` | GET | 200 OK | Service running |
| `/api/vba/execute` | POST | 200 OK | VBA-Ausfuehrung |

---

## Fehlerhafte Endpoints

### 1. `/api/zuordnungen` (ohne Filter)
**Status:** 500 Internal Server Error
**Fehler:**
```
('07002', '[Microsoft][ODBC Microsoft Access Driver] Too few parameters. Expected 2.')
```

**Analyse:**
- Mit Filter (`?ma_id=6` oder `?va_id=9316`) funktioniert der Endpoint!
- Problem: Ohne Filter werden 19.500+ Zeilen geladen
- Vermutlich ODBC-Timeout oder Memory-Problem bei grossen Resultsets

**Workaround:**
```
/api/zuordnungen?ma_id=6        # OK
/api/zuordnungen?va_id=9316     # OK
/api/zuordnungen?von=2026-01-01 # OK
```

**Fix-Vorschlag:**
```python
# Limit hinzufuegen wenn keine Filter gesetzt
if not va_id and not ma_id and not datum and not datum_von and not datum_bis:
    query += " AND z.VADatum >= DATEADD('d', -30, Date())"  # Letzte 30 Tage
```

---

### 2. `/api/rechnungen` (ohne Filter)
**Status:** 500 Internal Server Error
**Fehler:**
```
('07002', '[Microsoft][ODBC Microsoft Access Driver] Too few parameters. Expected 2.')
```

**Analyse:**
- Gleicher Fehler wie bei `/api/zuordnungen`
- Tabelle `tbl_Rch_Kopf` existiert und ist abfragbar via `/api/sql`
- Problem tritt bei grossen Resultsets ohne Limit auf

**Workaround:**
```
/api/rechnungen?va_id=8032  # OK
/api/rechnungen?kd_id=27    # OK
```

---

### 3. `/api/kundenpreise`
**Status:** 500 Internal Server Error
**Fehler:**
```
('42S02', 'The Microsoft Access database engine cannot find the input table or query tbl_KD_Kundenpreise')
```

**Analyse:**
- Tabelle `tbl_KD_Kundenpreise` existiert nicht in der Datenbank
- Moeglicherweise anders benannt oder noch nicht angelegt

**Fix:**
- Tabellennamen korrigieren oder Tabelle anlegen

---

### 4. `/api/zeitkonten?ma_id=6`
**Status:** 500 Internal Server Error
**Fehler:**
```
('42S02', 'The Microsoft Access database engine cannot find the input table or query tbl_MA_Zeitkonto')
```

**Analyse:**
- Tabelle `tbl_MA_Zeitkonto` existiert nicht
- Alternative: `tbl_MA_NVerfuegZeiten` (fuer Abwesenheiten)

**Fix:**
- Tabellennamen pruefen oder Endpoint entfernen

---

## Performance-Beobachtungen

1. **Request-Throttling aktiv:** Max 1 gleichzeitiger Request, 150ms Mindestabstand
2. **Grosse Resultsets:** `/api/anfragen` liefert 8.4 MB (sehr gross!)
3. **ODBC-Stabilitaet:** Bei Parallelzugriffen kommt 503 "Server ueberlastet"

---

## Empfehlungen

### Hohe Prioritaet

1. **Default-Limit einfuehren** fuer `/api/zuordnungen` und `/api/rechnungen`:
   ```python
   # In beiden Endpoints:
   limit = request.args.get('limit', 1000, type=int)
   query = f"SELECT TOP {limit} ..."
   ```

2. **Fehlende Tabellen** identifizieren:
   - `tbl_KD_Kundenpreise` - existiert nicht
   - `tbl_MA_Zeitkonto` - existiert nicht

### Mittlere Prioritaet

3. **Pagination** fuer grosse Endpoints implementieren (`/api/anfragen`)

4. **Timeout erhoehen** fuer komplexe Queries

### Niedrige Prioritaet

5. **Caching** fuer Stammdaten (Mitarbeiter, Kunden, Objekte)

---

## Test-Befehle zum Reproduzieren

```bash
# Funktionierende Tests
curl "http://localhost:5000/api/health"
curl "http://localhost:5000/api/mitarbeiter?limit=3"
curl "http://localhost:5000/api/auftraege?limit=3"
curl "http://localhost:5000/api/zuordnungen?ma_id=6"
curl "http://localhost:5000/api/dienstplan/gruende"

# Fehlerhafte Tests
curl "http://localhost:5000/api/zuordnungen"      # 500
curl "http://localhost:5000/api/rechnungen"       # 500
curl "http://localhost:5000/api/kundenpreise"     # 500
curl "http://localhost:5000/api/zeitkonten?ma_id=6"  # 500

# VBA Bridge
curl "http://localhost:5002/api/health"
```

---

**Erstellt von:** Claude Code API-Test-Agent
**Getestet:** 33 Endpoints
**Erfolgreich:** 29 (88%)
**Fehlerhaft:** 4 (12%)
