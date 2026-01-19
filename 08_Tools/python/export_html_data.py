# -*- coding: utf-8 -*-
"""
HTML Data Export - Exportiert alle Daten fuer HTML-Formulare
=============================================================
Mit Logging und optionaler gzip-Kompression

Aufruf:
  python export_html_data.py          # Normaler Export
  python export_html_data.py --gzip   # Mit gzip-Kompression
"""

import json
import os
import sys
import gzip
import logging
import pyodbc
from datetime import datetime, date, time
from decimal import Decimal

# Pfade - Backend direkt verwenden
BACKEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb"
EXPORT_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\data"
LOG_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\logs"

# Kommandozeilen-Parameter
USE_GZIP = '--gzip' in sys.argv

# Verbindungsstring
CONN_STR = f"DRIVER={{Microsoft Access Driver (*.mdb, *.accdb)}};DBQ={BACKEND_PATH};"

# ============================================================
# LOGGING SETUP
# ============================================================

os.makedirs(LOG_PATH, exist_ok=True)
log_file = os.path.join(LOG_PATH, f"export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log")

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[
        logging.FileHandler(log_file, encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Statistik-Zaehler
export_stats = {
    "total_files": 0,
    "total_records": 0,
    "errors": 0,
    "start_time": None,
    "end_time": None
}


def json_serial(obj):
    """JSON serializer fuer spezielle Objekte"""
    if isinstance(obj, (datetime, date)):
        return obj.strftime("%d.%m.%Y")
    if isinstance(obj, time):
        return obj.strftime("%H:%M")
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, bytes):
        return None
    raise TypeError(f"Type {type(obj)} not serializable")


def is_time_field(col_name):
    """Prüft ob ein Feld ein Zeit-Feld ist (anhand des Namens)"""
    time_indicators = ['_Start', '_Ende', 'Start', 'Ende', 'Zeit', 'von', 'bis', 'Time']
    col_lower = col_name.lower()
    return any(ind.lower() in col_lower for ind in time_indicators)


def format_datetime_value(val, col_name):
    """Formatiert datetime-Werte intelligent als Datum oder Uhrzeit"""
    if val is None:
        return None

    if isinstance(val, time):
        return val.strftime("%H:%M")

    if isinstance(val, datetime):
        # Prüfe ob es ein Access-Null-Datum ist (30.12.1899 oder 31.12.1899)
        # Diese werden für reine Zeit-Werte verwendet
        if val.year in (1899, 1900) and val.month == 12 and val.day in (30, 31):
            # Es ist ein reiner Zeit-Wert
            if val.hour == 0 and val.minute == 0 and val.second == 0:
                return None  # Keine Zeit gesetzt
            return val.strftime("%H:%M")

        # Prüfe anhand des Feldnamens ob es ein Zeit-Feld ist
        if is_time_field(col_name):
            # Extrahiere nur die Zeit
            if val.hour == 0 and val.minute == 0 and val.second == 0:
                return None
            return val.strftime("%H:%M")

        # Normales Datum
        return val.strftime("%d.%m.%Y")

    if isinstance(val, date):
        return val.strftime("%d.%m.%Y")

    return val


def export_to_json(cursor, query, filename, description=""):
    """Fuehrt Query aus und exportiert als JSON (optional gzip-komprimiert)"""
    try:
        cursor.execute(query)
        columns = [col[0] for col in cursor.description]
        rows = cursor.fetchall()

        data = []
        for row in rows:
            row_dict = {}
            for i, col in enumerate(columns):
                val = row[i]
                if val is None:
                    row_dict[col] = None
                elif isinstance(val, (datetime, date, time)):
                    row_dict[col] = format_datetime_value(val, col)
                elif isinstance(val, Decimal):
                    row_dict[col] = float(val)
                elif isinstance(val, bytes):
                    row_dict[col] = None
                else:
                    row_dict[col] = val
            data.append(row_dict)

        filepath = os.path.join(EXPORT_PATH, filename)
        json_content = json.dumps(data, ensure_ascii=False, indent=2, default=json_serial)

        # Normale JSON-Datei speichern
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(json_content)

        # Optional: gzip-komprimierte Version
        if USE_GZIP:
            gzip_path = filepath + '.gz'
            with gzip.open(gzip_path, 'wt', encoding='utf-8') as f:
                f.write(json_content)
            gzip_size = os.path.getsize(gzip_path)
            json_size = os.path.getsize(filepath)
            ratio = (1 - gzip_size / json_size) * 100 if json_size > 0 else 0
            logger.info(f"[OK] {description}: {len(data)} Datensaetze -> {filename} (gzip: {ratio:.1f}% kleiner)")
        else:
            logger.info(f"[OK] {description}: {len(data)} Datensaetze -> {filename}")

        # Statistik aktualisieren
        export_stats["total_files"] += 1
        export_stats["total_records"] += len(data)

        return True
    except Exception as e:
        logger.error(f"[!] Fehler bei {description}: {e}")
        export_stats["errors"] += 1
        return False


def main():
    os.makedirs(EXPORT_PATH, exist_ok=True)
    export_stats["start_time"] = datetime.now()

    logger.info("=" * 60)
    logger.info("HTML DATA EXPORT")
    logger.info("=" * 60)
    logger.info(f"Backend: {BACKEND_PATH}")
    logger.info(f"Export nach: {EXPORT_PATH}")
    logger.info(f"Log-Datei: {log_file}")
    logger.info(f"gzip-Kompression: {'Ja' if USE_GZIP else 'Nein'}")
    logger.info("")

    try:
        conn = pyodbc.connect(CONN_STR)
        cursor = conn.cursor()
        logger.info("[OK] Datenbankverbindung hergestellt\n")
    except Exception as e:
        logger.error(f"[!] Verbindungsfehler: {e}")
        return

    # === MITARBEITER (korrekte Feldnamen) ===
    export_to_json(cursor, """
        SELECT ID, Nachname, Vorname, [Tel_Mobil], [Tel_Festnetz], Email, IstAktiv,
               Strasse, Nr, PLZ, Ort, Bundesland, Land, Geschlecht,
               [Geb_Dat] as Geb_Datum, [Geb_Ort], Staatsang as Staatsangehoerigkeit,
               [LEXWare_ID] as LexNr, IstSubunternehmer as Subunternehmer
        FROM tbl_MA_Mitarbeiterstamm
        ORDER BY Nachname, Vorname
    """, "mitarbeiter.json", "Mitarbeiter")

    # === MITARBEITER DETAILS ===
    export_to_json(cursor, """
        SELECT ID, Nachname, Vorname, [Tel_Mobil], [Tel_Festnetz], Email, IstAktiv,
               Strasse, Nr, PLZ, Ort, Bundesland, Land, Geschlecht,
               [Geb_Dat] as Geb_Datum, [Geb_Ort], [Geb_Name], Staatsang,
               [LEXWare_ID] as LexNr, IstSubunternehmer,
               Bankname, BIC, IBAN, Kostenstelle
        FROM tbl_MA_Mitarbeiterstamm
        ORDER BY Nachname, Vorname
    """, "mitarbeiter_alle.json", "Mitarbeiter Details")

    # === KUNDEN (korrekte Feldnamen) ===
    export_to_json(cursor, """
        SELECT [kun_Id], [kun_Firma], [kun_Strasse], [kun_PLZ], [kun_Ort],
               [kun_telefon], [kun_email], [kun_Anschreiben], [kun_Bezeichnung]
        FROM tbl_KD_Kundenstamm
        ORDER BY [kun_Firma]
    """, "kunden.json", "Kunden")

    # === AUFTRAEGE (korrekte Feldnamen) ===
    export_to_json(cursor, """
        SELECT ID, Auftrag, Objekt, [Veranstalter_ID], Strasse, PLZ, Ort,
               [Dat_VA_Von], [Dat_VA_Bis], Bemerkungen
        FROM tbl_VA_Auftragstamm
        ORDER BY Auftrag DESC
    """, "auftraege.json", "Auftraege")

    # === SCHICHTEN ===
    export_to_json(cursor, """
        SELECT ID, [VA_ID], VADatum, [VA_Start], [VA_Ende], [MA_Anzahl], [MA_Anzahl_Ist]
        FROM tbl_VA_Start
        WHERE VADatum >= Date() - 30
        ORDER BY VADatum, [VA_Start]
    """, "schichten.json", "Schichten")

    # === MA-ZUORDNUNGEN ===
    export_to_json(cursor, """
        SELECT p.ID, p.[VA_ID], p.[VAStart_ID], p.[MA_ID], p.VADatum,
               p.[VA_Start], p.[VA_Ende], p.[Status_ID], m.Nachname, m.Vorname
        FROM tbl_MA_VA_Planung p
        INNER JOIN tbl_MA_Mitarbeiterstamm m ON p.[MA_ID] = m.ID
        WHERE p.VADatum >= Date() - 30
        ORDER BY p.VADatum, p.[VA_Start]
    """, "ma_zuordnungen.json", "MA-Zuordnungen")

    # === DIENSTPLAN ===
    export_to_json(cursor, """
        SELECT p.[MA_ID], m.Nachname, m.Vorname,
               p.VADatum, p.[VA_Start], p.[VA_Ende], p.[VA_ID]
        FROM tbl_MA_VA_Planung p
        INNER JOIN tbl_MA_Mitarbeiterstamm m ON p.[MA_ID] = m.ID
        WHERE p.VADatum >= Date() AND p.VADatum <= Date() + 14
        ORDER BY m.Nachname, p.VADatum
    """, "dienstplan.json", "Dienstplan")

    # === NICHTVERFUEGBAR ===
    export_to_json(cursor, """
        SELECT n.ID, n.[MA_ID], n.vonDat, n.bisDat, n.Bemerkung,
               n.[Zeittyp_ID], m.Nachname, m.Vorname
        FROM tbl_MA_NVerfuegZeiten n
        INNER JOIN tbl_MA_Mitarbeiterstamm m ON n.[MA_ID] = m.ID
        ORDER BY n.vonDat DESC
    """, "nichtverfuegbar.json", "Nichtverfuegbar")

    # === ABWESENHEITEN ===
    export_to_json(cursor, """
        SELECT [MA_ID], vonDat, bisDat, Bemerkung, [Zeittyp_ID]
        FROM tbl_MA_NVerfuegZeiten
        WHERE bisDat >= Date() - 365
        ORDER BY vonDat DESC
    """, "abwesenheiten.json", "Abwesenheiten")

    # === VA_AnzTage ===
    export_to_json(cursor, """
        SELECT [VA_ID], VADatum
        FROM tbl_VA_AnzTage
        WHERE VADatum >= Date() - 30
        ORDER BY VADatum
    """, "auftragstage.json", "Auftragstage")

    # === Ansprechpartner ===
    export_to_json(cursor, """
        SELECT * FROM tbl_KD_Ansprechpartner
        ORDER BY [kun_Id]
    """, "ansprechpartner.json", "Ansprechpartner")

    # === Dienstkleidung ===
    try:
        export_to_json(cursor, "SELECT * FROM tbl_MA_Dienstkleidung", "dienstkleidung.json", "Dienstkleidung")
    except:
        with open(os.path.join(EXPORT_PATH, "dienstkleidung.json"), 'w') as f:
            f.write("[]")
        print("[!] Keine Dienstkleidung-Tabelle gefunden")

    # === Zeitkonto ===
    try:
        cursor.execute("SELECT TOP 1 * FROM tbl_MA_Zeitkonto")
        export_to_json(cursor, "SELECT * FROM tbl_MA_Zeitkonto ORDER BY [MA_ID]", "zeitkonto.json", "Zeitkonto")
    except:
        with open(os.path.join(EXPORT_PATH, "zeitkonto.json"), 'w') as f:
            f.write("[]")
        print("[!] Keine Zeitkonto-Tabelle gefunden")

    # === Auftraege mit Kundennamen ===
    export_to_json(cursor, """
        SELECT a.ID, a.Auftrag, a.Objekt, a.[Veranstalter_ID],
               k.[kun_Firma] as Kunde, a.Strasse, a.PLZ, a.Ort,
               a.[Dat_VA_Von], a.[Dat_VA_Bis]
        FROM tbl_VA_Auftragstamm a
        LEFT JOIN tbl_KD_Kundenstamm k ON a.[Veranstalter_ID] = k.[kun_Id]
        ORDER BY a.Auftrag DESC
    """, "auftraege_komplett.json", "Auftraege komplett")

    # ================================================================
    # NEUE EXPORTS - Erweiterte Daten fuer HTML-Formulare
    # ================================================================

    # === OBJEKTE (eindeutige Liste aus Auftragstamm) ===
    export_to_json(cursor, """
        SELECT DISTINCT Objekt, Ort
        FROM tbl_VA_Auftragstamm
        WHERE Objekt IS NOT NULL AND Objekt <> ''
        ORDER BY Objekt
    """, "objekte.json", "Objekte")

    # === ZEITTYPEN (Abwesenheitsarten) ===
    try:
        export_to_json(cursor, """
            SELECT * FROM tbl_MA_Zeittypen
            ORDER BY ID
        """, "zeittypen.json", "Zeittypen")
    except:
        # Fallback: Versuche alternative Tabellennamen
        try:
            export_to_json(cursor, """
                SELECT * FROM tbl_Zeittypen
                ORDER BY ID
            """, "zeittypen.json", "Zeittypen")
        except:
            # Erstelle Standard-Zeittypen
            zeittypen = [
                {"ID": 1, "Bezeichnung": "Urlaub", "Farbe": "#4CAF50"},
                {"ID": 2, "Bezeichnung": "Krank", "Farbe": "#F44336"},
                {"ID": 3, "Bezeichnung": "Frei", "Farbe": "#2196F3"},
                {"ID": 4, "Bezeichnung": "Sonstiges", "Farbe": "#9E9E9E"}
            ]
            with open(os.path.join(EXPORT_PATH, "zeittypen.json"), 'w', encoding='utf-8') as f:
                json.dump(zeittypen, f, ensure_ascii=False, indent=2)
            print("[!] Zeittypen-Tabelle nicht gefunden - Standard-Werte erstellt")

    # === STATUS-TYPEN (Planungsstatus) ===
    try:
        export_to_json(cursor, """
            SELECT * FROM tbl_Status
            ORDER BY ID
        """, "status_typen.json", "Status-Typen")
    except:
        try:
            export_to_json(cursor, """
                SELECT * FROM tbl_MA_Status
                ORDER BY ID
            """, "status_typen.json", "Status-Typen")
        except:
            # Erstelle Standard-Status
            status_typen = [
                {"ID": 1, "Bezeichnung": "Geplant", "Farbe": "#FFC107"},
                {"ID": 2, "Bezeichnung": "Bestaetigt", "Farbe": "#4CAF50"},
                {"ID": 3, "Bezeichnung": "Abgesagt", "Farbe": "#F44336"},
                {"ID": 4, "Bezeichnung": "Krank", "Farbe": "#9C27B0"}
            ]
            with open(os.path.join(EXPORT_PATH, "status_typen.json"), 'w', encoding='utf-8') as f:
                json.dump(status_typen, f, ensure_ascii=False, indent=2)
            print("[!] Status-Tabelle nicht gefunden - Standard-Werte erstellt")

    # === MA-EINSAETZE (Historische Einsaetze pro Mitarbeiter) ===
    export_to_json(cursor, """
        SELECT p.ID, p.[MA_ID], p.VADatum, p.[VA_Start], p.[VA_Ende],
               p.[VA_ID], p.[Status_ID],
               a.Auftrag, a.Objekt,
               k.[kun_Firma] as Kunde
        FROM ((tbl_MA_VA_Planung p
        LEFT JOIN tbl_VA_Auftragstamm a ON p.[VA_ID] = a.ID)
        LEFT JOIN tbl_KD_Kundenstamm k ON a.[Veranstalter_ID] = k.[kun_Id])
        WHERE p.VADatum >= Date() - 365
        ORDER BY p.[MA_ID], p.VADatum DESC
    """, "ma_einsaetze.json", "MA-Einsaetze (12 Monate)")

    # === SCHICHTEN KOMPLETT (mit Auftrags- und Kundendaten) ===
    export_to_json(cursor, """
        SELECT s.ID, s.[VA_ID], s.VADatum, s.[VA_Start], s.[VA_Ende],
               s.[MA_Anzahl], s.[MA_Anzahl_Ist],
               a.Auftrag, a.Objekt,
               k.[kun_Firma] as Kunde
        FROM ((tbl_VA_Start s
        LEFT JOIN tbl_VA_Auftragstamm a ON s.[VA_ID] = a.ID)
        LEFT JOIN tbl_KD_Kundenstamm k ON a.[Veranstalter_ID] = k.[kun_Id])
        WHERE s.VADatum >= Date() - 30 AND s.VADatum <= Date() + 90
        ORDER BY s.VADatum, s.[VA_Start]
    """, "schichten_komplett.json", "Schichten komplett (mit Auftrag/Kunde)")

    # === DIENSTPLAN ERWEITERT (mit mehr Details) ===
    export_to_json(cursor, """
        SELECT p.ID, p.[MA_ID], m.Nachname, m.Vorname, m.[Tel_Mobil],
               p.VADatum, p.[VA_Start], p.[VA_Ende], p.[Status_ID],
               p.[VA_ID], a.Auftrag, a.Objekt,
               k.[kun_Firma] as Kunde
        FROM (((tbl_MA_VA_Planung p
        LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.[MA_ID] = m.ID)
        LEFT JOIN tbl_VA_Auftragstamm a ON p.[VA_ID] = a.ID)
        LEFT JOIN tbl_KD_Kundenstamm k ON a.[Veranstalter_ID] = k.[kun_Id])
        WHERE p.VADatum >= Date() - 7 AND p.VADatum <= Date() + 30
        ORDER BY p.VADatum, p.[VA_Start], m.Nachname
    """, "dienstplan_komplett.json", "Dienstplan komplett (30 Tage)")

    # === KUNDEN KOMPLETT (mit Ansprechpartnern) ===
    export_to_json(cursor, """
        SELECT k.[kun_Id], k.[kun_Firma], k.[kun_Strasse], k.[kun_PLZ], k.[kun_Ort],
               k.[kun_telefon], k.[kun_email], k.[kun_IstAktiv],
               k.[kun_Anschreiben], k.[kun_Bezeichnung]
        FROM tbl_KD_Kundenstamm k
        WHERE k.[kun_IstAktiv] = True OR k.[kun_IstAktiv] IS NULL
        ORDER BY k.[kun_Firma]
    """, "kunden_aktiv.json", "Kunden (nur aktive)")

    # === MITARBEITER AKTIV (gefiltert, nur mit Namen) ===
    export_to_json(cursor, """
        SELECT ID, Nachname, Vorname, [Tel_Mobil], [Tel_Festnetz], Email, IstAktiv,
               Strasse, Nr, PLZ, Ort, Bundesland, Land, Geschlecht,
               [Geb_Dat] as Geb_Datum, [Geb_Ort], Staatsang as Staatsangehoerigkeit,
               [LEXWare_ID] as LexNr, IstSubunternehmer as Subunternehmer,
               Bankname, BIC, IBAN
        FROM tbl_MA_Mitarbeiterstamm
        WHERE IstAktiv = True AND Nachname IS NOT NULL AND Nachname <> ''
        ORDER BY Nachname, Vorname
    """, "mitarbeiter_aktiv.json", "Mitarbeiter (nur aktive mit Namen)")

    # === QUALIFIKATIONEN (falls vorhanden) ===
    try:
        export_to_json(cursor, """
            SELECT * FROM tbl_MA_Qualifikationen
            ORDER BY [MA_ID]
        """, "qualifikationen.json", "Qualifikationen")
    except:
        try:
            # Alternative: Qualifikationsfelder aus Mitarbeitertabelle
            export_to_json(cursor, """
                SELECT ID as MA_ID,
                       [Quali_34a], [Quali_34a_bis],
                       [Quali_EH], [Quali_EH_bis],
                       [Quali_Brandschutz], [Quali_Brandschutz_bis]
                FROM tbl_MA_Mitarbeiterstamm
                WHERE [Quali_34a] = True OR [Quali_EH] = True OR [Quali_Brandschutz] = True
            """, "qualifikationen.json", "Qualifikationen (aus MA-Stamm)")
        except:
            with open(os.path.join(EXPORT_PATH, "qualifikationen.json"), 'w') as f:
                f.write("[]")
            print("[!] Keine Qualifikationen-Daten gefunden")

    # === POSITIONEN / FUNKTIONEN ===
    try:
        export_to_json(cursor, """
            SELECT * FROM tbl_Positionen
            ORDER BY ID
        """, "positionen.json", "Positionen")
    except:
        try:
            export_to_json(cursor, """
                SELECT * FROM tbl_MA_Positionen
                ORDER BY ID
            """, "positionen.json", "Positionen")
        except:
            # Standard-Positionen
            positionen = [
                {"ID": 1, "Bezeichnung": "Sicherheitsmitarbeiter"},
                {"ID": 2, "Bezeichnung": "Objektleiter"},
                {"ID": 3, "Bezeichnung": "Einsatzleiter"},
                {"ID": 4, "Bezeichnung": "Empfang"},
                {"ID": 5, "Bezeichnung": "Pforte"}
            ]
            with open(os.path.join(EXPORT_PATH, "positionen.json"), 'w', encoding='utf-8') as f:
                json.dump(positionen, f, ensure_ascii=False, indent=2)
            print("[!] Positionen-Tabelle nicht gefunden - Standard-Werte erstellt")

    # === AUFTRAEGE AKTIV (nur mit Schichten in Zukunft) ===
    export_to_json(cursor, """
        SELECT DISTINCT a.ID, a.Auftrag, a.Objekt, a.[Veranstalter_ID],
               k.[kun_Firma] as Kunde, a.Strasse, a.PLZ, a.Ort,
               a.[Dat_VA_Von], a.[Dat_VA_Bis]
        FROM tbl_VA_Auftragstamm a
        LEFT JOIN tbl_KD_Kundenstamm k ON a.[Veranstalter_ID] = k.[kun_Id]
        WHERE a.ID IN (
            SELECT DISTINCT [VA_ID] FROM tbl_VA_Start WHERE VADatum >= Date()
        )
        ORDER BY a.Auftrag
    """, "auftraege_aktiv.json", "Auftraege (nur mit zukuenftigen Schichten)")

    # === STATISTIK-DATEN ===
    try:
        # Schichten-Statistik pro Tag (naechste 14 Tage)
        export_to_json(cursor, """
            SELECT VADatum,
                   COUNT(*) as AnzahlSchichten,
                   SUM([MA_Anzahl]) as SollMA,
                   SUM([MA_Anzahl_Ist]) as IstMA
            FROM tbl_VA_Start
            WHERE VADatum >= Date() AND VADatum <= Date() + 14
            GROUP BY VADatum
            ORDER BY VADatum
        """, "statistik_schichten.json", "Statistik Schichten (14 Tage)")
    except Exception as e:
        print(f"[!] Statistik-Export fehlgeschlagen: {e}")

    # === MA-VERFUEGBARKEIT (aktive MA ohne Abwesenheit heute) ===
    export_to_json(cursor, """
        SELECT m.ID, m.Nachname, m.Vorname, m.[Tel_Mobil], m.IstAktiv
        FROM tbl_MA_Mitarbeiterstamm m
        WHERE m.IstAktiv = True
          AND m.Nachname IS NOT NULL
          AND m.ID NOT IN (
              SELECT DISTINCT [MA_ID] FROM tbl_MA_NVerfuegZeiten
              WHERE vonDat <= Date() AND bisDat >= Date()
          )
        ORDER BY m.Nachname, m.Vorname
    """, "ma_verfuegbar_heute.json", "MA verfuegbar heute")

    conn.close()

    # Export-Statistik
    export_stats["end_time"] = datetime.now()
    duration = (export_stats["end_time"] - export_stats["start_time"]).total_seconds()

    logger.info("")
    logger.info("=" * 60)
    logger.info("EXPORT STATISTIK")
    logger.info("=" * 60)
    logger.info(f"Dateien exportiert: {export_stats['total_files']}")
    logger.info(f"Datensaetze gesamt: {export_stats['total_records']}")
    logger.info(f"Fehler: {export_stats['errors']}")
    logger.info(f"Dauer: {duration:.2f} Sekunden")
    logger.info(f"Log-Datei: {log_file}")
    logger.info("=" * 60)
    logger.info("[OK] EXPORT ABGESCHLOSSEN")
    logger.info("=" * 60)

    # Statistik als JSON speichern
    stats_file = os.path.join(LOG_PATH, "last_export_stats.json")
    with open(stats_file, 'w', encoding='utf-8') as f:
        json.dump({
            "timestamp": export_stats["end_time"].strftime("%d.%m.%Y %H:%M:%S"),
            "files": export_stats["total_files"],
            "records": export_stats["total_records"],
            "errors": export_stats["errors"],
            "duration_seconds": duration,
            "gzip_enabled": USE_GZIP
        }, f, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    main()
