"""
WinForms Generator - Erstellt exakte 1:1 Kopie aus Access Form Definition
"""

import json
import os
from pathlib import Path

# Twips zu Pixel Konvertierung (1 Twip = 1/1440 Zoll, 96 DPI = 1/15)
TWIPS_TO_PIXELS = 1/15

def twips_to_pixels(twips):
    """Konvertiert Access Twips zu Pixel"""
    return int(twips * TWIPS_TO_PIXELS)

def access_color_to_hex(color):
    """Konvertiert Access-Farbe zu .NET Color"""
    if color is None:
        return "Color.Transparent"

    # Negative Werte sind System-Farben
    if color < 0:
        # -2147483616 = vbWindowText (schwarz)
        # -2147483630 = vbButtonText (schwarz)
        # -2147483607 = vbButtonFace
        system_colors = {
            -2147483616: "Color.Black",
            -2147483630: "Color.Black",
            -2147483607: "Color.FromArgb(240, 240, 240)",
            -2147483643: "Color.White",
            -2147483633: "Color.FromArgb(240, 240, 240)",
        }
        return system_colors.get(color, "Color.Black")

    # Positive Werte sind BGR Format
    r = color & 0xFF
    g = (color >> 8) & 0xFF
    b = (color >> 16) & 0xFF
    return f"Color.FromArgb({r}, {g}, {b})"

def sanitize_name(name):
    """Bereinigt Control-Namen für C#"""
    # Ersetze ungültige Zeichen
    name = name.replace(" ", "_").replace("-", "_").replace(".", "_")
    # Beginnt mit Zahl? Unterstrich voranstellen
    if name[0].isdigit():
        name = "_" + name
    return name

def generate_control_code(control, section_offset_y):
    """Generiert C# Code für ein Control"""
    name = sanitize_name(control['name'])
    ctrl_type = control['type_name']
    left = twips_to_pixels(control['left'])
    top = twips_to_pixels(control['top']) + section_offset_y
    width = twips_to_pixels(control['width'])
    height = twips_to_pixels(control['height'])

    caption = control.get('caption', '')
    if caption is None:
        caption = ''

    visible = control.get('visible', True)
    enabled = control.get('enabled', True)
    fore_color = access_color_to_hex(control.get('fore_color'))
    back_color = access_color_to_hex(control.get('back_color'))

    font_name = control.get('font_name', 'Arial')
    font_size = control.get('font_size', 10)
    font_bold = control.get('font_bold', 0)

    if font_name is None:
        font_name = 'Arial'
    if font_size is None:
        font_size = 10

    font_style = "FontStyle.Bold" if font_bold else "FontStyle.Regular"

    lines = []
    decl = ""

    if ctrl_type == 'Label':
        decl = f"private Label {name};"
        lines.append(f"            this.{name} = new Label();")
        lines.append(f"            this.{name}.Name = \"{name}\";")
        lines.append(f"            this.{name}.Text = \"{caption.replace(chr(34), chr(39))}\";")
        lines.append(f"            this.{name}.Location = new Point({left}, {top});")
        lines.append(f"            this.{name}.Size = new Size({width}, {height});")
        lines.append(f"            this.{name}.Font = new Font(\"{font_name}\", {font_size}F, {font_style});")
        lines.append(f"            this.{name}.ForeColor = {fore_color};")
        lines.append(f"            this.{name}.BackColor = {back_color};")
        lines.append(f"            this.{name}.AutoSize = false;")
        if not visible:
            lines.append(f"            this.{name}.Visible = false;")
        lines.append(f"            this.Controls.Add(this.{name});")

    elif ctrl_type == 'TextBox':
        decl = f"private TextBox {name};"
        control_source = control.get('control_source', '')
        lines.append(f"            this.{name} = new TextBox();")
        lines.append(f"            this.{name}.Name = \"{name}\";")
        lines.append(f"            this.{name}.Location = new Point({left}, {top});")
        lines.append(f"            this.{name}.Size = new Size({width}, {height});")
        lines.append(f"            this.{name}.Font = new Font(\"{font_name}\", {font_size}F, {font_style});")
        lines.append(f"            this.{name}.ForeColor = {fore_color};")
        lines.append(f"            this.{name}.BackColor = {back_color};")
        if control_source:
            lines.append(f"            // DataBinding: {control_source}")
        if not visible:
            lines.append(f"            this.{name}.Visible = false;")
        if not enabled:
            lines.append(f"            this.{name}.Enabled = false;")
        lines.append(f"            this.Controls.Add(this.{name});")

    elif ctrl_type == 'ComboBox':
        decl = f"private ComboBox {name};"
        lines.append(f"            this.{name} = new ComboBox();")
        lines.append(f"            this.{name}.Name = \"{name}\";")
        lines.append(f"            this.{name}.Location = new Point({left}, {top});")
        lines.append(f"            this.{name}.Size = new Size({width}, {height});")
        lines.append(f"            this.{name}.Font = new Font(\"{font_name}\", {font_size}F, {font_style});")
        lines.append(f"            this.{name}.ForeColor = {fore_color};")
        lines.append(f"            this.{name}.BackColor = {back_color};")
        lines.append(f"            this.{name}.DropDownStyle = ComboBoxStyle.DropDownList;")
        if control.get('row_source'):
            lines.append(f"            // RowSource: {control.get('row_source')}")
        if not visible:
            lines.append(f"            this.{name}.Visible = false;")
        lines.append(f"            this.Controls.Add(this.{name});")

    elif ctrl_type == 'ListBox':
        decl = f"private ListBox {name};"
        lines.append(f"            this.{name} = new ListBox();")
        lines.append(f"            this.{name}.Name = \"{name}\";")
        lines.append(f"            this.{name}.Location = new Point({left}, {top});")
        lines.append(f"            this.{name}.Size = new Size({width}, {height});")
        lines.append(f"            this.{name}.Font = new Font(\"{font_name}\", {font_size}F, {font_style});")
        lines.append(f"            this.{name}.ForeColor = {fore_color};")
        lines.append(f"            this.{name}.BackColor = {back_color};")
        if control.get('row_source'):
            lines.append(f"            // RowSource: {control.get('row_source')}")
        if not visible:
            lines.append(f"            this.{name}.Visible = false;")
        lines.append(f"            this.Controls.Add(this.{name});")

    elif ctrl_type == 'CommandButton':
        decl = f"private Button {name};"
        lines.append(f"            this.{name} = new Button();")
        lines.append(f"            this.{name}.Name = \"{name}\";")
        lines.append(f"            this.{name}.Text = \"{caption.replace(chr(34), chr(39))}\";")
        lines.append(f"            this.{name}.Location = new Point({left}, {top});")
        lines.append(f"            this.{name}.Size = new Size({width}, {height});")
        lines.append(f"            this.{name}.Font = new Font(\"{font_name}\", {font_size}F, {font_style});")
        lines.append(f"            this.{name}.ForeColor = {fore_color};")
        lines.append(f"            this.{name}.BackColor = {back_color};")
        lines.append(f"            this.{name}.FlatStyle = FlatStyle.Flat;")
        lines.append(f"            this.{name}.UseVisualStyleBackColor = false;")
        if not visible:
            lines.append(f"            this.{name}.Visible = false;")
        if not enabled:
            lines.append(f"            this.{name}.Enabled = false;")
        lines.append(f"            this.Controls.Add(this.{name});")

    elif ctrl_type == 'CheckBox':
        decl = f"private CheckBox {name};"
        lines.append(f"            this.{name} = new CheckBox();")
        lines.append(f"            this.{name}.Name = \"{name}\";")
        lines.append(f"            this.{name}.Text = \"{caption.replace(chr(34), chr(39))}\";")
        lines.append(f"            this.{name}.Location = new Point({left}, {top});")
        lines.append(f"            this.{name}.Size = new Size({width}, {height});")
        lines.append(f"            this.{name}.Font = new Font(\"{font_name}\", {font_size}F, {font_style});")
        lines.append(f"            this.{name}.ForeColor = {fore_color};")
        lines.append(f"            this.{name}.BackColor = {back_color};")
        if control.get('control_source'):
            lines.append(f"            // DataBinding: {control.get('control_source')}")
        if not visible:
            lines.append(f"            this.{name}.Visible = false;")
        lines.append(f"            this.Controls.Add(this.{name});")

    elif ctrl_type == 'SubForm':
        # Subforms werden als Panel mit Label dargestellt
        decl = f"private Panel {name};"
        source_obj = control.get('source_object', 'Subform')
        lines.append(f"            this.{name} = new Panel();")
        lines.append(f"            this.{name}.Name = \"{name}\";")
        lines.append(f"            this.{name}.Location = new Point({left}, {top});")
        lines.append(f"            this.{name}.Size = new Size({width}, {height});")
        lines.append(f"            this.{name}.BorderStyle = BorderStyle.FixedSingle;")
        lines.append(f"            this.{name}.BackColor = Color.White;")
        lines.append(f"            // SourceObject: {source_obj}")
        if control.get('link_child_fields'):
            lines.append(f"            // LinkChildFields: {control.get('link_child_fields')}")
        if control.get('link_master_fields'):
            lines.append(f"            // LinkMasterFields: {control.get('link_master_fields')}")
        if not visible:
            lines.append(f"            this.{name}.Visible = false;")
        lines.append(f"            this.Controls.Add(this.{name});")

    elif ctrl_type == 'WebBrowser':
        # WebBrowser als Panel
        decl = f"private Panel {name};"
        lines.append(f"            this.{name} = new Panel();")
        lines.append(f"            this.{name}.Name = \"{name}\";")
        lines.append(f"            this.{name}.Location = new Point({left}, {top});")
        lines.append(f"            this.{name}.Size = new Size({width}, {height});")
        lines.append(f"            this.{name}.BorderStyle = BorderStyle.FixedSingle;")
        lines.append(f"            this.{name}.BackColor = Color.LightGray;")
        if not visible:
            lines.append(f"            this.{name}.Visible = false;")
        lines.append(f"            this.Controls.Add(this.{name});")

    elif ctrl_type in ['BoundObjectFrame', 'UnboundObjectFrame', 'Image']:
        # OLE/Image als PictureBox
        decl = f"private PictureBox {name};"
        lines.append(f"            this.{name} = new PictureBox();")
        lines.append(f"            this.{name}.Name = \"{name}\";")
        lines.append(f"            this.{name}.Location = new Point({left}, {top});")
        lines.append(f"            this.{name}.Size = new Size({width}, {height});")
        lines.append(f"            this.{name}.BorderStyle = BorderStyle.FixedSingle;")
        lines.append(f"            this.{name}.BackColor = {back_color};")
        lines.append(f"            this.{name}.SizeMode = PictureBoxSizeMode.StretchImage;")
        if not visible:
            lines.append(f"            this.{name}.Visible = false;")
        lines.append(f"            this.Controls.Add(this.{name});")

    elif ctrl_type == 'NavigationButton':
        decl = f"private Button {name};"
        lines.append(f"            this.{name} = new Button();")
        lines.append(f"            this.{name}.Name = \"{name}\";")
        lines.append(f"            this.{name}.Text = \"{caption.replace(chr(34), chr(39))}\";")
        lines.append(f"            this.{name}.Location = new Point({left}, {top});")
        lines.append(f"            this.{name}.Size = new Size({width}, {height});")
        lines.append(f"            this.{name}.Font = new Font(\"{font_name}\", {font_size}F, {font_style});")
        if not visible:
            lines.append(f"            this.{name}.Visible = false;")
        lines.append(f"            this.Controls.Add(this.{name});")

    else:
        # Unbekannter Typ - als Panel
        decl = f"private Panel {name};"
        lines.append(f"            // Unknown control type: {ctrl_type}")
        lines.append(f"            this.{name} = new Panel();")
        lines.append(f"            this.{name}.Name = \"{name}\";")
        lines.append(f"            this.{name}.Location = new Point({left}, {top});")
        lines.append(f"            this.{name}.Size = new Size({width}, {height});")
        lines.append(f"            this.{name}.BorderStyle = BorderStyle.FixedSingle;")
        if not visible:
            lines.append(f"            this.{name}.Visible = false;")
        lines.append(f"            this.Controls.Add(this.{name});")

    return decl, "\n".join(lines)


def generate_winforms_project(json_path, output_dir):
    """Generiert komplettes WinForms-Projekt aus JSON-Definition"""

    # JSON laden
    with open(json_path, 'r', encoding='utf-8') as f:
        form_def = json.load(f)

    form_name = form_def['name']
    form_width = twips_to_pixels(form_def['width'])
    form_caption = form_def.get('caption', form_name)

    # Höhe berechnen aus Sektionen
    sections = form_def.get('sections', {})
    header_height = twips_to_pixels(sections.get('header', {}).get('height', 0))
    detail_height = twips_to_pixels(sections.get('detail', {}).get('height', 0))
    footer_height = twips_to_pixels(sections.get('footer', {}).get('height', 0))
    form_height = header_height + detail_height + footer_height + 50  # Extra für Titlebar

    if form_height < 600:
        form_height = 800

    # Controls generieren
    declarations = []
    initializations = []

    for control in form_def['controls']:
        section = control.get('section', 0)

        # Section offset berechnen
        if section == 1:  # Header
            section_offset = 0
        elif section == 0:  # Detail
            section_offset = header_height
        elif section == 2:  # Footer
            section_offset = header_height + detail_height
        else:
            section_offset = header_height

        decl, init = generate_control_code(control, section_offset)
        if decl:
            declarations.append(decl)
            initializations.append(init)

    # Form Designer Code generieren
    designer_code = f'''namespace {form_name}
{{
    partial class MainForm
    {{
        private System.ComponentModel.IContainer components = null;

        protected override void Dispose(bool disposing)
        {{
            if (disposing && (components != null))
            {{
                components.Dispose();
            }}
            base.Dispose(disposing);
        }}

        #region Windows Form Designer generated code

        private void InitializeComponent()
        {{
            this.SuspendLayout();

            // Form Properties
            this.AutoScaleDimensions = new SizeF(7F, 15F);
            this.AutoScaleMode = AutoScaleMode.Font;
            this.ClientSize = new Size({form_width}, {form_height});
            this.Name = "MainForm";
            this.Text = "{form_caption}";
            this.BackColor = Color.FromArgb(128, 0, 0);  // Access Dunkelrot
            this.AutoScroll = true;
            this.StartPosition = FormStartPosition.CenterScreen;

            // Initialize Controls
{chr(10).join(initializations)}

            this.ResumeLayout(false);
            this.PerformLayout();
        }}

        #endregion

        // Control Declarations
        {chr(10) + "        ".join(declarations)}
    }}
}}
'''

    # Main Form Code
    main_code = f'''using System;
using System.Drawing;
using System.Windows.Forms;

namespace {form_name}
{{
    public partial class MainForm : Form
    {{
        public MainForm()
        {{
            InitializeComponent();
            LoadData();
        }}

        private void LoadData()
        {{
            // TODO: Datenbindung implementieren
            // RecordSource: {form_def.get('record_source', 'None')}
        }}
    }}
}}
'''

    # Program.cs
    program_code = f'''using System;
using System.Windows.Forms;

namespace {form_name}
{{
    static class Program
    {{
        [STAThread]
        static void Main()
        {{
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainForm());
        }}
    }}
}}
'''

    # Projekt-Datei (.csproj)
    csproj_code = f'''<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net8.0-windows</TargetFramework>
    <UseWindowsForms>true</UseWindowsForms>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <RootNamespace>{form_name}</RootNamespace>
    <AssemblyName>{form_name}</AssemblyName>
  </PropertyGroup>

</Project>
'''

    # Ordner erstellen
    project_dir = Path(output_dir) / form_name
    project_dir.mkdir(parents=True, exist_ok=True)

    # Dateien schreiben
    with open(project_dir / "MainForm.Designer.cs", 'w', encoding='utf-8') as f:
        f.write(designer_code)

    with open(project_dir / "MainForm.cs", 'w', encoding='utf-8') as f:
        f.write(main_code)

    with open(project_dir / "Program.cs", 'w', encoding='utf-8') as f:
        f.write(program_code)

    with open(project_dir / f"{form_name}.csproj", 'w', encoding='utf-8') as f:
        f.write(csproj_code)

    print(f"\n=== WinForms Projekt erstellt ===")
    print(f"Ordner: {project_dir}")
    print(f"Dateien:")
    print(f"  - MainForm.cs")
    print(f"  - MainForm.Designer.cs")
    print(f"  - Program.cs")
    print(f"  - {form_name}.csproj")
    print(f"\nControls: {len(declarations)}")
    print(f"Form-Größe: {form_width} x {form_height} Pixel")

    return str(project_dir)


if __name__ == "__main__":
    json_path = r"C:\Users\guenther.siegert\Documents\0000\0_frms_Fertig\frm_MA_Mitarbeiterstamm_definition.json"
    output_dir = r"C:\Users\guenther.siegert\Documents\0000\0_frms_Fertig"

    generate_winforms_project(json_path, output_dir)
