"""
Füge fehlende Spalten zu zsub_lstAuftrag hinzu:
- Auftrag (war schon in Abfrage, fehlt im Formular)
- Einsatzleitung
- Information
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge
import time

with AccessBridge() as bridge:
    print("=" * 70)
    print("ERWEITERE zsub_lstAuftrag")
    print("=" * 70)

    # Zuerst die Abfrage erweitern um Einsatzleitung und Info
    print("\n1. Prüfe/Erweitere Abfrage qry_N_DP_Auftraege_Liste...")

    # Hole aktuelle SQL
    current_sql = ""
    for qdef in bridge.current_db.QueryDefs:
        if qdef.Name == "qry_N_DP_Auftraege_Liste":
            current_sql = qdef.SQL
            print(f"Aktuelle SQL:\n{current_sql}")
            break

    # Prüfe ob qry_lst_Row_Auftrag bereits Einsatzleitung/Info hat
    print("\n2. Prüfe qry_lst_Row_Auftrag...")
    for qdef in bridge.current_db.QueryDefs:
        if qdef.Name == "qry_lst_Row_Auftrag":
            print(f"SQL:\n{qdef.SQL}")
            break

    # Öffne Formular und füge die fehlenden Felder hinzu
    print("\n3. Füge Felder zum Formular hinzu...")

    try:
        bridge.access_app.DoCmd.OpenForm("zsub_lstAuftrag", 1)  # Design View
        time.sleep(0.5)
        form = bridge.access_app.Forms("zsub_lstAuftrag")

        # Aktuelle Breite und Controls auflisten
        old_width = form.Width
        print(f"Aktuelle Formularbreite: {old_width} twips")

        # Sammle aktuelle Control-Positionen
        controls_info = []
        for ctrl in form.Controls:
            try:
                controls_info.append({
                    'name': ctrl.Name,
                    'left': ctrl.Left,
                    'width': ctrl.Width,
                    'source': ctrl.ControlSource if hasattr(ctrl, 'ControlSource') else ''
                })
            except:
                pass

        print(f"Aktuelle Controls: {[c['name'] for c in controls_info]}")

        # Prüfe ob Auftrag-Feld bereits existiert
        has_auftrag = any(c['name'].lower() == 'auftrag' for c in controls_info)
        print(f"Hat Auftrag-Feld: {has_auftrag}")

        # Verschiebe alle Controls nach rechts um Platz für Auftrag zu machen
        # Neue Spaltenbreiten:
        # Datum: 1200 (Position 0)
        # Auftrag: 1800 (Position 1200) - NEU
        # Objekt: 2500 (Position 3000)
        # Ort: 1800 (Position 5500)
        # Soll: 600 (Position 7300)
        # Ist: 600 (Position 7900)
        # Einsatzleitung: 400 (Position 8500) - NEU
        # Info: 1500 (Position 8900) - NEU

        if not has_auftrag:
            # Verschiebe bestehende Controls
            for ctrl in form.Controls:
                try:
                    if ctrl.Name == "Datum":
                        ctrl.Left = 0
                        ctrl.Width = 1200
                    elif ctrl.Name == "Objekt":
                        ctrl.Left = 3000
                        ctrl.Width = 2400
                    elif ctrl.Name == "Ort":
                        ctrl.Left = 5500
                        ctrl.Width = 1700
                    elif ctrl.Name == "Soll":
                        ctrl.Left = 7300
                        ctrl.Width = 600
                    elif ctrl.Name == "Ist":
                        ctrl.Left = 7900
                        ctrl.Width = 600
                except Exception as e:
                    print(f"  Fehler bei {ctrl.Name}: {e}")

            # Füge Auftrag-Feld hinzu
            print("  Füge Auftrag-Feld hinzu...")
            txt_auftrag = bridge.access_app.CreateControl(
                "zsub_lstAuftrag",
                109,  # acTextBox
                0,    # acDetail
                "",   # Parent
                "Auftrag",  # ColumnName/ControlSource
                1200,  # Left
                0,     # Top
                1700,  # Width
                300    # Height
            )
            txt_auftrag.Name = "Auftrag"

        # Füge Einsatzleitung-Feld hinzu (Checkbox)
        print("  Füge Einsatzleitung-Feld hinzu...")
        try:
            chk_el = bridge.access_app.CreateControl(
                "zsub_lstAuftrag",
                106,  # acCheckBox
                0,    # acDetail
                "",   # Parent
                "",   # ControlSource - wird separat gesetzt
                8500, # Left
                60,   # Top
                260,  # Width
                240   # Height
            )
            chk_el.Name = "Einsatzleitung"
            # ControlSource muss manuell gesetzt werden
        except Exception as e:
            print(f"  Fehler Einsatzleitung: {e}")

        # Füge Info-Feld hinzu
        print("  Füge Info-Feld hinzu...")
        try:
            txt_info = bridge.access_app.CreateControl(
                "zsub_lstAuftrag",
                109,  # acTextBox
                0,    # acDetail
                "",   # Parent
                "",   # ControlSource
                8900, # Left
                0,    # Top
                1500, # Width
                300   # Height
            )
            txt_info.Name = "Information"
        except Exception as e:
            print(f"  Fehler Info: {e}")

        # Erweitere Formularbreite
        form.Width = 10500
        print(f"Neue Formularbreite: {form.Width} twips")

        # Speichern
        bridge.access_app.DoCmd.Close(2, "zsub_lstAuftrag", 1)  # acSaveYes
        print("\n[OK] Formular gespeichert!")

    except Exception as e:
        print(f"\n[FEHLER] {e}")
        import traceback
        traceback.print_exc()
        try:
            bridge.access_app.DoCmd.Close(2, "zsub_lstAuftrag", 2)
        except:
            pass

print("\n[FERTIG]")
