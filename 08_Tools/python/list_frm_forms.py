# -*- coding: utf-8 -*-
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')
from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    forms = bridge.list_forms()
    frm_forms = sorted([f for f in forms if f.lower().startswith('frm_')])
    print(f"\n=== FRM_ FORMULARE ({len(frm_forms)}) ===\n")
    for f in frm_forms:
        print(f"  {f}")
