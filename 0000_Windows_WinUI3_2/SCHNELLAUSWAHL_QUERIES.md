# SQL-Queries: Schnellauswahl-Seite

**Dokumentation der Datenbankzugriffe für frm_MA_VA_Schnellauswahl**

---

## Übersicht

| Query | Tabellen | Zweck | Zeilen (ca.) |
|-------|----------|-------|--------------|
| Q1 | tbl_VA_Auftragstamm, tbl_VA_AnzTage | Auftragsliste laden | 50-200 |
| Q2 | tbl_VA_AnzTage | Daten für Auftrag | 5-30 |
| Q3 | qry_Anz_MA_Start | Schichten/Zeiten | 1-10 |
| Q4 | qry_VA_Einsatz | Parallele Einsätze | 0-10 |
| Q5 | tbl_MA_Mitarbeiterstamm | Verfügbare MA | 20-200 |
| Q6 | tbl_MA_VA_Planung | Zugeordnete MA | 0-50 |
| Q7 | qry_Mitarbeiter_Zusage | MA mit Zusage | 0-20 |
| Q8 | tbl_hlp_MA_Anstellungsart | Anstellungsarten | 5 |
| Q9 | tbl_MA_Einsatzart | Qualifikationen | 10-20 |
| Q10 | tbl_VA_Auftragstamm | Auftrag-Details | 1 |

---

## Q1: Auftragsliste laden

**Zweck**: Lädt alle zukünftigen Aufträge mit Datum für VA-ComboBox

**Tabellen**:
- `tbl_VA_Auftragstamm` (Hauptaufträge)
- `tbl_VA_AnzTage` (Einsatztage pro Auftrag)
- `qry_tbl_Start_proTag` (Schichten pro Tag)

**SQL**:
```sql
SELECT DISTINCT
    a.ID AS VA_ID,
    d.ID AS VADatum_ID,
    FORMAT(d.VADatum, 'dd.MM.yyyy') + '   ' + a.Auftrag + '   ' + a.Objekt + '   ' + a.Ort AS DisplayText,
    d.VADatum
FROM tbl_VA_Auftragstamm a
INNER JOIN tbl_VA_AnzTage d ON a.ID = d.VA_ID
INNER JOIN qry_tbl_Start_proTag s ON d.VA_ID = s.VA_ID
    AND d.ID = s.VADatum_ID
WHERE d.VADatum >= CAST(GETDATE() AS DATE)
ORDER BY d.VADatum
```

**Parameter**: Keine

**Rückgabe**:
- `VA_ID` (int): Auftrag-ID
- `VADatum_ID` (int): Datum-ID
- `DisplayText` (string): "31.12.2025   Auftrag XY   Objekt ABC   Berlin"
- `VADatum` (DateTime): Einsatzdatum

**ViewModel-Binding**:
```csharp
AuftragListe = ObservableCollection<AuftragAuswahlItem>
```

**Access-Äquivalent**:
```vba
' VA_ID ComboBox Row Source
SELECT tbl_VA_Auftragstamm.ID, tbl_VA_AnzTage.ID AS VADatum_ID,
       [tbl_VA_AnzTage].[VADatum] & "   " & [Auftrag] & "   " & [Objekt] & "   " & [Ort] AS Auftragsname
FROM tbl_VA_Auftragstamm
INNER JOIN (tbl_VA_AnzTage INNER JOIN qry_tbl_Start_proTag
    ON (tbl_VA_AnzTage.VA_ID = qry_tbl_Start_proTag.VA_ID)
    AND (tbl_VA_AnzTage.ID = qry_tbl_Start_proTag.VADatum_ID))
    ON tbl_VA_Auftragstamm.ID = qry_tbl_Start_proTag.VA_ID
WHERE (((tbl_VA_AnzTage.VADatum)>=Format(Now(),"dd/mm/yyyy")))
ORDER BY tbl_VA_AnzTage.VADatum
```

---

## Q2: Datumsliste für Auftrag

**Zweck**: Lädt alle Einsatztage für ausgewählten Auftrag

**Tabellen**:
- `tbl_VA_AnzTage`

**SQL**:
```sql
SELECT ID, VADatum
FROM tbl_VA_AnzTage
WHERE VA_ID = @VaId
ORDER BY VADatum
```

**Parameter**:
- `@VaId` (int): Auftrag-ID

**Rückgabe**:
- `ID` (int): VADatum_ID
- `VADatum` (DateTime): Einsatzdatum

**ViewModel-Binding**:
```csharp
DatumListe = ObservableCollection<DatumAuswahlItem>
```

**Access-Äquivalent**:
```vba
' cboVADatum Row Source
SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum
FROM tbl_VA_AnzTage
WHERE (((tbl_VA_AnzTage.VA_ID)= 8470))
ORDER BY ID
```

---

## Q3: Schichten/Zeiten für Auftrag

**Zweck**: Lädt alle Schichten mit Ist/Soll-MA für ausgewählten Auftrag

**Tabellen**:
- `qry_Anz_MA_Start` (View mit Schicht-Info + MA-Zähler)

**SQL**:
```sql
SELECT
    VAStart_ID,
    VADatum,
    MVA_Start,
    MVA_Ende,
    MA_Ist as Ist,
    MA_Soll as Soll,
    LEFT(VA_Start, 5) As Beginn,
    LEFT(VA_Ende, 5) as Ende,
    VA_Start,
    VA_Ende
FROM qry_Anz_MA_Start
WHERE VA_ID = @VaId
ORDER BY VA_Start, VA_Ende
```

**Parameter**:
- `@VaId` (int): Auftrag-ID

**Rückgabe**:
- `VAStart_ID` (int): Schicht-ID
- `VA_Start` (TimeSpan): Beginn (HH:MM:SS)
- `VA_Ende` (TimeSpan): Ende (HH:MM:SS)
- `Ist` (int): Anzahl zugeordnete MA
- `Soll` (int): Anzahl benötigte MA

**ViewModel-Binding**:
```csharp
ZeitenListe = ObservableCollection<ZeitItem>
GesamtMa = Sum(Soll)
```

**Access-Äquivalent**:
```vba
' lstZeiten Row Source
SELECT VAStart_ID, VADatum, MVA_Start, MVA_Ende, MA_Ist as Ist, MA_Soll as Soll,
       left(VA_Start,5) As Beginn, left(VA_Ende,5) as Ende
FROM qry_Anz_MA_Start
WHERE VA_ID = 8470 AND VADatum_ID = 649066
ORDER BY VA_Start, VA_Ende
```

---

## Q4: Parallele Einsätze am selben Tag

**Zweck**: Zeigt andere Aufträge am selben Tag (für Übersicht)

**Tabellen**:
- `qry_VA_Einsatz` (View mit Auftrag-Info für Datum)

**SQL**:
```sql
SELECT *
FROM qry_VA_Einsatz
WHERE VADatum = @VaDatum
```

**Parameter**:
- `@VaDatum` (DateTime): Einsatzdatum

**Rückgabe**:
- `VA_ID` (int): Auftrag-ID
- `Auftrag` (string): Auftragname
- `Objekt` (string): Objektname
- `Ort` (string): Einsatzort

**ViewModel-Binding**:
```csharp
ParallelEinsaetzeListe = ObservableCollection<ParallelEinsatzItem>
DisplayText = "{Auftrag} - {Objekt} ({Ort})"
```

**Access-Äquivalent**:
```vba
' Lst_Parallel_Einsatz Row Source
SELECT * FROM qry_VA_Einsatz
WHERE VADatum = #2024-08-24#
```

---

## Q5: Verfügbare Mitarbeiter (mit Filtern)

**Zweck**: Lädt MA, die für die Schicht verfügbar sind (komplex!)

**Tabellen**:
- `tbl_MA_Mitarbeiterstamm` (Haupttabelle)
- `tbl_MA_VA_Planung` (Planung → für Ausschluss)
- `tbl_MA_NVerfuegZeiten` (Nichtverfügbarkeiten → für Ausschluss)

**SQL** (Vollversion mit allen Filtern):
```sql
SELECT
    m.MA_ID,
    m.Nachname,
    m.Vorname,
    m.Tel_Mobil,
    m.IstAktiv
FROM tbl_MA_Mitarbeiterstamm m
WHERE 1=1
  -- Filter: Nur Aktive
  AND m.IstAktiv = True

  -- Filter: Nur Verfügbare (nicht verplant am selben Tag/Zeit)
  AND m.MA_ID NOT IN (
      SELECT p.MA_ID
      FROM tbl_MA_VA_Planung p
      WHERE p.VADatum = @VaDatum
        AND (
            (p.VA_Start <= @VaEnde AND p.VA_Ende >= @VaStart)
            OR (p.VA_Start IS NULL)
        )
  )

  -- Filter: Nichtverfügbarkeiten prüfen
  AND m.MA_ID NOT IN (
      SELECT n.MA_ID
      FROM tbl_MA_NVerfuegZeiten n
      WHERE @VaDatum BETWEEN n.vonDat AND n.bisDat
  )

  -- Filter: Suchbegriff (optional)
  AND (m.Nachname LIKE @Such OR m.Vorname LIKE @Such)

ORDER BY m.Nachname, m.Vorname
```

**Parameter**:
- `@VaDatum` (DateTime): Einsatzdatum
- `@VaStart` (TimeSpan): Schichtbeginn
- `@VaEnde` (TimeSpan): Schichtende
- `@Such` (string, optional): Suchbegriff ("%Müller%")

**Filter-Flags** (ViewModel):
```csharp
if (NurAktive) → AND m.IstAktiv = True
if (FilterNurVerfuegbare) → AND m.MA_ID NOT IN (SELECT ...)
if (!string.IsNullOrWhiteSpace(Suchbegriff)) → AND (m.Nachname LIKE ...)
```

**Rückgabe**:
- `MA_ID` (int)
- `Nachname` (string)
- `Vorname` (string)
- `Tel_Mobil` (string)
- `IstAktiv` (bool)

**ViewModel-Binding**:
```csharp
VerfuegbareMitarbeiter = ObservableCollection<VerfuegbarerMitarbeiterItem>
DisplayName = "{Nachname}, {Vorname}"
```

**Access-Äquivalent**:
```vba
' List_MA Row Source
ztbl_MA_Schnellauswahl
```
*(Access verwendet eine temporäre Tabelle, die per VBA gefüllt wird)*

---

## Q6: Zugeordnete Mitarbeiter

**Zweck**: Lädt MA, die bereits dieser Schicht zugeordnet sind

**Tabellen**:
- `tbl_MA_VA_Planung` (Zuordnungen)
- `tbl_MA_Mitarbeiterstamm` (MA-Daten)

**SQL**:
```sql
SELECT
    p.MA_ID,
    m.Nachname,
    m.Vorname,
    m.Tel_Mobil,
    p.VA_Start,
    p.VA_Ende
FROM tbl_MA_VA_Planung p
INNER JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.MA_ID
WHERE p.VA_ID = @VaId
  AND p.VADatum = @VaDatum
  AND p.VA_Start = @VaStart
ORDER BY m.Nachname, m.Vorname
```

**Parameter**:
- `@VaId` (int): Auftrag-ID
- `@VaDatum` (DateTime): Einsatzdatum
- `@VaStart` (TimeSpan): Schichtbeginn

**Rückgabe**:
- `MA_ID` (int)
- `Nachname`, `Vorname`, `Tel_Mobil` (string)
- `VA_Start`, `VA_Ende` (TimeSpan)

**ViewModel-Binding**:
```csharp
ZugeordneteMitarbeiter = ObservableCollection<ZugeordneterMitarbeiterItem>
ZeitText = "{VaStart:HH:mm} - {VaEnde:HH:mm}"
```

**Access-Äquivalent**:
```vba
' lstMA_Plan Row Source
SELECT * FROM qry_Mitarbeiter_Geplant
WHERE VA_ID = 8470 AND VADatum_ID = 649066
```

---

## Q7: MA mit Zusage

**Zweck**: Lädt MA, die dem Auftrag zugesagt haben (spezielle Kategorie)

**Tabellen**:
- `qry_Mitarbeiter_Zusage` (View)

**SQL**:
```sql
SELECT *
FROM qry_Mitarbeiter_Zusage
WHERE VA_ID = @VaId
```

**Parameter**:
- `@VaId` (int): Auftrag-ID

**Rückgabe**:
- `MA_ID` (int)
- `Nachname`, `Vorname`, `Tel_Mobil` (string)
- `VA_Start`, `VA_Ende` (TimeSpan, nullable)

**ViewModel-Binding**:
```csharp
MitarbeiterMitZusage = ObservableCollection<ZugeordneterMitarbeiterItem>
```

**Access-Äquivalent**:
```vba
' lstMA_Zusage Row Source
SELECT * FROM qry_Mitarbeiter_Zusage
WHERE VA_ID = 8470 AND VADatum_ID = 649066
```

---

## Q8: Anstellungsarten (Filter)

**Zweck**: Lädt Anstellungsarten für Filter-ComboBox

**Tabellen**:
- `tbl_hlp_MA_Anstellungsart`

**SQL**:
```sql
SELECT ID, Anstellungsart, Sortierung
FROM tbl_hlp_MA_Anstellungsart
WHERE ID IN (3, 5, 11, 9, 13)
ORDER BY Sortierung
```

**Parameter**: Keine

**Rückgabe**:
- `ID` (int)
- `Anstellungsart` (string): z.B. "Festangestellt", "Geringfügig", etc.
- `Sortierung` (int)

**Hinweis**: Erster Eintrag "(Alle)" wird manuell hinzugefügt (ID=0)

**ViewModel-Binding**:
```csharp
AnstellungsartListe = ObservableCollection<AnstellungsartItem>
AnstellungsartListe.Insert(0, new AnstellungsartItem { Id = 0, Name = "(Alle)" })
```

**Access-Äquivalent**:
```vba
' cboAnstArt Row Source
SELECT tbl_hlp_MA_Anstellungsart.ID, tbl_hlp_MA_Anstellungsart.Anstellungsart, tbl_hlp_MA_Anstellungsart.Sortierung
FROM tbl_hlp_MA_Anstellungsart
WHERE (((tbl_hlp_MA_Anstellungsart.ID)=3 Or (tbl_hlp_MA_Anstellungsart.ID)=5 Or (tbl_hlp_MA_Anstellungsart.ID)=11 Or (tbl_hlp_MA_Anstellungsart.ID)=9 Or (tbl_hlp_MA_Anstellungsart.ID)=13))
ORDER BY tbl_hlp_MA_Anstellungsart.Sortierung
```

---

## Q9: Qualifikationen (Filter)

**Zweck**: Lädt Qualifikationen für Filter-ComboBox

**Tabellen**:
- `tbl_MA_Einsatzart`

**SQL**:
```sql
SELECT ID, QualiName
FROM tbl_MA_Einsatzart
ORDER BY QualiName
```

**Alternative** (aus ViewModel):
```sql
SELECT DISTINCT Qualifikation
FROM tbl_MA_Qualifikationen
WHERE Qualifikation IS NOT NULL
ORDER BY Qualifikation
```

**Parameter**: Keine

**Rückgabe**:
- `ID` (int)
- `QualiName` / `Qualifikation` (string): z.B. "Wachmann", "Pförtner", etc.

**Hinweis**: Erster Eintrag "(Alle)" wird manuell hinzugefügt

**ViewModel-Binding**:
```csharp
Qualifikationen = ObservableCollection<QualifikationItem>
Qualifikationen.Insert(0, new QualifikationItem { Id = 0, Name = "(Alle)" })
```

**Access-Äquivalent**:
```vba
' cboQuali Row Source
SELECT [tbl_MA_Einsatzart].ID, [tbl_MA_Einsatzart].QualiName
FROM tbl_MA_Einsatzart
```

---

## Q10: Auftrag-Details

**Zweck**: Lädt Auftragname und Objekt für Banner-Anzeige

**Tabellen**:
- `tbl_VA_Auftragstamm`

**SQL**:
```sql
SELECT a.Auftrag, a.Objekt
FROM tbl_VA_Auftragstamm a
WHERE a.ID = @VaId
```

**Parameter**:
- `@VaId` (int): Auftrag-ID

**Rückgabe**:
- `Auftrag` (string): Auftragname
- `Objekt` (string): Objektname

**ViewModel-Binding**:
```csharp
AuftragName = row["Auftrag"]
ObjektName = row["Objekt"]
```

---

## INSERT/UPDATE/DELETE (Aktionen)

### INSERT: MA zuordnen

**Zweck**: Ordnet MA einer Schicht zu

**SQL**:
```sql
INSERT INTO tbl_MA_VA_Planung (VA_ID, MA_ID, VADatum, VA_Start, VA_Ende)
VALUES (@VaId, @MaId, @VaDatum, @VaStart, @VaEnde)
```

**Parameter**:
- `@VaId` (int): Auftrag-ID
- `@MaId` (int): Mitarbeiter-ID
- `@VaDatum` (DateTime): Einsatzdatum
- `@VaStart` (TimeSpan): Schichtbeginn
- `@VaEnde` (TimeSpan): Schichtende

**Auswirkung**:
- Zeile in `tbl_MA_VA_Planung` eingefügt
- MA verschwindet aus "Verfügbare MA"
- MA erscheint in "Geplante Mitarbeiter"
- Statistik: Zugeordnet +1

**Nach INSERT**: Update MA_Anzahl_Ist ausführen (siehe unten)

---

### DELETE: MA entfernen

**Zweck**: Entfernt MA von Schicht

**SQL**:
```sql
DELETE FROM tbl_MA_VA_Planung
WHERE VA_ID = @VaId
  AND MA_ID = @MaId
  AND VADatum = @VaDatum
  AND VA_Start = @VaStart
```

**Parameter**:
- `@VaId` (int): Auftrag-ID
- `@MaId` (int): Mitarbeiter-ID
- `@VaDatum` (DateTime): Einsatzdatum
- `@VaStart` (TimeSpan): Schichtbeginn

**Auswirkung**:
- Zeile in `tbl_MA_VA_Planung` gelöscht
- MA verschwindet aus "Geplante Mitarbeiter"
- MA erscheint wieder in "Verfügbare MA"
- Statistik: Zugeordnet -1

**Nach DELETE**: Update MA_Anzahl_Ist ausführen (siehe unten)

---

### UPDATE: MA_Anzahl_Ist aktualisieren

**Zweck**: Aktualisiert Ist-Zähler in `tbl_VA_Start` nach Zuordnung/Entfernung

**SQL**:
```sql
UPDATE tbl_VA_Start
SET MA_Anzahl_Ist = (
    SELECT COUNT(*)
    FROM tbl_MA_VA_Planung
    WHERE VA_ID = @VaId
      AND VADatum = @VaDatum
      AND VA_Start = @VaStart
)
WHERE VA_ID = @VaId
  AND VADatum = @VaDatum
  AND VA_Start = @VaStart
```

**Parameter**:
- `@VaId` (int): Auftrag-ID
- `@VaDatum` (DateTime): Einsatzdatum
- `@VaStart` (TimeSpan): Schichtbeginn

**Auswirkung**:
- `MA_Anzahl_Ist` in `tbl_VA_Start` wird auf aktuelle Anzahl zugeordneter MA gesetzt
- Wichtig für Zeiten-Liste (Ist/Soll-Anzeige)

**Hinweis**: Wird IMMER nach INSERT oder DELETE ausgeführt

---

## Query-Performance-Optimierung

### Indizes (empfohlen)

**tbl_MA_VA_Planung**:
```sql
CREATE INDEX idx_Planung_Datum ON tbl_MA_VA_Planung(VADatum, VA_Start, VA_Ende)
CREATE INDEX idx_Planung_MA ON tbl_MA_VA_Planung(MA_ID)
CREATE INDEX idx_Planung_VA ON tbl_MA_VA_Planung(VA_ID)
```

**tbl_MA_NVerfuegZeiten**:
```sql
CREATE INDEX idx_NVerfueg_Datum ON tbl_MA_NVerfuegZeiten(vonDat, bisDat)
CREATE INDEX idx_NVerfueg_MA ON tbl_MA_NVerfuegZeiten(MA_ID)
```

**tbl_VA_AnzTage**:
```sql
CREATE INDEX idx_AnzTage_Datum ON tbl_VA_AnzTage(VADatum)
CREATE INDEX idx_AnzTage_VA ON tbl_VA_AnzTage(VA_ID)
```

---

## Transaktionen (bei Batch-Operationen)

**Mehrere MA zuordnen** (ZuordnenSelectedAsync):
```csharp
// Pseudocode - in der Praxis einzelne INSERTs
foreach (var ma in SelectedVerfuegbare)
{
    await _databaseService.ExecuteNonQueryAsync(insertSql, ...);
}
```

**Hinweis**: Access/ODBC unterstützt eingeschränkte Transaktionen. Bei Fehler könnte Inkonsistenz entstehen. Empfehlung: Bei kritischen Batch-Ops Rollback-Mechanismus implementieren.

---

## Fehlerbehandlung

**Häufige Fehler**:

1. **Duplicate Key** (MA bereits zugeordnet):
   - Fehler: "Cannot insert duplicate key in tbl_MA_VA_Planung"
   - Ursache: MA wurde bereits zugeordnet
   - Lösung: Before INSERT prüfen ob bereits existiert

2. **Foreign Key** (VA_ID existiert nicht):
   - Fehler: "Foreign key constraint violated"
   - Ursache: Auftrag wurde gelöscht
   - Lösung: Daten aktualisieren, neuen Auftrag wählen

3. **Timeout** (Query zu langsam):
   - Fehler: "Query timeout after 30 seconds"
   - Ursache: Viele MA, komplexe Filter, keine Indizes
   - Lösung: Indizes erstellen, LIMIT verwenden

---

## Zusammenfassung

**Gesamtzahl Queries**: 10 SELECT + 3 INSERT/UPDATE/DELETE
**Komplexität**:
- Einfach (1-2 Tabellen): Q2, Q7, Q8, Q9, Q10
- Mittel (3-4 Tabellen): Q1, Q3, Q4, Q6
- Komplex (Subqueries): Q5 (Verfügbare MA)

**Performance-Kritisch**:
- Q5 (Verfügbare MA) - Läuft bei jedem Filter-Change
- Q6 (Zugeordnete MA) - Läuft nach jedem INSERT/DELETE

**Empfehlung**: Indizes auf allen Fremdschlüsseln und Datums-Feldern erstellen.

---

**Erstellt**: 30.12.2025
**Autor**: Claude (Sonnet 4.5)
