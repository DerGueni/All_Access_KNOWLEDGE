#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import sys

# Try different encodings
encodings = ['utf-8', 'utf-8-sig', 'latin-1', 'cp1252', 'iso-8859-1']

controls_file = r'C:\Users\guenther.siegert\Documents\01_ClaudeCode_HTML\exports\forms\frm_KD_Kundenstamm\controls.json'

for enc in encodings:
    try:
        with open(controls_file, 'r', encoding=enc) as f:
            data = json.load(f)
        print(f"Successfully loaded with encoding: {enc}")
        print(f"\nTotal Controls: {len(data['Controls'])}")

        # Count by type
        types = {}
        for ctrl in data['Controls']:
            ct = ctrl.get('ControlType', 'Unknown')
            types[ct] = types.get(ct, 0) + 1

        print("\nControl Types:")
        for k, v in sorted(types.items()):
            print(f"  {k}: {v}")

        # List first 20 control names
        print("\nFirst 20 Controls:")
        for i, ctrl in enumerate(data['Controls'][:20]):
            name = ctrl.get('Name', 'N/A')
            ctype = ctrl.get('ControlType', 'N/A')
            print(f"  {i+1}. {name} ({ctype})")

        break
    except Exception as e:
        if enc == encodings[-1]:
            print(f"Failed with all encodings. Last error: {e}")
            sys.exit(1)
        continue
