#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Prueft HTML-Dateien auf strukturelle Fehler:
- Nicht geschlossene Tags
- Fehlerhafte Verschachtelung
"""
import os
from html.parser import HTMLParser

forms3_path = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3'

# Self-closing tags die nicht geschlossen werden muessen
VOID_ELEMENTS = {
    'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input',
    'link', 'meta', 'param', 'source', 'track', 'wbr'
}

# Optional closing tags (Browser toleriert fehlende Closing-Tags)
OPTIONAL_CLOSE = {
    'li', 'dt', 'dd', 'p', 'tr', 'td', 'th', 'tbody', 'thead', 'tfoot',
    'option', 'optgroup', 'colgroup', 'rt', 'rp'
}

class HTMLStructureChecker(HTMLParser):
    def __init__(self, filepath):
        super().__init__()
        self.filepath = filepath
        self.tag_stack = []
        self.errors = []
        self.in_script = False
        self.in_style = False

    def handle_starttag(self, tag, attrs):
        tag_lower = tag.lower()

        if tag_lower == 'script':
            self.in_script = True
        elif tag_lower == 'style':
            self.in_style = True

        # Skip void elements
        if tag_lower in VOID_ELEMENTS:
            return

        # Track opening tags
        self.tag_stack.append((tag_lower, self.getpos()))

    def handle_endtag(self, tag):
        tag_lower = tag.lower()

        if tag_lower == 'script':
            self.in_script = False
        elif tag_lower == 'style':
            self.in_style = False

        # Skip void elements
        if tag_lower in VOID_ELEMENTS:
            return

        # Check if there's a matching opening tag
        if not self.tag_stack:
            self.errors.append(f'Zeile {self.getpos()[0]}: Schliessendes </{tag}> ohne oeffnendes Tag')
            return

        # Find matching opening tag
        found = False
        for i in range(len(self.tag_stack) - 1, -1, -1):
            if self.tag_stack[i][0] == tag_lower:
                # Check for unclosed tags between
                unclosed = self.tag_stack[i+1:]
                for unclosed_tag, unclosed_pos in unclosed:
                    if unclosed_tag not in OPTIONAL_CLOSE:
                        self.errors.append(f'Zeile {unclosed_pos[0]}: <{unclosed_tag}> moeglicherweise nicht geschlossen')
                self.tag_stack = self.tag_stack[:i]
                found = True
                break

        if not found:
            self.errors.append(f'Zeile {self.getpos()[0]}: Schliessendes </{tag}> ohne oeffnendes Tag')

    def check_unclosed(self):
        """Prueft auf nicht geschlossene Tags am Ende"""
        for tag, pos in self.tag_stack:
            if tag not in OPTIONAL_CLOSE:
                self.errors.append(f'Zeile {pos[0]}: <{tag}> nicht geschlossen am Ende')

# Find all HTML files
html_files = []
for root, dirs, files in os.walk(forms3_path):
    for f in files:
        if f.endswith('.html'):
            html_files.append(os.path.join(root, f))

print(f'Pruefe {len(html_files)} HTML-Dateien auf strukturelle Fehler...')
print()

results = {}
for filepath in html_files:
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except:
        continue

    checker = HTMLStructureChecker(filepath)
    try:
        checker.feed(content)
        checker.check_unclosed()
    except Exception as e:
        checker.errors.append(f'Parse-Fehler: {str(e)}')

    if checker.errors:
        rel_path = os.path.relpath(filepath, forms3_path)
        results[rel_path] = checker.errors

if results:
    print('=== STRUKTURELLE HTML-FEHLER GEFUNDEN ===')
    print()
    for filepath, errors in sorted(results.items()):
        print(f'DATEI: {filepath}')
        for err in errors[:10]:  # Max 10 Fehler pro Datei
            print(f'  {err}')
        if len(errors) > 10:
            print(f'  ... und {len(errors) - 10} weitere Fehler')
        print()
else:
    print('Keine strukturellen HTML-Fehler gefunden!')
