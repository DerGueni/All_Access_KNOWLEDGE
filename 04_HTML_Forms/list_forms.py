#!/usr/bin/env python3
"""Listet alle Formulare auf"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")
from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    forms = bridge.list_forms()
    print(f"\n{len(forms)} Formulare gefunden:\n")
    for f in sorted(forms):
        if "Auftrag" in f or "Mitarbeiter" in f or "Kunden" in f or "Objekt" in f:
            print(f"  * {f}")
