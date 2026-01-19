"""
WinForms Generator V2 - Exakte 1:1 Kopie mit korrekten Sektionen und allen Controls
"""

import json
import os
from pathlib import Path

# Twips zu Pixel Konvertierung
TWIPS_TO_PIXELS = 1/15

def twips_to_pixels(twips):
    return int(twips * TWIPS_TO_PIXELS)

def access_color_to_dotnet(color):
    """Konvertiert Access-Farbe zu .NET Color"""
    if color is None:
        return "Color.Transparent"

    if color < 0:
        system_colors = {
            -2147483616: "SystemColors.WindowText",
            -2147483630: "SystemColors.ControlText",
            -2147483607: "SystemColors.Control",
            -2147483643: "SystemColors.Window",
            -2147483633: "SystemColors.Control",
            -2147483624: "SystemColors.Highlight",
            -2147483625: "SystemColors.HighlightText",
        }
        return system_colors.get(color, "Color.Black")

    r = color & 0xFF
    g = (color >> 8) & 0xFF
    b = (color >> 16) & 0xFF
    return f"Color.FromArgb({r}, {g}, {b})"

def sanitize_name(name):
    """Bereinigt Namen für C#"""
    name = str(name).replace(" ", "_").replace("-", "_").replace(".", "_").replace("/", "_")
    name = ''.join(c if c.isalnum() or c == '_' else '_' for c in name)
    if name and name[0].isdigit():
        name = "_" + name
    if not name:
        name = "_unnamed"
    return name

def escape_string(s):
    """Escaped String für C#"""
    if s is None:
        return ""
    return str(s).replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r")

class WinFormsGenerator:
    def __init__(self, form_def):
        self.form_def = form_def
        self.declarations = []
        self.initializations = []
        self.used_names = set()

    def get_unique_name(self, base_name):
        name = sanitize_name(base_name)
        if name in self.used_names:
            i = 2
            while f"{name}_{i}" in self.used_names:
                i += 1
            name = f"{name}_{i}"
        self.used_names.add(name)
        return name

    def generate_control(self, ctl, section_offset_y):
        name = self.get_unique_name(ctl['name'])
        ctrl_type = ctl['type_name']

        left = twips_to_pixels(ctl['left'])
        top = twips_to_pixels(ctl['top']) + section_offset_y
        width = max(twips_to_pixels(ctl['width']), 1)
        height = max(twips_to_pixels(ctl['height']), 1)

        caption = escape_string(ctl.get('caption', ''))
        visible = ctl.get('visible', True)
        enabled = ctl.get('enabled', True)

        fore_color = access_color_to_dotnet(ctl.get('fore_color'))
        back_color = access_color_to_dotnet(ctl.get('back_color'))

        font_name = ctl.get('font_name') or 'Arial'
        font_size = ctl.get('font_size') or 10
        font_bold = ctl.get('font_bold', False)
        font_style = "FontStyle.Bold" if font_bold else "FontStyle.Regular"

        lines = []
        decl = ""

        if ctrl_type == 'Label':
            decl = f"        private Label {name};"
            lines.append(f"            // {ctl['name']}")
            lines.append(f"            this.{name} = new Label();")
            lines.append(f"            this.{name}.Name = \"{name}\";")
            lines.append(f"            this.{name}.Text = \"{caption}\";")
            lines.append(f"            this.{name}.Location = new Point({left}, {top});")
            lines.append(f"            this.{name}.Size = new Size({width}, {height});")
            lines.append(f"            this.{name}.Font = new Font(\"{font_name}\", {font_size}F, {font_style});")
            lines.append(f"            this.{name}.ForeColor = {fore_color};")
            lines.append(f"            this.{name}.BackColor = {back_color};")
            lines.append(f"            this.{name}.AutoSize = false;")
            if not visible:
                lines.append(f"            this.{name}.Visible = false;")
            lines.append(f"            this.panelMain.Controls.Add(this.{name});")

        elif ctrl_type == 'TextBox':
            decl = f"        private TextBox {name};"
            control_source = ctl.get('control_source', '')
            lines.append(f"            // {ctl['name']} - Binding: {control_source}")
            lines.append(f"            this.{name} = new TextBox();")
            lines.append(f"            this.{name}.Name = \"{name}\";")
            lines.append(f"            this.{name}.Location = new Point({left}, {top});")
            lines.append(f"            this.{name}.Size = new Size({width}, {height});")
            lines.append(f"            this.{name}.Font = new Font(\"{font_name}\", {font_size}F, {font_style});")
            lines.append(f"            this.{name}.ForeColor = {fore_color};")
            lines.append(f"            this.{name}.BackColor = {back_color};")
            if not visible:
                lines.append(f"            this.{name}.Visible = false;")
            if not enabled:
                lines.append(f"            this.{name}.Enabled = false;")
            lines.append(f"            this.panelMain.Controls.Add(this.{name});")

        elif ctrl_type == 'ComboBox':
            decl = f"        private ComboBox {name};"
            lines.append(f"            // {ctl['name']}")
            lines.append(f"            this.{name} = new ComboBox();")
            lines.append(f"            this.{name}.Name = \"{name}\";")
            lines.append(f"            this.{name}.Location = new Point({left}, {top});")
            lines.append(f"            this.{name}.Size = new Size({width}, {height});")
            lines.append(f"            this.{name}.Font = new Font(\"{font_name}\", {font_size}F, {font_style});")
            lines.append(f"            this.{name}.ForeColor = {fore_color};")
            lines.append(f"            this.{name}.BackColor = {back_color};")
            lines.append(f"            this.{name}.DropDownStyle = ComboBoxStyle.DropDownList;")
            if ctl.get('row_source'):
                lines.append(f"            // RowSource: {escape_string(ctl.get('row_source'))[:50]}")
            if not visible:
                lines.append(f"            this.{name}.Visible = false;")
            lines.append(f"            this.panelMain.Controls.Add(this.{name});")

        elif ctrl_type == 'ListBox':
            decl = f"        private ListBox {name};"
            lines.append(f"            // {ctl['name']}")
            lines.append(f"            this.{name} = new ListBox();")
            lines.append(f"            this.{name}.Name = \"{name}\";")
            lines.append(f"            this.{name}.Location = new Point({left}, {top});")
            lines.append(f"            this.{name}.Size = new Size({width}, {height});")
            lines.append(f"            this.{name}.Font = new Font(\"{font_name}\", {font_size}F, {font_style});")
            lines.append(f"            this.{name}.ForeColor = {fore_color};")
            lines.append(f"            this.{name}.BackColor = {back_color};")
            if ctl.get('row_source'):
                lines.append(f"            // RowSource: {escape_string(ctl.get('row_source'))[:50]}")
            if not visible:
                lines.append(f"            this.{name}.Visible = false;")
            lines.append(f"            this.panelMain.Controls.Add(this.{name});")

        elif ctrl_type == 'CommandButton':
            decl = f"        private Button {name};"
            lines.append(f"            // {ctl['name']}")
            lines.append(f"            this.{name} = new Button();")
            lines.append(f"            this.{name}.Name = \"{name}\";")
            lines.append(f"            this.{name}.Text = \"{caption}\";")
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
            lines.append(f"            this.panelMain.Controls.Add(this.{name});")

        elif ctrl_type == 'CheckBox':
            decl = f"        private CheckBox {name};"
            lines.append(f"            // {ctl['name']}")
            lines.append(f"            this.{name} = new CheckBox();")
            lines.append(f"            this.{name}.Name = \"{name}\";")
            lines.append(f"            this.{name}.Text = \"{caption}\";")
            lines.append(f"            this.{name}.Location = new Point({left}, {top});")
            lines.append(f"            this.{name}.Size = new Size({width}, {height});")
            lines.append(f"            this.{name}.Font = new Font(\"{font_name}\", {font_size}F, {font_style});")
            lines.append(f"            this.{name}.ForeColor = {fore_color};")
            lines.append(f"            this.{name}.BackColor = {back_color};")
            if not visible:
                lines.append(f"            this.{name}.Visible = false;")
            lines.append(f"            this.panelMain.Controls.Add(this.{name});")

        elif ctrl_type == 'SubForm':
            # Subforms nur als kleines Label anzeigen, nicht als großes Panel
            # Die meisten Subforms in Access sind Tab-Seiten oder eingebettete Formulare
            source_obj = escape_string(ctl.get('source_object', 'SubForm'))

            # Nur das Menü-Subform (links) als Panel darstellen
            if 'Menuefuehrung' in source_obj or 'Menu' in source_obj:
                decl = f"        private Panel {name};"
                lines.append(f"            // SubForm (Menu): {ctl['name']} -> {source_obj}")
                lines.append(f"            this.{name} = new Panel();")
                lines.append(f"            this.{name}.Name = \"{name}\";")
                lines.append(f"            this.{name}.Location = new Point({left}, {top});")
                lines.append(f"            this.{name}.Size = new Size({width}, {height});")
                lines.append(f"            this.{name}.BorderStyle = BorderStyle.FixedSingle;")
                lines.append(f"            this.{name}.BackColor = Color.FromArgb(128, 0, 0);")
                lines.append(f"            var lbl{name} = new Label();")
                lines.append(f"            lbl{name}.Text = \"{source_obj}\";")
                lines.append(f"            lbl{name}.Dock = DockStyle.Top;")
                lines.append(f"            lbl{name}.ForeColor = Color.White;")
                lines.append(f"            lbl{name}.BackColor = Color.FromArgb(100, 0, 0);")
                lines.append(f"            lbl{name}.TextAlign = ContentAlignment.MiddleCenter;")
                lines.append(f"            this.{name}.Controls.Add(lbl{name});")
                if not visible:
                    lines.append(f"            this.{name}.Visible = false;")
                lines.append(f"            this.panelMain.Controls.Add(this.{name});")
            else:
                # Andere Subforms überspringen (sind meist Tab-Seiten)
                decl = ""
                lines.append(f"            // SubForm SKIP (Tab-Seite): {ctl['name']} -> {source_obj}")

        elif ctrl_type in ['BoundObjectFrame', 'UnboundObjectFrame', 'Image']:
            decl = f"        private PictureBox {name};"
            lines.append(f"            // {ctrl_type}: {ctl['name']}")
            lines.append(f"            this.{name} = new PictureBox();")
            lines.append(f"            this.{name}.Name = \"{name}\";")
            lines.append(f"            this.{name}.Location = new Point({left}, {top});")
            lines.append(f"            this.{name}.Size = new Size({width}, {height});")
            lines.append(f"            this.{name}.BorderStyle = BorderStyle.FixedSingle;")
            lines.append(f"            this.{name}.BackColor = {back_color};")
            lines.append(f"            this.{name}.SizeMode = PictureBoxSizeMode.StretchImage;")
            if not visible:
                lines.append(f"            this.{name}.Visible = false;")
            lines.append(f"            this.panelMain.Controls.Add(this.{name});")

        elif ctrl_type in ['WebBrowser', 'CustomControl']:
            # WebBrowser/CustomControl überspringen - verdecken andere Controls
            decl = ""
            lines.append(f"            // {ctrl_type} SKIP: {ctl['name']}")

        elif ctrl_type == 'NavigationButton':
            decl = f"        private Button {name};"
            lines.append(f"            // NavigationButton: {ctl['name']}")
            lines.append(f"            this.{name} = new Button();")
            lines.append(f"            this.{name}.Name = \"{name}\";")
            lines.append(f"            this.{name}.Text = \"{caption}\";")
            lines.append(f"            this.{name}.Location = new Point({left}, {top});")
            lines.append(f"            this.{name}.Size = new Size({width}, {height});")
            if not visible:
                lines.append(f"            this.{name}.Visible = false;")
            lines.append(f"            this.panelMain.Controls.Add(this.{name});")

        else:
            # Unbekannter Typ als Panel
            decl = f"        private Panel {name};"
            lines.append(f"            // Unknown: {ctrl_type} - {ctl['name']}")
            lines.append(f"            this.{name} = new Panel();")
            lines.append(f"            this.{name}.Name = \"{name}\";")
            lines.append(f"            this.{name}.Location = new Point({left}, {top});")
            lines.append(f"            this.{name}.Size = new Size({width}, {height});")
            lines.append(f"            this.{name}.BorderStyle = BorderStyle.FixedSingle;")
            if not visible:
                lines.append(f"            this.{name}.Visible = false;")
            lines.append(f"            this.panelMain.Controls.Add(this.{name});")

        lines.append("")
        return decl, "\n".join(lines)

    def generate(self, output_dir):
        form_name = sanitize_name(self.form_def['name'])
        form_width = twips_to_pixels(self.form_def['width'])
        form_caption = escape_string(self.form_def.get('caption', form_name))

        # Sektionshöhen
        sections = self.form_def.get('sections', {})
        header_height = twips_to_pixels(sections.get('header', {}).get('height', 0))
        detail_height = twips_to_pixels(sections.get('detail', {}).get('height', 0))
        footer_height = twips_to_pixels(sections.get('footer', {}).get('height', 0))

        total_height = header_height + detail_height + footer_height
        form_height = max(total_height + 50, 700)

        # Header-Hintergrundfarbe (dunkelrot wie Access)
        header_back_color = access_color_to_dotnet(sections.get('header', {}).get('back_color', 8388608))
        detail_back_color = access_color_to_dotnet(sections.get('detail', {}).get('back_color', 8388608))

        # Controls verarbeiten
        for ctl in self.form_def['controls']:
            section = ctl.get('section', 0)

            if section == 1:  # Header
                section_offset = 0
            elif section == 0:  # Detail
                section_offset = header_height
            elif section == 2:  # Footer
                section_offset = header_height + detail_height
            else:
                section_offset = header_height

            decl, init = self.generate_control(ctl, section_offset)
            if decl:
                self.declarations.append(decl)
                self.initializations.append(init)

        # Designer Code
        designer_code = f'''using System;
using System.Drawing;
using System.Windows.Forms;

namespace {form_name}
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

            // Main scrollable panel
            this.panelMain = new Panel();
            this.panelMain.Name = "panelMain";
            this.panelMain.Dock = DockStyle.Fill;
            this.panelMain.AutoScroll = true;
            this.panelMain.BackColor = Color.FromArgb(128, 0, 0);  // Access dunkelrot
            this.Controls.Add(this.panelMain);

            // === CONTROLS ===
{chr(10).join(self.initializations)}

            // Form Properties
            this.AutoScaleDimensions = new SizeF(7F, 15F);
            this.AutoScaleMode = AutoScaleMode.Font;
            this.ClientSize = new Size({form_width}, {form_height});
            this.Name = "MainForm";
            this.Text = "{form_caption}";
            this.BackColor = Color.FromArgb(128, 0, 0);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.WindowState = FormWindowState.Maximized;

            this.ResumeLayout(false);
            this.PerformLayout();
        }}

        #endregion

        private Panel panelMain;
{chr(10).join(self.declarations)}
    }}
}}
'''

        # Main Code
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
            // RecordSource: {self.form_def.get('record_source', 'None')}
            // TODO: Datenbindung implementieren
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

        # csproj
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
        (project_dir / "MainForm.Designer.cs").write_text(designer_code, encoding='utf-8')
        (project_dir / "MainForm.cs").write_text(main_code, encoding='utf-8')
        (project_dir / "Program.cs").write_text(program_code, encoding='utf-8')
        (project_dir / f"{form_name}.csproj").write_text(csproj_code, encoding='utf-8')

        print(f"\n=== WinForms Projekt V2 erstellt ===")
        print(f"Ordner: {project_dir}")
        print(f"Controls: {len(self.declarations)}")
        print(f"Form: {form_width} x {form_height} px")
        print(f"Sektionen: Header={header_height}px, Detail={detail_height}px, Footer={footer_height}px")

        return str(project_dir)


if __name__ == "__main__":
    json_path = r"C:\Users\guenther.siegert\Documents\0000\0_frms_Fertig\frm_MA_Mitarbeiterstamm_definition_v2.json"
    output_dir = r"C:\Users\guenther.siegert\Documents\0000\0_frms_Fertig"

    with open(json_path, 'r', encoding='utf-8') as f:
        form_def = json.load(f)

    generator = WinFormsGenerator(form_def)
    generator.generate(output_dir)
