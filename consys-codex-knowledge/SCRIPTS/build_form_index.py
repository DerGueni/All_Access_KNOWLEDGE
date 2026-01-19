#!/usr/bin/env python3
"""
Build/refresh FORM_MAP_INDEX.json by scanning:
- 04_HTML_Forms/forms/*.html
- 04_HTML_Forms/forms/logic/*.logic.js
- exports/forms/*/(controls.json, recordsource.json, subforms.json, tabs.json)
"""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]

def main():
    idx = {}
    # HTML forms
    for html in (ROOT/"04_HTML_Forms"/"forms").glob("*.html"):
        name = html.stem
        idx.setdefault(name, {})
        idx[name]["html_form"] = str(html.relative_to(ROOT)).replace("\\","/")
    # Logic
    logic_dir = ROOT/"04_HTML_Forms"/"forms"/"logic"
    if logic_dir.exists():
        for js in logic_dir.glob("*.logic.js"):
            # remove ".logic" from stem
            stem = js.name.replace(".logic.js","")
            idx.setdefault(stem, {})
            idx[stem]["logic"] = str(js.relative_to(ROOT)).replace("\\","/")
    # Exports
    exp_root = ROOT/"exports"/"forms"
    if exp_root.exists():
        for form_dir in exp_root.iterdir():
            if not form_dir.is_dir():
                continue
            name = form_dir.name
            idx.setdefault(name, {})
            idx[name]["exports_dir"] = str(form_dir.relative_to(ROOT)).replace("\\","/")
            for fn in ["controls.json","recordsource.json","subforms.json","tabs.json"]:
                p = form_dir/fn
                if p.exists():
                    idx[name][fn.replace(".json","")] = str(p.relative_to(ROOT)).replace("\\","/")
    out = ROOT/"FORM_MAP_INDEX.json"
    out.write_text(json.dumps(idx, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Wrote {out} with {len(idx)} forms.")

if __name__ == "__main__":
    main()
