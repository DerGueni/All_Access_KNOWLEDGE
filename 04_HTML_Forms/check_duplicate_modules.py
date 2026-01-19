#!/usr/bin/env python3
"""
Prüft auf doppelte Module in der Datenbank
"""

import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")
from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("\nAlle VBA-Module:")
    modules = bridge.list_modules()

    # Nach WebView2 oder Shell suchen
    for m in sorted(modules):
        if "WebView" in m or "Shell" in m or "HTML" in m:
            print(f"  * {m}")

    print(f"\nGesamt: {len(modules)} Module")

    # Auf Duplikate prüfen
    seen = {}
    for m in modules:
        m_lower = m.lower()
        if m_lower in seen:
            print(f"\n!!! DUPLIKAT: {m} und {seen[m_lower]}")
        seen[m_lower] = m
