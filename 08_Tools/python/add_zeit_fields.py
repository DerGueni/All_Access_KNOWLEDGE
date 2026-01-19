# -*- coding: utf-8 -*-
"""
Fuegt Zeit1-Zeit4 Felder zu Unterformular und Sub-Bericht hinzu
"""

import win32com.client
import pythoncom
import time

def main():
    print("=" * 70)
    print("HINZUFUEGEN: Zeit1-Zeit4 Felder")
    print("=" * 70)

    pythoncom.CoInitialize()

    try:
        access = win32com.client.GetObject(Class="Access.Application")
        print("Access-Verbindung hergestellt!")

        # === 1. Unterformular erweitern ===
        print("\n" + "=" * 70)
        print("1. UNTERFORMULAR sub_OB_Objekt_Positionen erweitern")
        print("=" * 70)

        try:
            access.DoCmd.OpenForm("sub_OB_Objekt_Positionen", 1)  # acViewDesign
            time.sleep(1)

            frm = access.Forms("sub_OB_Objekt_Positionen")

            # Aktuelle Breite ermitteln
            current_width = frm.Width
            print(f"Aktuelle Formularbreite: {current_width} Twips")

            # Neue Textboxen fuer Zeit1-Zeit4 hinzufuegen
            # Position nach den existierenden Controls

            # Ermittle die Position des letzten Controls
            max_left = 0
            for i in range(frm.Controls.Count):
                ctl = frm.Controls.Item(i)
                if hasattr(ctl, 'Left'):
                    left = ctl.Left
                    width = ctl.Width if hasattr(ctl, 'Width') else 0
                    if left + width > max_left:
                        max_left = left + width

            print(f"Maximale Position: {max_left} Twips")

            # Neue Controls erstellen
            # 1 cm = 567 Twips
            control_width = 1000  # ca. 1.8 cm
            control_height = 300
            gap = 50
            start_left = max_left + gap

            zeit_fields = ['Zeit1', 'Zeit2', 'Zeit3', 'Zeit4']

            for i, field_name in enumerate(zeit_fields):
                left_pos = start_left + (i * (control_width + gap))

                # Textbox erstellen
                try:
                    # CreateControl(FormName, ControlType, Section, Parent, ColumnName, Left, Top, Width, Height)
                    # acTextBox = 109
                    new_ctl = access.CreateControl(
                        "sub_OB_Objekt_Positionen",  # Form
                        109,  # acTextBox
                        0,    # acDetail section
                        "",   # Parent
                        field_name,  # ColumnName (bindet an Feld)
                        left_pos,
                        0,
                        control_width,
                        control_height
                    )
                    new_ctl.Name = field_name
                    print(f"  TextBox '{field_name}' erstellt bei Position {left_pos}")

                except Exception as e:
                    print(f"  Fehler beim Erstellen von {field_name}: {e}")
                    # Alternative: Manuell Controls hinzufuegen
                    try:
                        section = frm.Section(0)  # Detail section
                        new_ctl = section.Controls.Add(109)  # acTextBox
                        new_ctl.Name = field_name
                        new_ctl.ControlSource = field_name
                        new_ctl.Left = left_pos
                        new_ctl.Width = control_width
                        print(f"  TextBox '{field_name}' (alternativ) erstellt")
                    except Exception as e2:
                        print(f"  Auch alternative Methode fehlgeschlagen: {e2}")

            # Formularbreite anpassen
            new_width = start_left + (4 * (control_width + gap)) + 500
            frm.Width = new_width
            print(f"Neue Formularbreite: {new_width} Twips")

            access.DoCmd.Close(2, "sub_OB_Objekt_Positionen", 1)  # acSaveYes
            print("Unterformular gespeichert!")

        except Exception as e:
            print(f"Unterformular-Fehler: {e}")
            try:
                access.DoCmd.Close(2, "sub_OB_Objekt_Positionen", 2)
            except:
                pass

        # === 2. Sub-Bericht erweitern ===
        print("\n" + "=" * 70)
        print("2. SUB-BERICHT rpt_OB_Objekt_Sub erweitern")
        print("=" * 70)

        try:
            access.DoCmd.OpenReport("rpt_OB_Objekt_Sub", 1)  # acViewDesign
            time.sleep(1)

            rpt = access.Reports("rpt_OB_Objekt_Sub")

            # Maximale Position ermitteln
            max_left = 0
            for i in range(rpt.Controls.Count):
                ctl = rpt.Controls.Item(i)
                if hasattr(ctl, 'Left'):
                    left = ctl.Left
                    width = ctl.Width if hasattr(ctl, 'Width') else 0
                    if left + width > max_left:
                        max_left = left + width

            print(f"Maximale Position: {max_left} Twips")

            # Neue Controls erstellen
            control_width = 800
            control_height = 280
            gap = 50
            start_left = max_left + gap

            zeit_fields = ['Zeit1', 'Zeit2', 'Zeit3', 'Zeit4']

            for i, field_name in enumerate(zeit_fields):
                left_pos = start_left + (i * (control_width + gap))

                try:
                    # CreateReportControl(ReportName, ControlType, Section, Parent, ColumnName, Left, Top, Width, Height)
                    new_ctl = access.CreateReportControl(
                        "rpt_OB_Objekt_Sub",
                        109,  # acTextBox
                        0,    # acDetail
                        "",
                        field_name,
                        left_pos,
                        0,
                        control_width,
                        control_height
                    )
                    new_ctl.Name = field_name
                    print(f"  TextBox '{field_name}' erstellt bei Position {left_pos}")

                except Exception as e:
                    print(f"  Fehler beim Erstellen von {field_name}: {e}")

            # Berichtsbreite anpassen
            new_width = start_left + (4 * (control_width + gap)) + 300
            rpt.Width = new_width
            print(f"Neue Berichtsbreite: {new_width} Twips")

            access.DoCmd.Close(3, "rpt_OB_Objekt_Sub", 1)  # acSaveYes
            print("Sub-Bericht gespeichert!")

        except Exception as e:
            print(f"Sub-Bericht-Fehler: {e}")
            try:
                access.DoCmd.Close(3, "rpt_OB_Objekt_Sub", 2)
            except:
                pass

        # === 3. Hauptbericht Zeit-Labels hinzufuegen ===
        print("\n" + "=" * 70)
        print("3. HAUPTBERICHT rpt_OB_Objekt mit Zeit-Labels")
        print("=" * 70)

        try:
            access.DoCmd.OpenReport("rpt_OB_Objekt", 1)  # acViewDesign
            time.sleep(1)

            rpt = access.Reports("rpt_OB_Objekt")

            # Suche nach dem SubReport Control
            subreport_ctl = None
            for i in range(rpt.Controls.Count):
                ctl = rpt.Controls.Item(i)
                if ctl.ControlType == 112:  # SubReport
                    subreport_ctl = ctl
                    print(f"SubReport gefunden: {ctl.Name}")
                    print(f"  Position: Left={ctl.Left}, Top={ctl.Top}")
                    print(f"  Groesse: Width={ctl.Width}, Height={ctl.Height}")
                    break

            if subreport_ctl:
                # Labels oberhalb des SubReports fuer Zeit-Spalten hinzufuegen
                # Diese sollen die Werte aus Zeit1_Label bis Zeit4_Label anzeigen

                # Position der Zeit-Spalten im SubReport berechnen
                # (Basierend auf der Analyse: die Zeit-Spalten sind am Ende)

                sub_left = subreport_ctl.Left
                sub_width = subreport_ctl.Width
                label_top = subreport_ctl.Top - 400  # Oberhalb des SubReports

                # Annahme: Zeit-Spalten beginnen bei ca. 75% der Breite
                zeit_start = sub_left + int(sub_width * 0.7)
                zeit_width = int(sub_width * 0.075)  # Jede Zeit-Spalte ca. 7.5%

                for i in range(4):
                    field_name = f"Zeit{i+1}_Label"
                    label_left = zeit_start + (i * zeit_width)

                    try:
                        # Label erstellen das den Wert aus der Tabelle anzeigt
                        new_label = access.CreateReportControl(
                            "rpt_OB_Objekt",
                            109,  # acTextBox (um Wert aus RecordSource zu zeigen)
                            3,    # acPageHeader oder Detail
                            "",
                            field_name,
                            label_left,
                            label_top,
                            zeit_width - 50,
                            300
                        )
                        new_label.Name = f"txt{field_name}"
                        print(f"  Zeit-Label '{field_name}' erstellt")

                    except Exception as e:
                        print(f"  Fehler beim Erstellen von {field_name}: {e}")

            access.DoCmd.Close(3, "rpt_OB_Objekt", 1)  # acSaveYes
            print("Hauptbericht gespeichert!")

        except Exception as e:
            print(f"Hauptbericht-Fehler: {e}")
            try:
                access.DoCmd.Close(3, "rpt_OB_Objekt", 2)
            except:
                pass

        print("\n" + "=" * 70)
        print("ZEIT-FELDER HINZUGEFUEGT")
        print("=" * 70)

        print("""
Die Zeit1-Zeit4 Felder wurden zu folgenden Objekten hinzugefuegt:
1. sub_OB_Objekt_Positionen (Unterformular)
2. rpt_OB_Objekt_Sub (Sub-Bericht)
3. rpt_OB_Objekt (Hauptbericht - Zeit-Labels)

Bitte pruefen Sie die Positionierung der neuen Felder
und passen Sie diese bei Bedarf manuell an.
""")

    except Exception as e:
        print(f"Hauptfehler: {e}")

    finally:
        pythoncom.CoUninitialize()

if __name__ == "__main__":
    main()
