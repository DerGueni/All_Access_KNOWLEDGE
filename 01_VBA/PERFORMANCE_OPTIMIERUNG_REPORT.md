# Performance-Optimierung Report
## Access Frontend: 0_Consys_FE_Test.accdb
## Datum: 2026-01-06

---

## 1. ANALYSE-ZUSAMMENFASSUNG

### 1.1 Analysierte Module
- **Anzahl VBA-Module:** 100+
- **Gefundene TLookup/TCount/TSum Aufrufe:** 339 in 29 Dateien
- **Recordset-Schleifen (Do While/Until):** 100+ Vorkommen
- **Hauptproblem-Module:**
  - `zmd_Funktionen.bas` - 42 Domain-Funktionsaufrufe
  - `zmd_Ersatzfunktionen.bas` - 45 Domain-Funktionsaufrufe
  - `mdl_CONSEC_Divers1.bas` - 49 Domain-Funktionsaufrufe
  - `zmd_Zeitkonten.bas` - 51 Domain-Funktionsaufrufe
  - `zmd_Mail.bas` - 29 Domain-Funktionsaufrufe

### 1.2 Identifizierte Performance-Probleme

| Problem | Schweregrad | Haeufigkeit | Beschreibung |
|---------|-------------|-------------|--------------|
| Mehrfache TLookup-Aufrufe | HOCH | 339+ | TLookup/TCount/TSum werden in Schleifen aufgerufen |
| Nicht geschlossene Recordsets | MITTEL | 30+ | Recordsets werden nicht immer sauber geschlossen |
| Fehlende Indizes | MITTEL | Unbekannt | Haeufig gefilterte Felder ohne Index |
| Ineffiziente Schleifen | HOCH | 100+ | Do While/Until ohne Batch-Optimierung |
| Fehlende Fehlerbehandlung | NIEDRIG | 50+ | On Error Resume Next ohne Cleanup |
| Mehrfache CurrentDb-Aufrufe | MITTEL | Haeufig | CurrentDb wird mehrfach pro Funktion aufgerufen |

---

## 2. KRITISCHE PERFORMANCE-PROBLEME

### 2.1 Problem: Wiederholte Domain-Funktionen in Schleifen

**Fundstelle:** `zmd_Funktionen.bas`, Zeile 1017-1026

```vba
' VORHER (LANGSAM):
Do
    If Not IsNull(rst.fields("Anfragezeitpunkt")) Then
        rst.Edit
        rst.fields("Reaktionszeit") = DateDiff("h", _
            rst.fields("Anfragezeitpunkt"), _
            rst.fields("Rueckmeldezeitpunkt"))
        rst.update
    End If
    rst.MoveNext
Loop Until rst.EOF
```

**Problem:** Einzelne Record-Updates statt Batch-Update

**LOESUNG:**
```vba
' NACHHER (SCHNELL):
CurrentDb.Execute "UPDATE ztbl_Rueckmeldezeiten " & _
    "SET Reaktionszeit = DateDiff('h', Anfragezeitpunkt, Rueckmeldezeitpunkt) " & _
    "WHERE Anfragezeitpunkt IS NOT NULL AND Rueckmeldezeitpunkt IS NOT NULL"
```

**Geschaetzte Verbesserung:** 90-95% schneller bei 1000+ Datensaetzen

---

### 2.2 Problem: Mehrfache TLookup in check_Anzahl_MA

**Fundstelle:** `zmd_Funktionen.bas`, Zeile 1061-1157

```vba
' VORHER (LANGSAM):
For i = 1 To UBound(VAStart_ID)
    Soll = TLookup("MA_Anzahl", VAStart, "ID = " & VAStart_ID(i))
    Ist = TCount("PosNr", ZUORDNUNG, "VA_ID = " & VA_ID & " AND ...")
    ' ... weitere TLookup/TCount Aufrufe in der Schleife
Next i
```

**Problem:** N x TLookup = N Datenbankabfragen

**LOESUNG:**
```vba
' NACHHER (SCHNELL):
' Alle Daten in einem Recordset laden
Dim sql As String
sql = "SELECT s.ID, s.MA_Anzahl, " & _
      "(SELECT COUNT(*) FROM tbl_MA_VA_Zuordnung z " & _
      " WHERE z.VAStart_ID = s.ID AND z.VA_ID = " & VA_ID & ") AS IstAnzahl " & _
      "FROM tbl_VA_Start s WHERE s.VA_ID = " & VA_ID

Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
Do Until rs.EOF
    ' Verarbeitung ohne weitere Datenbankabfragen
    rs.MoveNext
Loop
```

**Geschaetzte Verbesserung:** 80-90% schneller

---

### 2.3 Problem: Ineffiziente fVAUpd_AllSI Funktion

**Fundstelle:** `mdlAutoexec.bas`, Zeile 116-125

```vba
' VORHER (4 separate Queries):
CurrentDb.Execute ("SELECT ... INTO tbltmp_VA_All_SollIst ...")
CurrentDb.Execute ("UPDATE tbltmp_VA_All_SollIst SET SI = ...")
CurrentDb.Execute ("UPDATE tbltmp_VA_All_SollIst SET SI = 0 WHERE ...")
CurrentDb.Execute ("UPDATE tbltmp_VA_All_SollIst INNER JOIN ...")
```

**LOESUNG:**
```vba
' NACHHER (1 optimierte Query):
CurrentDb.Execute _
    "UPDATE tbl_VA_Auftragstamm AS a " & _
    "INNER JOIN (" & _
    "  SELECT VA_ID, SUM(TVA_Soll) AS Soll, SUM(TVA_Ist) AS Ist " & _
    "  FROM tbl_VA_AnzTage GROUP BY VA_ID " & _
    "  HAVING SUM(TVA_Soll) = SUM(TVA_Ist) AND SUM(TVA_Soll) > 0" & _
    ") AS t ON a.ID = t.VA_ID " & _
    "SET a.Veranst_Status_ID = 2"
```

**Geschaetzte Verbesserung:** 60-70% schneller, keine temp-Tabelle noetig

---

### 2.4 Problem: Wait-Funktion blockiert

**Fundstelle:** `zmd_Funktionen.bas`, Zeile 153-164

```vba
' VORHER (CPU-intensiv):
Function Wait(n As Double)
    Do Until TNow >= TWait
         TNow = Time
    Loop
End Function
```

**LOESUNG:**
```vba
' NACHHER (CPU-freundlich):
Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal ms As LongPtr)

Function Wait(n As Double)
    Sleep n * 1000  ' n in Sekunden
End Function
```

---

## 3. IMPLEMENTIERTE OPTIMIERUNGEN

### 3.1 Neues Performance-Modul: mod_N_Performance.bas

Das neue Modul bietet folgende Funktionen:

| Funktion | Beschreibung |
|----------|--------------|
| `Performance_Initialize()` | Initialisiert Caches und Timer |
| `StartTimer()` / `GetElapsedTime()` | Hochpraezisions-Zeitmessung |
| `MeasureExecutionTime()` | Misst und loggt Ausfuehrungszeiten |
| `LogSlowQuery()` | Protokolliert langsame Abfragen |
| `OptimizeFormLoad()` / `OptimizeFormLoadEnd()` | Formular-Lade-Optimierung |
| `GetCachedMitarbeiter()` | Gecachter Mitarbeiter-Zugriff |
| `GetCachedKunde()` | Gecachter Kunden-Zugriff |
| `GetCachedObjekt()` | Gecachter Objekt-Zugriff |
| `ClearAllCaches()` | Leert alle Caches |
| `FastLookup()` / `FastCount()` / `FastSum()` | Schnellere Domain-Funktionen |
| `ExecuteBatchSQL()` | Batch-SQL-Ausfuehrung |
| `GeneratePerformanceReport()` | Erstellt Performance-Report |

### 3.2 Stammdaten-Caching

```vba
' Verwendung:
Dim maData As Variant
maData = GetCachedMitarbeiter(152)
Debug.Print maData(1) ' Nachname
Debug.Print maData(2) ' Vorname

' Cache-Einstellungen:
SetCacheMaxAge 300    ' 5 Minuten
InvalidateMitarbeiterCache 152  ' Einzelnen Eintrag invalidieren
ClearAllCaches        ' Alle Caches leeren
```

### 3.3 Slow Query Logging

```vba
' Automatisches Logging:
SetSlowQueryThreshold 0.5  ' 500ms Schwellwert
EnableLogging True

' Manuelles Messen:
StartTimer
' ... Code ausfuehren ...
MeasureExecutionTime "MeineProzedur"

' Log anzeigen:
PrintPerformanceReport
```

---

## 4. EMPFEHLUNGEN FUER WEITERE OPTIMIERUNGEN

### 4.1 Sofort umsetzbar (Quick Wins)

| Massnahme | Aufwand | Auswirkung |
|-----------|---------|------------|
| TLookup durch FastLookup ersetzen | Niedrig | Mittel |
| Recordset mit dbOpenSnapshot oeffnen | Niedrig | Hoch |
| SetWarnings False bei Batch-Ops | Niedrig | Mittel |
| DBEngine.Idle nach grossen Ops | Niedrig | Mittel |

### 4.2 Mittelfristig empfohlen

| Massnahme | Aufwand | Auswirkung |
|-----------|---------|------------|
| Indizes auf haeufig gefilterte Felder | Mittel | Hoch |
| Schleifen durch Batch-SQL ersetzen | Mittel | Sehr Hoch |
| Unterformulare lazy loaden | Mittel | Hoch |
| Abfragen mit nur noetigen Feldern | Mittel | Mittel |

### 4.3 Langfristig empfohlen

| Massnahme | Aufwand | Auswirkung |
|-----------|---------|------------|
| Frontend regelmaessig komprimieren | Niedrig | Mittel |
| Backend-Indizes ueberpruefen | Hoch | Sehr Hoch |
| Komplexe Abfragen aufteilen | Hoch | Hoch |
| Passthrough-Queries verwenden | Hoch | Hoch |

---

## 5. INDEX-EMPFEHLUNGEN

Basierend auf der Analyse sollten folgende Indizes geprueft/erstellt werden:

### Backend-Tabellen:

```sql
-- tbl_MA_VA_Zuordnung (haeufig gefiltert)
CREATE INDEX idx_Zuo_VA_ID ON tbl_MA_VA_Zuordnung (VA_ID);
CREATE INDEX idx_Zuo_VADatum_ID ON tbl_MA_VA_Zuordnung (VADatum_ID);
CREATE INDEX idx_Zuo_MA_ID ON tbl_MA_VA_Zuordnung (MA_ID);
CREATE INDEX idx_Zuo_VAStart_ID ON tbl_MA_VA_Zuordnung (VAStart_ID);
CREATE INDEX idx_Zuo_Composite ON tbl_MA_VA_Zuordnung (VA_ID, VADatum_ID, VAStart_ID);

-- tbl_VA_Start
CREATE INDEX idx_Start_VA_ID ON tbl_VA_Start (VA_ID);
CREATE INDEX idx_Start_VADatum_ID ON tbl_VA_Start (VADatum_ID);

-- tbl_VA_AnzTage
CREATE INDEX idx_AnzTage_VA_ID ON tbl_VA_AnzTage (VA_ID);
CREATE INDEX idx_AnzTage_VADatum ON tbl_VA_AnzTage (VADatum);

-- tbl_MA_Mitarbeiterstamm
CREATE INDEX idx_MA_IstAktiv ON tbl_MA_Mitarbeiterstamm (IstAktiv);
```

---

## 6. VERWENDUNG DES PERFORMANCE-MODULS

### 6.1 Installation

1. Modul `mod_N_Performance.bas` in Access importieren
2. Im VBA-Editor: Extras > Verweise > "Microsoft Scripting Runtime" aktivieren
3. `Performance_Initialize` wird automatisch beim Oeffnen ausgefuehrt

### 6.2 Beispiel: Formular optimieren

```vba
Private Sub Form_Load()
    ' Performance-Optimierung starten
    OptimizeFormLoad Me

    ' Unterformulare erst bei Bedarf laden
    Me.sfrmDetails.SourceObject = ""

    ' Performance-Optimierung beenden
    OptimizeFormLoadEnd Me
End Sub

Private Sub txtFilter_AfterUpdate()
    ' Unterformular laden wenn Filter gesetzt
    LoadSubformData Me.sfrmDetails, "qry_Details", "FilterID = " & Me.txtFilter
End Sub
```

### 6.3 Beispiel: Zeitmessung

```vba
Sub TestPerformance()
    Dim elapsed As Double

    StartTimer

    ' Zu messender Code
    Call MeineAufwaendigeFunktion()

    elapsed = MeasureExecutionTime("MeineAufwaendigeFunktion")
    Debug.Print "Dauer: " & FormatDuration(elapsed)
End Sub
```

### 6.4 Beispiel: Gecachter Zugriff

```vba
' Statt:
Nachname = TLookup("Nachname", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID)

' Besser:
Dim maData As Variant
maData = GetCachedMitarbeiter(MA_ID)
Nachname = maData(1)  ' Index 0=ID, 1=Nachname, 2=Vorname, 3=IstAktiv
```

---

## 7. MESSBARE VERBESSERUNGEN

### Vorher/Nachher-Vergleich (geschaetzt)

| Operation | Vorher | Nachher | Verbesserung |
|-----------|--------|---------|--------------|
| Formular laden (frm_va_Auftragstamm) | ~3-5s | ~1-2s | 50-60% |
| TLookup in Schleife (1000x) | ~8-10s | ~0.5-1s | 90% |
| Batch-Update (1000 Records) | ~15-20s | ~2-3s | 85% |
| Stammdaten-Lookup (gecacht) | ~50ms | ~1ms | 98% |

---

## 8. FAZIT

Die Hauptprobleme des Access-Frontends sind:

1. **Zu viele einzelne Datenbankabfragen** - Domain-Funktionen (TLookup, TCount, TSum) werden in Schleifen verwendet statt Batch-Operationen
2. **Fehlendes Caching** - Stammdaten werden bei jedem Zugriff neu geladen
3. **Keine Zeitmessung** - Performance-Probleme werden nicht erkannt
4. **Ineffiziente Schleifen** - Einzelne Record-Updates statt SQL-Batch

Das neue **mod_N_Performance.bas** Modul adressiert diese Probleme durch:
- Stammdaten-Caching mit konfigurierbarer Lebenszeit
- Hochpraezisions-Zeitmessung
- Automatisches Slow-Query-Logging
- Optimierte Alternative zu Domain-Funktionen
- Batch-SQL-Ausfuehrung

---

*Report erstellt mit Claude Code - 2026-01-06*
