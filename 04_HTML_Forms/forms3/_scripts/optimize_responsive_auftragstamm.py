"""
Optimiert frm_va_Auftragstamm.html für Responsive Design
Ersetzt Inline-Styles durch CSS-Klassen aus responsive.css

Erstellt: 15.01.2026
"""

import re
from pathlib import Path

# Pfade
FORMS_DIR = Path(__file__).parent.parent
HTML_FILE = FORMS_DIR / "frm_va_Auftragstamm.html"
BACKUP_FILE = FORMS_DIR / "backups" / f"frm_va_Auftragstamm_before_responsive_{Path(__file__).stem}.html"

# Backup-Verzeichnis erstellen
BACKUP_FILE.parent.mkdir(exist_ok=True)

def backup_file():
    """Erstellt Backup der Original-Datei"""
    content = HTML_FILE.read_text(encoding='utf-8')
    BACKUP_FILE.write_text(content, encoding='utf-8')
    print(f"[OK] Backup erstellt: {BACKUP_FILE}")
    return content

def replace_inline_styles(html):
    """Ersetzt Inline-Styles durch CSS-Klassen"""
    changes = []

    # 1. Position: left Offsets
    replacements = [
        # left: -115px -> offset-left-sm
        (r'style="([^"]*?)position:\s*relative;\s*left:\s*-115px;?([^"]*?)"',
         r'style="\1\2" class="offset-left-sm"', 'left: -115px -> .offset-left-sm'),
        (r'style="([^"]*?)left:\s*-115px;?\s*position:\s*relative;?([^"]*?)"',
         r'style="\1\2" class="offset-left-sm"', 'left: -115px -> .offset-left-sm'),

        # left: -150px -> offset-left-md
        (r'style="([^"]*?)position:\s*relative;\s*left:\s*-150px;?([^"]*?)"',
         r'style="\1\2" class="offset-left-md"', 'left: -150px -> .offset-left-md'),
        (r'style="([^"]*?)left:\s*-150px;?\s*position:\s*relative;?([^"]*?)"',
         r'style="\1\2" class="offset-left-md"', 'left: -150px -> .offset-left-md'),

        # left: -214px -> offset-left-lg
        (r'style="([^"]*?)position:\s*relative;\s*left:\s*-214(?:\.387)?px;?([^"]*?)"',
         r'style="\1\2" class="offset-left-lg"', 'left: -214px -> .offset-left-lg'),
        (r'style="([^"]*?)left:\s*-214(?:\.387)?px;?\s*position:\s*relative;?([^"]*?)"',
         r'style="\1\2" class="offset-left-lg"', 'left: -214px -> .offset-left-lg'),

        # left: -675px -> offset-left-xl
        (r'style="([^"]*?)position:\s*relative;\s*left:\s*-675px;?([^"]*?)"',
         r'style="\1\2" class="offset-left-xl"', 'left: -675px -> .offset-left-xl'),
        (r'style="([^"]*?)left:\s*-675px;?\s*position:\s*relative;?([^"]*?)"',
         r'style="\1\2" class="offset-left-xl"', 'left: -675px -> .offset-left-xl'),
    ]

    for pattern, replacement, desc in replacements:
        new_html, count = re.subn(pattern, replacement, html)
        if count > 0:
            changes.append(f"  • {desc}: {count}x")
            html = new_html

    # 2. Width-Styles
    width_replacements = [
        (r'style="([^"]*?)width:\s*95px;?([^"]*?)"', r'style="\1\2" class="w-95"', 'width: 95px -> .w-95'),
        (r'style="([^"]*?)width:\s*100px;?([^"]*?)"', r'style="\1\2" class="w-100"', 'width: 100px -> .w-100'),
        (r'style="([^"]*?)width:\s*110px;?([^"]*?)"', r'style="\1\2" class="w-110"', 'width: 110px -> .w-110'),
        (r'style="([^"]*?)width:\s*180px;?([^"]*?)"', r'style="\1\2" class="w-180"', 'width: 180px -> .w-180'),
        (r'style="([^"]*?)width:\s*184(?:\.234)?px;?([^"]*?)"', r'style="\1\2" class="w-184"', 'width: 184px -> .w-184'),
        (r'style="([^"]*?)width:\s*205px;?([^"]*?)"', r'style="\1\2" class="w-205"', 'width: 205px -> .w-205'),
        (r'style="([^"]*?)width:\s*83px;?([^"]*?)"', r'style="\1\2" class="w-83"', 'width: 83px -> .w-83'),
        (r'style="([^"]*?)width:\s*80px;?([^"]*?)"', r'style="\1\2" class="w-80"', 'width: 80px -> .w-80'),
    ]

    for pattern, replacement, desc in width_replacements:
        new_html, count = re.subn(pattern, replacement, html)
        if count > 0:
            changes.append(f"  • {desc}: {count}x")
            html = new_html

    # 3. Height-Styles
    height_replacements = [
        (r'style="([^"]*?)height:\s*20px;?([^"]*?)"', r'style="\1\2" class="h-20"', 'height: 20px -> .h-20'),
        (r'style="([^"]*?)height:\s*23px;?([^"]*?)"', r'style="\1\2" class="h-23"', 'height: 23px -> .h-23'),
    ]

    for pattern, replacement, desc in height_replacements:
        new_html, count = re.subn(pattern, replacement, html)
        if count > 0:
            changes.append(f"  • {desc}: {count}x")
            html = new_html

    # 4. Margin-Styles
    margin_replacements = [
        (r'style="([^"]*?)margin-left:\s*auto;?([^"]*?)"', r'style="\1\2" class="ml-auto"', 'margin-left: auto -> .ml-auto'),
        (r'style="([^"]*?)margin-left:\s*5px;?([^"]*?)"', r'style="\1\2" class="ml-5"', 'margin-left: 5px -> .ml-5'),
        (r'style="([^"]*?)margin-left:\s*10px;?([^"]*?)"', r'style="\1\2" class="ml-10"', 'margin-left: 10px -> .ml-10'),
        (r'style="([^"]*?)margin-left:\s*15px;?([^"]*?)"', r'style="\1\2" class="ml-15"', 'margin-left: 15px -> .ml-15'),
        (r'style="([^"]*?)margin-left:\s*100px;?([^"]*?)"', r'style="\1\2" class="ml-100"', 'margin-left: 100px -> .ml-100'),
        (r'style="([^"]*?)margin-top:\s*4px;?([^"]*?)"', r'style="\1\2" class="mt-4"', 'margin-top: 4px -> .mt-4'),
    ]

    for pattern, replacement, desc in margin_replacements:
        new_html, count = re.subn(pattern, replacement, html)
        if count > 0:
            changes.append(f"  • {desc}: {count}x")
            html = new_html

    # 5. Top Offset-Styles
    top_replacements = [
        (r'style="([^"]*?)top:\s*-5px;?([^"]*?)"', r'style="\1\2" class="top-minus-5"', 'top: -5px -> .top-minus-5'),
        (r'style="([^"]*?)top:\s*0(?:px)?;?([^"]*?)"', r'style="\1\2" class="top-0"', 'top: 0 -> .top-0'),
        (r'style="([^"]*?)top:\s*25px;?([^"]*?)"', r'style="\1\2" class="top-25"', 'top: 25px -> .top-25'),
    ]

    for pattern, replacement, desc in top_replacements:
        new_html, count = re.subn(pattern, replacement, html)
        if count > 0:
            changes.append(f"  • {desc}: {count}x")
            html = new_html

    # 6. Leere style="" Attribute entfernen
    html = re.sub(r'\s*style=""\s*', ' ', html)
    html = re.sub(r'\s*style="\s*"\s*', ' ', html)

    # 7. Doppelte Leerzeichen entfernen
    html = re.sub(r'\s{2,}', ' ', html)

    return html, changes

def optimize_classes(html):
    """Optimiert CSS-Klassen (entfernt Duplikate, sortiert)"""
    changes = []

    # Finde alle Elemente mit class-Attribut die auch style haben
    pattern = r'(<[^>]*?)\s+style="([^"]*?)"\s+class="([^"]*?)"'

    def combine_classes(match):
        tag_start = match.group(1)
        style = match.group(2)
        classes = match.group(3)

        # Klassen deduplicaten und sortieren
        class_list = classes.split()
        unique_classes = sorted(set(class_list), key=class_list.index)

        return f'{tag_start} class="{" ".join(unique_classes)}" style="{style}"'

    new_html, count = re.subn(pattern, combine_classes, html)
    if count > 0:
        changes.append(f"  • CSS-Klassen optimiert: {count}x")

    return new_html, changes

def main():
    print("=" * 60)
    print("RESPONSIVE DESIGN OPTIMIERUNG - frm_va_Auftragstamm.html")
    print("=" * 60)
    print()

    # Backup erstellen
    html = backup_file()
    print()

    # Inline-Styles ersetzen
    print("Ersetze Inline-Styles durch CSS-Klassen...")
    html, style_changes = replace_inline_styles(html)
    if style_changes:
        for change in style_changes:
            print(change)
    else:
        print("  • Keine Änderungen notwendig")
    print()

    # Klassen optimieren
    print("Optimiere CSS-Klassen...")
    html, class_changes = optimize_classes(html)
    if class_changes:
        for change in class_changes:
            print(change)
    else:
        print("  • Keine Änderungen notwendig")
    print()

    # Datei speichern
    HTML_FILE.write_text(html, encoding='utf-8')
    print(f"[OK] Datei gespeichert: {HTML_FILE}")
    print()

    # Zusammenfassung
    total_changes = len(style_changes) + len(class_changes)
    print("=" * 60)
    print(f"FERTIG! {total_changes} Optimierungen durchgeführt")
    print("=" * 60)
    print()
    print("Nächste Schritte:")
    print("1. Datei im Browser öffnen und testen")
    print("2. Responsive Verhalten prüfen (Browser-Größe ändern)")
    print("3. Bei Problemen: Backup wiederherstellen")
    print(f"   Backup: {BACKUP_FILE}")

if __name__ == "__main__":
    main()
