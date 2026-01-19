"""
Füge Einsatzleitung und Info zu zsub_N_DP_Einsatzliste hinzu
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("FÜGE EINSATZLEITUNG UND INFO ZU EINSATZLISTE HINZU")
    print("=" * 70)

    # 1. Erweitere die Abfrage qry_N_DP_Einsatzliste
    print("\n1. Erweitere Abfrage qry_N_DP_Einsatzliste...")

    new_sql = """SELECT z.ID, z.VA_ID, z.VADatum_ID, z.VAStart_ID, z.PosNr, z.MA_ID, m.Nachname & ' ' & m.Vorname AS MA_Name, z.MA_Start, z.MA_Ende, Round((z.MA_Ende - z.MA_Start) * 24, 2) AS Std, z.Bemerkungen, z.PKW, z.Einsatzleitung, z.Info
FROM tbl_MA_VA_Zuordnung AS z LEFT JOIN tbl_MA_Mitarbeiterstamm AS m ON z.MA_ID = m.ID
ORDER BY z.MA_Start, z.PosNr;"""

    for qdef in bridge.current_db.QueryDefs:
        if qdef.Name == "qry_N_DP_Einsatzliste":
            qdef.SQL = new_sql
            print("  [OK] Abfrage erweitert um Einsatzleitung und Info")
            break

    # 2. Füge Felder zum Formular hinzu
    print("\n2. Füge Felder zum Formular hinzu...")

    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        # Aktuelle Positionen:
        # PKW endet bei ca. 7400
        # Neue Felder danach:
        # Einsatzleitung (Checkbox): Position 7500, Breite 400
        # Info (TextBox): Position 8000, Breite 1500

        # Füge Einsatzleitung-Checkbox hinzu
        print("  Füge Einsatzleitung hinzu...")
        chk_el = bridge.access_app.CreateControl(
            "zsub_N_DP_Einsatzliste",
            106,  # acCheckBox
            0,    # acDetail
            "",   # Parent
            "Einsatzleitung",  # ControlSource
            7500, # Left
            60,   # Top
            260,  # Width
            240   # Height
        )
        chk_el.Name = "Einsatzleitung"

        # Füge Info-TextBox hinzu
        print("  Füge Info hinzu...")
        txt_info = bridge.access_app.CreateControl(
            "zsub_N_DP_Einsatzliste",
            109,  # acTextBox
            0,    # acDetail
            "",   # Parent
            "Info",  # ControlSource
            7900, # Left
            0,    # Top
            1500, # Width
            300   # Height
        )
        txt_info.Name = "Info"

        # Erweitere Formularbreite
        form.Width = 9500
        print(f"  Neue Formularbreite: {form.Width} twips")

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
        print("\n  [OK] Formular gespeichert!")

    except Exception as e:
        print(f"  Fehler: {e}")
        import traceback
        traceback.print_exc()
        try:
            bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
        except:
            pass

    # 3. Verifiziere
    print("\n3. Verifiziere...")
    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        print(f"  RecordSource: {form.RecordSource}")
        print(f"  Breite: {form.Width} twips")

        print("\n  Controls:")
        for ctrl in form.Controls:
            try:
                cs = ctrl.ControlSource if hasattr(ctrl, 'ControlSource') else ''
                print(f"    {ctrl.Name} (Left:{ctrl.Left}, W:{ctrl.Width}) -> '{cs}'")
            except:
                pass

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
    except Exception as e:
        print(f"  Fehler: {e}")

print("\n[FERTIG]")
