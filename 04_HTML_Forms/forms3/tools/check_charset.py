#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Prueft alle HTML-Dateien auf charset UTF-8 Meta-Tag
"""
import os
import re

forms3_path = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3'

# Find all HTML files
html_files = []
for root, dirs, files in os.walk(forms3_path):
    for f in files:
        if f.endswith('.html'):
            html_files.append(os.path.join(root, f))

print(f'Pruefe {len(html_files)} HTML-Dateien auf charset...')
print()

# Patterns - charset kann in verschiedenen Formen vorkommen
charset_patterns = [
    r'<meta\s+charset\s*=\s*["\']?utf-?8["\']?\s*/?>',
    r'<meta\s+http-equiv\s*=\s*["\']Content-Type["\']\s+content\s*=\s*["\']text/html;\s*charset=utf-?8["\']\s*/?>',
    r'charset\s*=\s*["\']?utf-?8["\']?'
]

head_pattern = re.compile(r'<head[^>]*>', re.IGNORECASE)

missing_charset = []

for filepath in html_files:
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except:
        continue

    # Pruefen ob head vorhanden
    has_head = bool(head_pattern.search(content))
    if not has_head:
        continue

    # Pruefen ob charset vorhanden
    has_charset = False
    content_lower = content.lower()
    for pattern in charset_patterns:
        if re.search(pattern, content_lower):
            has_charset = True
            break

    if not has_charset:
        rel_path = os.path.relpath(filepath, forms3_path)
        missing_charset.append(rel_path)

if missing_charset:
    print('=== DATEIEN OHNE charset UTF-8 META-TAG ===')
    print()
    for f in sorted(missing_charset):
        print(f'  - {f}')
else:
    print('Alle Dateien haben charset UTF-8 Meta-Tag!')
