"""
Captures Access form screenshots and analyzes their layouts.
Uses pyautogui and win32gui for window manipulation and screenshot capture.
"""

import json
import os
import time
import subprocess

# Try to import required libraries
try:
    import pyautogui
    from PIL import Image, ImageGrab
except ImportError:
    print("Installing required libraries...")
    subprocess.check_call(['pip', 'install', 'pyautogui', 'pillow'])
    import pyautogui
    from PIL import Image, ImageGrab

try:
    import win32gui
    import win32con
    import win32com.client
except ImportError:
    print("Installing pywin32...")
    subprocess.check_call(['pip', 'install', 'pywin32'])
    import win32gui
    import win32con
    import win32com.client


# Paths
JSON_EXPORT_PATH = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\000_Consys_Eport_11_25\30_forms"
SCREENSHOT_PATH = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0000_Windows_WinUI3_2\screenshots"
ACCESS_DB = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb"

# Forms to capture
FORMS_TO_CAPTURE = [
    "frm_MA_Mitarbeiterstamm",
    "frm_KD_Kundenstamm",
    "frm_OB_Objekt",
    "frm_VA_Auftragstamm",
    "frm_MA_Abwesenheiten",
]


def ensure_screenshot_dir():
    """Ensure screenshot directory exists"""
    if not os.path.exists(SCREENSHOT_PATH):
        os.makedirs(SCREENSHOT_PATH)


def convert_twips_to_pixels(twips):
    """Convert Access twips to pixels (1 twip = 1/1440 inch, 96 DPI = 1/15 twip per pixel)"""
    return int(twips / 15)


def convert_access_color(color_value):
    """Convert Access color (BGR Long) to HEX RGB"""
    if isinstance(color_value, str):
        try:
            color_value = int(color_value)
        except ValueError:
            return "#000000"

    if color_value < 0:
        # System colors
        system_colors = {
            -2147483633: "#F0F0F0",  # COLOR_BTNFACE
            -2147483643: "#000000",  # COLOR_WINDOWTEXT
            -2147483640: "#FFFFFF",  # COLOR_WINDOW
            -2147483635: "#C0C0C0",  # COLOR_BTNSHADOW
            -2147483632: "#808080",  # COLOR_GRAYTEXT
            -2147483630: "#000000",  # COLOR_BTNTEXT
            -2147483616: "#000000",  # COLOR_INFOTEXT
            -2147483605: "#F0F0F0",  # COLOR_BTNHIGHLIGHT
        }
        return system_colors.get(color_value, "#000000")

    # BGR to RGB
    r = color_value & 0xFF
    g = (color_value >> 8) & 0xFF
    b = (color_value >> 16) & 0xFF
    return f"#{r:02X}{g:02X}{b:02X}"


def analyze_form_json(form_name):
    """Analyze form JSON and extract layout information"""
    json_path = os.path.join(JSON_EXPORT_PATH, f"FRM_{form_name}.json")

    if not os.path.exists(json_path):
        print(f"[WARNING] JSON not found: {json_path}")
        return None

    with open(json_path, 'r', encoding='cp1252') as f:
        content = f.read()
        # Fix German boolean values
        content = content.replace('"Wahr"', 'true').replace('"Falsch"', 'false')
        content = content.replace(':wahr', ':true').replace(':falsch', ':false')
        data = json.loads(content)

    layout = {
        "name": data.get("name", form_name),
        "record_source": data.get("record_source", {}),
        "controls": []
    }

    for ctrl in data.get("controls", []):
        props = ctrl.get("properties", {})

        # Extract positioning
        left_twips = int(props.get("Left", 0))
        top_twips = int(props.get("Top", 0))
        width_twips = int(props.get("Width", 0))
        height_twips = int(props.get("Height", 0))

        control_info = {
            "name": ctrl.get("name"),
            "type": ctrl.get("type"),
            "control_source": ctrl.get("control_source", ""),
            "visible": props.get("Visible", "true") == "true" or props.get("Visible", True) == True,
            "enabled": props.get("Enabled", "true") == "true" or props.get("Enabled", True) == True,
            # Twips values
            "left_twips": left_twips,
            "top_twips": top_twips,
            "width_twips": width_twips,
            "height_twips": height_twips,
            # Pixel values
            "left_px": convert_twips_to_pixels(left_twips),
            "top_px": convert_twips_to_pixels(top_twips),
            "width_px": convert_twips_to_pixels(width_twips),
            "height_px": convert_twips_to_pixels(height_twips),
            # Colors
            "forecolor": convert_access_color(props.get("ForeColor", "0")),
            "backcolor": convert_access_color(props.get("BackColor", "16777215")),
            "bordercolor": convert_access_color(props.get("BorderColor", "0")),
            "borderstyle": props.get("BorderStyle", "0"),
            "borderwidth": props.get("BorderWidth", "0"),
        }

        # Add subform-specific info
        if ctrl.get("type") == "SubForm":
            subform = ctrl.get("subform", {})
            control_info["subform"] = {
                "source_object": subform.get("source_object"),
                "link_master": subform.get("link_master_fields", []),
                "link_child": subform.get("link_child_fields", [])
            }

        # Add list/combo-specific info
        if ctrl.get("type") in ["ListBox", "ComboBox"]:
            control_info["row_source"] = ctrl.get("row_source", {})
            control_info["list_props"] = ctrl.get("list_props", {})

        layout["controls"].append(control_info)

    return layout


def capture_access_screenshot(form_name):
    """
    Capture a screenshot of an Access form.
    Note: Access must be running with the form open.
    """
    try:
        # Find Access window
        def enum_windows_callback(hwnd, results):
            if win32gui.IsWindowVisible(hwnd):
                title = win32gui.GetWindowText(hwnd)
                if "Microsoft Access" in title or form_name in title:
                    results.append(hwnd)

        windows = []
        win32gui.EnumWindows(enum_windows_callback, windows)

        if not windows:
            print(f"[WARNING] Access window not found for {form_name}")
            return None

        # Get the first matching window
        hwnd = windows[0]

        # Bring window to front
        win32gui.SetForegroundWindow(hwnd)
        time.sleep(0.5)

        # Get window rect
        rect = win32gui.GetWindowRect(hwnd)
        x, y, x2, y2 = rect
        width = x2 - x
        height = y2 - y

        # Capture screenshot
        screenshot = ImageGrab.grab(bbox=(x, y, x2, y2))

        # Save screenshot
        screenshot_path = os.path.join(SCREENSHOT_PATH, f"{form_name}.png")
        screenshot.save(screenshot_path)
        print(f"[OK] Screenshot saved: {screenshot_path}")

        return screenshot_path

    except Exception as e:
        print(f"[ERROR] Failed to capture {form_name}: {e}")
        return None


def create_layout_report(form_name, layout):
    """Create a detailed layout report for a form"""
    if not layout:
        return

    report_path = os.path.join(SCREENSHOT_PATH, f"{form_name}_layout.md")

    with open(report_path, 'w', encoding='utf-8') as f:
        f.write(f"# Layout Report: {form_name}\n\n")
        f.write(f"Record Source: {layout.get('record_source', {})}\n\n")
        f.write("## Controls\n\n")

        # Group by type
        by_type = {}
        for ctrl in layout["controls"]:
            ctrl_type = ctrl["type"]
            if ctrl_type not in by_type:
                by_type[ctrl_type] = []
            by_type[ctrl_type].append(ctrl)

        for ctrl_type, controls in sorted(by_type.items()):
            f.write(f"\n### {ctrl_type} ({len(controls)})\n\n")
            f.write("| Name | X (px) | Y (px) | W (px) | H (px) | ForeColor | BackColor | Visible |\n")
            f.write("|------|--------|--------|--------|--------|-----------|-----------|----------|\n")

            for ctrl in sorted(controls, key=lambda x: (x["top_px"], x["left_px"])):
                f.write(f"| {ctrl['name'][:30]} | {ctrl['left_px']} | {ctrl['top_px']} | ")
                f.write(f"{ctrl['width_px']} | {ctrl['height_px']} | {ctrl['forecolor']} | ")
                f.write(f"{ctrl['backcolor']} | {ctrl['visible']} |\n")

    print(f"[OK] Layout report: {report_path}")


def create_xaml_mapping(form_name, layout):
    """Create XAML mapping suggestions based on Access layout"""
    if not layout:
        return

    xaml_path = os.path.join(SCREENSHOT_PATH, f"{form_name}_xaml_mapping.txt")

    with open(xaml_path, 'w', encoding='utf-8') as f:
        f.write(f"// XAML Mapping for {form_name}\n")
        f.write("// Use these values for pixel-perfect WinUI3 recreation\n\n")

        for ctrl in layout["controls"]:
            if not ctrl["visible"]:
                continue

            f.write(f"// {ctrl['name']} ({ctrl['type']})\n")

            if ctrl["type"] == "TextBox":
                f.write(f'<TextBox x:Name="{ctrl["name"]}"\n')
                f.write(f'         Margin="{ctrl["left_px"]},{ctrl["top_px"]},0,0"\n')
                f.write(f'         Width="{ctrl["width_px"]}" Height="{ctrl["height_px"]}"\n')
                f.write(f'         Foreground="{ctrl["forecolor"]}"\n')
                f.write(f'         Background="{ctrl["backcolor"]}"\n')
                if ctrl.get("control_source"):
                    f.write(f'         Text="{{Binding {ctrl["control_source"]}}}"\n')
                f.write(f'/>\n\n')

            elif ctrl["type"] == "Label":
                f.write(f'<TextBlock x:Name="{ctrl["name"]}"\n')
                f.write(f'           Margin="{ctrl["left_px"]},{ctrl["top_px"]},0,0"\n')
                f.write(f'           Width="{ctrl["width_px"]}" Height="{ctrl["height_px"]}"\n')
                f.write(f'           Foreground="{ctrl["forecolor"]}"\n')
                f.write(f'/>\n\n')

            elif ctrl["type"] == "CommandButton":
                f.write(f'<Button x:Name="{ctrl["name"]}"\n')
                f.write(f'        Margin="{ctrl["left_px"]},{ctrl["top_px"]},0,0"\n')
                f.write(f'        Width="{ctrl["width_px"]}" Height="{ctrl["height_px"]}"\n')
                f.write(f'        Foreground="{ctrl["forecolor"]}"\n')
                f.write(f'        Background="{ctrl["backcolor"]}"\n')
                f.write(f'/>\n\n')

            elif ctrl["type"] == "ListBox":
                f.write(f'<ListView x:Name="{ctrl["name"]}"\n')
                f.write(f'          Margin="{ctrl["left_px"]},{ctrl["top_px"]},0,0"\n')
                f.write(f'          Width="{ctrl["width_px"]}" Height="{ctrl["height_px"]}"\n')
                f.write(f'/>\n\n')

            elif ctrl["type"] == "ComboBox":
                f.write(f'<ComboBox x:Name="{ctrl["name"]}"\n')
                f.write(f'          Margin="{ctrl["left_px"]},{ctrl["top_px"]},0,0"\n')
                f.write(f'          Width="{ctrl["width_px"]}" Height="{ctrl["height_px"]}"\n')
                f.write(f'/>\n\n')

            elif ctrl["type"] == "SubForm":
                subform = ctrl.get("subform", {})
                f.write(f'<!-- SubForm: {subform.get("source_object", "Unknown")} -->\n')
                f.write(f'<Frame x:Name="{ctrl["name"]}"\n')
                f.write(f'       Margin="{ctrl["left_px"]},{ctrl["top_px"]},0,0"\n')
                f.write(f'       Width="{ctrl["width_px"]}" Height="{ctrl["height_px"]}"\n')
                f.write(f'/>\n\n')

            elif ctrl["type"] == "TabControl":
                f.write(f'<TabView x:Name="{ctrl["name"]}"\n')
                f.write(f'         Margin="{ctrl["left_px"]},{ctrl["top_px"]},0,0"\n')
                f.write(f'         Width="{ctrl["width_px"]}" Height="{ctrl["height_px"]}"\n')
                f.write(f'/>\n\n')

    print(f"[OK] XAML mapping: {xaml_path}")


def main():
    print("=" * 60)
    print("ACCESS FORM LAYOUT ANALYZER")
    print("=" * 60)

    ensure_screenshot_dir()

    for form_name in FORMS_TO_CAPTURE:
        print(f"\n--- Processing: {form_name} ---")

        # Analyze JSON layout
        layout = analyze_form_json(form_name)

        if layout:
            print(f"[OK] Found {len(layout['controls'])} controls")

            # Create reports
            create_layout_report(form_name, layout)
            create_xaml_mapping(form_name, layout)

            # Save raw layout as JSON
            layout_json_path = os.path.join(SCREENSHOT_PATH, f"{form_name}_layout.json")
            with open(layout_json_path, 'w', encoding='utf-8') as f:
                json.dump(layout, f, indent=2, ensure_ascii=False)
            print(f"[OK] Layout JSON: {layout_json_path}")

        # Try to capture screenshot (requires Access to be running)
        # capture_access_screenshot(form_name)

    print("\n" + "=" * 60)
    print("ANALYSIS COMPLETE")
    print(f"Reports saved to: {SCREENSHOT_PATH}")
    print("=" * 60)


if __name__ == "__main__":
    main()
