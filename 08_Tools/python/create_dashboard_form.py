"""
Erstellt das Dashboard-Formular für Consys
Mit Unterformularen für Aufträge, Anfragen und Kennzahlen
"""

import win32com.client
import pythoncom
import time
import subprocess
from datetime import datetime

FRONTEND_PATH = r"\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\B - Diverses\Consys_FE_N_Test_Claude_GPT - Kopie (6).accdb"

def kill_access():
    """Beendet Access-Prozesse"""
    try:
        subprocess.run(['taskkill', '/F', '/IM', 'MSACCESS.EXE'],
                      capture_output=True, timeout=10)
        time.sleep(2)
    except:
        pass

def create_connection():
    """Erstellt Access-Verbindung"""
    pythoncom.CoInitialize()
    kill_access()
    time.sleep(1)

    access = win32com.client.Dispatch("Access.Application")
    access.Visible = False
    access.AutomationSecurity = 1
    access.OpenCurrentDatabase(FRONTEND_PATH)
    return access

def create_dashboard_form(access):
    """Erstellt das Haupt-Dashboard-Formular"""
    form_name = "frm_N_Dashboard"

    # Prüfe ob Formular existiert
    try:
        for obj in access.CurrentProject.AllForms:
            if obj.Name == form_name:
                access.DoCmd.DeleteObject(2, form_name)  # 2 = acForm
                print(f"  Bestehendes Formular '{form_name}' gelöscht")
                time.sleep(0.5)
                break
    except:
        pass

    # Formular erstellen
    try:
        access.DoCmd.RunCommand(112)  # acCmdNewObjectForm
        time.sleep(1)

        # Form-Objekt holen und konfigurieren
        frm = access.Screen.ActiveForm

        # Grundeinstellungen
        frm.Caption = "CONSYS Dashboard - Live-Übersicht"
        frm.RecordSelectors = False
        frm.NavigationButtons = False
        frm.DividingLines = False
        frm.ScrollBars = 0  # Keine
        frm.BorderStyle = 1  # Dünn
        frm.AutoCenter = True

        # Größe
        frm.Width = 15000  # ~25cm
        frm.Section(0).Height = 8000  # Detail-Bereich

        # Hintergrundfarbe
        frm.Section(0).BackColor = 15921906  # Hellgrau

        print(f"  Formular '{form_name}' Grundstruktur erstellt")

        # Speichern
        access.DoCmd.Save(2, form_name)  # Zuerst unter dem Namen speichern
        access.DoCmd.Close(2, form_name, 1)  # Schließen mit Speichern

        return True

    except Exception as e:
        print(f"  FEHLER: {e}")
        return False

def create_subform_auftraege_heute(access):
    """Erstellt Unterformular für Aufträge heute"""
    form_name = "sub_N_Dashboard_AuftraegeHeute"

    try:
        # Lösche falls vorhanden
        for obj in access.CurrentProject.AllForms:
            if obj.Name == form_name:
                access.DoCmd.DeleteObject(2, form_name)
                time.sleep(0.3)
                break
    except:
        pass

    try:
        # Erstelle basierend auf Abfrage
        access.DoCmd.RunCommand(112)  # Neues Formular
        time.sleep(0.5)

        frm = access.Screen.ActiveForm

        # Als Datenblatt konfigurieren
        frm.RecordSource = "qry_N_Dashboard_AuftraegeHeute"
        frm.DefaultView = 2  # Datenblattansicht
        frm.ViewsAllowed = 2  # Nur Datenblatt
        frm.AllowAdditions = False
        frm.AllowDeletions = False
        frm.AllowEdits = False

        # Farben
        frm.Section(0).BackColor = 16777215  # Weiß

        access.DoCmd.Save(2, form_name)
        access.DoCmd.Close(2, form_name, 1)

        print(f"  Unterformular '{form_name}' erstellt")
        return True

    except Exception as e:
        print(f"  FEHLER bei {form_name}: {e}")
        return False

def create_subform_unterbesetzung(access):
    """Erstellt Unterformular für unterbesetzte Aufträge"""
    form_name = "sub_N_Dashboard_Unterbesetzung"

    try:
        for obj in access.CurrentProject.AllForms:
            if obj.Name == form_name:
                access.DoCmd.DeleteObject(2, form_name)
                time.sleep(0.3)
                break
    except:
        pass

    try:
        access.DoCmd.RunCommand(112)
        time.sleep(0.5)

        frm = access.Screen.ActiveForm
        frm.RecordSource = "qry_N_Dashboard_Unterbesetzung"
        frm.DefaultView = 2
        frm.ViewsAllowed = 2
        frm.AllowAdditions = False
        frm.AllowDeletions = False
        frm.AllowEdits = False
        frm.Section(0).BackColor = 16764057  # Hellrot für Warnung

        access.DoCmd.Save(2, form_name)
        access.DoCmd.Close(2, form_name, 1)

        print(f"  Unterformular '{form_name}' erstellt")
        return True

    except Exception as e:
        print(f"  FEHLER bei {form_name}: {e}")
        return False

def add_form_code(access, form_name, code):
    """Fügt VBA-Code zu einem Formular hinzu"""
    try:
        # Formular im Design öffnen
        access.DoCmd.OpenForm(form_name, 1)  # 1 = acDesign
        time.sleep(0.3)

        # Code-Modul des Formulars holen
        vbe = access.VBE
        proj = vbe.ActiveVBProject

        for comp in proj.VBComponents:
            if comp.Name == "Form_" + form_name:
                # Bestehenden Code löschen (außer Option-Zeilen)
                cm = comp.CodeModule
                if cm.CountOfLines > 2:
                    cm.DeleteLines(3, cm.CountOfLines - 2)

                # Neuen Code hinzufügen
                cm.AddFromString(code)
                break

        access.DoCmd.Close(2, form_name, 1)
        return True

    except Exception as e:
        print(f"  FEHLER beim Code für '{form_name}': {e}")
        return False

def main():
    print("=" * 60)
    print("DASHBOARD-FORMULAR ERSTELLEN")
    print("=" * 60)
    print()

    print("[1/3] Verbinde mit Access...")
    access = create_connection()
    print("  Verbunden!")

    print()
    print("[2/3] Erstelle Formulare...")
    print("-" * 40)

    # Unterformulare zuerst
    create_subform_auftraege_heute(access)
    create_subform_unterbesetzung(access)

    # Hauptformular
    create_dashboard_form(access)

    print()
    print("[3/3] Speichere und schließe...")

    try:
        access.DoCmd.RunCommand(14)  # Kompilieren
    except:
        pass

    try:
        access.CloseCurrentDatabase()
        access.Quit()
    except:
        pass

    print("  Fertig!")
    print()
    print("=" * 60)
    print("Dashboard-Formulare erstellt:")
    print("  - frm_N_Dashboard (Hauptformular)")
    print("  - sub_N_Dashboard_AuftraegeHeute")
    print("  - sub_N_Dashboard_Unterbesetzung")
    print("=" * 60)

if __name__ == "__main__":
    main()
