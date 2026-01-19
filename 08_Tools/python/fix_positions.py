"""
Korrigiere die Positionen der Felder in zsub_N_DP_Einsatzliste
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("KORRIGIERE POSITIONEN IN EINSATZLISTE")
    print("=" * 70)

    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        # Neue Positionen:
        # PosNr: 0, W:400
        # MA_Name: 500, W:1800
        # MA_Start: 2400, W:700
        # MA_Ende: 3200, W:700
        # Std: 4000, W:500
        # Bemerkungen: 4600, W:1200
        # PKW: 5900, W:500
        # Einsatzleitung: 6500, W:300
        # Info: 6900, W:1800
        # (versteckte Felder bleiben bei 0 Breite)

        positions = {
            'PosNr': (0, 400),
            'MA_Name': (500, 1800),
            'MA_Start': (2400, 700),
            'MA_Ende': (3200, 700),
            'Std': (4000, 500),
            'Bemerkungen': (4600, 1200),
            'PKW': (5900, 500),
            'Einsatzleitung': (6500, 300),
            'Info': (6900, 1800),
        }

        print("\nSetze Positionen:")
        for ctrl in form.Controls:
            try:
                if ctrl.Name in positions:
                    new_left, new_width = positions[ctrl.Name]
                    old_left = ctrl.Left
                    ctrl.Left = new_left
                    ctrl.Width = new_width
                    print(f"  {ctrl.Name}: Left {old_left} -> {new_left}, Width -> {new_width}")
            except Exception as e:
                print(f"  Fehler bei {ctrl.Name}: {e}")

        # Erweitere Formularbreite
        form.Width = 8800
        print(f"\nFormularbreite: {form.Width} twips")

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
        print("\n[OK] Gespeichert!")

    except Exception as e:
        print(f"Fehler: {e}")
        try:
            bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
        except:
            pass

    # Verifiziere
    print("\nVerifiziere:")
    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        for ctrl in form.Controls:
            try:
                if ctrl.Width > 0:
                    cs = ctrl.ControlSource if hasattr(ctrl, 'ControlSource') else ''
                    print(f"  {ctrl.Name}: Left={ctrl.Left}, W={ctrl.Width}, Source='{cs}'")
            except:
                pass

        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
    except:
        pass

print("\n[FERTIG]")
