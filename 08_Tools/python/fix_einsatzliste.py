"""
1. Entferne Einsatzleitung/Information aus zsub_lstAuftrag
2. Setze Abfrage zurück
3. Analysiere zsub_N_DP_Einsatzliste
4. Füge Einsatzleitung/Information dort hinzu
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("KORRIGIERE UNTERFORMULARE")
    print("=" * 70)

    # 1. Entferne Einsatzleitung/Information aus zsub_lstAuftrag
    print("\n1. Entferne falsche Felder aus zsub_lstAuftrag...")
    try:
        bridge.access_app.DoCmd.OpenForm("zsub_lstAuftrag", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_lstAuftrag")

        # Lösche die falschen Controls
        controls_to_delete = []
        for ctrl in form.Controls:
            if ctrl.Name in ["Einsatzleitung", "Information"]:
                controls_to_delete.append(ctrl.Name)

        for ctrl_name in controls_to_delete:
            try:
                bridge.access_app.DoCmd.DeleteObject(2, ctrl_name)  # Funktioniert nicht für Controls
            except:
                pass

        # Manuell löschen über DeleteControl
        for ctrl_name in controls_to_delete:
            try:
                bridge.access_app.DeleteControl("zsub_lstAuftrag", ctrl_name)
                print(f"  Gelöscht: {ctrl_name}")
            except Exception as e:
                print(f"  Fehler beim Löschen von {ctrl_name}: {e}")

        # Breite zurücksetzen
        form.Width = 9000
        bridge.access_app.DoCmd.Close(2, "zsub_lstAuftrag", 1)
        print("  [OK] zsub_lstAuftrag bereinigt")
    except Exception as e:
        print(f"  Fehler: {e}")
        try:
            bridge.access_app.DoCmd.Close(2, "zsub_lstAuftrag", 2)
        except:
            pass

    # 2. Setze Abfrage zurück
    print("\n2. Setze Abfrage qry_N_DP_Auftraege_Liste zurück...")
    original_sql = """SELECT [tbl_VA_Auftragstamm].[ID] AS VA_ID, [tbl_VA_AnzTage].[ID] AS AnzTage_ID, qry_lst_Row_Auftrag.Datum, qry_lst_Row_Auftrag.Auftrag, qry_lst_Row_Auftrag.Objekt, qry_lst_Row_Auftrag.Ort, qry_lst_Row_Auftrag.Soll, qry_lst_Row_Auftrag.Ist
FROM qry_lst_Row_Auftrag
WHERE qry_lst_Row_Auftrag.Datum >= Date()
ORDER BY qry_lst_Row_Auftrag.Datum, qry_lst_Row_Auftrag.Auftrag;"""

    for qdef in bridge.current_db.QueryDefs:
        if qdef.Name == "qry_N_DP_Auftraege_Liste":
            qdef.SQL = original_sql
            print("  [OK] Abfrage zurückgesetzt")
            break

    # 3. Analysiere zsub_N_DP_Einsatzliste
    print("\n3. Analysiere zsub_N_DP_Einsatzliste...")
    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        print(f"  RecordSource: {form.RecordSource}")
        print(f"  DefaultView: {form.DefaultView}")
        print(f"  Breite: {form.Width} twips")

        print("\n  Controls:")
        max_left = 0
        for ctrl in form.Controls:
            try:
                ctrl_type = ctrl.ControlType
                ctrl_source = ""
                try:
                    ctrl_source = ctrl.ControlSource
                except:
                    pass
                print(f"    {ctrl.Name} (Type:{ctrl_type}, Left:{ctrl.Left}, W:{ctrl.Width}, Source:'{ctrl_source}')")
                if ctrl.Left + ctrl.Width > max_left:
                    max_left = ctrl.Left + ctrl.Width
            except:
                pass

        print(f"\n  Maximale Position rechts: {max_left} twips")
        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
    except Exception as e:
        print(f"  Fehler: {e}")

    # Prüfe die Abfrage der Einsatzliste
    print("\n4. Prüfe RecordSource-Abfrage...")
    try:
        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        form = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")
        rs = form.RecordSource
        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)

        if rs:
            for qdef in bridge.current_db.QueryDefs:
                if qdef.Name == rs:
                    print(f"  SQL von {rs}:")
                    print(f"  {qdef.SQL}")
                    break
    except Exception as e:
        print(f"  Fehler: {e}")

print("\n[FERTIG]")
