# -*- coding: utf-8 -*-
"""
Exakte WinForms-Generierung aus Access Form JSON-Definition V3
Korrigiert Tab-Control Positionierung
"""

import json
import os

def twips_to_px(twips):
    return int(twips / 15)

def access_color_to_rgb(color):
    if color is None:
        return (255, 255, 255)
    if color < 0:
        if color == -2147483616: return (0, 0, 0)
        elif color == -2147483643: return (240, 240, 240)
        elif color == -2147483633: return (0, 120, 215)
        elif color == -2147483630: return (0, 0, 0)
        elif color == -2147483607: return (240, 240, 240)
        else: return (0, 0, 0)
    r = color & 0xFF
    g = (color >> 8) & 0xFF
    b = (color >> 16) & 0xFF
    return (r, g, b)

json_path = r"C:\Users\guenther.siegert\Documents\0000\0_frms_Fertig\frm_MA_Mitarbeiterstamm_definition_v2.json"
output_dir = r"C:\Users\guenther.siegert\Documents\0000\0_frms_Fertig\frm_MA_Mitarbeiterstamm"

with open(json_path, 'r', encoding='utf-8') as f:
    form_def = json.load(f)

form_width_px = twips_to_px(form_def['width'])
header_height_px = twips_to_px(form_def['sections']['header']['height'])
detail_height_px = twips_to_px(form_def['sections']['detail']['height'])
footer_height_px = twips_to_px(form_def['sections']['footer']['height'])

header_bg = access_color_to_rgb(form_def['sections']['header']['back_color'])
detail_bg = access_color_to_rgb(form_def['sections']['detail']['back_color'])
footer_bg = access_color_to_rgb(form_def['sections']['footer']['back_color'])

# Finde Tab Control und Tab Pages
reg_ma = None
tab_pages = {}
for ctrl in form_def['controls']:
    if ctrl['name'] == 'reg_MA':
        reg_ma = ctrl
    elif ctrl['type_name'] == 'WebBrowser' and ctrl.get('parent') == 'reg_MA':
        tab_pages[ctrl['name']] = ctrl

tab_left = twips_to_px(reg_ma['left']) if reg_ma else 0
tab_top = twips_to_px(reg_ma['top']) if reg_ma else 0
TAB_HEADER_HEIGHT = 24  # Tab header height in pixels

print(f"Tab Control Position: {tab_left}px, {tab_top}px")

header_controls = []
detail_controls = []
footer_controls = []

for ctrl in form_def['controls']:
    section = ctrl.get('section', 0)
    if section == 1:
        header_controls.append(ctrl)
    elif section == 2:
        footer_controls.append(ctrl)
    else:
        detail_controls.append(ctrl)

def generate_control_name(ctrl_name):
    name = ctrl_name.replace(' ', '_').replace('-', '_').replace('.', '_').replace('ü', 'ue').replace('Ü', 'Ue')
    if name[0].isdigit():
        name = '_' + name
    return name

def escape_string(s):
    if s is None:
        return ""
    return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r')

# Start generating code
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

total_height = header_height_px + detail_height_px + footer_height_px

designer_code += f'''
            // MainForm
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb({detail_bg[0]}, {detail_bg[1]}, {detail_bg[2]});
            this.ClientSize = new System.Drawing.Size({form_width_px}, {total_height});
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "MainForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "{escape_string(form_def.get('caption', 'Mitarbeiterstamm'))}";

            // pnlHeader
            this.pnlHeader = new System.Windows.Forms.Panel();
            this.pnlHeader.BackColor = System.Drawing.Color.FromArgb({header_bg[0]}, {header_bg[1]}, {header_bg[2]});
            this.pnlHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlHeader.Size = new System.Drawing.Size({form_width_px}, {header_height_px});
            this.Controls.Add(this.pnlHeader);

            // pnlFooter
            this.pnlFooter = new System.Windows.Forms.Panel();
            this.pnlFooter.BackColor = System.Drawing.Color.FromArgb({footer_bg[0]}, {footer_bg[1]}, {footer_bg[2]});
            this.pnlFooter.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlFooter.Size = new System.Drawing.Size({form_width_px}, {footer_height_px});
            this.Controls.Add(this.pnlFooter);

            // pnlDetail
            this.pnlDetail = new System.Windows.Forms.Panel();
            this.pnlDetail.BackColor = System.Drawing.Color.FromArgb({detail_bg[0]}, {detail_bg[1]}, {detail_bg[2]});
            this.pnlDetail.Location = new System.Drawing.Point(0, {header_height_px});
            this.pnlDetail.Size = new System.Drawing.Size({form_width_px}, {detail_height_px});
            this.Controls.Add(this.pnlDetail);
'''

control_declarations = []
generated_names = set()

def get_unique_name(base_name):
    name = generate_control_name(base_name)
    if name in generated_names:
        i = 2
        while f"{name}{i}" in generated_names:
            i += 1
        name = f"{name}{i}"
    generated_names.add(name)
    return name

# Header Controls
for ctrl in header_controls:
    if not ctrl.get('visible', True):
        continue

    ctrl_name = get_unique_name(ctrl['name'])
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
            this.{ctrl_name} = new System.Windows.Forms.Label();
            this.{ctrl_name}.AutoSize = false;
            this.{ctrl_name}.BackColor = System.Drawing.Color.FromArgb({back_color[0]}, {back_color[1]}, {back_color[2]});
            this.{ctrl_name}.ForeColor = System.Drawing.Color.FromArgb({fore_color[0]}, {fore_color[1]}, {fore_color[2]});
            this.{ctrl_name}.Font = new System.Drawing.Font("{font_name}", {font_size}F, {font_style});
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.{ctrl_name}.Text = "{caption}";
            this.{ctrl_name}.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.pnlHeader.Controls.Add(this.{ctrl_name});
'''
    elif type_name == 'CommandButton':
        control_declarations.append(f'private System.Windows.Forms.Button {ctrl_name};')
        designer_code += f'''
            this.{ctrl_name} = new System.Windows.Forms.Button();
            this.{ctrl_name}.BackColor = System.Drawing.Color.FromArgb({back_color[0]}, {back_color[1]}, {back_color[2]});
            this.{ctrl_name}.ForeColor = System.Drawing.Color.FromArgb({fore_color[0]}, {fore_color[1]}, {fore_color[2]});
            this.{ctrl_name}.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.{ctrl_name}.Font = new System.Drawing.Font("{font_name}", {font_size}F, {font_style});
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.{ctrl_name}.Text = "{caption}";
            this.{ctrl_name}.UseVisualStyleBackColor = false;
            this.pnlHeader.Controls.Add(this.{ctrl_name});
'''

# Tab Control
if reg_ma:
    tab_width = twips_to_px(reg_ma['width'])
    tab_height = twips_to_px(reg_ma['height'])

    designer_code += f'''
            // tabControl
            this.tabControl = new System.Windows.Forms.TabControl();
            this.tabControl.Location = new System.Drawing.Point({tab_left}, {tab_top});
            this.tabControl.Size = new System.Drawing.Size({tab_width}, {tab_height});
            this.pnlDetail.Controls.Add(this.tabControl);
'''
    control_declarations.append('private System.Windows.Forms.TabControl tabControl;')

# Tab Pages
for page_name, page_ctrl in tab_pages.items():
    safe_page_name = get_unique_name(page_name)
    page_caption = escape_string(page_ctrl.get('caption', page_name))
    tab_width = twips_to_px(reg_ma['width']) if reg_ma else 1600
    tab_height = twips_to_px(reg_ma['height']) if reg_ma else 800

    control_declarations.append(f'private System.Windows.Forms.TabPage {safe_page_name};')
    designer_code += f'''
            // {safe_page_name}
            this.{safe_page_name} = new System.Windows.Forms.TabPage();
            this.{safe_page_name}.BackColor = System.Drawing.Color.White;
            this.{safe_page_name}.Text = "{page_caption}";
            this.{safe_page_name}.AutoScroll = true;
            this.tabControl.Controls.Add(this.{safe_page_name});
'''

    # Controls auf dieser Tab Page
    page_controls = [c for c in detail_controls if c.get('parent') == page_name and c.get('visible', True)]

    for ctrl in page_controls:
        ctrl_name = get_unique_name(ctrl['name'])
        type_name = ctrl['type_name']

        # Position relativ zum Tab Control berechnen
        abs_left = twips_to_px(ctrl['left'])
        abs_top = twips_to_px(ctrl['top'])

        # Korrigiere Position relativ zur Tab Page
        left = abs_left - tab_left
        top = abs_top - TAB_HEADER_HEIGHT  # Nach Tab Header

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
            this.{ctrl_name} = new System.Windows.Forms.Label();
            this.{ctrl_name}.AutoSize = false;
            this.{ctrl_name}.BackColor = System.Drawing.Color.White;
            this.{ctrl_name}.ForeColor = System.Drawing.Color.FromArgb({fore_color[0]}, {fore_color[1]}, {fore_color[2]});
            this.{ctrl_name}.Font = new System.Drawing.Font("{font_name}", {font_size}F, {font_style});
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.{ctrl_name}.Text = "{caption}";
            this.{safe_page_name}.Controls.Add(this.{ctrl_name});
'''
        elif type_name == 'TextBox':
            control_declarations.append(f'private System.Windows.Forms.TextBox {ctrl_name};')
            designer_code += f'''
            this.{ctrl_name} = new System.Windows.Forms.TextBox();
            this.{ctrl_name}.BackColor = System.Drawing.Color.FromArgb({back_color[0]}, {back_color[1]}, {back_color[2]});
            this.{ctrl_name}.ForeColor = System.Drawing.Color.FromArgb({fore_color[0]}, {fore_color[1]}, {fore_color[2]});
            this.{ctrl_name}.Font = new System.Drawing.Font("{font_name}", {font_size}F, {font_style});
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.{safe_page_name}.Controls.Add(this.{ctrl_name});
'''
        elif type_name == 'ComboBox':
            control_declarations.append(f'private System.Windows.Forms.ComboBox {ctrl_name};')
            designer_code += f'''
            this.{ctrl_name} = new System.Windows.Forms.ComboBox();
            this.{ctrl_name}.BackColor = System.Drawing.Color.FromArgb({back_color[0]}, {back_color[1]}, {back_color[2]});
            this.{ctrl_name}.ForeColor = System.Drawing.Color.FromArgb({fore_color[0]}, {fore_color[1]}, {fore_color[2]});
            this.{ctrl_name}.Font = new System.Drawing.Font("{font_name}", {font_size}F, {font_style});
            this.{ctrl_name}.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.{safe_page_name}.Controls.Add(this.{ctrl_name});
'''
        elif type_name == 'CheckBox':
            control_declarations.append(f'private System.Windows.Forms.CheckBox {ctrl_name};')
            designer_code += f'''
            this.{ctrl_name} = new System.Windows.Forms.CheckBox();
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.{ctrl_name}.Text = "{caption}";
            this.{safe_page_name}.Controls.Add(this.{ctrl_name});
'''
        elif type_name == 'CommandButton':
            control_declarations.append(f'private System.Windows.Forms.Button {ctrl_name};')
            designer_code += f'''
            this.{ctrl_name} = new System.Windows.Forms.Button();
            this.{ctrl_name}.BackColor = System.Drawing.Color.FromArgb({back_color[0]}, {back_color[1]}, {back_color[2]});
            this.{ctrl_name}.ForeColor = System.Drawing.Color.FromArgb({fore_color[0]}, {fore_color[1]}, {fore_color[2]});
            this.{ctrl_name}.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.{ctrl_name}.Font = new System.Drawing.Font("{font_name}", {font_size}F, {font_style});
            this.{ctrl_name}.Location = new System.Drawing.Point({left}, {top});
            this.{ctrl_name}.Size = new System.Drawing.Size({width}, {height});
            this.{ctrl_name}.Text = "{caption}";
            this.{safe_page_name}.Controls.Add(this.{ctrl_name});
'''

# Menü Panel
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

    designer_code += f'''
            // pnlMenu
            this.pnlMenu = new System.Windows.Forms.Panel();
            this.pnlMenu.BackColor = System.Drawing.Color.FromArgb(206, 228, 239);
            this.pnlMenu.Location = new System.Drawing.Point({menu_left}, {menu_top});
            this.pnlMenu.Size = new System.Drawing.Size({menu_width}, {menu_height});
            this.pnlMenu.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pnlDetail.Controls.Add(this.pnlMenu);
'''
    control_declarations.append('private System.Windows.Forms.Panel pnlMenu;')

# Mitarbeiter-Liste
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

    designer_code += f'''
            // lstMitarbeiter
            this.lstMitarbeiter = new System.Windows.Forms.ListView();
            this.lstMitarbeiter.View = System.Windows.Forms.View.Details;
            this.lstMitarbeiter.FullRowSelect = true;
            this.lstMitarbeiter.GridLines = true;
            this.lstMitarbeiter.Font = new System.Drawing.Font("Arial", 9F);
            this.lstMitarbeiter.Location = new System.Drawing.Point({lst_left}, {lst_top});
            this.lstMitarbeiter.Size = new System.Drawing.Size({lst_width}, {lst_height});
            this.lstMitarbeiter.Columns.Add("ID", 40);
            this.lstMitarbeiter.Columns.Add("Nachname", 100);
            this.lstMitarbeiter.Columns.Add("Vorname", 100);
            this.lstMitarbeiter.Columns.Add("Ort", 100);
            this.pnlDetail.Controls.Add(this.lstMitarbeiter);
'''
    control_declarations.append('private System.Windows.Forms.ListView lstMitarbeiter;')

designer_code += '''
            this.ResumeLayout(false);
        }

        #endregion

        private System.Windows.Forms.Panel pnlHeader;
        private System.Windows.Forms.Panel pnlDetail;
        private System.Windows.Forms.Panel pnlFooter;
'''

for decl in control_declarations:
    designer_code += f'        {decl}\n'

designer_code += '''    }
}
'''

# Write file
designer_path = os.path.join(output_dir, 'MainForm.Designer.cs')
with open(designer_path, 'w', encoding='utf-8') as f:
    f.write(designer_code)

print(f"\nDesigner.cs written to: {designer_path}")
print(f"Generated {len(control_declarations)} controls")
