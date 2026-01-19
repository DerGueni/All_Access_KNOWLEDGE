"""
Ersetze MA_Name TextBox durch eine ComboBox für MA_ID Auswahl
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("ERSETZE MA_NAME DURCH MA_ID COMBOBOX")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)  # Design
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        # Finde Position des MA_Name Feldes
        ma_name_left = 500
        ma_name_width = 1800
        ma_name_top = 0

        for ctrl in form.Controls:
            if ctrl.Name == "MA_Name":
                ma_name_left = ctrl.Left
                ma_name_width = ctrl.Width
                ma_name_top = ctrl.Top
                print(f"MA_Name gefunden: Left={ma_name_left}, Width={ma_name_width}")
                break

        # Lösche MA_Name TextBox
        print("\n1. Lösche MA_Name TextBox...")
        try:
            bridge.access_app.DeleteControl("zsub_N_DP_Einsatzliste", "MA_Name")
            print("   [OK] MA_Name gelöscht")
        except Exception as e:
            print(f"   Fehler: {e}")

        # Erstelle ComboBox für MA_ID
        print("\n2. Erstelle ComboBox für Mitarbeiter-Auswahl...")
        cbo_ma = bridge.access_app.CreateControl(
            "zsub_N_DP_Einsatzliste",
            111,  # acComboBox
            0,    # acDetail
            "",   # Parent
            "MA_ID",  # ControlSource
            ma_name_left,
            ma_name_top,
            ma_name_width,
            300
        )
        cbo_ma.Name = "cboMA_ID"

        # Setze RowSource für die ComboBox (aktive Mitarbeiter)
        cbo_ma.RowSourceType = "Table/Query"
        cbo_ma.RowSource = "SELECT ID, Nachname & ' ' & Vorname AS Name FROM tbl_MA_Mitarbeiterstamm WHERE IstAktiv = True ORDER BY Nachname, Vorname"
        cbo_ma.ColumnCount = 2
        cbo_ma.ColumnWidths = "0;1800"  # ID versteckt, Name sichtbar
        cbo_ma.BoundColumn = 1  # ID ist der gebundene Wert
        cbo_ma.LimitToList = True

        print("   [OK] ComboBox erstellt")
        print(f"   RowSource: {cbo_ma.RowSource}")

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
        print("\n[OK] Formular gespeichert!")

    except Exception as e:
        print(f"Fehler: {e}")
        import traceback
        traceback.print_exc()
        try:
            bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
        except:
            pass

    # Verifiziere
    print("\n" + "=" * 70)
    print("VERIFIZIERE")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        print("\nControls:")
        for ctrl in form.Controls:
            try:
                if ctrl.Width > 0:
                    cs = ctrl.ControlSource if hasattr(ctrl, 'ControlSource') else ''
                    print(f"  {ctrl.Name} (Type:{ctrl.ControlType}, Left:{ctrl.Left}) -> '{cs}'")
            except:
                pass

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
    except:
        pass

print("\n[FERTIG]")
