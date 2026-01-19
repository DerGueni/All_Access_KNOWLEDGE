"""
HTML Formulare Analyse Script
Extrahiert Controls, Events, Validierungen und Tab-Reihenfolge aus allen HTML-Formularen
"""

import os
import json
import re
from pathlib import Path
from bs4 import BeautifulSoup

# Pfad zum forms3 Verzeichnis
FORMS3_DIR = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3")
OUTPUT_FILE = FORMS3_DIR / "_reports" / "HTML_FORMULARE_ANALYSE_2026-01-15.json"

def extract_controls(soup):
    """Extrahiert alle Controls aus dem HTML"""
    controls = {
        "input": [],
        "select": [],
        "button": [],
        "textarea": [],
        "checkbox": [],
        "radio": []
    }

    # Input-Felder
    for inp in soup.find_all("input"):
        inp_type = inp.get("type", "text").lower()

        if inp_type in ["checkbox"]:
            controls["checkbox"].append({
                "type": inp_type,
                "name": inp.get("name"),
                "id": inp.get("id"),
                "value": inp.get("value"),
                "checked": inp.has_attr("checked"),
                "required": inp.has_attr("required"),
                "disabled": inp.has_attr("disabled")
            })
        elif inp_type in ["radio"]:
            controls["radio"].append({
                "type": inp_type,
                "name": inp.get("name"),
                "id": inp.get("id"),
                "value": inp.get("value"),
                "checked": inp.has_attr("checked"),
                "required": inp.has_attr("required"),
                "disabled": inp.has_attr("disabled")
            })
        else:
            controls["input"].append({
                "type": inp_type,
                "name": inp.get("name"),
                "id": inp.get("id"),
                "placeholder": inp.get("placeholder"),
                "required": inp.has_attr("required"),
                "disabled": inp.has_attr("disabled"),
                "readonly": inp.has_attr("readonly"),
                "pattern": inp.get("pattern"),
                "min": inp.get("min"),
                "max": inp.get("max"),
                "maxlength": inp.get("maxlength")
            })

    # Select-Dropdowns
    for select in soup.find_all("select"):
        options = []
        for opt in select.find_all("option"):
            options.append({
                "value": opt.get("value"),
                "text": opt.get_text(strip=True),
                "selected": opt.has_attr("selected")
            })

        controls["select"].append({
            "name": select.get("name"),
            "id": select.get("id"),
            "required": select.has_attr("required"),
            "disabled": select.has_attr("disabled"),
            "multiple": select.has_attr("multiple"),
            "size": select.get("size"),
            "options_count": len(options),
            "has_options": len(options) > 0
        })

    # Buttons
    for btn in soup.find_all("button"):
        controls["button"].append({
            "type": btn.get("type", "button"),
            "id": btn.get("id"),
            "name": btn.get("name"),
            "text": btn.get_text(strip=True),
            "disabled": btn.has_attr("disabled"),
            "onclick": btn.get("onclick"),
            "class": btn.get("class")
        })

    # Input type="button" auch als Button erfassen
    for inp in soup.find_all("input", type=["button", "submit", "reset"]):
        controls["button"].append({
            "type": inp.get("type"),
            "id": inp.get("id"),
            "name": inp.get("name"),
            "value": inp.get("value"),
            "disabled": inp.has_attr("disabled"),
            "onclick": inp.get("onclick"),
            "class": inp.get("class")
        })

    # Textareas
    for textarea in soup.find_all("textarea"):
        controls["textarea"].append({
            "name": textarea.get("name"),
            "id": textarea.get("id"),
            "placeholder": textarea.get("placeholder"),
            "required": textarea.has_attr("required"),
            "disabled": textarea.has_attr("disabled"),
            "readonly": textarea.has_attr("readonly"),
            "rows": textarea.get("rows"),
            "cols": textarea.get("cols"),
            "maxlength": textarea.get("maxlength")
        })

    return controls

def extract_events(soup):
    """Extrahiert alle Event-Handler aus dem HTML"""
    events = {
        "onclick": [],
        "onchange": [],
        "onsubmit": [],
        "oninput": [],
        "onblur": [],
        "onfocus": [],
        "onkeyup": [],
        "onkeydown": [],
        "onload": []
    }

    # Alle Event-Attribute durchsuchen
    for event_type in events.keys():
        for elem in soup.find_all(attrs={event_type: True}):
            event_handler = elem.get(event_type)
            events[event_type].append({
                "element": elem.name,
                "id": elem.get("id"),
                "name": elem.get("name"),
                "handler": event_handler[:200] if event_handler else None  # Limit length
            })

    # Inline Script-Tags nach Event-Listenern durchsuchen
    script_events = {
        "addEventListener": [],
        "attachEvent": []
    }

    for script in soup.find_all("script"):
        script_content = script.string if script.string else ""

        # addEventListener Pattern
        listener_pattern = r'\.addEventListener\s*\(\s*["\'](\w+)["\']\s*,\s*(\w+)'
        for match in re.finditer(listener_pattern, script_content):
            event_name = match.group(1)
            function_name = match.group(2)
            script_events["addEventListener"].append({
                "event": event_name,
                "function": function_name
            })

    events["script_listeners"] = script_events

    return events

def extract_validations(soup):
    """Extrahiert alle Validierungs-Regeln"""
    validations = []

    # Required Felder
    for elem in soup.find_all(attrs={"required": True}):
        validations.append({
            "type": "required",
            "element": elem.name,
            "id": elem.get("id"),
            "name": elem.get("name")
        })

    # Pattern Validierung
    for elem in soup.find_all(attrs={"pattern": True}):
        validations.append({
            "type": "pattern",
            "element": elem.name,
            "id": elem.get("id"),
            "name": elem.get("name"),
            "pattern": elem.get("pattern")
        })

    # Min/Max Validierung
    for elem in soup.find_all(attrs={"min": True}):
        validations.append({
            "type": "min",
            "element": elem.name,
            "id": elem.get("id"),
            "name": elem.get("name"),
            "min": elem.get("min")
        })

    for elem in soup.find_all(attrs={"max": True}):
        validations.append({
            "type": "max",
            "element": elem.name,
            "id": elem.get("id"),
            "name": elem.get("name"),
            "max": elem.get("max")
        })

    # Maxlength
    for elem in soup.find_all(attrs={"maxlength": True}):
        validations.append({
            "type": "maxlength",
            "element": elem.name,
            "id": elem.get("id"),
            "name": elem.get("name"),
            "maxlength": elem.get("maxlength")
        })

    return validations

def extract_tab_order(soup):
    """Extrahiert die Tab-Reihenfolge der interaktiven Elemente"""
    tab_order = []

    # Elemente mit explizitem tabindex
    for elem in soup.find_all(attrs={"tabindex": True}):
        tab_order.append({
            "element": elem.name,
            "id": elem.get("id"),
            "name": elem.get("name"),
            "tabindex": elem.get("tabindex"),
            "explicit": True
        })

    # Interaktive Elemente in DOM-Reihenfolge (ohne expliziten tabindex)
    interactive_tags = ["input", "select", "textarea", "button", "a"]
    for elem in soup.find_all(interactive_tags):
        if not elem.has_attr("tabindex") and not elem.has_attr("disabled"):
            tab_order.append({
                "element": elem.name,
                "id": elem.get("id"),
                "name": elem.get("name"),
                "tabindex": None,
                "explicit": False,
                "type": elem.get("type") if elem.name == "input" else None
            })

    return tab_order

def analyze_html_file(html_path):
    """Analysiert eine einzelne HTML-Datei"""
    try:
        with open(html_path, "r", encoding="utf-8") as f:
            content = f.read()

        soup = BeautifulSoup(content, "html.parser")

        analysis = {
            "controls": extract_controls(soup),
            "events": extract_events(soup),
            "validations": extract_validations(soup),
            "tab_order": extract_tab_order(soup)
        }

        # Statistiken
        analysis["statistics"] = {
            "total_inputs": len(analysis["controls"]["input"]),
            "total_selects": len(analysis["controls"]["select"]),
            "total_buttons": len(analysis["controls"]["button"]),
            "total_textareas": len(analysis["controls"]["textarea"]),
            "total_checkboxes": len(analysis["controls"]["checkbox"]),
            "total_radios": len(analysis["controls"]["radio"]),
            "total_validations": len(analysis["validations"]),
            "total_tab_order": len(analysis["tab_order"])
        }

        return analysis

    except Exception as e:
        return {
            "error": str(e),
            "controls": {},
            "events": {},
            "validations": [],
            "tab_order": []
        }

def main():
    """Hauptfunktion - Analysiert alle HTML-Formulare"""
    print("Starte HTML-Formulare Analyse...")
    print(f"Verzeichnis: {FORMS3_DIR}")

    # Sammle alle HTML-Dateien
    html_files = []
    patterns = ["frm_*.html", "frmTop_*.html", "sub_*.html", "zfrm_*.html"]

    for pattern in patterns:
        html_files.extend(FORMS3_DIR.glob(pattern))

    print(f"Gefunden: {len(html_files)} HTML-Formulare")

    # Analysiere alle Formulare
    results = {}

    for i, html_file in enumerate(html_files, 1):
        print(f"[{i}/{len(html_files)}] Analysiere: {html_file.name}")
        results[html_file.name] = analyze_html_file(html_file)

    # Erstelle Gesamt-Statistik
    total_stats = {
        "total_forms": len(html_files),
        "total_inputs": sum(r.get("statistics", {}).get("total_inputs", 0) for r in results.values()),
        "total_selects": sum(r.get("statistics", {}).get("total_selects", 0) for r in results.values()),
        "total_buttons": sum(r.get("statistics", {}).get("total_buttons", 0) for r in results.values()),
        "total_textareas": sum(r.get("statistics", {}).get("total_textareas", 0) for r in results.values()),
        "total_checkboxes": sum(r.get("statistics", {}).get("total_checkboxes", 0) for r in results.values()),
        "total_radios": sum(r.get("statistics", {}).get("total_radios", 0) for r in results.values()),
        "total_validations": sum(r.get("statistics", {}).get("total_validations", 0) for r in results.values()),
        "forms_with_errors": sum(1 for r in results.values() if "error" in r)
    }

    # Erstelle Ausgabe-Struktur
    output = {
        "timestamp": "2026-01-15",
        "total_statistics": total_stats,
        "formulare": results
    }

    # Speichere Ergebnisse
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    print(f"\n✅ Analyse abgeschlossen!")
    print(f"📄 Ergebnisse gespeichert: {OUTPUT_FILE}")
    print(f"\n📊 Gesamt-Statistik:")
    print(f"   - Formulare: {total_stats['total_forms']}")
    print(f"   - Inputs: {total_stats['total_inputs']}")
    print(f"   - Selects: {total_stats['total_selects']}")
    print(f"   - Buttons: {total_stats['total_buttons']}")
    print(f"   - Textareas: {total_stats['total_textareas']}")
    print(f"   - Checkboxes: {total_stats['total_checkboxes']}")
    print(f"   - Radios: {total_stats['total_radios']}")
    print(f"   - Validierungen: {total_stats['total_validations']}")
    print(f"   - Fehler: {total_stats['forms_with_errors']}")

if __name__ == "__main__":
    main()
