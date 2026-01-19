"""
Integriere frm_Menuefuehrung als Unterformular links in frm_N_DP_Dashboard
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

# Menü-Breite: ca. 2685 twips (4.7 cm) + etwas Abstand = 3000 twips
MENU_WIDTH = 3000
MENU_OFFSET = 200  # Abstand links

with AccessBridge() as bridge:
    print("=" * 70)
    print("INTEGRIERE MENÜ IN DASHBOARD")
    print("=" * 70)

    try:
        # Öffne Dashboard in Design-Ansicht
        bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
        time.sleep(1)
        form = bridge.access_app.Forms("frm_N_DP_Dashboard")

        # Aktuelle Breite
        old_width = form.Width
        print(f"Alte Dashboard-Breite: {old_width} twips ({old_width/567:.1f} cm)")

        # 1. Verschiebe alle bestehenden Controls nach rechts
        print("\nVerschiebe Controls nach rechts...")
        for ctrl in form.Controls:
            try:
                old_left = ctrl.Left
                ctrl.Left = old_left + MENU_WIDTH
                print(f"  {ctrl.Name}: {old_left} -> {ctrl.Left}")
            except Exception as e:
                print(f"  {ctrl.Name}: Fehler - {e}")

        # 2. Vergrößere die Formularbreite
        new_width = old_width + MENU_WIDTH
        form.Width = new_width
        print(f"\nNeue Dashboard-Breite: {new_width} twips ({new_width/567:.1f} cm)")

        # 3. Füge Subform-Control für das Menü hinzu
        print("\nFüge Menü-Unterformular hinzu...")

        # Höhe des Detail-Bereichs ermitteln
        detail_height = form.Section(0).Height

        # Erstelle das Subform-Control
        sub_menu = bridge.access_app.CreateControl(
            "frm_N_DP_Dashboard",
            112,  # acSubform
            0,    # acDetail
            "",   # Parent
            "",   # ColumnName
            MENU_OFFSET,  # Left
            120,  # Top
            MENU_WIDTH - 200,  # Width (2800)
            detail_height - 240  # Height
        )

        sub_menu.Name = "sub_N_Menuefuehrung"
        sub_menu.SourceObject = "frm_Menuefuehrung"

        print(f"  Unterformular erstellt: sub_N_Menuefuehrung")
        print(f"  Position: Left={MENU_OFFSET}, Top=120")
        print(f"  Größe: Width={MENU_WIDTH - 200}, Height={detail_height - 240}")

        # Speichern und schließen
        bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)  # acSaveYes
        print("\n[OK] Dashboard mit Menü gespeichert!")

    except Exception as e:
        print(f"\n[FEHLER] {e}")
        import traceback
        traceback.print_exc()
        try:
            bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)  # ohne Speichern
        except:
            pass

print("\n[FERTIG]")
