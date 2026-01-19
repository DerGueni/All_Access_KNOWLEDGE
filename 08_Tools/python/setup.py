"""
Setup-Script für Access Bridge Installation
Installiert alle benötigten Abhängigkeiten
"""

import subprocess
import sys
import os

def install_package(package):
    """Installiert Python-Paket via pip"""
    print(f"Installiere {package}...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
        print(f"✓ {package} erfolgreich installiert")
        return True
    except subprocess.CalledProcessError:
        print(f"✗ Fehler bei Installation von {package}")
        return False

def check_package(package):
    """Prüft ob Paket installiert ist"""
    try:
        __import__(package)
        return True
    except ImportError:
        return False

def main():
    print("="*60)
    print("ACCESS BRIDGE - SETUP")
    print("="*60)
    
    # Benötigte Pakete
    packages = {
        'pywin32': 'pywin32',
        'pyodbc': 'pyodbc',
        'win32com.client': 'pywin32'  # Teil von pywin32
    }
    
    print("\nPrüfe installierte Pakete...")
    
    to_install = set()
    for import_name, package_name in packages.items():
        if check_package(import_name.split('.')[0]):
            print(f"✓ {package_name} ist installiert")
        else:
            print(f"✗ {package_name} fehlt")
            to_install.add(package_name)
    
    if to_install:
        print(f"\nInstalliere fehlende Pakete: {', '.join(to_install)}")
        for package in to_install:
            install_package(package)
    else:
        print("\n✓ Alle benötigten Pakete sind installiert")
    
    # Verzeichnisse erstellen
    print("\nErstelle Verzeichnisse...")
    
    base_path = os.path.dirname(os.path.abspath(__file__))
    dirs = [
        os.path.join(base_path, "backups"),
        os.path.join(base_path, "exports"),
        os.path.join(base_path, "logs")
    ]
    
    for dir_path in dirs:
        os.makedirs(dir_path, exist_ok=True)
        print(f"✓ {dir_path}")
    
    # VBA-Modul Info
    print("\n" + "="*60)
    print("WICHTIG - VBA-MODUL IMPORTIEREN")
    print("="*60)
    print("\nFühre folgende Schritte in Access durch:")
    print("1. Öffne die Datenbank")
    print("2. Drücke ALT+F11 für VBA-Editor")
    print("3. Menü: Datei -> Datei importieren")
    print("4. Wähle: BridgeCommunication.bas")
    print("5. Führe aus: InitializeBridge")
    print("\nDanach ist die Bridge einsatzbereit!")
    
    print("\n" + "="*60)
    print("SETUP ABGESCHLOSSEN")
    print("="*60)
    
    print("\nTeste Installation mit:")
    print("  python quick_start.py")

if __name__ == "__main__":
    main()
