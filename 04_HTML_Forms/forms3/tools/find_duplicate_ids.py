#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Findet Duplicate IDs in allen HTML-Dateien
Ignoriert JavaScript-Code und Template-Strings
"""
import os
import re
from collections import defaultdict
from html.parser import HTMLParser

forms3_path = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3'

class HTMLIDFinder(HTMLParser):
    """Parser der nur echte HTML id-Attribute findet"""
    def __init__(self):
        super().__init__()
        self.ids = []
        self.in_script = False
        self.in_style = False

    def handle_starttag(self, tag, attrs):
        if tag == 'script':
            self.in_script = True
        elif tag == 'style':
            self.in_style = True

        # Ignoriere IDs in Script/Style Tags
        if not self.in_script and not self.in_style:
            for name, value in attrs:
                if name.lower() == 'id' and value:
                    # Ignoriere Template-Literale
                    if '${' not in value and '+' not in value:
                        self.ids.append(value)

    def handle_endtag(self, tag):
        if tag == 'script':
            self.in_script = False
        elif tag == 'style':
            self.in_style = False

# Find all HTML files
html_files = []
for root, dirs, files in os.walk(forms3_path):
    for f in files:
        if f.endswith('.html'):
            html_files.append(os.path.join(root, f))

print(f'Analysiere {len(html_files)} HTML-Dateien...')
print()

results = {}
for filepath in html_files:
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except:
        continue

    # Parse HTML and find IDs
    parser = HTMLIDFinder()
    try:
        parser.feed(content)
    except:
        continue

    ids = parser.ids

    # Count duplicates
    id_counts = defaultdict(int)
    for id_val in ids:
        id_counts[id_val] += 1

    # Filter to only duplicates
    duplicates = {k: v for k, v in id_counts.items() if v > 1}

    if duplicates:
        results[filepath] = duplicates

# Print results
if results:
    print('=== DUPLICATE IDs GEFUNDEN ===')
    print()
    for filepath, dups in results.items():
        rel_path = os.path.relpath(filepath, forms3_path)
        print(f'DATEI: {rel_path}')
        for id_val, count in sorted(dups.items()):
            print(f'  - id="{id_val}" erscheint {count}x')
        print()
else:
    print('Keine Duplicate IDs gefunden!')
