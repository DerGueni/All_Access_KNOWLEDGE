# -*- coding: utf-8 -*-
file = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_MA_VA_Schnellauswahl.html'

with open(file, 'rb') as f:
    content = f.read()

# Fix double-encoded UTF-8 umlauts (as bytes)
replacements = [
    (b'\xc3\x83\xc2\xbc', b'\xc3\xbc'),  # ü
    (b'\xc3\x83\xc2\xa4', b'\xc3\xa4'),  # ä
    (b'\xc3\x83\xc2\xb6', b'\xc3\xb6'),  # ö
    (b'\xc3\x83\xc5\xb8', b'\xc3\x9f'),  # ß
    (b'\xc3\x83\xc2\x9c', b'\xc3\x9c'),  # Ü
    (b'\xc3\x83\xe2\x80\x9e', b'\xc3\x84'),  # Ä
    (b'\xc3\x83\xe2\x80\x93', b'\xc3\x96'),  # Ö
    # Simple replacements
    (b'\xc3\x83\xc2\xbc', b'\xc3\xbc'),  # Ã¼ -> ü
]

# Alternative: decode as latin-1, then fix
content_str = content.decode('utf-8', errors='replace')

# Direct string replacements
fixes = [
    ('\u00c3\u00bc', '\u00fc'),  # Ã¼ -> ü
    ('\u00c3\u00a4', '\u00e4'),  # Ã¤ -> ä
    ('\u00c3\u00b6', '\u00f6'),  # Ã¶ -> ö
    ('\u00c3\u0178', '\u00df'),  # ÃŸ -> ß
    ('\u00c3\u0153', '\u00dc'),  # Ãœ -> Ü
    ('\u00c3\u201e', '\u00c4'),  # Ã„ -> Ä
    ('\u00c3\u2013', '\u00d6'),  # Ã– -> Ö
]

for old, new in fixes:
    content_str = content_str.replace(old, new)

with open(file, 'w', encoding='utf-8') as f:
    f.write(content_str)

print('Encoding korrigiert')

# Verify
with open(file, 'r', encoding='utf-8') as f:
    v = f.read()

for word in ['Zurück', 'verfügbar', 'auswählen', 'Einsätze']:
    print(f'{word}: {"OK" if word in v else "FEHLT"}')
