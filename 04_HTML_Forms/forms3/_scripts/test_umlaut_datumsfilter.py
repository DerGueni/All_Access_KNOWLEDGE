# -*- coding: utf-8 -*-
"""
Test-Skript für Umlaut-Korrektur und Datumsfilter
Testet die API-Endpoints auf korrekte UTF-8 Kodierung und Datumsfilterung
"""

import requests
import json
from datetime import datetime, timedelta

API_BASE = "http://localhost:5000"

def test_umlaut():
    """Testet ob Umlaute korrekt übertragen werden"""
    print("\n" + "="*60)
    print("TEST 1: Umlaut-Kodierung")
    print("="*60)

    try:
        response = requests.get(f"{API_BASE}/api/auftraege", params={"limit": 10})
        response.encoding = 'utf-8'  # Explizit UTF-8

        if response.status_code == 200:
            data = response.json()

            if data.get('success'):
                print(f"✓ API erreichbar, {len(data['data'])} Aufträge geladen")

                # Prüfe auf Umlaute
                umlaut_gefunden = False
                for auftrag in data['data'][:5]:  # Erste 5 Aufträge
                    ort = auftrag.get('Ort', '')
                    objekt = auftrag.get('Objekt', '')
                    auftrag_name = auftrag.get('Auftrag', '')

                    # Zeige Beispiele an
                    if any(c in ort for c in 'äöüÄÖÜß'):
                        print(f"✓ Umlaut in Ort gefunden: {ort}")
                        umlaut_gefunden = True
                    if any(c in objekt for c in 'äöüÄÖÜß'):
                        print(f"✓ Umlaut in Objekt gefunden: {objekt}")
                        umlaut_gefunden = True
                    if any(c in auftrag_name for c in 'äöüÄÖÜß'):
                        print(f"✓ Umlaut in Auftrag gefunden: {auftrag_name}")
                        umlaut_gefunden = True

                if not umlaut_gefunden:
                    print("⚠ Keine Umlaute in den ersten 5 Aufträgen gefunden")
                    print("   (Das ist OK wenn die Daten keine Umlaute enthalten)")
            else:
                print(f"✗ API-Fehler: {data.get('error')}")
        else:
            print(f"✗ HTTP-Fehler {response.status_code}")

    except Exception as e:
        print(f"✗ Fehler beim Verbinden: {e}")


def test_datumsfilter():
    """Testet ob der Datumsfilter funktioniert"""
    print("\n" + "="*60)
    print("TEST 2: Datumsfilter")
    print("="*60)

    try:
        # Test 1: Ohne Datumsfilter
        response1 = requests.get(f"{API_BASE}/api/auftraege", params={"limit": 100})

        if response1.status_code == 200:
            data1 = response1.json()
            count_ohne_filter = len(data1['data'])
            print(f"✓ Ohne Filter: {count_ohne_filter} Aufträge")

        # Test 2: Mit Datumsfilter (heute)
        heute = datetime.now().strftime('%Y-%m-%d')
        response2 = requests.get(f"{API_BASE}/api/auftraege", params={"limit": 100, "ab": heute})

        if response2.status_code == 200:
            data2 = response2.json()
            count_mit_filter = len(data2['data'])
            print(f"✓ Mit Filter (ab {heute}): {count_mit_filter} Aufträge")

            # Prüfe ob Filterung wirkt
            if count_mit_filter <= count_ohne_filter:
                print(f"✓ Filter funktioniert (reduziert von {count_ohne_filter} auf {count_mit_filter})")

                # Prüfe ob alle Aufträge >= heute
                alle_korrekt = True
                for auftrag in data2['data'][:5]:
                    dat_von = auftrag.get('Dat_VA_Von', '')
                    if dat_von:
                        print(f"  - Auftrag {auftrag.get('ID')}: Datum={dat_von}")
                        if dat_von < heute:
                            print(f"    ✗ Datum liegt VOR Filter-Datum!")
                            alle_korrekt = False

                if alle_korrekt:
                    print("✓ Alle angezeigten Aufträge sind >= Filter-Datum")
            else:
                print(f"⚠ Filter scheint nicht zu funktionieren (mehr Ergebnisse MIT Filter)")

        # Test 3: Mit Datumsfilter (in 30 Tagen)
        zukunft = (datetime.now() + timedelta(days=30)).strftime('%Y-%m-%d')
        response3 = requests.get(f"{API_BASE}/api/auftraege", params={"limit": 100, "ab": zukunft})

        if response3.status_code == 200:
            data3 = response3.json()
            count_zukunft = len(data3['data'])
            print(f"✓ Mit Filter (ab {zukunft}): {count_zukunft} Aufträge")

            if count_zukunft < count_ohne_filter:
                print(f"✓ Zukunfts-Filter funktioniert (reduziert auf {count_zukunft})")

    except Exception as e:
        print(f"✗ Fehler beim Testen: {e}")


def test_api_health():
    """Testet ob die API erreichbar ist"""
    print("\n" + "="*60)
    print("TEST 0: API Health Check")
    print("="*60)

    try:
        response = requests.get(f"{API_BASE}/api/health", timeout=5)

        if response.status_code == 200:
            data = response.json()
            print(f"✓ API ist erreichbar")
            print(f"  Status: {data.get('status')}")
            print(f"  Zeit: {data.get('timestamp')}")
            return True
        else:
            print(f"✗ API antwortet mit HTTP {response.status_code}")
            return False

    except requests.exceptions.ConnectionError:
        print(f"✗ API ist nicht erreichbar!")
        print(f"  Bitte starten: python mini_api.py")
        return False
    except Exception as e:
        print(f"✗ Fehler: {e}")
        return False


if __name__ == '__main__':
    print("\n" + "="*60)
    print("MINI-API TEST-SUITE")
    print("="*60)
    print(f"API-Basis: {API_BASE}")
    print(f"Datum: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

    # Prüfe zuerst ob API läuft
    if test_api_health():
        test_umlaut()
        test_datumsfilter()

    print("\n" + "="*60)
    print("TESTS ABGESCHLOSSEN")
    print("="*60 + "\n")
