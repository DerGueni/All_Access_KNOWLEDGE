# -*- coding: utf-8 -*-
"""
Test-Script für VBA Bridge Server Button-Endpoints
Testet die neuen Endpoints: namensliste-ess, el-drucken, el-senden
"""

import requests
import json

BASE_URL = "http://localhost:5002/api/vba"

def test_health():
    """Test: Server Health-Check"""
    print("\n=== TEST: Health-Check ===")
    try:
        response = requests.get("http://localhost:5002/api/health", timeout=5)
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"FEHLER: {e}")
        return False

def test_status():
    """Test: Server Status und Access-Verbindung"""
    print("\n=== TEST: Server Status ===")
    try:
        response = requests.get(f"{BASE_URL}/status", timeout=5)
        print(f"Status: {response.status_code}")
        data = response.json()
        print(json.dumps(data, indent=2))

        if not data.get("access_connected"):
            print("\n[WARNUNG] Access ist nicht verbunden!")
            print("   Bitte oeffne 0_Consys_FE_Test.accdb")
            return False

        print(f"\n[OK] Access verbunden: {data['access_database']}")
        return True
    except Exception as e:
        print(f"FEHLER: {e}")
        return False

def test_namensliste_ess(va_id=None, ma_id=0, kun_id=0):
    """Test: Namensliste ESS erstellen"""
    print("\n=== TEST: Namensliste ESS ===")

    if va_id is None:
        print("INFO: Kein VA_ID angegeben - Test wird übersprungen")
        print("      Verwendung: test_namensliste_ess(va_id=12345, kun_id=456)")
        return None

    try:
        payload = {
            "VA_ID": va_id,
            "MA_ID": ma_id,
            "kun_ID": kun_id
        }
        print(f"Request: {json.dumps(payload, indent=2)}")

        response = requests.post(f"{BASE_URL}/namensliste-ess",
                                json=payload,
                                timeout=30)

        print(f"Status: {response.status_code}")
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")

        if data.get("success"):
            print("\n[OK] Namensliste ESS erfolgreich erstellt")
            return True
        else:
            print(f"\n[FEHLER] {data.get('error')}")
            return False

    except requests.Timeout:
        print("FEHLER: Timeout (>30s) - VBA-Funktion dauert zu lange")
        return False
    except Exception as e:
        print(f"FEHLER: {e}")
        return False

def test_el_drucken(va_id=None, vadatum_id=0):
    """Test: Einsatzliste drucken"""
    print("\n=== TEST: EL drucken ===")

    if va_id is None:
        print("INFO: Kein va_id angegeben - Test wird übersprungen")
        print("      Verwendung: test_el_drucken(va_id=12345)")
        return None

    try:
        payload = {
            "va_id": va_id,
            "vadatum_id": vadatum_id
        }
        print(f"Request: {json.dumps(payload, indent=2)}")

        response = requests.post(f"{BASE_URL}/el-drucken",
                                json=payload,
                                timeout=60)

        print(f"Status: {response.status_code}")
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")

        if data.get("success"):
            print("\n[OK] Einsatzliste erfolgreich gedruckt")
            return True
        else:
            print(f"\n[FEHLER] {data.get('error')}")
            return False

    except requests.Timeout:
        print("FEHLER: Timeout (>60s) - Excel-Export dauert zu lange")
        return False
    except Exception as e:
        print(f"FEHLER: {e}")
        return False

def test_el_senden(va_id=None, vadatum_id=0):
    """Test: Einsatzliste senden"""
    print("\n=== TEST: EL senden ===")

    if va_id is None:
        print("INFO: Kein va_id angegeben - Test wird übersprungen")
        print("      Verwendung: test_el_senden(va_id=12345)")
        return None

    try:
        payload = {
            "va_id": va_id,
            "vadatum_id": vadatum_id
        }
        print(f"Request: {json.dumps(payload, indent=2)}")

        response = requests.post(f"{BASE_URL}/el-senden",
                                json=payload,
                                timeout=120)

        print(f"Status: {response.status_code}")
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")

        if data.get("success"):
            print("\n[OK] Einsatzliste erfolgreich gesendet")
            return True
        else:
            print(f"\n[FEHLER] {data.get('error')}")
            return False

    except requests.Timeout:
        print("FEHLER: Timeout (>120s) - E-Mail-Versand dauert zu lange")
        return False
    except Exception as e:
        print(f"FEHLER: {e}")
        return False

def run_all_tests(va_id=None, kun_id=0):
    """Führt alle Tests aus"""
    print("=" * 60)
    print("VBA BRIDGE SERVER - BUTTON ENDPOINTS TEST")
    print("=" * 60)

    results = {}

    # 1. Health-Check
    results['health'] = test_health()

    # 2. Status-Check
    results['status'] = test_status()

    if not results['status']:
        print("\n[ABBRUCH] Server oder Access nicht verfuegbar")
        return results

    # 3. Namensliste ESS (nur wenn VA_ID angegeben)
    if va_id:
        results['namensliste'] = test_namensliste_ess(va_id, kun_id=kun_id)
        results['el_drucken'] = test_el_drucken(va_id)
        # EL senden auskommentiert (versendet echte E-Mails!)
        # results['el_senden'] = test_el_senden(va_id)
    else:
        print("\n" + "=" * 60)
        print("INFO: Keine VA_ID angegeben - Funktions-Tests übersprungen")
        print("Verwendung:")
        print("  python test_button_endpoints.py")
        print("  >>> run_all_tests(va_id=12345, kun_id=456)")
        print("=" * 60)

    # Zusammenfassung
    print("\n" + "=" * 60)
    print("TEST-ZUSAMMENFASSUNG")
    print("=" * 60)

    for test_name, result in results.items():
        if result is None:
            status = "[UEBERSPRUNGEN]"
        elif result:
            status = "[OK]"
        else:
            status = "[FEHLER]"
        print(f"{test_name:20s} : {status}")

    print("=" * 60)

    return results

if __name__ == "__main__":
    # Basis-Tests (ohne VA_ID)
    run_all_tests()

    # MANUELL MIT VA_ID TESTEN:
    # Uncomment und anpassen:
    # run_all_tests(va_id=12345, kun_id=456)
