"""
Entferne Info und füge IstFraglich hinzu in zsub_N_DP_Einsatzliste
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("ERSETZE INFO DURCH ISTFRAGLICH")
    print("=" * 70)

    # 1. Aktualisiere Abfrage - ersetze Info durch IstFraglich
    print("\n1. Aktualisiere Abfrage...")
    new_sql = """SELECT z.ID, z.VA_ID, z.VADatum_ID, z.VAStart_ID, z.PosNr, z.MA_ID, m.Nachname & ' ' & m.Vorname AS MA_Name, z.MA_Start, z.MA_Ende, Round((z.MA_Ende - z.MA_Start) * 24, 2) AS Std, z.Bemerkungen, z.PKW, z.Einsatzleitung, z.IstFraglich
FROM tbl_MA_VA_Zuordnung AS z LEFT JOIN tbl_MA_Mitarbeiterstamm AS m ON z.MA_ID = m.ID
ORDER BY z.MA_Start, z.PosNr;"""

    for qdef in bridge.current_db.QueryDefs:
        if qdef.Name == "qry_N_DP_Einsatzliste":
            qdef.SQL = new_sql
            print("  [OK] Abfrage aktualisiert (Info -> IstFraglich)")
            break

    # 2. Formular anpassen
    print("\n2. Formular anpassen...")
    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        # Lösche Info-Feld
        try:
            bridge.access_app.DeleteControl("zsub_N_DP_Einsatzliste", "Info")
            print("  [OK] Info gelöscht")
        except Exception as e:
            print(f"  Info löschen: {e}")

        # Füge IstFraglich als Checkbox hinzu
        print("  Füge IstFraglich hinzu...")
        chk_fraglich = bridge.access_app.CreateControl(
            "zsub_N_DP_Einsatzliste",
            106,  # acCheckBox
            0,    # acDetail
            "",   # Parent
            "IstFraglich",  # ControlSource
            6900, # Left (gleiche Position wie Info war)
            60,   # Top
            260,  # Width
            240   # Height
        )
        chk_fraglich.Name = "IstFraglich"

        # Formularbreite anpassen (kleiner, da Checkbox statt Textfeld)
        form.Width = 7300

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
        print("  [OK] Formular gespeichert!")

    except Exception as e:
        print(f"  Fehler: {e}")
        try:
            bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
        except:
            pass

    # 3. Verifiziere
    print("\n3. Verifiziere...")
    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        print(f"  Breite: {form.Width} twips")
        print("\n  Sichtbare Controls:")
        for ctrl in form.Controls:
            try:
                if ctrl.Width > 0:
                    cs = ctrl.ControlSource if hasattr(ctrl, 'ControlSource') else ''
                    print(f"    {ctrl.Name}: Left={ctrl.Left}, W={ctrl.Width}, Source='{cs}'")
            except:
                pass

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
    except:
        pass

print("\n[FERTIG]")
