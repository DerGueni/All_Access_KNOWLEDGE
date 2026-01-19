"""
Query-Tool für HTML-Formulare Analyse
Ermöglicht einfache Abfragen der generierten JSON-Daten
"""

import json
import sys
from pathlib import Path

JSON_FILE = Path(__file__).parent.parent / "_reports" / "HTML_FORMULARE_ANALYSE_2026-01-15.json"

def load_data():
    """Lädt die Analyse-Daten"""
    with open(JSON_FILE, "r", encoding="utf-8") as f:
        return json.load(f)

def find_forms_with_event(event_type, data):
    """Findet alle Formulare die einen bestimmten Event-Typ verwenden"""
    results = []
    for form_name, form_data in data["formulare"].items():
        events = form_data["events"].get(event_type, [])
        if events:
            results.append({
                "form": form_name,
                "count": len(events),
                "handlers": [e["handler"][:50] + "..." if e["handler"] and len(e["handler"]) > 50 else e["handler"] for e in events[:5]]
            })
    return sorted(results, key=lambda x: x["count"], reverse=True)

def find_forms_with_control_type(control_type, data):
    """Findet alle Formulare die einen bestimmten Control-Typ haben"""
    results = []
    for form_name, form_data in data["formulare"].items():
        controls = form_data["controls"].get(control_type, [])
        if controls:
            results.append({
                "form": form_name,
                "count": len(controls)
            })
    return sorted(results, key=lambda x: x["count"], reverse=True)

def find_forms_with_validation_type(validation_type, data):
    """Findet alle Formulare die einen bestimmten Validierungs-Typ verwenden"""
    results = []
    for form_name, form_data in data["formulare"].items():
        validations = [v for v in form_data["validations"] if v["type"] == validation_type]
        if validations:
            results.append({
                "form": form_name,
                "count": len(validations),
                "fields": [f"{v['element']}#{v['id']}" for v in validations[:5]]
            })
    return sorted(results, key=lambda x: x["count"], reverse=True)

def find_required_fields(data):
    """Findet alle Pflichtfelder"""
    results = []
    for form_name, form_data in data["formulare"].items():
        required = [v for v in form_data["validations"] if v["type"] == "required"]
        if required:
            results.append({
                "form": form_name,
                "count": len(required),
                "fields": [v["id"] or v["name"] for v in required]
            })
    return sorted(results, key=lambda x: x["count"], reverse=True)

def find_buttons_by_text(search_text, data):
    """Findet Buttons mit bestimmtem Text"""
    results = []
    search_lower = search_text.lower()

    for form_name, form_data in data["formulare"].items():
        buttons = form_data["controls"].get("button", [])
        matching = [b for b in buttons if b.get("text") and search_lower in b["text"].lower()]

        if matching:
            results.append({
                "form": form_name,
                "count": len(matching),
                "buttons": [{"id": b["id"], "text": b["text"][:30]} for b in matching[:5]]
            })

    return sorted(results, key=lambda x: x["count"], reverse=True)

def print_statistics(data):
    """Gibt Gesamt-Statistiken aus"""
    stats = data["total_statistics"]
    print("\n=== GESAMT-STATISTIK ===")
    print(f"Formulare:      {stats['total_forms']}")
    print(f"Input-Felder:   {stats['total_inputs']}")
    print(f"Selects:        {stats['total_selects']}")
    print(f"Buttons:        {stats['total_buttons']}")
    print(f"Textareas:      {stats['total_textareas']}")
    print(f"Checkboxes:     {stats['total_checkboxes']}")
    print(f"Radios:         {stats['total_radios']}")
    print(f"Validierungen:  {stats['total_validations']}")
    print(f"Fehler:         {stats['forms_with_errors']}\n")

def main():
    """Hauptfunktion"""
    if not JSON_FILE.exists():
        print(f"FEHLER: {JSON_FILE} nicht gefunden!")
        print("Bitte zuerst analyze_html_forms.py ausführen.")
        return

    data = load_data()

    if len(sys.argv) < 2:
        print("HTML Formulare Query Tool")
        print("=" * 50)
        print_statistics(data)
        print("\nVERWENDUNG:")
        print("  python query_forms_analysis.py stats              # Statistiken anzeigen")
        print("  python query_forms_analysis.py event <typ>        # Formulare mit Event-Typ")
        print("  python query_forms_analysis.py control <typ>      # Formulare mit Control-Typ")
        print("  python query_forms_analysis.py validation <typ>   # Formulare mit Validierungs-Typ")
        print("  python query_forms_analysis.py required           # Alle Pflichtfelder")
        print("  python query_forms_analysis.py button <text>      # Buttons mit Text suchen")
        print("\nBEISPIELE:")
        print("  python query_forms_analysis.py event onclick")
        print("  python query_forms_analysis.py control checkbox")
        print("  python query_forms_analysis.py validation required")
        print("  python query_forms_analysis.py button speichern")
        return

    command = sys.argv[1].lower()

    if command == "stats":
        print_statistics(data)

    elif command == "event":
        if len(sys.argv) < 3:
            print("FEHLER: Event-Typ fehlt!")
            print("Beispiel: python query_forms_analysis.py event onclick")
            return

        event_type = sys.argv[2]
        results = find_forms_with_event(event_type, data)

        print(f"\n=== FORMULARE MIT {event_type.upper()} EVENT ===")
        print(f"Gefunden: {len(results)} Formulare\n")

        for r in results[:10]:
            print(f"{r['form']:<50} ({r['count']} Events)")
            for handler in r['handlers'][:3]:
                print(f"  - {handler}")
            print()

    elif command == "control":
        if len(sys.argv) < 3:
            print("FEHLER: Control-Typ fehlt!")
            print("Beispiel: python query_forms_analysis.py control checkbox")
            return

        control_type = sys.argv[2]
        results = find_forms_with_control_type(control_type, data)

        print(f"\n=== FORMULARE MIT {control_type.upper()} CONTROLS ===")
        print(f"Gefunden: {len(results)} Formulare\n")

        for r in results[:20]:
            print(f"{r['form']:<50} ({r['count']} Controls)")

    elif command == "validation":
        if len(sys.argv) < 3:
            print("FEHLER: Validierungs-Typ fehlt!")
            print("Beispiel: python query_forms_analysis.py validation required")
            return

        validation_type = sys.argv[2]
        results = find_forms_with_validation_type(validation_type, data)

        print(f"\n=== FORMULARE MIT {validation_type.upper()} VALIDIERUNG ===")
        print(f"Gefunden: {len(results)} Formulare\n")

        for r in results[:10]:
            print(f"{r['form']:<50} ({r['count']} Felder)")
            for field in r['fields'][:5]:
                print(f"  - {field}")
            print()

    elif command == "required":
        results = find_required_fields(data)

        print(f"\n=== PFLICHTFELDER ===")
        print(f"Gefunden: {len(results)} Formulare mit Pflichtfeldern\n")

        for r in results:
            print(f"{r['form']:<50} ({r['count']} Pflichtfelder)")
            for field in r['fields'][:5]:
                print(f"  - {field}")
            print()

    elif command == "button":
        if len(sys.argv) < 3:
            print("FEHLER: Such-Text fehlt!")
            print("Beispiel: python query_forms_analysis.py button speichern")
            return

        search_text = sys.argv[2]
        results = find_buttons_by_text(search_text, data)

        print(f"\n=== BUTTONS MIT TEXT '{search_text.upper()}' ===")
        print(f"Gefunden: {len(results)} Formulare\n")

        for r in results[:10]:
            print(f"{r['form']:<50} ({r['count']} Buttons)")
            for btn in r['buttons']:
                print(f"  - {btn['id']}: {btn['text']}")
            print()

    else:
        print(f"FEHLER: Unbekannter Befehl '{command}'")
        print("Verwende: python query_forms_analysis.py (ohne Parameter) für Hilfe")

if __name__ == "__main__":
    main()
