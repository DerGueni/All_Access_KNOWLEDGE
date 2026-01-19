"""
Export Form Definition V2 - Mit korrekten Sektionshöhen und allen Details
"""

import win32com.client
import pythoncom
import json
import os

def export_form_definition(form_name):
    """Exportiert alle Eigenschaften eines Access-Formulars"""

    pythoncom.CoInitialize()

    try:
        # Verbinde mit laufender Access-Instanz
        access_app = win32com.client.GetObject(Class="Access.Application")
        print(f"Verbunden mit Access")

        # Öffne Formular in Design-Ansicht
        access_app.DoCmd.OpenForm(form_name, 1)  # 1 = acDesign
        print(f"Formular '{form_name}' in Design-Ansicht geöffnet")

        form = access_app.Forms(form_name)

        # Sektionen auslesen
        sections = {}
        section_names = {0: 'detail', 1: 'header', 2: 'footer', 3: 'page_header', 4: 'page_footer'}

        for sec_idx in range(5):
            try:
                section = form.Section(sec_idx)
                sections[section_names.get(sec_idx, f'section_{sec_idx}')] = {
                    'height': section.Height,
                    'back_color': section.BackColor if hasattr(section, 'BackColor') else None,
                    'visible': section.Visible if hasattr(section, 'Visible') else True
                }
                print(f"  Sektion {sec_idx} ({section_names.get(sec_idx)}): Höhe = {section.Height} twips ({section.Height/15:.0f} px)")
            except:
                pass

        # Formular-Eigenschaften
        form_props = {
            'name': form_name,
            'width': form.Width,
            'record_source': str(form.RecordSource) if form.RecordSource else None,
            'caption': str(form.Caption) if form.Caption else form_name,
            'default_view': form.DefaultView,
            'allow_edits': form.AllowEdits,
            'allow_deletions': form.AllowDeletions,
            'allow_additions': form.AllowAdditions,
            'scroll_bars': form.ScrollBars,
            'record_selectors': form.RecordSelectors,
            'navigation_buttons': form.NavigationButtons,
            'dividing_lines': form.DividingLines,
            'auto_center': form.AutoCenter,
            'border_style': form.BorderStyle,
            'sections': sections,
            'controls': []
        }

        # Controls nach Sektion gruppieren
        controls_by_section = {0: [], 1: [], 2: [], 3: [], 4: []}

        for ctl in form.Controls:
            control_info = {
                'name': ctl.Name,
                'control_type': ctl.ControlType,
                'left': ctl.Left,
                'top': ctl.Top,
                'width': ctl.Width,
                'height': ctl.Height,
            }

            # Control-Type-Namen zuordnen
            control_types = {
                100: 'Label',
                104: 'CommandButton',
                109: 'TextBox',
                110: 'ListBox',
                111: 'ComboBox',
                112: 'SubForm',
                106: 'CheckBox',
                105: 'OptionButton',
                107: 'OptionGroup',
                114: 'Line',
                115: 'Rectangle',
                116: 'PageBreak',
                118: 'TabControl',
                122: 'Image',
                119: 'Page',
                103: 'BoundObjectFrame',
                101: 'UnboundObjectFrame',
                102: 'AttachmentControl',
                123: 'CustomControl',
                124: 'WebBrowser',
                126: 'NavigationControl',
                127: 'NavigationButton'
            }

            control_info['type_name'] = control_types.get(ctl.ControlType, f'Unknown({ctl.ControlType})')

            # Sektion
            try:
                control_info['section'] = ctl.Section
            except:
                control_info['section'] = 0

            # Zusätzliche Eigenschaften
            try:
                control_info['caption'] = str(ctl.Caption) if hasattr(ctl, 'Caption') and ctl.Caption else None
            except:
                control_info['caption'] = None

            try:
                control_info['control_source'] = str(ctl.ControlSource) if hasattr(ctl, 'ControlSource') and ctl.ControlSource else None
            except:
                control_info['control_source'] = None

            try:
                control_info['font_name'] = str(ctl.FontName) if hasattr(ctl, 'FontName') else 'Arial'
                control_info['font_size'] = ctl.FontSize if hasattr(ctl, 'FontSize') else 10
                control_info['font_bold'] = ctl.FontBold if hasattr(ctl, 'FontBold') else False
            except:
                control_info['font_name'] = 'Arial'
                control_info['font_size'] = 10
                control_info['font_bold'] = False

            try:
                control_info['fore_color'] = ctl.ForeColor if hasattr(ctl, 'ForeColor') else 0
                control_info['back_color'] = ctl.BackColor if hasattr(ctl, 'BackColor') else 16777215
            except:
                control_info['fore_color'] = 0
                control_info['back_color'] = 16777215

            try:
                control_info['visible'] = ctl.Visible if hasattr(ctl, 'Visible') else True
            except:
                control_info['visible'] = True

            try:
                control_info['enabled'] = ctl.Enabled if hasattr(ctl, 'Enabled') else True
            except:
                control_info['enabled'] = True

            # RowSource für ComboBox/ListBox
            try:
                if hasattr(ctl, 'RowSource') and ctl.RowSource:
                    control_info['row_source'] = str(ctl.RowSource)
                    control_info['row_source_type'] = ctl.RowSourceType if hasattr(ctl, 'RowSourceType') else None
                    control_info['column_count'] = ctl.ColumnCount if hasattr(ctl, 'ColumnCount') else 1
                    control_info['bound_column'] = ctl.BoundColumn if hasattr(ctl, 'BoundColumn') else 1
                    control_info['column_widths'] = str(ctl.ColumnWidths) if hasattr(ctl, 'ColumnWidths') else None
            except:
                pass

            # SubForm-Eigenschaften
            try:
                if ctl.ControlType == 112:  # SubForm
                    control_info['source_object'] = str(ctl.SourceObject) if hasattr(ctl, 'SourceObject') else None
                    control_info['link_child_fields'] = str(ctl.LinkChildFields) if hasattr(ctl, 'LinkChildFields') else None
                    control_info['link_master_fields'] = str(ctl.LinkMasterFields) if hasattr(ctl, 'LinkMasterFields') else None
            except:
                pass

            # TabControl-Eigenschaften
            try:
                if ctl.ControlType == 118:  # TabControl
                    pages = []
                    for i in range(ctl.Pages.Count):
                        page = ctl.Pages(i)
                        pages.append({
                            'name': page.Name,
                            'caption': str(page.Caption) if page.Caption else page.Name,
                            'page_index': page.PageIndex
                        })
                    control_info['pages'] = pages
            except:
                pass

            try:
                control_info['tab_index'] = ctl.TabIndex if hasattr(ctl, 'TabIndex') else None
            except:
                pass

            try:
                control_info['border_style'] = ctl.BorderStyle if hasattr(ctl, 'BorderStyle') else 0
                control_info['border_color'] = ctl.BorderColor if hasattr(ctl, 'BorderColor') else 0
                control_info['border_width'] = ctl.BorderWidth if hasattr(ctl, 'BorderWidth') else 0
            except:
                pass

            try:
                control_info['special_effect'] = ctl.SpecialEffect if hasattr(ctl, 'SpecialEffect') else 0
            except:
                pass

            # Text-Alignment
            try:
                control_info['text_align'] = ctl.TextAlign if hasattr(ctl, 'TextAlign') else 0
            except:
                pass

            # Parent für verschachtelte Controls (z.B. in TabControl)
            try:
                if hasattr(ctl, 'Parent') and ctl.Parent:
                    parent_name = ctl.Parent.Name
                    if parent_name != form_name:
                        control_info['parent'] = parent_name
            except:
                pass

            form_props['controls'].append(control_info)

            # Nach Sektion gruppieren
            sec = control_info.get('section', 0)
            if sec in controls_by_section:
                controls_by_section[sec].append(control_info['name'])

        # Schließe Formular ohne zu speichern
        access_app.DoCmd.Close(2, form_name, 2)  # 2 = acSaveNo

        print(f"\n=== Controls nach Sektion ===")
        for sec, names in controls_by_section.items():
            if names:
                print(f"  Sektion {sec}: {len(names)} Controls")

        return form_props

    except Exception as e:
        print(f"Fehler: {e}")
        import traceback
        traceback.print_exc()
        return None
    finally:
        pythoncom.CoUninitialize()


if __name__ == "__main__":
    form_name = "frm_MA_Mitarbeiterstamm"

    print(f"\n=== Exportiere Formular-Definition V2: {form_name} ===\n")

    props = export_form_definition(form_name)

    if props:
        # In JSON speichern
        output_path = r"C:\Users\guenther.siegert\Documents\0000\0_frms_Fertig\frm_MA_Mitarbeiterstamm_definition_v2.json"

        # Ordner erstellen wenn nicht vorhanden
        os.makedirs(os.path.dirname(output_path), exist_ok=True)

        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(props, f, indent=2, ensure_ascii=False, default=str)

        print(f"\nDefinition gespeichert in: {output_path}")

        # Zusammenfassung
        print(f"\n=== Zusammenfassung ===")
        print(f"Formular: {props['name']}")
        print(f"Breite: {props['width']} twips ({props['width']/15:.0f} Pixel)")
        print(f"Record Source: {props['record_source']}")
        print(f"Controls: {len(props['controls'])}")

        print(f"\nSektionen:")
        for name, sec in props['sections'].items():
            print(f"  {name}: {sec['height']} twips ({sec['height']/15:.0f} px)")

        # Nach Typ gruppieren
        type_counts = {}
        for ctl in props['controls']:
            t = ctl['type_name']
            type_counts[t] = type_counts.get(t, 0) + 1

        print("\nControl-Typen:")
        for t, count in sorted(type_counts.items()):
            print(f"  {t}: {count}")
