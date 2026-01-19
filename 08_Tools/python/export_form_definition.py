"""
Export Form Definition - Exportiert Formular-Eigenschaften für WinForms-Nachbau
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
            'controls': []
        }

        # Sektionen
        sections = {}
        try:
            # Detail-Sektion (0)
            sections['detail'] = {
                'height': form.Section(0).Height
            }
        except:
            pass

        try:
            # Form Header (1)
            sections['header'] = {
                'height': form.Section(1).Height
            }
        except:
            pass

        try:
            # Form Footer (2)
            sections['footer'] = {
                'height': form.Section(2).Height
            }
        except:
            pass

        form_props['sections'] = sections

        # Controls
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
                124: 'WebBrowser',
                126: 'NavigationControl',
                127: 'NavigationButton'
            }

            control_info['type_name'] = control_types.get(ctl.ControlType, f'Unknown({ctl.ControlType})')

            # Zusätzliche Eigenschaften je nach Control-Typ
            try:
                control_info['caption'] = str(ctl.Caption) if hasattr(ctl, 'Caption') and ctl.Caption else None
            except:
                pass

            try:
                control_info['control_source'] = str(ctl.ControlSource) if hasattr(ctl, 'ControlSource') and ctl.ControlSource else None
            except:
                pass

            try:
                control_info['font_name'] = str(ctl.FontName) if hasattr(ctl, 'FontName') else None
                control_info['font_size'] = ctl.FontSize if hasattr(ctl, 'FontSize') else None
                control_info['font_bold'] = ctl.FontBold if hasattr(ctl, 'FontBold') else None
            except:
                pass

            try:
                control_info['fore_color'] = ctl.ForeColor if hasattr(ctl, 'ForeColor') else None
                control_info['back_color'] = ctl.BackColor if hasattr(ctl, 'BackColor') else None
            except:
                pass

            try:
                control_info['visible'] = ctl.Visible if hasattr(ctl, 'Visible') else True
            except:
                control_info['visible'] = True

            try:
                control_info['enabled'] = ctl.Enabled if hasattr(ctl, 'Enabled') else True
            except:
                control_info['enabled'] = True

            try:
                if hasattr(ctl, 'RowSource') and ctl.RowSource:
                    control_info['row_source'] = str(ctl.RowSource)
                    control_info['row_source_type'] = ctl.RowSourceType if hasattr(ctl, 'RowSourceType') else None
                    control_info['column_count'] = ctl.ColumnCount if hasattr(ctl, 'ColumnCount') else None
                    control_info['bound_column'] = ctl.BoundColumn if hasattr(ctl, 'BoundColumn') else None
            except:
                pass

            try:
                if ctl.ControlType == 112:  # SubForm
                    control_info['source_object'] = str(ctl.SourceObject) if hasattr(ctl, 'SourceObject') else None
                    control_info['link_child_fields'] = str(ctl.LinkChildFields) if hasattr(ctl, 'LinkChildFields') else None
                    control_info['link_master_fields'] = str(ctl.LinkMasterFields) if hasattr(ctl, 'LinkMasterFields') else None
            except:
                pass

            try:
                if hasattr(ctl, 'Section'):
                    control_info['section'] = ctl.Section
            except:
                pass

            try:
                control_info['tab_index'] = ctl.TabIndex if hasattr(ctl, 'TabIndex') else None
            except:
                pass

            try:
                control_info['border_style'] = ctl.BorderStyle if hasattr(ctl, 'BorderStyle') else None
                control_info['border_color'] = ctl.BorderColor if hasattr(ctl, 'BorderColor') else None
                control_info['border_width'] = ctl.BorderWidth if hasattr(ctl, 'BorderWidth') else None
            except:
                pass

            try:
                control_info['special_effect'] = ctl.SpecialEffect if hasattr(ctl, 'SpecialEffect') else None
            except:
                pass

            form_props['controls'].append(control_info)

        # Schließe Formular ohne zu speichern
        access_app.DoCmd.Close(2, form_name, 2)  # 2 = acSaveNo

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

    print(f"\n=== Exportiere Formular-Definition: {form_name} ===\n")

    props = export_form_definition(form_name)

    if props:
        # In JSON speichern
        output_path = r"C:\Users\guenther.siegert\Documents\0000\0_frms_Fertig\frm_MA_Mitarbeiterstamm_definition.json"

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

        # Nach Typ gruppieren
        type_counts = {}
        for ctl in props['controls']:
            t = ctl['type_name']
            type_counts[t] = type_counts.get(t, 0) + 1

        print("\nControl-Typen:")
        for t, count in sorted(type_counts.items()):
            print(f"  {t}: {count}")
