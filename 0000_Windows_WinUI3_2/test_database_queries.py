"""
Test-Skript für ConsysWinUI Datenbankabfragen
Prüft ob alle SQL-Queries korrekt funktionieren
"""

import pyodbc
import sys
from datetime import datetime

# Connection String für Access Backend
BACKEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb"
CONN_STRING = f"Driver={{Microsoft Access Driver (*.mdb, *.accdb)}};DBQ={BACKEND_PATH};"

def test_connection():
    """Teste Datenbankverbindung"""
    print("=" * 60)
    print("TEST: Datenbankverbindung")
    print("=" * 60)
    try:
        conn = pyodbc.connect(CONN_STRING)
        print(f"[OK] Verbindung zu {BACKEND_PATH} erfolgreich")
        conn.close()
        return True
    except Exception as e:
        print(f"[FEHLER] Verbindung fehlgeschlagen: {e}")
        return False

def test_mitarbeiter():
    """Teste Mitarbeiterstamm-Abfragen"""
    print("\n" + "=" * 60)
    print("TEST: Mitarbeiterstamm (tbl_MA_Mitarbeiterstamm)")
    print("=" * 60)

    conn = pyodbc.connect(CONN_STRING)
    cursor = conn.cursor()

    # Liste laden
    try:
        cursor.execute("""
            SELECT MA_ID, MA_Nachname, MA_Vorname, IstAktiv, Tel_Mobil, Email
            FROM tbl_MA_Mitarbeiterstamm
            WHERE IstAktiv = True
            ORDER BY MA_Nachname, MA_Vorname
        """)
        rows = cursor.fetchall()
        print(f"[OK] {len(rows)} aktive Mitarbeiter gefunden")
        if rows:
            print(f"     Erster: {rows[0].MA_Nachname}, {rows[0].MA_Vorname}")
    except Exception as e:
        print(f"[FEHLER] Liste laden: {e}")

    # Einzelnen Mitarbeiter laden
    try:
        cursor.execute("""
            SELECT MA_ID, MA_Nachname, MA_Vorname, IstAktiv,
                   Strasse, PLZ, Ort, Tel_Mobil, Tel_Privat, Email
            FROM tbl_MA_Mitarbeiterstamm
            WHERE MA_ID = 1
        """)
        row = cursor.fetchone()
        if row:
            print(f"[OK] Einzelner MA geladen: ID={row.MA_ID}, {row.MA_Nachname}")
        else:
            print("[INFO] MA_ID=1 nicht gefunden, versuche ersten Datensatz")
            cursor.execute("SELECT TOP 1 MA_ID FROM tbl_MA_Mitarbeiterstamm")
            first = cursor.fetchone()
            if first:
                print(f"[INFO] Erster MA hat ID={first.MA_ID}")
    except Exception as e:
        print(f"[FEHLER] Einzeln laden: {e}")

    conn.close()

def test_kunden():
    """Teste Kundenstamm-Abfragen"""
    print("\n" + "=" * 60)
    print("TEST: Kundenstamm (tbl_KD_Kundenstamm)")
    print("=" * 60)

    conn = pyodbc.connect(CONN_STRING)
    cursor = conn.cursor()

    # Felder prüfen
    try:
        cursor.execute("SELECT TOP 1 * FROM tbl_KD_Kundenstamm")
        columns = [desc[0] for desc in cursor.description]
        print(f"[OK] Tabelle hat {len(columns)} Spalten")

        # Wichtige Felder prüfen
        required = ['kun_Id', 'kun_Firma', 'kun_IstAktiv']
        optional = ['kun_Kontakt_Nachname', 'kun_Kontakt_Vorname']

        for field in required:
            if field in columns:
                print(f"[OK] Feld '{field}' vorhanden")
            else:
                print(f"[FEHLER] Pflichtfeld '{field}' fehlt!")

        for field in optional:
            if field in columns:
                print(f"[OK] Feld '{field}' vorhanden")
            else:
                print(f"[WARNUNG] Optionales Feld '{field}' fehlt")

    except Exception as e:
        print(f"[FEHLER] Tabelle prüfen: {e}")

    # Liste laden
    try:
        cursor.execute("""
            SELECT kun_Id, kun_Firma, kun_IstAktiv
            FROM tbl_KD_Kundenstamm
            ORDER BY kun_Firma
        """)
        rows = cursor.fetchall()
        print(f"[OK] {len(rows)} Kunden gefunden")
    except Exception as e:
        print(f"[FEHLER] Liste laden: {e}")

    conn.close()

def test_objekte():
    """Teste Objektstamm-Abfragen"""
    print("\n" + "=" * 60)
    print("TEST: Objektstamm (tbl_OB_Objektstamm)")
    print("=" * 60)

    conn = pyodbc.connect(CONN_STRING)
    cursor = conn.cursor()

    # Tabelle und Felder prüfen
    try:
        cursor.execute("SELECT TOP 1 * FROM tbl_OB_Objektstamm")
        columns = [desc[0] for desc in cursor.description]
        print(f"[OK] Tabelle tbl_OB_Objektstamm existiert mit {len(columns)} Spalten")
        print(f"     Spalten: {', '.join(columns[:10])}...")

        # Feldnamen prüfen (korrigiert)
        check_fields = ['Objekt_ID', 'Objektname', 'IstAktiv', 'Strasse', 'PLZ', 'Ort', 'Kunde_ID']
        for field in check_fields:
            if field in columns:
                print(f"[OK] Feld '{field}' vorhanden")
            else:
                # Alternative Namen prüfen
                alt_names = {
                    'Objektname': ['Objekt', 'Name', 'ObjektName'],
                    'Strasse': ['Objekt_Strasse', 'Straße'],
                    'Kunde_ID': ['Veranstalter_ID', 'KundeID']
                }
                found = False
                if field in alt_names:
                    for alt in alt_names[field]:
                        if alt in columns:
                            print(f"[WARNUNG] '{field}' heißt tatsächlich '{alt}'")
                            found = True
                            break
                if not found:
                    print(f"[FEHLER] Feld '{field}' nicht gefunden!")

    except pyodbc.Error as e:
        if 'tbl_OB_Objektstamm' in str(e):
            print("[FEHLER] Tabelle tbl_OB_Objektstamm existiert nicht!")
            # Alternative prüfen
            try:
                cursor.execute("SELECT TOP 1 * FROM tbl_OB_Objekt")
                print("[INFO] Tabelle heißt 'tbl_OB_Objekt' statt 'tbl_OB_Objektstamm'")
            except:
                print("[FEHLER] Auch tbl_OB_Objekt nicht gefunden!")
        else:
            print(f"[FEHLER] {e}")

    conn.close()

def test_auftraege():
    """Teste Auftragstamm-Abfragen"""
    print("\n" + "=" * 60)
    print("TEST: Auftragstamm (tbl_VA_Auftragstamm)")
    print("=" * 60)

    conn = pyodbc.connect(CONN_STRING)
    cursor = conn.cursor()

    # Felder prüfen
    try:
        cursor.execute("SELECT TOP 1 * FROM tbl_VA_Auftragstamm")
        columns = [desc[0] for desc in cursor.description]
        print(f"[OK] Tabelle hat {len(columns)} Spalten")
        print(f"     Erste 10: {', '.join(columns[:10])}")

        # Berechnete Felder NICHT in Tabelle
        calc_fields = ['AnzahlTage', 'AnzahlSchichten', 'MA_Anzahl_Gesamt', 'MA_Anzahl_Ist']
        for field in calc_fields:
            if field in columns:
                print(f"[INFO] '{field}' ist in Tabelle (nicht berechnet)")
            else:
                print(f"[OK] '{field}' muss berechnet werden")

    except Exception as e:
        print(f"[FEHLER] {e}")

    # AnzahlTage berechnen testen
    try:
        cursor.execute("SELECT TOP 1 VA_ID FROM tbl_VA_Auftragstamm")
        row = cursor.fetchone()
        if row:
            va_id = row.VA_ID

            # AnzahlTage aus tbl_VA_AnzTage
            cursor.execute(f"SELECT COUNT(*) FROM tbl_VA_AnzTage WHERE VA_ID = {va_id}")
            anz_tage = cursor.fetchone()[0]
            print(f"[OK] AnzahlTage für VA_ID={va_id}: {anz_tage}")

            # AnzahlSchichten aus tbl_VA_Start
            cursor.execute(f"SELECT COUNT(*) FROM tbl_VA_Start WHERE VA_ID = {va_id}")
            anz_schichten = cursor.fetchone()[0]
            print(f"[OK] AnzahlSchichten für VA_ID={va_id}: {anz_schichten}")

    except Exception as e:
        print(f"[FEHLER] Berechnete Felder: {e}")

    conn.close()

def test_bewerber():
    """Teste Bewerber-Abfragen"""
    print("\n" + "=" * 60)
    print("TEST: Bewerber (tbl_MA_Bewerber)")
    print("=" * 60)

    conn = pyodbc.connect(CONN_STRING)
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT TOP 1 * FROM tbl_MA_Bewerber")
        columns = [desc[0] for desc in cursor.description]
        print(f"[OK] Tabelle tbl_MA_Bewerber existiert mit {len(columns)} Spalten")
        print(f"     Spalten: {', '.join(columns)}")
    except pyodbc.Error as e:
        if 'tbl_MA_Bewerber' in str(e):
            print("[WARNUNG] Tabelle tbl_MA_Bewerber existiert nicht (Demo-Modus)")
        else:
            print(f"[FEHLER] {e}")

    conn.close()

def test_abwesenheit():
    """Teste Abwesenheit-Abfragen"""
    print("\n" + "=" * 60)
    print("TEST: Abwesenheit (tbl_MA_NVerfuegZeiten)")
    print("=" * 60)

    conn = pyodbc.connect(CONN_STRING)
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT COUNT(*) FROM tbl_MA_NVerfuegZeiten
        """)
        count = cursor.fetchone()[0]
        print(f"[OK] {count} Abwesenheitseinträge gefunden")

        # Gründe prüfen
        cursor.execute("SELECT COUNT(*) FROM tbl_MA_NV_Gruende")
        gruende = cursor.fetchone()[0]
        print(f"[OK] {gruende} Abwesenheitsgründe definiert")

    except Exception as e:
        print(f"[FEHLER] {e}")

    conn.close()

def test_zeitkonten():
    """Teste Zeitkonten-Abfragen"""
    print("\n" + "=" * 60)
    print("TEST: Zeitkonten (tbl_MA_Zeitkonto, tbl_MA_ZK_Buchungen)")
    print("=" * 60)

    conn = pyodbc.connect(CONN_STRING)
    cursor = conn.cursor()

    try:
        # Zeitkonto
        cursor.execute("SELECT TOP 1 * FROM tbl_MA_Zeitkonto")
        columns = [desc[0] for desc in cursor.description]
        print(f"[OK] tbl_MA_Zeitkonto: {len(columns)} Spalten")
    except Exception as e:
        print(f"[WARNUNG] tbl_MA_Zeitkonto: {e}")

    try:
        # Buchungen
        cursor.execute("SELECT TOP 1 * FROM tbl_MA_ZK_Buchungen")
        columns = [desc[0] for desc in cursor.description]
        print(f"[OK] tbl_MA_ZK_Buchungen: {len(columns)} Spalten")
    except Exception as e:
        print(f"[WARNUNG] tbl_MA_ZK_Buchungen: {e}")

    conn.close()

def test_dienstplan():
    """Teste Dienstplan-Abfragen"""
    print("\n" + "=" * 60)
    print("TEST: Dienstplan (tbl_MA_VA_Planung, tbl_VA_Start)")
    print("=" * 60)

    conn = pyodbc.connect(CONN_STRING)
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT COUNT(*) FROM tbl_MA_VA_Planung
        """)
        count = cursor.fetchone()[0]
        print(f"[OK] {count} Planungseinträge in tbl_MA_VA_Planung")

        cursor.execute("""
            SELECT COUNT(*) FROM tbl_VA_Start
        """)
        count = cursor.fetchone()[0]
        print(f"[OK] {count} Schichten in tbl_VA_Start")

    except Exception as e:
        print(f"[FEHLER] {e}")

    conn.close()

def main():
    print("\n" + "=" * 60)
    print("ConsysWinUI - Datenbank-Testlauf")
    print(f"Zeitpunkt: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)

    if not test_connection():
        print("\n[ABBRUCH] Keine Datenbankverbindung möglich!")
        sys.exit(1)

    test_mitarbeiter()
    test_kunden()
    test_objekte()
    test_auftraege()
    test_bewerber()
    test_abwesenheit()
    test_zeitkonten()
    test_dienstplan()

    print("\n" + "=" * 60)
    print("TESTLAUF ABGESCHLOSSEN")
    print("=" * 60)

if __name__ == "__main__":
    main()
