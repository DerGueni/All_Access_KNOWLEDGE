"""
CONSYS Shell Refactoring Tool
Konvertiert HTML-Formulare zu Views (entfernt Sidebars)

Verwendung:
    python convert_to_views.py --source forms --target views --report

Features:
- Erkennt verschiedene Sidebar-Varianten automatisch
- Erstellt Views ohne Navigation-Sidebars
- Behaelt Content-Sidebars (Formular-intern)
- Generiert JSON/Markdown Report
- Trockenlauf-Modus verfuegbar
"""

import os
import re
import json
import argparse
from datetime import datetime
from pathlib import Path
from html.parser import HTMLParser
from typing import List, Dict, Tuple, Optional


class SidebarPattern:
    """Definiert erkannte Sidebar-Patterns"""

    # Navigation-Sidebars (zu entfernen)
    NAV_SIDEBAR_PATTERNS = [
        # Variante A: Leere app-sidebar
        r'<aside\s+class="app-sidebar">\s*</aside>',
        # Variante B: Custom Menu-Sidebars
        r'<aside\s+class="[a-z]+-menu">\s*<div\s+class="menu-header">.*?</aside>',
        # Variante D: Inline Sidebar mit kompletter Struktur
        r'<aside\s+class="app-sidebar">\s*<div\s+class="sidebar-header">.*?</aside>',
        # Dashboard Sidebar
        r'<aside\s+class="db-sidebar">.*?</aside>',
    ]

    # Zu beibehaltende Sidebars (Formular-Content)
    CONTENT_SIDEBAR_PATTERNS = [
        r'<div\s+class="content-sidebar"',
        r'<div\s+class="auftragsliste-sidebar"',
    ]

    # Script-Einbindungen die entfernt werden sollen
    SCRIPT_PATTERNS = [
        r'<script\s+src="[^"]*sidebar\.js"[^>]*>\s*</script>',
    ]

    # Container die angepasst werden muessen
    CONTAINER_PATTERNS = [
        # ma-container, va-container etc -> view-container
        (r'class="([a-z]{2,4})-container"', r'class="view-container"'),
    ]


class HTMLSidebarRemover:
    """Entfernt Sidebars aus HTML-Dateien"""

    def __init__(self, preserve_content_sidebars: bool = True):
        self.preserve_content_sidebars = preserve_content_sidebars
        self.changes = []

    def process_file(self, content: str) -> Tuple[str, List[Dict]]:
        """
        Verarbeitet HTML-Content und entfernt Navigation-Sidebars.

        Returns:
            Tuple[str, List[Dict]]: (Bereinigter Content, Liste der Aenderungen)
        """
        self.changes = []
        result = content

        # 1. Navigation-Sidebars entfernen
        for pattern in SidebarPattern.NAV_SIDEBAR_PATTERNS:
            matches = list(re.finditer(pattern, result, re.DOTALL | re.IGNORECASE))
            for match in reversed(matches):
                # Pruefen ob Content-Sidebar
                if self.preserve_content_sidebars:
                    is_content = any(re.search(p, match.group(0))
                                   for p in SidebarPattern.CONTENT_SIDEBAR_PATTERNS)
                    if is_content:
                        continue

                self.changes.append({
                    'type': 'remove_sidebar',
                    'pattern': pattern[:50] + '...',
                    'content': match.group(0)[:100] + '...' if len(match.group(0)) > 100 else match.group(0)
                })
                result = result[:match.start()] + result[match.end():]

        # 2. Sidebar-Script-Einbindungen entfernen
        for pattern in SidebarPattern.SCRIPT_PATTERNS:
            matches = list(re.finditer(pattern, result, re.IGNORECASE))
            for match in reversed(matches):
                self.changes.append({
                    'type': 'remove_script',
                    'content': match.group(0)
                })
                result = result[:match.start()] + result[match.end():]

        # 3. Container-Klassen anpassen (optional)
        # for old_pattern, new_pattern in SidebarPattern.CONTAINER_PATTERNS:
        #     result = re.sub(old_pattern, new_pattern, result)

        # 4. Leere divs bereinigen
        result = re.sub(r'\n\s*\n\s*\n', '\n\n', result)

        return result, self.changes


class ViewConverter:
    """Hauptklasse fuer die Konvertierung"""

    def __init__(self, source_dir: str, target_dir: str, dry_run: bool = False):
        self.source_dir = Path(source_dir)
        self.target_dir = Path(target_dir)
        self.dry_run = dry_run
        self.remover = HTMLSidebarRemover()
        self.report = {
            'timestamp': datetime.now().isoformat(),
            'source': str(source_dir),
            'target': str(target_dir),
            'dry_run': dry_run,
            'files': [],
            'summary': {
                'total': 0,
                'converted': 0,
                'skipped': 0,
                'errors': 0
            }
        }

    def convert_all(self) -> Dict:
        """Konvertiert alle HTML-Dateien im Source-Verzeichnis"""

        if not self.source_dir.exists():
            raise FileNotFoundError(f"Source-Verzeichnis nicht gefunden: {self.source_dir}")

        # Target-Verzeichnis erstellen
        if not self.dry_run:
            self.target_dir.mkdir(parents=True, exist_ok=True)

        # Alle HTML-Dateien finden
        html_files = list(self.source_dir.glob('*.html'))

        # Subformulare ausschliessen
        main_forms = [f for f in html_files
                      if not f.name.startswith('sub_')
                      and not f.name.startswith('zsub_')
                      and not f.name.startswith('_')]

        for html_file in main_forms:
            self.convert_file(html_file)

        # Subformulare kopieren (ohne Aenderung)
        sub_forms = [f for f in html_files
                     if f.name.startswith('sub_') or f.name.startswith('zsub_')]
        for sub_file in sub_forms:
            self.copy_subform(sub_file)

        return self.report

    def convert_file(self, file_path: Path) -> None:
        """Konvertiert eine einzelne HTML-Datei"""

        self.report['summary']['total'] += 1

        try:
            # Datei lesen
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Sidebar entfernen
            converted, changes = self.remover.process_file(content)

            # Report aktualisieren
            file_report = {
                'file': file_path.name,
                'status': 'converted' if changes else 'no_changes',
                'changes': changes
            }
            self.report['files'].append(file_report)

            if changes:
                self.report['summary']['converted'] += 1

                if not self.dry_run:
                    # Konvertierte Datei speichern
                    target_file = self.target_dir / file_path.name
                    with open(target_file, 'w', encoding='utf-8') as f:
                        f.write(converted)
            else:
                self.report['summary']['skipped'] += 1

                if not self.dry_run:
                    # Datei ohne Aenderung kopieren
                    target_file = self.target_dir / file_path.name
                    with open(target_file, 'w', encoding='utf-8') as f:
                        f.write(content)

        except Exception as e:
            self.report['summary']['errors'] += 1
            self.report['files'].append({
                'file': file_path.name,
                'status': 'error',
                'error': str(e)
            })

    def copy_subform(self, file_path: Path) -> None:
        """Kopiert Subformular ohne Aenderung"""

        if self.dry_run:
            return

        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        target_file = self.target_dir / file_path.name
        with open(target_file, 'w', encoding='utf-8') as f:
            f.write(content)

    def generate_report(self, format: str = 'json') -> str:
        """Generiert Report im angegebenen Format"""

        if format == 'json':
            return json.dumps(self.report, indent=2, ensure_ascii=False)

        elif format == 'markdown':
            md = f"""# View Conversion Report

**Zeitstempel:** {self.report['timestamp']}
**Source:** `{self.report['source']}`
**Target:** `{self.report['target']}`
**Dry Run:** {self.report['dry_run']}

## Zusammenfassung

| Metrik | Wert |
|--------|------|
| Gesamt | {self.report['summary']['total']} |
| Konvertiert | {self.report['summary']['converted']} |
| Uebersprungen | {self.report['summary']['skipped']} |
| Fehler | {self.report['summary']['errors']} |

## Dateien

"""
            for file_info in self.report['files']:
                status_icon = '✅' if file_info['status'] == 'converted' else '⏭️' if file_info['status'] == 'no_changes' else '❌'
                md += f"### {status_icon} {file_info['file']}\n\n"

                if file_info.get('changes'):
                    md += "**Aenderungen:**\n"
                    for change in file_info['changes']:
                        md += f"- {change['type']}: `{change.get('content', '')[:60]}...`\n"
                    md += "\n"

                if file_info.get('error'):
                    md += f"**Fehler:** {file_info['error']}\n\n"

            return md

        else:
            raise ValueError(f"Unbekanntes Format: {format}")


def main():
    parser = argparse.ArgumentParser(
        description='Konvertiert HTML-Formulare zu Views (entfernt Sidebars)'
    )
    parser.add_argument('--source', '-s', default='forms',
                        help='Source-Verzeichnis mit HTML-Formularen')
    parser.add_argument('--target', '-t', default='views',
                        help='Ziel-Verzeichnis fuer Views')
    parser.add_argument('--report', '-r', action='store_true',
                        help='Report generieren')
    parser.add_argument('--report-format', choices=['json', 'markdown'], default='markdown',
                        help='Report-Format')
    parser.add_argument('--dry-run', '-n', action='store_true',
                        help='Trockenlauf ohne Dateiaenderungen')

    args = parser.parse_args()

    # Absoluten Pfad ermitteln
    base_dir = Path(__file__).parent.parent / '02_web'
    source_dir = base_dir / args.source
    target_dir = base_dir / args.target

    print(f"CONSYS View Converter")
    print(f"=" * 40)
    print(f"Source: {source_dir}")
    print(f"Target: {target_dir}")
    print(f"Dry Run: {args.dry_run}")
    print()

    # Konvertierung durchfuehren
    converter = ViewConverter(source_dir, target_dir, args.dry_run)
    report = converter.convert_all()

    # Ergebnis ausgeben
    print(f"Konvertierung abgeschlossen:")
    print(f"  - Gesamt: {report['summary']['total']}")
    print(f"  - Konvertiert: {report['summary']['converted']}")
    print(f"  - Uebersprungen: {report['summary']['skipped']}")
    print(f"  - Fehler: {report['summary']['errors']}")

    # Report speichern
    if args.report:
        report_content = converter.generate_report(args.report_format)
        report_ext = 'json' if args.report_format == 'json' else 'md'
        report_file = base_dir.parent / f'VIEW_CONVERSION_REPORT.{report_ext}'

        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(report_content)

        print(f"\nReport gespeichert: {report_file}")


if __name__ == '__main__':
    main()
