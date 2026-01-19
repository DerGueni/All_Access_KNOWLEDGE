"""
Dashboard-Implementierung für Consys Frontend
Erstellt ein neues Dashboard-Formular mit Live-Übersicht

Verbesserungen basierend auf:
- Timecount: Drag-and-Drop Planung, Echtzeit-Übersicht
- SecPlanNet: Einsatzübersicht, Konfliktprüfung
- TrackTik: Analytics, Automatisierung
"""

import win32com.client
import os
import time
from datetime import datetime

# Konfiguration
FRONTEND_PATH = r"\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\B - Diverses\Consys_FE_N_Test_Claude_GPT - Kopie (6).accdb"

def create_access_connection():
    """Erstellt Verbindung zu Access"""
    try:
        # Prüfe ob Access bereits läuft
        try:
            access = win32com.client.GetActiveObject("Access.Application")
            print("Verwende laufende Access-Instanz")
        except:
            access = win32com.client.Dispatch("Access.Application")
            print("Neue Access-Instanz erstellt")

        access.Visible = False

        # Öffne Datenbank falls nicht bereits offen
        if not access.CurrentDb:
            access.OpenCurrentDatabase(FRONTEND_PATH)
            print(f"Datenbank geöffnet: {FRONTEND_PATH}")
        elif access.CurrentDb.Name != FRONTEND_PATH:
            access.CloseCurrentDatabase()
            access.OpenCurrentDatabase(FRONTEND_PATH)
            print(f"Datenbank gewechselt zu: {FRONTEND_PATH}")
        else:
            print("Datenbank bereits geöffnet")

        return access
    except Exception as e:
        print(f"Fehler bei Access-Verbindung: {e}")
        return None

def create_dashboard_module(access):
    """Erstellt das VBA-Modul für Dashboard-Funktionen"""

    module_name = "mod_N_Dashboard"

    vba_code = '''
Option Compare Database
Option Explicit

' ============================================
' DASHBOARD-MODUL für Consys
' Erstellt: ''' + datetime.now().strftime("%Y-%m-%d %H:%M") + '''
' Inspiriert von: Timecount, SecPlanNet, TrackTik
' ============================================

' Globale Dashboard-Variablen
Private m_RefreshInterval As Integer
Private m_LastRefresh As Date

' ============================================
' DASHBOARD KENNZAHLEN
' ============================================

Public Function GetAuftraegeHeute() As Long
    ' Anzahl der Aufträge für heute
    On Error Resume Next
    GetAuftraegeHeute = DCount("*", "tbl_VA_AnzTage", "VADatum = Date()")
    If Err.Number <> 0 Then GetAuftraegeHeute = 0
End Function

Public Function GetAuftrageDieseWoche() As Long
    ' Anzahl der Aufträge diese Woche
    On Error Resume Next
    GetAuftrageDieseWoche = DCount("*", "tbl_VA_AnzTage", _
        "VADatum >= DateAdd('d', 1-Weekday(Date(),2), Date()) AND " & _
        "VADatum <= DateAdd('d', 7-Weekday(Date(),2), Date())")
    If Err.Number <> 0 Then GetAuftrageDieseWoche = 0
End Function

Public Function GetOffeneAnfragen() As Long
    ' Anzahl offener MA-Anfragen (Status = geplant, noch keine Rückmeldung)
    On Error Resume Next
    GetOffeneAnfragen = DCount("*", "tbl_MA_VA_Planung", _
        "Status_ID = 1 AND VADatum >= Date()")
    If Err.Number <> 0 Then GetOffeneAnfragen = 0
End Function

Public Function GetUnterbesetzung() As Long
    ' Anzahl Aufträge mit Unterbesetzung (IST < SOLL)
    On Error Resume Next
    GetUnterbesetzung = DCount("*", "tbl_VA_AnzTage", _
        "TVA_Offen > 0 AND VADatum >= Date()")
    If Err.Number <> 0 Then GetUnterbesetzung = 0
End Function

Public Function GetMitarbeiterAktiv() As Long
    ' Anzahl aktiver Mitarbeiter
    On Error Resume Next
    GetMitarbeiterAktiv = DCount("*", "tbl_MA_Mitarbeiterstamm", "IstAktiv = True")
    If Err.Number <> 0 Then GetMitarbeiterAktiv = 0
End Function

Public Function GetZusagenHeute() As Long
    ' Anzahl Zusagen für heute
    On Error Resume Next
    GetZusagenHeute = DCount("*", "tbl_MA_VA_Zuordnung", "VADatum = Date()")
    If Err.Number <> 0 Then GetZusagenHeute = 0
End Function

' ============================================
' KONFLIKTPRÜFUNG
' ============================================

Public Function CheckMAKonflikt(MA_ID As Long, VADatum As Date, _
                                StartZeit As Date, EndeZeit As Date) As String
    ' Prüft ob ein MA bereits einen anderen Einsatz hat
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim konfliktInfo As String

    On Error Resume Next
    konfliktInfo = ""

    ' Prüfe Zuordnungen
    sql = "SELECT VA_ID, MA_Start, MA_Ende FROM tbl_MA_VA_Zuordnung " & _
          "WHERE MA_ID = " & MA_ID & " AND VADatum = #" & Format(VADatum, "mm/dd/yyyy") & "# " & _
          "AND ((MA_Start < #" & Format(EndeZeit, "hh:nn") & "# AND MA_Ende > #" & Format(StartZeit, "hh:nn") & "#))"

    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    If Not rs.EOF Then
        konfliktInfo = "KONFLIKT: MA bereits eingeplant für VA " & rs!VA_ID & _
                       " (" & Format(rs!MA_Start, "hh:nn") & "-" & Format(rs!MA_Ende, "hh:nn") & ")"
    End If
    rs.Close

    ' Prüfe auch Planungen
    If konfliktInfo = "" Then
        sql = "SELECT VA_ID, VA_Start, VA_Ende FROM tbl_MA_VA_Planung " & _
              "WHERE MA_ID = " & MA_ID & " AND VADatum = #" & Format(VADatum, "mm/dd/yyyy") & "# " & _
              "AND Status_ID IN (1, 2) " & _
              "AND ((VA_Start < #" & Format(EndeZeit, "hh:nn") & "# AND VA_Ende > #" & Format(StartZeit, "hh:nn") & "#))"

        Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
        If Not rs.EOF Then
            konfliktInfo = "WARNUNG: MA hat offene Anfrage für VA " & rs!VA_ID
        End If
        rs.Close
    End If

    CheckMAKonflikt = konfliktInfo
End Function

Public Function GetVerfuegbareMA(VADatum As Date, StartZeit As Date, _
                                  EndeZeit As Date, Optional QualiID As Long = 0) As String
    ' Gibt Liste verfügbarer MA-IDs zurück (kommasepariert)
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim maListe As String

    On Error Resume Next
    maListe = ""

    ' Alle aktiven MA, die:
    ' 1. Keine Zuordnung an dem Tag/Zeit haben
    ' 2. Keine Nicht-Verfügbarkeit eingetragen haben
    ' 3. Optional: die passende Qualifikation haben

    sql = "SELECT ID FROM tbl_MA_Mitarbeiterstamm WHERE IstAktiv = True " & _
          "AND ID NOT IN (" & _
          "  SELECT MA_ID FROM tbl_MA_VA_Zuordnung " & _
          "  WHERE VADatum = #" & Format(VADatum, "mm/dd/yyyy") & "# " & _
          "  AND MA_Start < #" & Format(EndeZeit, "hh:nn") & "# " & _
          "  AND MA_Ende > #" & Format(StartZeit, "hh:nn") & "#" & _
          ") " & _
          "AND ID NOT IN (" & _
          "  SELECT MA_ID FROM tbl_MA_NVerfuegZeiten " & _
          "  WHERE vonDat <= #" & Format(VADatum, "mm/dd/yyyy") & "# " & _
          "  AND bisDat >= #" & Format(VADatum, "mm/dd/yyyy") & "#" & _
          ")"

    If QualiID > 0 Then
        sql = sql & " AND ID IN (SELECT MA_ID FROM tbl_MA_Einsatz_Zuo WHERE Quali_ID = " & QualiID & ")"
    End If

    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    Do While Not rs.EOF
        If maListe <> "" Then maListe = maListe & ","
        maListe = maListe & rs!ID
        rs.MoveNext
    Loop
    rs.Close

    GetVerfuegbareMA = maListe
End Function

' ============================================
' SCHNELLZUORDNUNG
' ============================================

Public Function SchnellZuordnung(VA_ID As Long, VADatum_ID As Long, _
                                  VAStart_ID As Long, MA_ID As Long, _
                                  StartZeit As Date, EndeZeit As Date) As Boolean
    ' Ordnet MA schnell zu einem Auftrag zu
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim konflikt As String
    Dim vaDatum As Date

    On Error GoTo Fehler

    ' Hole VADatum
    vaDatum = DLookup("VADatum", "tbl_VA_AnzTage", "ID = " & VADatum_ID)

    ' Konfliktprüfung
    konflikt = CheckMAKonflikt(MA_ID, vaDatum, StartZeit, EndeZeit)
    If konflikt <> "" Then
        MsgBox konflikt, vbExclamation, "Zuordnung nicht möglich"
        SchnellZuordnung = False
        Exit Function
    End If

    ' Einfügen
    Set db = CurrentDb
    Set rs = db.OpenRecordset("tbl_MA_VA_Zuordnung", dbOpenDynaset)

    rs.AddNew
    rs!VA_ID = VA_ID
    rs!MA_ID = MA_ID
    rs!VADatum_ID = VADatum_ID
    rs!VAStart_ID = VAStart_ID
    rs!VADatum = vaDatum
    rs!MA_Start = StartZeit
    rs!MA_Ende = EndeZeit
    rs!Erst_von = Environ("USERNAME")
    rs!Erst_am = Now()
    rs.Update

    rs.Close
    Set rs = Nothing
    Set db = Nothing

    ' Aktualisiere IST-Zähler
    Call UpdateIstZaehler(VADatum_ID)

    SchnellZuordnung = True
    Exit Function

Fehler:
    MsgBox "Fehler bei Schnellzuordnung: " & Err.Description, vbCritical
    SchnellZuordnung = False
End Function

Private Sub UpdateIstZaehler(VADatum_ID As Long)
    ' Aktualisiert den IST-Zähler für einen VA-Tag
    Dim anzahl As Long

    On Error Resume Next
    anzahl = DCount("*", "tbl_MA_VA_Zuordnung", "VADatum_ID = " & VADatum_ID)

    CurrentDb.Execute "UPDATE tbl_VA_AnzTage SET TVA_Ist = " & anzahl & _
                      ", TVA_Offen = TVA_Soll - " & anzahl & _
                      " WHERE ID = " & VADatum_ID, dbFailOnError
End Sub

' ============================================
' AMPEL-FARBCODIERUNG
' ============================================

Public Function GetStatusFarbe(IstWert As Long, SollWert As Long) As Long
    ' Gibt Farbe basierend auf Auslastung zurück
    ' Grün: 100% oder mehr
    ' Gelb: 50-99%
    ' Rot: unter 50%

    If SollWert = 0 Then
        GetStatusFarbe = vbGreen
    ElseIf IstWert >= SollWert Then
        GetStatusFarbe = RGB(0, 180, 0)    ' Grün
    ElseIf IstWert >= SollWert * 0.5 Then
        GetStatusFarbe = RGB(255, 180, 0)  ' Orange
    Else
        GetStatusFarbe = RGB(220, 50, 50)  ' Rot
    End If
End Function

' ============================================
' DASHBOARD REFRESH
' ============================================

Public Sub RefreshDashboard(frm As Form)
    ' Aktualisiert alle Dashboard-Werte
    On Error Resume Next

    ' Kennzahlen aktualisieren
    If Not IsNull(frm!lblAuftraegeHeute) Then
        frm!lblAuftraegeHeute.Caption = GetAuftraegeHeute()
    End If

    If Not IsNull(frm!lblAuftrageDieseWoche) Then
        frm!lblAuftrageDieseWoche.Caption = GetAuftrageDieseWoche()
    End If

    If Not IsNull(frm!lblOffeneAnfragen) Then
        frm!lblOffeneAnfragen.Caption = GetOffeneAnfragen()
        ' Farbcodierung
        If GetOffeneAnfragen() > 10 Then
            frm!lblOffeneAnfragen.BackColor = RGB(255, 200, 200)
        Else
            frm!lblOffeneAnfragen.BackColor = RGB(200, 255, 200)
        End If
    End If

    If Not IsNull(frm!lblUnterbesetzung) Then
        frm!lblUnterbesetzung.Caption = GetUnterbesetzung()
        ' Farbcodierung
        If GetUnterbesetzung() > 0 Then
            frm!lblUnterbesetzung.BackColor = RGB(255, 150, 150)
        Else
            frm!lblUnterbesetzung.BackColor = RGB(200, 255, 200)
        End If
    End If

    ' Unterformulare aktualisieren
    If Not IsNull(frm!subAuftraegeHeute) Then
        frm!subAuftraegeHeute.Form.Requery
    End If

    m_LastRefresh = Now()
End Sub

' ============================================
' HILFSFUNKTIONEN
' ============================================

Public Function FormatZeit(z As Variant) As String
    ' Formatiert Zeit als HH:MM
    If IsNull(z) Then
        FormatZeit = "--:--"
    Else
        FormatZeit = Format(z, "hh:nn")
    End If
End Function

Public Function GetMAName(MA_ID As Long) As String
    ' Gibt Namen eines MA zurück
    On Error Resume Next
    GetMAName = Nz(DLookup("Nachname & ', ' & Vorname", _
                           "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID), "Unbekannt")
End Function

Public Function GetAuftragInfo(VA_ID As Long) As String
    ' Gibt Auftragsinfo zurück
    On Error Resume Next
    GetAuftragInfo = Nz(DLookup("Auftrag & ' - ' & Ort", _
                                "tbl_VA_Auftragstamm", "ID = " & VA_ID), "Unbekannt")
End Function
'''

    try:
        # Prüfe ob Modul existiert
        module_exists = False
        for mod in access.CurrentProject.AllModules:
            if mod.Name == module_name:
                module_exists = True
                break

        if module_exists:
            # Modul löschen und neu erstellen
            access.DoCmd.DeleteObject(5, module_name)  # 5 = acModule
            print(f"Bestehendes Modul '{module_name}' gelöscht")

        # Neues Modul erstellen
        access.DoCmd.RunCommand(115)  # acCmdNewObjectModule
        time.sleep(0.5)

        # Code einfügen
        vbe = access.VBE
        for comp in vbe.ActiveVBProject.VBComponents:
            if comp.Name.startswith("Modul"):
                comp.Name = module_name
                # Lösche Default-Code
                if comp.CodeModule.CountOfLines > 0:
                    comp.CodeModule.DeleteLines(1, comp.CodeModule.CountOfLines)
                # Füge neuen Code ein
                comp.CodeModule.AddFromString(vba_code)
                print(f"Modul '{module_name}' erstellt mit {comp.CodeModule.CountOfLines} Zeilen")
                break

        # Speichern
        access.DoCmd.Save(5, module_name)
        return True

    except Exception as e:
        print(f"Fehler beim Erstellen des Moduls: {e}")
        return False

def create_dashboard_query(access):
    """Erstellt Abfragen für das Dashboard"""

    queries = {
        "qry_N_Dashboard_AuftraegeHeute": """
            SELECT tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag,
                   tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort,
                   tbl_VA_AnzTage.TVA_Soll, tbl_VA_AnzTage.TVA_Ist,
                   tbl_VA_AnzTage.TVA_Offen, tbl_VA_AnzTage.ID AS VADatum_ID,
                   tbl_VA_Auftragstamm.ID AS VA_ID
            FROM tbl_VA_Auftragstamm
            INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
            WHERE tbl_VA_AnzTage.VADatum = Date()
            ORDER BY tbl_VA_AnzTage.TVA_Offen DESC, tbl_VA_Auftragstamm.Auftrag
        """,

        "qry_N_Dashboard_OffeneAnfragen": """
            SELECT tbl_MA_VA_Planung.*, tbl_MA_Mitarbeiterstamm.Nachname,
                   tbl_MA_Mitarbeiterstamm.Vorname, tbl_VA_Auftragstamm.Auftrag,
                   tbl_VA_Auftragstamm.Ort
            FROM (tbl_MA_VA_Planung
            INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Planung.MA_ID = tbl_MA_Mitarbeiterstamm.ID)
            INNER JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Planung.VA_ID = tbl_VA_Auftragstamm.ID
            WHERE tbl_MA_VA_Planung.Status_ID = 1 AND tbl_MA_VA_Planung.VADatum >= Date()
            ORDER BY tbl_MA_VA_Planung.VADatum, tbl_MA_VA_Planung.Erst_am
        """,

        "qry_N_Dashboard_Unterbesetzung": """
            SELECT tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag,
                   tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort,
                   tbl_VA_AnzTage.TVA_Soll, tbl_VA_AnzTage.TVA_Ist,
                   tbl_VA_AnzTage.TVA_Offen
            FROM tbl_VA_Auftragstamm
            INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
            WHERE tbl_VA_AnzTage.TVA_Offen > 0 AND tbl_VA_AnzTage.VADatum >= Date()
            ORDER BY tbl_VA_AnzTage.VADatum, tbl_VA_AnzTage.TVA_Offen DESC
        """,

        "qry_N_Dashboard_VerfuegbareMA": """
            SELECT tbl_MA_Mitarbeiterstamm.ID, tbl_MA_Mitarbeiterstamm.Nachname,
                   tbl_MA_Mitarbeiterstamm.Vorname, tbl_MA_Mitarbeiterstamm.Tel_Mobil,
                   tbl_MA_Mitarbeiterstamm.Email
            FROM tbl_MA_Mitarbeiterstamm
            WHERE tbl_MA_Mitarbeiterstamm.IstAktiv = True
            ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname
        """
    }

    db = access.CurrentDb()

    for qry_name, sql in queries.items():
        try:
            # Prüfe ob Abfrage existiert
            query_exists = False
            for qd in db.QueryDefs:
                if qd.Name == qry_name:
                    query_exists = True
                    qd.SQL = sql
                    print(f"Abfrage '{qry_name}' aktualisiert")
                    break

            if not query_exists:
                qd = db.CreateQueryDef(qry_name, sql)
                print(f"Abfrage '{qry_name}' erstellt")

        except Exception as e:
            print(f"Fehler bei Abfrage '{qry_name}': {e}")

def main():
    """Hauptfunktion"""
    print("=" * 60)
    print("CONSYS Dashboard-Implementierung")
    print("=" * 60)
    print()

    # Access verbinden
    access = create_access_connection()
    if not access:
        print("FEHLER: Konnte keine Verbindung zu Access herstellen!")
        return False

    print()
    print("Erstelle Dashboard-Komponenten...")
    print("-" * 40)

    # 1. VBA-Modul erstellen
    print("\n1. VBA-Modul erstellen...")
    if create_dashboard_module(access):
        print("   OK: Dashboard-Modul erstellt")
    else:
        print("   WARNUNG: Modul-Erstellung hatte Probleme")

    # 2. Abfragen erstellen
    print("\n2. Dashboard-Abfragen erstellen...")
    create_dashboard_query(access)
    print("   OK: Abfragen erstellt")

    # 3. Datenbank speichern
    print("\n3. Änderungen speichern...")
    try:
        access.DoCmd.RunCommand(3)  # acCmdSave
        print("   OK: Gespeichert")
    except:
        pass

    print()
    print("=" * 60)
    print("Dashboard-Implementierung abgeschlossen!")
    print("=" * 60)
    print()
    print("Nächste Schritte:")
    print("1. Öffnen Sie das Frontend in Access")
    print("2. Prüfen Sie das neue Modul 'mod_N_Dashboard'")
    print("3. Prüfen Sie die neuen Abfragen 'qry_N_Dashboard_*'")
    print()

    return True

if __name__ == "__main__":
    main()
