"""
Setze ControlSources und erweitere die Abfrage
Einsatzleitung und Info müssen aus tbl_MA_VA_Zuordnung kommen
- Wir zeigen ob mindestens ein MA als Einsatzleitung markiert ist
- Info zeigt die erste gefundene Info zum Auftrag/Tag
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("ERWEITERE ABFRAGE UND SETZE CONTROLSOURCES")
    print("=" * 70)

    # Erweiterte SQL für qry_N_DP_Auftraege_Liste
    # Füge Unterabfragen für Einsatzleitung und Info hinzu
    new_sql = """SELECT
    [tbl_VA_Auftragstamm].[ID] AS VA_ID,
    [tbl_VA_AnzTage].[ID] AS AnzTage_ID,
    qry_lst_Row_Auftrag.Datum,
    qry_lst_Row_Auftrag.Auftrag,
    qry_lst_Row_Auftrag.Objekt,
    qry_lst_Row_Auftrag.Ort,
    qry_lst_Row_Auftrag.Soll,
    qry_lst_Row_Auftrag.Ist,
    (SELECT TOP 1 Einsatzleitung FROM tbl_MA_VA_Zuordnung WHERE VA_ID = [tbl_VA_Auftragstamm].[ID] AND VADatum = qry_lst_Row_Auftrag.Datum AND Einsatzleitung = True) AS Einsatzleitung,
    (SELECT TOP 1 Info FROM tbl_MA_VA_Zuordnung WHERE VA_ID = [tbl_VA_Auftragstamm].[ID] AND VADatum = qry_lst_Row_Auftrag.Datum AND Info Is Not Null AND Info <> '') AS Information
FROM qry_lst_Row_Auftrag
WHERE qry_lst_Row_Auftrag.Datum >= Date()
ORDER BY qry_lst_Row_Auftrag.Datum, qry_lst_Row_Auftrag.Auftrag;"""

    print("\n1. Aktualisiere Abfrage qry_N_DP_Auftraege_Liste...")
    print(f"Neue SQL:\n{new_sql}")

    # Aktualisiere die Abfrage
    for qdef in bridge.current_db.QueryDefs:
        if qdef.Name == "qry_N_DP_Auftraege_Liste":
            qdef.SQL = new_sql
            print("\n[OK] Abfrage aktualisiert!")
            break

    # Setze ControlSources im Formular
    print("\n2. Setze ControlSources im Formular...")

    try:
        bridge.access_app.DoCmd.OpenForm("zsub_lstAuftrag", 1)
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_lstAuftrag")

        for ctrl in form.Controls:
            try:
                if ctrl.Name == "Einsatzleitung":
                    ctrl.ControlSource = "Einsatzleitung"
                    print(f"  {ctrl.Name} -> Einsatzleitung")
                elif ctrl.Name == "Information":
                    ctrl.ControlSource = "Information"
                    print(f"  {ctrl.Name} -> Information")
            except Exception as e:
                print(f"  Fehler bei {ctrl.Name}: {e}")

        bridge.access_app.DoCmd.Close(2, "zsub_lstAuftrag", 1)
        print("\n[OK] Formular gespeichert!")

    except Exception as e:
        print(f"Fehler: {e}")
        try:
            bridge.access_app.DoCmd.Close(2, "zsub_lstAuftrag", 2)
        except:
            pass

    # Verifiziere
    print("\n3. Verifiziere...")
    try:
        bridge.access_app.DoCmd.OpenForm("zsub_lstAuftrag", 1)
        form = bridge.access_app.Forms("zsub_lstAuftrag")

        print("\nControls:")
        for ctrl in form.Controls:
            try:
                cs = ctrl.ControlSource if hasattr(ctrl, 'ControlSource') else ''
                print(f"  {ctrl.Name} -> '{cs}'")
            except:
                pass

        bridge.access_app.DoCmd.Close(2, "zsub_lstAuftrag", 2)
    except:
        pass

print("\n[FERTIG]")
