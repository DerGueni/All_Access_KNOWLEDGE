#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
VBA Bridge Phase 2 - Test Script

Testet alle neuen Endpoints:
- Word-Integration
- PDF-Generierung
- Nummernkreis
- Ausweis

Verwendung:
    python test_vba_bridge_phase2.py
"""

import requests
import json
import sys

BASE_URL = 'http://localhost:5002'

def print_header(title):
    """Formatierter Test-Header"""
    print("\n" + "=" * 60)
    print(f"TEST: {title}")
    print("=" * 60)

def print_result(response):
    """Formatierte Response-Ausgabe"""
    print(f"Status: {response.status_code}")
    try:
        data = response.json()
        print(json.dumps(data, indent=2, ensure_ascii=False))
    except:
        print(response.text)
    print()

def test_status():
    """Test: Server-Status"""
    print_header("Server-Status")
    response = requests.get(f'{BASE_URL}/api/vba/status')
    print_result(response)

    if response.status_code == 200:
        data = response.json()
        if not data.get('access_connected'):
            print("⚠️  WARNING: Access nicht verbunden!")
            print("           Bitte Access öffnen mit 0_Consys_FE_Test.accdb")
            return False
    return True

def test_nummernkreis():
    """Test: Nummernkreis-System"""

    # Test 1: Aktuelle Nummer abrufen
    print_header("Nummernkreis - Aktuelle Nummer (ohne Inkrement)")
    response = requests.get(f'{BASE_URL}/api/vba/nummern/current/1')
    print_result(response)

    if response.status_code == 200:
        data = response.json()
        current_nummer = data.get('nummer', 0)
        print(f"✓ Aktuelle Rechnungsnummer: {current_nummer}")

    # Test 2: Nächste Nummer holen (mit Inkrement)
    print_header("Nummernkreis - Nächste Nummer (mit Inkrement)")
    response = requests.post(
        f'{BASE_URL}/api/vba/nummern/next',
        json={'id': 1}  # 1 = Rechnung
    )
    print_result(response)

    if response.status_code == 200:
        data = response.json()
        next_nummer = data.get('nummer', 0)
        print(f"✓ Nächste Rechnungsnummer: {next_nummer}")

        if next_nummer > current_nummer:
            print(f"✓ Inkrement erfolgreich: {current_nummer} → {next_nummer}")
        else:
            print(f"⚠️  WARNING: Keine Inkrement-Änderung festgestellt")

def test_word_integration():
    """Test: Word-Integration"""
    print_header("Word-Integration - Template füllen")

    response = requests.post(
        f'{BASE_URL}/api/vba/word/fill-template',
        json={
            'doc_nr': 1,
            'kun_ID': 123,
            'iRch_KopfID': 456
        }
    )
    print_result(response)

    if response.status_code == 200:
        print("✓ Word-Template erfolgreich gefüllt")
    else:
        print("✗ Fehler beim Füllen des Word-Templates")

def test_pdf_conversion():
    """Test: PDF-Generierung"""
    print_header("PDF-Generierung - Word zu PDF")

    # HINWEIS: Hier sollte ein echter Pfad zu einem Word-Dokument stehen
    test_word_path = "C:\\Temp\\Test_Dokument.docx"

    print(f"Test-Pfad: {test_word_path}")
    print("⚠️  HINWEIS: Test wird nur funktionieren wenn das Dokument existiert!")

    response = requests.post(
        f'{BASE_URL}/api/vba/pdf/convert',
        json={'word_path': test_word_path}
    )
    print_result(response)

    if response.status_code == 200:
        data = response.json()
        pdf_path = data.get('pdf_path')
        print(f"✓ PDF erstellt: {pdf_path}")
    else:
        print("✗ PDF-Konvertierung fehlgeschlagen (Dokument existiert vermutlich nicht)")

def test_ausweis_system():
    """Test: Ausweis-System"""

    # Test 1: Ausweis-Nummer vergeben
    print_header("Ausweis-System - Nummer vergeben")
    response = requests.post(
        f'{BASE_URL}/api/vba/ausweis/nummer',
        json={'MA_ID': 1}
    )
    print_result(response)

    if response.status_code == 200:
        data = response.json()
        ausweis_nr = data.get('ausweis_nr')
        print(f"✓ Ausweis-Nummer vergeben: {ausweis_nr}")

    # Test 2: Ausweis drucken
    print_header("Ausweis-System - Ausweis drucken")
    response = requests.post(
        f'{BASE_URL}/api/vba/ausweis/drucken',
        json={
            'MA_ID': 1,
            'drucker': 'Microsoft Print to PDF'  # Sicherer Standard-Drucker
        }
    )
    print_result(response)

    if response.status_code == 200:
        print("✓ Ausweis-Druck erfolgreich ausgelöst")
    else:
        print("✗ Ausweis-Druck fehlgeschlagen")

def test_vba_execute_generic():
    """Test: Allgemeiner VBA-Aufruf"""
    print_header("Allgemeiner VBA-Aufruf - TLookup")

    # Test TLookup-Funktion
    response = requests.post(
        f'{BASE_URL}/api/vba/execute',
        json={
            'function': 'TLookup',
            'args': ['Nachname', 'tbl_MA_Mitarbeiterstamm', 'ID = 1']
        }
    )
    print_result(response)

    if response.status_code == 200:
        data = response.json()
        result = data.get('result')
        print(f"✓ TLookup-Ergebnis: {result}")

def run_all_tests():
    """Führt alle Tests durch"""
    print("\n" + "╔" + "=" * 58 + "╗")
    print("║" + " " * 10 + "VBA BRIDGE PHASE 2 - TEST SUITE" + " " * 16 + "║")
    print("╚" + "=" * 58 + "╝")

    # Prüfe Server-Status zuerst
    if not test_status():
        print("\n⚠️  Server nicht erreichbar oder Access nicht verbunden!")
        print("   Bitte sicherstellen dass:")
        print("   1. VBA-Bridge Server läuft (python vba_bridge_server.py)")
        print("   2. Access geöffnet ist mit 0_Consys_FE_Test.accdb")
        sys.exit(1)

    # Führe Tests durch
    try:
        test_nummernkreis()
        test_word_integration()
        test_pdf_conversion()  # Wird fehlschlagen wenn Test-Dokument nicht existiert
        test_ausweis_system()
        test_vba_execute_generic()

        print("\n" + "=" * 60)
        print("✓ ALLE TESTS ABGESCHLOSSEN")
        print("=" * 60)

    except requests.exceptions.ConnectionError:
        print("\n✗ FEHLER: Server nicht erreichbar!")
        print("   Starte VBA-Bridge Server mit: python vba_bridge_server.py")
        sys.exit(1)
    except Exception as e:
        print(f"\n✗ FEHLER: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    run_all_tests()
