"""
Import und Ausführung des Claude Export Moduls in Access
=========================================================
Importiert mod_N_Claude_Export.bas in das Frontend und führt den Export aus.
"""

import win32com.client
import os
import time
import sys

# Pfade
PROJECT_PATH = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE"
ACCESS_DB = os.path.join(PROJECT_PATH, "0_Consys_FE_Test.accdb")
VBA_MODULE = os.path.join(PROJECT_PATH, "01_VBA", "mod_N_Claude_Export.bas")
EXPORT_FOLDER = os.path.join(PROJECT_PATH, "exports", "claude")

def main():
    print("=" * 60)
    print("CLAUDE EXPORT - VBA Modul Import und Ausführung")
    print("=" * 60)
    
    # Prüfen ob Dateien existieren
    if not os.path.exists(ACCESS_DB):
        print(f"FEHLER: Access-Datenbank nicht gefunden: {ACCESS_DB}")
        return False
    
    if not os.path.exists(VBA_MODULE):
        print(f"FEHLER: VBA-Modul nicht gefunden: {VBA_MODULE}")
        return False
    
    print(f"\nAccess DB: {ACCESS_DB}")
    print(f"VBA Modul: {VBA_MODULE}")
    
    # Export-Ordner erstellen
    os.makedirs(EXPORT_FOLDER, exist_ok=True)
    print(f"Export-Ordner: {EXPORT_FOLDER}")
    
    try:
        # Access starten
        print("\n>>> Access wird gestartet...")
        access = win32com.client.Dispatch("Access.Application")
        access.Visible = True
        
        # Datenbank öffnen
        print(">>> Datenbank wird geöffnet...")
        access.OpenCurrentDatabase(ACCESS_DB)
        time.sleep(2)
        
        # VBA-Projekt zugreifen
        print(">>> VBA-Projekt wird geladen...")
        vbProject = access.VBE.ActiveVBProject
        
        # Prüfen ob Modul bereits existiert
        moduleExists = False
        moduleName = "mod_N_Claude_Export"
        
        for comp in vbProject.VBComponents:
            if comp.Name == moduleName:
                moduleExists = True
                print(f"    Modul '{moduleName}' existiert bereits - wird aktualisiert")
                # Altes Modul entfernen
                vbProject.VBComponents.Remove(comp)
                time.sleep(1)
                break
        
        # Neues Modul importieren
        print(f">>> Modul '{moduleName}' wird importiert...")
        vbProject.VBComponents.Import(VBA_MODULE)
        time.sleep(1)
        
        # VBA kompilieren
        print(">>> VBA wird kompiliert...")
        access.DoCmd.RunCommand(14)  # acCmdCompileAllModules
        time.sleep(1)
        
        # Export-Funktion ausführen
        print("\n>>> EXPORT WIRD GESTARTET...")
        print("-" * 40)
        
        # Macro ausführen
        access.Run("ExportAllesFuerClaude")
        
        print("-" * 40)
        print("\n>>> EXPORT ABGESCHLOSSEN!")
        
        # Warten auf Benutzer-Bestätigung (MsgBox in Access)
        print("\n[Bitte die MsgBox in Access bestätigen]")
        
        # Ergebnis prüfen
        time.sleep(3)
        
        # Dateien zählen
        if os.path.exists(EXPORT_FOLDER):
            formular_folder = os.path.join(EXPORT_FOLDER, "formulare")
            vba_folder = os.path.join(EXPORT_FOLDER, "vba")
            
            form_count = 0
            vba_count = 0
            
            if os.path.exists(formular_folder):
                form_count = len([f for f in os.listdir(formular_folder) if f.endswith('.json')])
            
            if os.path.exists(vba_folder):
                vba_count = len([f for f in os.listdir(vba_folder) if f.endswith(('.bas', '.cls'))])
            
            print(f"\n✅ Export erfolgreich!")
            print(f"   Formulare: {form_count}")
            print(f"   VBA-Module: {vba_count}")
            print(f"   Pfad: {EXPORT_FOLDER}")
        
        return True
        
    except Exception as e:
        print(f"\n❌ FEHLER: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    finally:
        # Access nicht schließen - Benutzer soll Ergebnis sehen
        print("\n[Access bleibt offen für Überprüfung]")


if __name__ == "__main__":
    success = main()
    print("\n" + "=" * 60)
    if success:
        print("FERTIG - Export-Dateien können jetzt verwendet werden")
    else:
        print("FEHLER - Bitte Fehlermeldungen prüfen")
    print("=" * 60)
