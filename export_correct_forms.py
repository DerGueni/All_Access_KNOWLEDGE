"""
Export der korrekten 11 Access-Formulare zu MD-Dateien
"""
import sys
import os

sys.path.append(r'C:\Users\guenther.siegert\Documents\Access Bridge')
from access_bridge_ultimate import AccessBridge

# Korrigierte Formularliste basierend auf verfuegbaren Formularen
FORMS_TO_EXPORT = [
    'frmTop_Geo_Verwaltung',        # OK - existiert
    'frmOff_Outlook_aufrufen',      # Aehnlich zu frmOff_WinWord
    'zfrm_Lohnabrechnungen',        # Lohnabrechnungen
    'zfrm_MA_Stunden_Lexware',      # Stunden-Export
    'zfrm_Rueckmeldungen',          # Rueckmeldungen
    'frm_Kundenpreise',             # Kundenpreise
    'frm_MA_Maintainance',          # MA-Verwaltung
    'frm_Zeiterfassung',            # Zeiterfassung
    'frm_Rechnungen_bezahlt_offen', # Rechnungen
    'frm_Umsatzuebersicht_2',       # Umsatzauswertung
    'frm_Startmenue'                # Startmenue
]

OUTPUT_DIR = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\Access_Abgleich\forms'

def get_color_name(color_value):
    """Konvertiere Access-Farbwert zu lesbarem Namen"""
    if color_value is None:
        return "-"

    color_map = {
        16777215: "Weiss",
        0: "Schwarz",
        8355711: "Grau",
        4210752: "Dunkelgrau",
        10921638: "Hellgrau",
        8210719: "Blau",
        255: "Rot",
        65280: "Gruen",
        16777088: "Gelb"
    }

    return f"{color_value} ({color_map.get(color_value, 'Unbekannt')})"

def get_view_name(view_value):
    """Konvertiere DefaultView zu lesbarem Namen"""
    view_map = {
        0: "SingleForm",
        1: "Continuous",
        2: "Datasheet",
        3: "PivotTable",
        4: "PivotChart",
        5: "SplitForm"
    }
    return view_map.get(view_value, f"Unknown ({view_value})")

def get_control_type_name(ctrl):
    """Bestimme Control-Typ"""
    try:
        type_value = ctrl.ControlType
        type_map = {
            100: "Label",
            104: "CommandButton",
            109: "TextBox",
            110: "ListBox",
            111: "ComboBox",
            112: "Subform",
            106: "OptionButton",
            107: "OptionGroup",
            108: "CheckBox",
            103: "ToggleButton",
            114: "Image",
            105: "BoundObjectFrame",
            113: "TabControl",
            122: "Rectangle",
            118: "Line"
        }
        return type_map.get(type_value, f"Unknown ({type_value})")
    except:
        return "Unknown"

def export_form_to_md(bridge, form_name):
    """Exportiere ein Formular zu MD"""
    print(f"\nExportiere {form_name}...")

    try:
        app = bridge.access_app

        # Formular im Design-Modus oeffnen
        app.DoCmd.OpenForm(form_name, 0)
        frm = app.Forms(form_name)

        # Metadaten sammeln
        md_content = f"# {form_name}\n\n"
        md_content += "## Formular-Metadaten\n\n"
        md_content += "| Eigenschaft | Wert |\n"
        md_content += "|-------------|------|\n"
        md_content += f"| **Name** | {form_name} |\n"

        try:
            record_source = frm.RecordSource if frm.RecordSource else "-"
            md_content += f"| **Datensatzquelle** | {record_source} |\n"

            if record_source and record_source != "-":
                if record_source.upper().startswith("SELECT"):
                    md_content += f"| **Datenquellentyp** | SQL |\n"
                elif "qry_" in record_source.lower():
                    md_content += f"| **Datenquellentyp** | Query |\n"
                elif "tbl_" in record_source.lower():
                    md_content += f"| **Datenquellentyp** | Table |\n"
                else:
                    md_content += f"| **Datenquellentyp** | Unknown |\n"
        except:
            md_content += f"| **Datensatzquelle** | - |\n"
            md_content += f"| **Datenquellentyp** | - |\n"

        try:
            default_view = get_view_name(frm.DefaultView)
            md_content += f"| **Default View** | {default_view} |\n"
        except:
            md_content += f"| **Default View** | - |\n"

        try:
            md_content += f"| **Allow Edits** | {'Ja' if frm.AllowEdits else 'Nein'} |\n"
        except:
            md_content += f"| **Allow Edits** | - |\n"

        try:
            md_content += f"| **Allow Additions** | {'Ja' if frm.AllowAdditions else 'Nein'} |\n"
        except:
            md_content += f"| **Allow Additions** | - |\n"

        try:
            md_content += f"| **Allow Deletions** | {'Ja' if frm.AllowDeletions else 'Nein'} |\n"
        except:
            md_content += f"| **Allow Deletions** | - |\n"

        try:
            md_content += f"| **Data Entry** | {'Ja' if frm.DataEntry else 'Nein'} |\n"
        except:
            md_content += f"| **Data Entry** | - |\n"

        try:
            md_content += f"| **Navigation Buttons** | {'Ja' if frm.NavigationButtons else 'Nein'} |\n"
        except:
            md_content += f"| **Navigation Buttons** | - |\n"

        md_content += "\n## Controls\n\n"

        # Controls nach Typ gruppieren
        controls_by_type = {}

        for ctrl in frm.Controls:
            try:
                ctrl_type = get_control_type_name(ctrl)
                if ctrl_type not in controls_by_type:
                    controls_by_type[ctrl_type] = []

                ctrl_info = {
                    'name': ctrl.Name,
                    'type': ctrl_type
                }

                try:
                    ctrl_info['control_source'] = ctrl.ControlSource if ctrl.ControlSource else "-"
                except:
                    ctrl_info['control_source'] = "-"

                try:
                    ctrl_info['caption'] = ctrl.Caption if ctrl.Caption else "-"
                except:
                    ctrl_info['caption'] = "-"

                try:
                    ctrl_info['left'] = ctrl.Left
                    ctrl_info['top'] = ctrl.Top
                    ctrl_info['width'] = ctrl.Width
                    ctrl_info['height'] = ctrl.Height
                except:
                    ctrl_info['left'] = "-"
                    ctrl_info['top'] = "-"
                    ctrl_info['width'] = "-"
                    ctrl_info['height'] = "-"

                try:
                    ctrl_info['forecolor'] = get_color_name(ctrl.ForeColor)
                except:
                    ctrl_info['forecolor'] = "-"

                try:
                    ctrl_info['backcolor'] = get_color_name(ctrl.BackColor)
                except:
                    ctrl_info['backcolor'] = "-"

                try:
                    ctrl_info['tab_index'] = ctrl.TabIndex
                except:
                    ctrl_info['tab_index'] = "-"

                # Events pruefen
                events = []
                event_props = ['OnClick', 'AfterUpdate', 'BeforeUpdate', 'OnChange',
                              'OnDblClick', 'OnEnter', 'OnExit', 'GotFocus', 'LostFocus']

                for event_prop in event_props:
                    try:
                        event_val = getattr(ctrl, event_prop, None)
                        if event_val and str(event_val).strip():
                            events.append(f"{event_prop}: {event_val}")
                    except:
                        pass

                ctrl_info['events'] = events

                controls_by_type[ctrl_type].append(ctrl_info)
            except Exception as e:
                pass

        # Controls nach Typ ausgeben
        for ctrl_type in sorted(controls_by_type.keys()):
            ctrls = controls_by_type[ctrl_type]

            if ctrl_type == "Label":
                md_content += f"### Labels (Bezeichnungsfelder)\n\n"
                md_content += "| Name | Position (L/T) | Groesse (W/H) | ForeColor |\n"
                md_content += "|------|----------------|---------------|-----------||\n"
                for ctrl in ctrls:
                    md_content += f"| {ctrl['name']} | {ctrl['left']} / {ctrl['top']} | {ctrl['width']} x {ctrl['height']} | {ctrl['forecolor']} |\n"

            elif ctrl_type == "TextBox":
                md_content += f"\n### TextBoxen\n\n"
                md_content += "| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |\n"
                md_content += "|------|----------------|----------------|---------------|----------||\n"
                for ctrl in ctrls:
                    md_content += f"| {ctrl['name']} | {ctrl['control_source']} | {ctrl['left']} / {ctrl['top']} | {ctrl['width']} x {ctrl['height']} | {ctrl['tab_index']} |\n"

            elif ctrl_type == "CommandButton":
                md_content += f"\n### Buttons (Schaltflaechen)\n\n"
                md_content += "| Name | Caption | Position (L/T) | Groesse (W/H) | Events |\n"
                md_content += "|------|---------|----------------|---------------|--------|\n"
                for ctrl in ctrls:
                    events_str = "; ".join(ctrl['events']) if ctrl['events'] else "-"
                    md_content += f"| {ctrl['name']} | {ctrl['caption']} | {ctrl['left']} / {ctrl['top']} | {ctrl['width']} x {ctrl['height']} | {events_str} |\n"

            elif ctrl_type == "ComboBox":
                md_content += f"\n### ComboBoxen (Auswahllisten)\n\n"
                md_content += "| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |\n"
                md_content += "|------|----------------|----------------|---------------|----------|\n"
                for ctrl in ctrls:
                    md_content += f"| {ctrl['name']} | {ctrl['control_source']} | {ctrl['left']} / {ctrl['top']} | {ctrl['width']} x {ctrl['height']} | {ctrl['tab_index']} |\n"

            elif ctrl_type == "Subform":
                md_content += f"\n### Subforms (Unterformulare)\n\n"
                md_content += "| Name | Source Object | Position (L/T) | Groesse (W/H) |\n"
                md_content += "|------|---------------|----------------|---------------|\n"
                for ctrl in ctrls:
                    md_content += f"| {ctrl['name']} | {ctrl['control_source']} | {ctrl['left']} / {ctrl['top']} | {ctrl['width']} x {ctrl['height']} |\n"

            else:
                md_content += f"\n### {ctrl_type}s\n\n"
                md_content += "| Name | Caption | Position (L/T) | Groesse (W/H) |\n"
                md_content += "|------|---------|----------------|---------------|\n"
                for ctrl in ctrls:
                    md_content += f"| {ctrl['name']} | {ctrl['caption']} | {ctrl['left']} / {ctrl['top']} | {ctrl['width']} x {ctrl['height']} |\n"

        # Events-Sektion
        md_content += "\n## Events\n\n"
        md_content += "### Formular-Events\n"

        form_events = []
        form_event_props = ['OnOpen', 'OnLoad', 'OnClose', 'OnCurrent',
                           'BeforeUpdate', 'AfterUpdate', 'OnActivate', 'OnDeactivate']

        for event_prop in form_event_props:
            try:
                event_val = getattr(frm, event_prop, None)
                if event_val and str(event_val).strip():
                    form_events.append(f"- {event_prop}: {event_val}")
                else:
                    form_events.append(f"- {event_prop}: Keine")
            except:
                form_events.append(f"- {event_prop}: Keine")

        md_content += "\n".join(form_events) + "\n"

        # VBA-Code extrahieren
        md_content += "\n## VBA-Code\n\n"

        try:
            if frm.HasModule:
                md_content += "```vba\n"
                try:
                    vba_project = app.VBE.ActiveVBProject
                    for component in vba_project.VBComponents:
                        if component.Name == f"Form_{form_name}":
                            code_module = component.CodeModule
                            line_count = code_module.CountOfLines
                            if line_count > 0:
                                vba_code = code_module.Lines(1, line_count)
                                md_content += vba_code
                            break
                except Exception as e:
                    md_content += f"' VBA-Code konnte nicht extrahiert werden: {e}\n"

                md_content += "```\n"
            else:
                md_content += "Kein VBA-Code vorhanden.\n"
        except:
            md_content += "VBA-Status konnte nicht ermittelt werden.\n"

        # Formular schliessen
        app.DoCmd.Close(2, form_name, 2)

        # MD-Datei schreiben
        output_path = os.path.join(OUTPUT_DIR, f"{form_name}.md")
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(md_content)

        print(f"  OK Exportiert nach: {output_path}")
        return True

    except Exception as e:
        print(f"  FEHLER beim Export: {e}")
        try:
            app.DoCmd.Close(2, form_name, 2)
        except:
            pass
        return False

def main():
    print("=" * 60)
    print("Export von 11 Access-Formularen zu MD-Dateien")
    print("=" * 60)

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    success_count = 0
    failed_forms = []

    with AccessBridge() as bridge:
        for form_name in FORMS_TO_EXPORT:
            if export_form_to_md(bridge, form_name):
                success_count += 1
            else:
                failed_forms.append(form_name)

    print("\n" + "=" * 60)
    print("Export abgeschlossen")
    print("=" * 60)
    print(f"Erfolgreich: {success_count}/{len(FORMS_TO_EXPORT)}")

    if failed_forms:
        print(f"\nFehlgeschlagen:")
        for form in failed_forms:
            print(f"  - {form}")

    print(f"\nAusgabe-Ordner: {OUTPUT_DIR}")

if __name__ == '__main__':
    main()
