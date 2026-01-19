# -*- coding: utf-8 -*-
"""
Exakte WinForms-Generierung aus Access Form JSON-Definition
Erstellt ein 1:1 Abbild des Access-Formulars
"""

import json
import os

# Twips zu Pixel Konvertierung (Access verwendet Twips: 1 Twip = 1/15 Pixel)
def twips_to_px(twips):
    return int(twips / 15)

# Access BGR zu .NET RGB Konvertierung
def access_color_to_rgb(color):
    if color is None:
        return (255, 255, 255)
    if color < 0:
        # System-Farben
        if color == -2147483616:  # vbWindowText
            return (0, 0, 0)
        elif color == -2147483643:  # vbButtonFace
            return (240, 240, 240)
        elif color == -2147483633:  # vbHighlight
            return (0, 120, 215)
        elif color == -2147483630:  # vbButtonText
            return (0, 0, 0)
        elif color == -2147483607:  # vbMenu
            return (240, 240, 240)
        else:
            return (0, 0, 0)
    else:
        # Access speichert als RGB (nicht BGR!) - nur extrahieren
        r = color & 0xFF
        g = (color >> 8) & 0xFF
        b = (color >> 16) & 0xFF
        return (r, g, b)

def rgb_to_color_string(rgb):
    return f"Color.FromArgb({rgb[0]}, {rgb[1]}, {rgb[2]})"

# JSON laden
json_path = r"C:\Users\guenther.siegert\Documents\0000\0_frms_Fertig\frm_MA_Mitarbeiterstamm_definition_v2.json"
output_dir = r"C:\Users\guenther.siegert\Documents\0000\0_frms_Fertig\frm_MA_Mitarbeiterstamm"

with open(json_path, 'r', encoding='utf-8') as f:
    form_def = json.load(f)

# Dimensionen berechnen
form_width_px = twips_to_px(form_def['width'])
header_height_px = twips_to_px(form_def['sections']['header']['height'])
detail_height_px = twips_to_px(form_def['sections']['detail']['height'])
footer_height_px = twips_to_px(form_def['sections']['footer']['height'])

# Header-Hintergrundfarbe
header_bg = access_color_to_rgb(form_def['sections']['header']['back_color'])
detail_bg = access_color_to_rgb(form_def['sections']['detail']['back_color'])
footer_bg = access_color_to_rgb(form_def['sections']['footer']['back_color'])

print(f"Form Width: {form_width_px}px")
print(f"Header Height: {header_height_px}px, BG: {header_bg}")
print(f"Detail Height: {detail_height_px}px, BG: {detail_bg}")
print(f"Footer Height: {footer_height_px}px, BG: {footer_bg}")

# Controls nach Section sortieren
header_controls = []
detail_controls = []
footer_controls = []

for ctrl in form_def['controls']:
    section = ctrl.get('section', 0)
    if section == 1:  # Header
        header_controls.append(ctrl)
    elif section == 2:  # Footer
        footer_controls.append(ctrl)
    else:  # Detail (0)
        detail_controls.append(ctrl)

print(f"\nHeader Controls: {len(header_controls)}")
print(f"Detail Controls: {len(detail_controls)}")
print(f"Footer Controls: {len(footer_controls)}")

# Zeige Tab-Control Info
for ctrl in detail_controls:
    if ctrl['type_name'] == 'CustomControl' and 'reg' in ctrl['name']:
        print(f"\nTab Control: {ctrl['name']}")
        print(f"  Position: {twips_to_px(ctrl['left'])}px, {twips_to_px(ctrl['top'])}px")
        print(f"  Size: {twips_to_px(ctrl['width'])}px x {twips_to_px(ctrl['height'])}px")
        print(f"  BackColor: {access_color_to_rgb(ctrl['back_color'])}")

# Tab Pages finden
tab_pages = []
for ctrl in detail_controls:
    if ctrl['type_name'] == 'WebBrowser' and ctrl.get('parent') == 'reg_MA':
        tab_pages.append(ctrl)
        print(f"\nTab Page: {ctrl['name']} - Caption: {ctrl.get('caption', 'N/A')}")

# Controls innerhalb Tab Pages zählen
for page in tab_pages:
    page_controls = [c for c in detail_controls if c.get('parent') == page['name']]
    print(f"  {page['name']}: {len(page_controls)} controls")

# Generiere Designer.cs
def generate_control_name(ctrl_name):
    # Bereinige Namen für C#
    name = ctrl_name.replace(' ', '_').replace('-', '_').replace('.', '_')
    if name[0].isdigit():
        name = '_' + name
    return name

def escape_string(s):
    if s is None:
        return ""
    return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r')

# Beginne mit Designer.cs
designer_code = '''namespace frm_MA_Mitarbeiterstamm
{
    partial class MainForm
    {
        private System.ComponentModel.IContainer components = null;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        private void InitializeComponent()
        {
            this.SuspendLayout();
'''

# Form properties - GENAU wie Access
total_height = header_height_px + detail_height_px + footer_height_px
designer_code += f'''
            //
            // MainForm - EXAKT wie Access Form
            //
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb({detail_bg[0]}, {detail_bg[1]}, {detail_bg[2]});
            this.ClientSize = new System.Drawing.Size({form_width_px}, {total_height});
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "MainForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "{escape_string(form_def.get('caption', 'Mitarbeiterstamm'))}";
'''

# Header Panel
designer_code += f'''
            //
            // pnlHeader - Header Section
            //
            this.pnlHeader = new System.Windows.Forms.Panel();
            this.pnlHeader.BackColor = System.Drawing.Color.FromArgb({header_bg[0]}, {header_bg[1]}, {header_bg[2]});
            this.pnlHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlHeader.Location = new System.Drawing.Point(0, 0);
            this.pnlHeader.Name = "pnlHeader";
            this.pnlHeader.Size = new System.Drawing.Size({form_width_px}, {header_height_px});
            this.Controls.Add(this.pnlHeader);
'''

# Footer Panel
designer_code += f'''
            //
            // pnlFooter - Footer Section
            //
            this.pnlFooter = new System.Windows.Forms.Panel();
            this.pnlFooter.BackColor = System.Drawing.Color.FromArgb({footer_bg[0]}, {footer_bg[1]}, {footer_bg[2]});
            this.pnlFooter.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlFooter.Location = new System.Drawing.Point(0, {header_height_px + detail_height_px});
            this.pnlFooter.Name = "pnlFooter";
            this.pnlFooter.Size = new System.Drawing.Size({form_width_px}, {footer_height_px});
            this.Controls.Add(this.pnlFooter);
'''

# Detail Panel
designer_code += f'''
            //
            // pnlDetail - Detail Section
            //
            this.pnlDetail = new System.Windows.Forms.Panel();
            this.pnlDetail.BackColor = System.Drawing.Color.FromArgb({detail_bg[0]}, {detail_bg[1]}, {detail_bg[2]});
            this.pnlDetail.Location = new System.Drawing.Point(0, {header_height_px});
            this.pnlDetail.Name = "pnlDetail";
            this.pnlDetail.Size = new System.Drawing.Size({form_width_px}, {detail_height_px});
            this.Controls.Add(this.pnlDetail);
'''

# Zähler für generierte Controls
control_declarations = []
control_count = 0
skipped_controls = []

# Header Controls generieren
for ctrl in header_controls:
    if not ctrl.get('visible', True):
        continue

    ctrl_name = generate_control_name(ctrl['name'])
    type_name = ctrl['type_name']

    left = twips_to_px(ctrl['left'])
    top = twips_to_px(ctrl['top'])
    width = twips_to_px(ctrl['width'])
    height = twips_to_px(ctrl['height'])

    fore_color = access_color_to_rgb(ctrl.get('fore_color', 0))
    back_color = access_color_to_rgb(ctrl.get('back_color', 16777215))

    font_name = ctrl.get('font_name', 'Arial')
    font_size = ctrl.get('font_size', 10)
    font_bold = ctrl.get('font_bold', 0)
    font_style = 'System.Drawing.FontStyle.Bold' if font_bold else 'System.Drawing.FontStyle.Regular'

    caption = escape_string(ctrl.get('caption', ''))

    if type_name == 'Label':
        control_declarations.append(f'private System.Windows.Forms.Label {ctrl_name};')
        designer_code += f'''
            //
            // {ctrl_name} (Label)
            //
            this.{ctrl_name} = new System.Windows.Forms.Label();
            this.{ctrl_name}.AutoSize = false;
            this.{ctrl_name}.BackColor = System.Drawing.Color.FromArgb({back_color[0]}, {back_color[1]}, {back_color[2]});
            this.{ctrl_name}.ForeColor = System.Drawing.Color.FromArgb({fore_color[0]}, {fore_color[1]}, {fore_color[2]});
            this.{ctrl_name}.Font = new System.Drawing.Font("{font_name}", {font_size}F, {font_style});
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Name = "{ctrl_name}";
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.{ctrl_name}.Text = "{caption}";
            this.{ctrl_name}.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.pnlHeader.Controls.Add(this.{ctrl_name});
'''
        control_count += 1

    elif type_name == 'CommandButton':
        control_declarations.append(f'private System.Windows.Forms.Button {ctrl_name};')
        designer_code += f'''
            //
            // {ctrl_name} (Button)
            //
            this.{ctrl_name} = new System.Windows.Forms.Button();
            this.{ctrl_name}.BackColor = System.Drawing.Color.FromArgb({back_color[0]}, {back_color[1]}, {back_color[2]});
            this.{ctrl_name}.ForeColor = System.Drawing.Color.FromArgb({fore_color[0]}, {fore_color[1]}, {fore_color[2]});
            this.{ctrl_name}.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.{ctrl_name}.FlatAppearance.BorderSize = 1;
            this.{ctrl_name}.Font = new System.Drawing.Font("{font_name}", {font_size}F, {font_style});
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Name = "{ctrl_name}";
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.{ctrl_name}.Text = "{caption}";
            this.{ctrl_name}.UseVisualStyleBackColor = false;
            this.pnlHeader.Controls.Add(this.{ctrl_name});
'''
        control_count += 1

    elif type_name == 'TextBox':
        control_declarations.append(f'private System.Windows.Forms.TextBox {ctrl_name};')
        designer_code += f'''
            //
            // {ctrl_name} (TextBox)
            //
            this.{ctrl_name} = new System.Windows.Forms.TextBox();
            this.{ctrl_name}.BackColor = System.Drawing.Color.FromArgb({back_color[0]}, {back_color[1]}, {back_color[2]});
            this.{ctrl_name}.ForeColor = System.Drawing.Color.FromArgb({fore_color[0]}, {fore_color[1]}, {fore_color[2]});
            this.{ctrl_name}.Font = new System.Drawing.Font("{font_name}", {font_size}F, {font_style});
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Name = "{ctrl_name}";
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.pnlHeader.Controls.Add(this.{ctrl_name});
'''
        control_count += 1
    else:
        skipped_controls.append((ctrl_name, type_name))

# Detail Controls - Tab Control
# Finde das reg_MA Tab Control
reg_ma = None
for ctrl in detail_controls:
    if ctrl['name'] == 'reg_MA':
        reg_ma = ctrl
        break

if reg_ma:
    tab_left = twips_to_px(reg_ma['left'])
    tab_top = twips_to_px(reg_ma['top'])
    tab_width = twips_to_px(reg_ma['width'])
    tab_height = twips_to_px(reg_ma['height'])
    tab_bg = access_color_to_rgb(reg_ma.get('back_color', 14277081))

    control_declarations.append('private System.Windows.Forms.TabControl tabControl;')
    designer_code += f'''
            //
            // tabControl - TabControl (reg_MA)
            //
            this.tabControl = new System.Windows.Forms.TabControl();
            this.tabControl.Location = new System.Drawing.Point({tab_left}, {tab_top});
            this.tabControl.Name = "tabControl";
            this.tabControl.Size = new System.Drawing.Size({tab_width}, {tab_height});
            this.pnlDetail.Controls.Add(this.tabControl);
'''

# Tab Pages hinzufügen
tab_page_names = []
for page in tab_pages:
    page_name = generate_control_name(page['name'])
    page_caption = escape_string(page.get('caption', page['name']))
    tab_page_names.append(page_name)

    control_declarations.append(f'private System.Windows.Forms.TabPage {page_name};')
    designer_code += f'''
            //
            // {page_name} (TabPage)
            //
            this.{page_name} = new System.Windows.Forms.TabPage();
            this.{page_name}.BackColor = System.Drawing.Color.White;
            this.{page_name}.Location = new System.Drawing.Point(4, 24);
            this.{page_name}.Name = "{page_name}";
            this.{page_name}.Padding = new System.Windows.Forms.Padding(3);
            this.{page_name}.Size = new System.Drawing.Size({tab_width - 8}, {tab_height - 28});
            this.{page_name}.Text = "{page_caption}";
            this.tabControl.Controls.Add(this.{page_name});
'''

# Controls auf den Tab Pages
for page in tab_pages:
    page_name = generate_control_name(page['name'])
    page_controls = [c for c in detail_controls if c.get('parent') == page['name'] and c.get('visible', True)]

    for ctrl in page_controls:
        ctrl_name = generate_control_name(ctrl['name'])
        type_name = ctrl['type_name']

        left = twips_to_px(ctrl['left'])
        top = twips_to_px(ctrl['top'])
        width = twips_to_px(ctrl['width'])
        height = twips_to_px(ctrl['height'])

        fore_color = access_color_to_rgb(ctrl.get('fore_color', 0))
        back_color = access_color_to_rgb(ctrl.get('back_color', 16777215))

        font_name = ctrl.get('font_name', 'Arial')
        font_size = ctrl.get('font_size', 10)
        font_bold = ctrl.get('font_bold', 0)
        font_style = 'System.Drawing.FontStyle.Bold' if font_bold else 'System.Drawing.FontStyle.Regular'

        caption = escape_string(ctrl.get('caption', ''))

        if type_name == 'Label':
            control_declarations.append(f'private System.Windows.Forms.Label {ctrl_name};')
            designer_code += f'''
            //
            // {ctrl_name} (Label on {page_name})
            //
            this.{ctrl_name} = new System.Windows.Forms.Label();
            this.{ctrl_name}.AutoSize = false;
            this.{ctrl_name}.BackColor = System.Drawing.Color.FromArgb({back_color[0]}, {back_color[1]}, {back_color[2]});
            this.{ctrl_name}.ForeColor = System.Drawing.Color.FromArgb({fore_color[0]}, {fore_color[1]}, {fore_color[2]});
            this.{ctrl_name}.Font = new System.Drawing.Font("{font_name}", {font_size}F, {font_style});
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Name = "{ctrl_name}";
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.{ctrl_name}.Text = "{caption}";
            this.{page_name}.Controls.Add(this.{ctrl_name});
'''
            control_count += 1

        elif type_name == 'TextBox':
            control_declarations.append(f'private System.Windows.Forms.TextBox {ctrl_name};')
            designer_code += f'''
            //
            // {ctrl_name} (TextBox on {page_name})
            //
            this.{ctrl_name} = new System.Windows.Forms.TextBox();
            this.{ctrl_name}.BackColor = System.Drawing.Color.FromArgb({back_color[0]}, {back_color[1]}, {back_color[2]});
            this.{ctrl_name}.ForeColor = System.Drawing.Color.FromArgb({fore_color[0]}, {fore_color[1]}, {fore_color[2]});
            this.{ctrl_name}.Font = new System.Drawing.Font("{font_name}", {font_size}F, {font_style});
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Name = "{ctrl_name}";
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.{page_name}.Controls.Add(this.{ctrl_name});
'''
            control_count += 1

        elif type_name == 'ComboBox':
            control_declarations.append(f'private System.Windows.Forms.ComboBox {ctrl_name};')
            designer_code += f'''
            //
            // {ctrl_name} (ComboBox on {page_name})
            //
            this.{ctrl_name} = new System.Windows.Forms.ComboBox();
            this.{ctrl_name}.BackColor = System.Drawing.Color.FromArgb({back_color[0]}, {back_color[1]}, {back_color[2]});
            this.{ctrl_name}.ForeColor = System.Drawing.Color.FromArgb({fore_color[0]}, {fore_color[1]}, {fore_color[2]});
            this.{ctrl_name}.Font = new System.Drawing.Font("{font_name}", {font_size}F, {font_style});
            this.{ctrl_name}.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Name = "{ctrl_name}";
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.{page_name}.Controls.Add(this.{ctrl_name});
'''
            control_count += 1

        elif type_name == 'CheckBox':
            control_declarations.append(f'private System.Windows.Forms.CheckBox {ctrl_name};')
            designer_code += f'''
            //
            // {ctrl_name} (CheckBox on {page_name})
            //
            this.{ctrl_name} = new System.Windows.Forms.CheckBox();
            this.{ctrl_name}.BackColor = System.Drawing.Color.FromArgb({back_color[0]}, {back_color[1]}, {back_color[2]});
            this.{ctrl_name}.ForeColor = System.Drawing.Color.FromArgb({fore_color[0]}, {fore_color[1]}, {fore_color[2]});
            this.{ctrl_name}.Font = new System.Drawing.Font("{font_name}", {font_size}F, {font_style});
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Name = "{ctrl_name}";
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.{page_name}.Controls.Add(this.{ctrl_name});
'''
            control_count += 1

        elif type_name == 'CommandButton':
            control_declarations.append(f'private System.Windows.Forms.Button {ctrl_name};')
            designer_code += f'''
            //
            // {ctrl_name} (Button on {page_name})
            //
            this.{ctrl_name} = new System.Windows.Forms.Button();
            this.{ctrl_name}.BackColor = System.Drawing.Color.FromArgb({back_color[0]}, {back_color[1]}, {back_color[2]});
            this.{ctrl_name}.ForeColor = System.Drawing.Color.FromArgb({fore_color[0]}, {fore_color[1]}, {fore_color[2]});
            this.{ctrl_name}.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.{ctrl_name}.Font = new System.Drawing.Font("{font_name}", {font_size}F, {font_style});
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Name = "{ctrl_name}";
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.{ctrl_name}.Text = "{caption}";
            this.{page_name}.Controls.Add(this.{ctrl_name});
'''
            control_count += 1
        else:
            skipped_controls.append((ctrl_name, type_name))

# Menü Subform (wird als Panel mit Buttons)
menu_ctrl = None
for ctrl in detail_controls:
    if ctrl['name'] == 'Menü':
        menu_ctrl = ctrl
        break

if menu_ctrl:
    menu_left = twips_to_px(menu_ctrl['left'])
    menu_top = twips_to_px(menu_ctrl['top'])
    menu_width = twips_to_px(menu_ctrl['width'])
    menu_height = twips_to_px(menu_ctrl['height'])

    control_declarations.append('private System.Windows.Forms.Panel pnlMenu;')
    designer_code += f'''
            //
            // pnlMenu - HAUPTMENÜ
            //
            this.pnlMenu = new System.Windows.Forms.Panel();
            this.pnlMenu.BackColor = System.Drawing.Color.FromArgb(206, 228, 239);
            this.pnlMenu.Location = new System.Drawing.Point({menu_left}, {menu_top});
            this.pnlMenu.Name = "pnlMenu";
            this.pnlMenu.Size = new System.Drawing.Size({menu_width}, {menu_height});
            this.pnlMenu.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pnlDetail.Controls.Add(this.pnlMenu);
'''

# ListBox lst_MA (Mitarbeiter-Liste)
lst_ma = None
for ctrl in detail_controls:
    if ctrl['name'] == 'lst_MA':
        lst_ma = ctrl
        break

if lst_ma:
    lst_left = twips_to_px(lst_ma['left'])
    lst_top = twips_to_px(lst_ma['top'])
    lst_width = twips_to_px(lst_ma['width'])
    lst_height = twips_to_px(lst_ma['height'])
    lst_bg = access_color_to_rgb(lst_ma.get('back_color', 16777215))

    control_declarations.append('private System.Windows.Forms.ListBox lstMitarbeiter;')
    designer_code += f'''
            //
            // lstMitarbeiter - Mitarbeiterliste (lst_MA)
            //
            this.lstMitarbeiter = new System.Windows.Forms.ListBox();
            this.lstMitarbeiter.BackColor = System.Drawing.Color.FromArgb({lst_bg[0]}, {lst_bg[1]}, {lst_bg[2]});
            this.lstMitarbeiter.Font = new System.Drawing.Font("Arial", 9F);
            this.lstMitarbeiter.Location = new System.Drawing.Point({lst_left}, {lst_top});
            this.lstMitarbeiter.Name = "lstMitarbeiter";
            this.lstMitarbeiter.Size = new System.Drawing.Size({lst_width}, {lst_height});
            this.lstMitarbeiter.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pnlDetail.Controls.Add(this.lstMitarbeiter);
'''

# Close Form
designer_code += '''
            this.ResumeLayout(false);
        }

        #endregion
'''

# Control declarations
designer_code += '''
        private System.Windows.Forms.Panel pnlHeader;
        private System.Windows.Forms.Panel pnlDetail;
        private System.Windows.Forms.Panel pnlFooter;
'''
for decl in control_declarations:
    designer_code += f'        {decl}\n'

designer_code += '''    }
}
'''

# Schreibe Designer.cs
designer_path = os.path.join(output_dir, 'MainForm.Designer.cs')
with open(designer_path, 'w', encoding='utf-8') as f:
    f.write(designer_code)

print(f"\n\nGenerated {control_count} controls")
print(f"Skipped {len(skipped_controls)} controls:")
for name, type_name in skipped_controls[:20]:
    print(f"  - {name}: {type_name}")
if len(skipped_controls) > 20:
    print(f"  ... and {len(skipped_controls) - 20} more")

print(f"\nDesigner.cs written to: {designer_path}")
