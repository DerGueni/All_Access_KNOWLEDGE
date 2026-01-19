from __future__ import annotations

import json
import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Dict, List, Optional

import pandas as pd
from bs4 import BeautifulSoup

BASE_DIR = Path(__file__).resolve().parents[1]
ACCESS_DIR = BASE_DIR / "Access_Abgleich" / "forms"
HTML_INVENTORY_PATH = BASE_DIR / "INVENTORY_controls.json"
OUTPUT_PATH = BASE_DIR / "forms3_access_html_abgleich.xlsx"

FORMS_CONFIG = [
    {
        "name": "frm_VA_Auftragstamm",
        "html_entry": "frm_va_Auftragstamm",
        "html_file": "frm_va_Auftragstamm.html",
        "title": "Auftragstamm"
    },
    {
        "name": "frm_MA_Mitarbeiterstamm",
        "html_entry": "frm_MA_Mitarbeiterstamm",
        "html_file": "frm_MA_Mitarbeiterstamm.html",
        "title": "Mitarbeiterstamm"
    },
    {
        "name": "frm_KD_Kundenstamm",
        "html_entry": "frm_KD_Kundenstamm",
        "html_file": "frm_KD_Kundenstamm.html",
        "title": "Kundenstamm"
    },
    {
        "name": "frm_MA_VA_Schnellauswahl",
        "html_entry": "frm_MA_VA_Schnellauswahl",
        "html_file": "frm_MA_VA_Schnellauswahl.html",
        "title": "Schnellauswahl"
    },
]

SECTION_TYPE_MAP = {
    "Buttons": "Button",
    "CommandButtons": "Button",
    "TextBoxen": "TextBox",
    "TextBoxes": "TextBox",
    "ComboBoxen": "ComboBox",
    "ComboBoxes": "ComboBox",
    "ListBoxen": "ListBox",
    "Unterformulare": "Subform",
    "SubForms": "Subform",
    "TabControls": "TabControl",
    "CheckBoxen": "CheckBox",
    "CheckBoxes": "CheckBox",
}
INCLUDED_TYPES = set(SECTION_TYPE_MAP.values())
EVENT_PREFIXES = ("On", "After", "Before")
HTML_TYPE_MAP = {
    "button": "Button",
    "checkbox": "CheckBox",
    "radio": "CheckBox",
    "select": "ComboBox",
    "input": "TextBox",
    "date": "TextBox",
    "textarea": "TextBox",
    "tab": "TabControl",
    "table": "ListBox",
    "list": "ListBox",
    "subform": "Subform",
    "iframe": "Subform",
}
ID_PATTERN = re.compile(r"#([A-Za-z0-9_\-]+)")
NAME_PATTERN = re.compile(r"name=['\"]([^'\"]+)['\"]")
DATAFIELD_PATTERN = re.compile(r"\[data-field=['\"]([^'\"]+)['\"]\]")


def normalize_name(name: Optional[str]) -> Optional[str]:
    if not name:
        return None
    cleaned = name.strip()
    return cleaned.lower() if cleaned else None


def clean_section_name(section: str) -> str:
    base = section.replace("###", "").strip()
    if "(" in base:
        base = base.split("(")[0]
    return base.strip()


def parse_markdown_controls(path: Path) -> List[Dict[str, str]]:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    controls: List[Dict[str, str]] = []
    current_section: Optional[str] = None
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if line.startswith("### "):
            current_section = clean_section_name(line)
            i += 1
            continue
        if line.startswith("|") and i + 1 < len(lines):
            divider = lines[i + 1].strip()
            if not divider.startswith("|"):
                i += 1
                continue
            if not set(divider.replace("|", "").strip()).issubset({"-", " ", ":"}):
                i += 1
                continue
            headers = [part.strip() for part in line.strip("|").split("|")]
            i += 2
            while i < len(lines):
                row = lines[i].strip()
                if not row.startswith("|"):
                    break
                values = [part.strip() for part in row.strip("|").split("|")]
                if len(values) < len(headers):
                    values.extend([""] * (len(headers) - len(values)))
                entry = dict(zip(headers, values))
                if current_section:
                    entry["__section"] = current_section
                    controls.append(entry)
                i += 1
            continue
        i += 1
    return controls


def extract_access_controls(path: Path) -> List[Dict[str, str]]:
    raw_controls = parse_markdown_controls(path)
    parsed: List[Dict[str, str]] = []
    for entry in raw_controls:
        section = entry.get("__section", "")
        section_key = clean_section_name(section)
        control_type = SECTION_TYPE_MAP.get(section_key)
        if control_type not in INCLUDED_TYPES:
            continue
        name = entry.get("Name") or entry.get("name")
        if not name or name == "-":
            continue
        events: List[str] = []
        properties: List[str] = []
        for key, value in entry.items():
            if key in {"Name", "__section"}:
                continue
            if not value or value in {"-", ""}:
                continue
            if key == "Events":
                events.append(value)
                continue
            if any(key.startswith(prefix) for prefix in EVENT_PREFIXES):
                events.append(f"{key}:{value}")
                continue
            properties.append(f"{key}={value}")
        parsed.append(
            {
                "name": name,
                "name_norm": normalize_name(name),
                "type": control_type,
                "events": ", ".join(events),
                "properties": "; ".join(properties),
            }
        )
    return parsed


def load_inventory() -> Dict[str, dict]:
    if not HTML_INVENTORY_PATH.exists():
        return {}
    data = json.loads(HTML_INVENTORY_PATH.read_text(encoding="utf-8"))
    return {entry["name"]: entry for entry in data.get("forms", [])}


def selector_to_name(selector: Optional[str]) -> Optional[str]:
    if not selector:
        return None
    match = ID_PATTERN.search(selector)
    if match:
        return match.group(1)
    match = DATAFIELD_PATTERN.search(selector)
    if match:
        return match.group(1)
    match = NAME_PATTERN.search(selector)
    if match:
        return match.group(1)
    return None


def extract_iframes(html_path: Path) -> List[Dict[str, str]]:
    html = html_path.read_text(encoding="utf-8", errors="ignore")
    soup = BeautifulSoup(html, "html.parser")
    entries: List[Dict[str, str]] = []
    for idx, iframe in enumerate(soup.find_all("iframe")):
        raw_id = iframe.get("id")
        src = iframe.get("src", "")
        src_base = src.split("?")[0] if src else ""
        derived = raw_id or (Path(src_base).stem if src_base else None)
        if not derived:
            derived = f"iframe_{idx}"
        entries.append(
            {
                "name": derived,
                "name_norm": normalize_name(derived),
                "type": "subform",
                "event": iframe.get("onload") or "load",
                "selector": f"iframe#{raw_id}" if raw_id else f"iframe[src='{src}']",
                "details": src,
                "source": "iframe",
                "matched": False,
            }
        )
    return entries


def extract_dom_controls(html_path: Path) -> List[Dict[str, str]]:
    html = html_path.read_text(encoding="utf-8", errors="ignore")
    soup = BeautifulSoup(html, "html.parser")
    entries: List[Dict[str, str]] = []
    tags = soup.find_all(["input", "select", "textarea", "button"])
    for idx, tag in enumerate(tags):
        ctrl_id = tag.get("id") or tag.get("name") or tag.get("data-field") or tag.get("data-control")
        if not ctrl_id:
            continue
        tag_name = tag.name.lower()
        input_type = tag.get("type", "text").lower() if tag_name == "input" else tag_name
        if input_type in {"checkbox", "radio"}:
            html_type = "checkbox"
        elif tag_name == "select":
            html_type = "select"
        elif tag_name == "textarea":
            html_type = "textarea"
        elif tag_name == "button":
            html_type = "button"
        elif input_type in {"date", "datetime-local"}:
            html_type = "date"
        else:
            html_type = "input"
        inline_events = []
        for attr in ("onclick", "onchange", "oninput", "ondblclick"):
            if attr in tag.attrs:
                inline_events.append(f"{attr}={tag.attrs[attr][:40]}")
        entries.append(
            {
                "name": ctrl_id,
                "name_norm": normalize_name(ctrl_id),
                "type": html_type,
                "event": ", ".join(inline_events) if inline_events else None,
                "selector": f"#{ctrl_id}",
                "details": "DOM",
                "source": "dom",
                "matched": False,
            }
        )
    entries.extend(extract_iframes(html_path))
    return entries


def build_html_entries(config: dict, inventory_index: Dict[str, dict]) -> List[Dict[str, str]]:
    entries: List[Dict[str, str]] = []
    inventory_entry = inventory_index.get(config["html_entry"])
    if inventory_entry:
        for ctrl in inventory_entry.get("controls", []):
            ctrl_name = selector_to_name(ctrl.get("selector")) or selector_to_name(ctrl.get("fallback"))
            entries.append(
                {
                    "name": ctrl_name or ctrl.get("selector") or ctrl.get("fallback") or "",
                    "name_norm": normalize_name(ctrl_name),
                    "type": ctrl.get("type", ""),
                    "event": ctrl.get("event"),
                    "selector": ctrl.get("selector") or ctrl.get("fallback"),
                    "details": ctrl.get("expectedAction"),
                    "source": "inventory",
                    "matched": False,
                }
            )
    html_path = BASE_DIR / config["html_file"]
    if html_path.exists():
        dom_entries = extract_dom_controls(html_path)
        known = {entry["name_norm"] for entry in entries if entry["name_norm"]}
        for dom_entry in dom_entries:
            if dom_entry["name_norm"] and dom_entry["name_norm"] in known:
                continue
            entries.append(dom_entry)
    return entries


def map_html_type(value: Optional[str]) -> Optional[str]:
    if not value:
        return None
    base = value.lower()
    return HTML_TYPE_MAP.get(base, None)


def find_html_match(name_norm: Optional[str], lookup: Dict[str, List[Dict[str, str]]]) -> Optional[Dict[str, str]]:
    if not name_norm:
        return None
    candidates = lookup.get(name_norm)
    if not candidates:
        return None
    for entry in candidates:
        if not entry["matched"]:
            entry["matched"] = True
            return entry
    return None


def compare_form(config: dict, inventory_index: Dict[str, dict]) -> (List[Dict[str, str]], Counter):
    access_path = ACCESS_DIR / f"{config['name']}.md"
    html_entries = build_html_entries(config, inventory_index)
    html_lookup = defaultdict(list)
    for entry in html_entries:
        if entry["name_norm"]:
            html_lookup[entry["name_norm"]].append(entry)
    access_controls = extract_access_controls(access_path)
    rows: List[Dict[str, str]] = []
    stats = Counter()
    for ctrl in access_controls:
        stats["access_total"] += 1
        match = find_html_match(ctrl["name_norm"], html_lookup)
        if match:
            html_type = map_html_type(match.get("type")) or match.get("type")
            differences: List[str] = []
            if html_type and html_type != ctrl["type"]:
                differences.append(f"Typ: HTML={html_type} vs Access={ctrl['type']}")
            access_has_event = bool(ctrl["events"].strip())
            html_has_event = bool(match.get("event") and match.get("event") != "none")
            if access_has_event and not html_has_event:
                differences.append("HTML ohne Event-Handler")
            status = "Match" if not differences else "Abweichung"
            stats["matches" if status == "Match" else "mismatches"] += 1
            rows.append(
                {
                    "Form": config["title"],
                    "Control": ctrl["name"],
                    "AccessType": ctrl["type"],
                    "HTMLType": html_type,
                    "AccessEvents": ctrl["events"],
                    "HTMLEvent": match.get("event"),
                    "AccessProperties": ctrl["properties"],
                    "HTMLSelector": match.get("selector"),
                    "Status": status,
                    "Details": "; ".join(differences) or match.get("details"),
                }
            )
        else:
            stats["access_only"] += 1
            rows.append(
                {
                    "Form": config["title"],
                    "Control": ctrl["name"],
                    "AccessType": ctrl["type"],
                    "HTMLType": None,
                    "AccessEvents": ctrl["events"],
                    "HTMLEvent": None,
                    "AccessProperties": ctrl["properties"],
                    "HTMLSelector": None,
                    "Status": "Nur Access",
                    "Details": "Kein HTML-Gegenstück gefunden",
                }
            )
    for entry in html_entries:
        if entry["matched"]:
            continue
        stats["html_only"] += 1
        rows.append(
            {
                "Form": config["title"],
                "Control": entry.get("name") or entry.get("selector"),
                "AccessType": None,
                "HTMLType": map_html_type(entry.get("type")) or entry.get("type"),
                "AccessEvents": None,
                "HTMLEvent": entry.get("event"),
                "AccessProperties": None,
                "HTMLSelector": entry.get("selector"),
                "Status": "Nur HTML",
                "Details": entry.get("details") or entry.get("source"),
            }
        )
    return rows, stats


def main() -> None:
    inventory_index = load_inventory()
    all_rows: List[Dict[str, str]] = []
    summary_records: List[Dict[str, str]] = []
    for config in FORMS_CONFIG:
        rows, stats = compare_form(config, inventory_index)
        all_rows.extend(rows)
        summary_records.append(
            {
                "Form": config["title"],
                "AccessControls": stats["access_total"],
                "Matches": stats["matches"],
                "Abweichungen": stats["mismatches"],
                "NurAccess": stats["access_only"],
                "NurHTML": stats["html_only"],
            }
        )
    df = pd.DataFrame(all_rows)
    summary_df = pd.DataFrame(summary_records)
    with pd.ExcelWriter(OUTPUT_PATH, engine="openpyxl") as writer:
        summary_df.to_excel(writer, sheet_name="Summary", index=False)
        df.to_excel(writer, sheet_name="Abweichungen", index=False)
    print(f"Excel-Report geschrieben: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
