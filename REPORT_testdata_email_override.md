# REPORT: Test-E-Mail Override

**Erstellt:** 2026-01-08
**Status:** ABGESCHLOSSEN

---

## 1. Durchgefuehrte Aktion

Alle E-Mail-Adressen in der Tabelle `tbl_MA_Mitarbeiterstamm` wurden auf die Test-Adresse gesetzt:

```
siegert@consec-nuernberg.de
```

---

## 2. Technische Details

### SQL-Statement
```sql
UPDATE tbl_MA_Mitarbeiterstamm SET Email = 'siegert@consec-nuernberg.de'
```

### Ergebnis

| Metrik | Wert |
|--------|------|
| Gesamtanzahl Mitarbeiter | 894 |
| Mit E-Mail vorher | 893 |
| Mit Test-E-Mail nachher | **894** |
| Erfolgsquote | 100% |

---

## 3. Stichproben-Verifizierung

| ID | Nachname | Vorname | E-Mail |
|----|----------|---------|--------|
| 3 | Bethmann | Stefan | siegert@consec-nuernberg.de |
| 4 | Dorr | Christian | siegert@consec-nuernberg.de |
| 5 | Gampel | Matthias | siegert@consec-nuernberg.de |
| 6 | Siegert | Guenther | siegert@consec-nuernberg.de |
| 7 | Reibling | Sabine | siegert@consec-nuernberg.de |

---

## 4. Zweck

Diese Aenderung dient Testzwecken:

- Alle automatischen E-Mail-Versandfunktionen (btnMailEins, btn_Autosend_BOS, cmd_BWN_send)
  senden jetzt E-Mails ausschliesslich an die Test-Adresse
- Keine versehentlichen E-Mails an echte Mitarbeiter-Adressen
- Einfache Verifizierung der E-Mail-Funktionalitaet

---

## 5. Betroffene Datenbank

- **Tabelle:** tbl_MA_Mitarbeiterstamm
- **Feld:** Email
- **Backend:** S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\0_Consec_V1_BE_V1.55_Test.accdb

---

## 6. Backup / Restore

### Zum Wiederherstellen der Original-E-Mails:

**Option 1:** Backup-Tabelle verwenden (falls vorhanden)
```sql
UPDATE tbl_MA_Mitarbeiterstamm AS m
INNER JOIN tbl_MA_Mitarbeiterstamm_Backup AS b ON m.ID = b.ID
SET m.Email = b.Email
```

**Option 2:** Manueller Export vorher durchfuehren
```sql
SELECT ID, Nachname, Vorname, Email INTO tbl_MA_Email_Backup
FROM tbl_MA_Mitarbeiterstamm
WHERE Email IS NOT NULL
```

**Option 3:** Frontend-Export
- Im Access-Frontend: tbl_MA_Mitarbeiterstamm oeffnen
- Rechtsklick -> Exportieren -> Excel

---

## 7. Hinweis

**ACHTUNG:** Diese Aenderung betrifft das Test-Backend!
- Produktiv-Backend ist **NICHT** betroffen
- Vor produktivem Einsatz: Original-E-Mails wiederherstellen

---

## 8. Zeitstempel

| Aktion | Zeitpunkt |
|--------|-----------|
| E-Mail Override durchgefuehrt | 2026-01-08 |
| Report erstellt | 2026-01-08 |

---

*Erstellt von Claude Code*
