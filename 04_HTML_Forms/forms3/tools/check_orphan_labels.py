#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Prueft HTML-Dateien auf verwaiste Labels
(Labels mit for-Attribut das auf nicht-existierende IDs zeigt)
"""
import os
import re
from html.parser import HTMLParser

forms3_path = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3'

class LabelChecker(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids = set()
        self.label_fors = []  # (for_value, line_number)
        self.in_script = False

    def handle_starttag(self, tag, attrs):
        tag_lower = tag.lower()

        if tag_lower == 'script':
            self.in_script = True
            return

        if self.in_script:
            return

        attrs_dict = dict(attrs)

        # Sammle alle IDs
        if 'id' in attrs_dict and attrs_dict['id']:
            # Ignoriere Template-Literale
            id_val = attrs_dict['id']
            if '${' not in id_val and '+' not in id_val:
                self.ids.add(id_val)

        # Sammle alle label for-Attribute
        if tag_lower == 'label' and 'for' in attrs_dict:
            for_val = attrs_dict['for']
            if for_val and '${' not in for_val:
                self.label_fors.append((for_val, self.getpos()[0]))

    def handle_endtag(self, tag):
        if tag.lower() == 'script':
            self.in_script = False

    def get_orphans(self):
        """Findet labels deren for auf nicht-existierende IDs zeigt"""
        orphans = []
        for for_val, line in self.label_fors:
            if for_val not in self.ids:
                orphans.append((for_val, line))
        return orphans

# Find all HTML files
html_files = []
for root, dirs, files in os.walk(forms3_path):
    for f in files:
        if f.endswith('.html'):
            html_files.append(os.path.join(root, f))

print(f'Pruefe {len(html_files)} HTML-Dateien auf verwaiste Labels...')
print()

results = {}
for filepath in html_files:
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except:
        continue

    checker = LabelChecker()
    try:
        checker.feed(content)
    except:
        continue

    orphans = checker.get_orphans()
    if orphans:
        rel_path = os.path.relpath(filepath, forms3_path)
        results[rel_path] = orphans

if results:
    print('=== VERWAISTE LABELS GEFUNDEN ===')
    print()
    for filepath, orphans in sorted(results.items()):
        print(f'DATEI: {filepath}')
        for for_val, line in orphans:
            print(f'  Zeile {line}: for="{for_val}" zeigt auf nicht-existierende ID')
        print()
else:
    print('Keine verwaisten Labels gefunden!')
