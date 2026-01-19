"""
Menu API Endpoints fuer CONSYS Shell v2
Erweitert den bestehenden api_server.py

Diese Datei definiert die Endpoints:
- GET /api/me - Aktueller Benutzer
- GET /api/menu - Menu-Struktur basierend auf Benutzerrechten

Integration in bestehenden api_server.py:
    from api.menu_endpoints import register_menu_routes
    register_menu_routes(app)
"""

from flask import jsonify, request, g
import os

# Benutzer-Rollen und ihre erlaubten Menu-Bereiche
ROLE_PERMISSIONS = {
    'admin': ['stammdaten', 'planung', 'personal', 'lohn', 'system', 'extras'],
    'planer': ['stammdaten', 'planung', 'personal'],
    'personal': ['stammdaten', 'personal', 'lohn'],
    'standard': ['stammdaten', 'planung'],
    'readonly': ['stammdaten']
}

# Vollstaendige Menu-Struktur
MENU_STRUCTURE = [
    {
        'section': 'Stammdaten',
        'category': 'stammdaten',
        'items': [
            {'id': 'mitarbeiter', 'label': 'Mitarbeiter', 'icon': '&#128100;', 'view': 'frm_MA_Mitarbeiterstamm.html'},
            {'id': 'kunden', 'label': 'Kunden', 'icon': '&#127970;', 'view': 'frm_KD_Kundenstamm.html'},
            {'id': 'auftraege', 'label': 'Auftraege', 'icon': '&#128203;', 'view': 'frm_va_Auftragstamm.html'},
            {'id': 'objekte', 'label': 'Objekte', 'icon': '&#127919;', 'view': 'frm_OB_Objekt.html'}
        ]
    },
    {
        'section': 'Planung',
        'category': 'planung',
        'items': [
            {'id': 'dienstplan', 'label': 'Dienstplan', 'icon': '&#128197;', 'view': 'frm_N_Dienstplanuebersicht.html'},
            {'id': 'planungsuebersicht', 'label': 'Planungsuebersicht', 'icon': '&#128200;', 'view': 'frm_VA_Planungsuebersicht.html'},
            {'id': 'einsatzuebersicht', 'label': 'Einsatzuebersicht', 'icon': '&#127939;', 'view': 'frm_Einsatzuebersicht.html'},
            {'id': 'ma_schnellauswahl', 'label': 'MA Schnellauswahl', 'icon': '&#9889;', 'view': 'frm_MA_VA_Schnellauswahl.html'}
        ]
    },
    {
        'section': 'Personal',
        'category': 'personal',
        'items': [
            {'id': 'abwesenheit', 'label': 'Abwesenheit', 'icon': '&#128197;', 'view': 'frm_MA_Abwesenheit.html'},
            {'id': 'abwesenheiten', 'label': 'Abwesenheiten', 'icon': '&#128197;', 'view': 'frm_Abwesenheiten.html'},
            {'id': 'zeitkonten', 'label': 'Zeitkonten', 'icon': '&#9201;', 'view': 'frm_MA_Zeitkonten.html'},
            {'id': 'bewerber', 'label': 'Bewerber', 'icon': '&#128101;', 'view': 'frm_N_MA_Bewerber_Verarbeitung.html'},
            {'id': 'ausweis', 'label': 'Ausweise', 'icon': '&#128179;', 'view': 'frm_Ausweis_Create.html'}
        ]
    },
    {
        'section': 'Lohn',
        'category': 'lohn',
        'items': [
            {'id': 'lohnabrechnungen', 'label': 'Lohnabrechnungen', 'icon': '&#128176;', 'view': 'frm_N_Lohnabrechnungen.html'},
            {'id': 'stundenauswertung', 'label': 'Stundenauswertung', 'icon': '&#128202;', 'view': 'frm_N_Stundenauswertung.html'},
            {'id': 'stunden_lexware', 'label': 'Stunden Lexware', 'icon': '&#128200;', 'view': 'zfrm_MA_Stunden_Lexware.html'}
        ]
    },
    {
        'section': 'Kommunikation',
        'category': 'extras',
        'items': [
            {'id': 'email_versenden', 'label': 'E-Mail versenden', 'icon': '&#9993;', 'view': 'frm_N_Email_versenden.html'},
            {'id': 'serien_email', 'label': 'Serien-E-Mail', 'icon': '&#128231;', 'view': 'frm_MA_Serien_eMail_Auftrag.html'},
            {'id': 'rueckmeldungen', 'label': 'Rueckmeldungen', 'icon': '&#128172;', 'view': 'zfrm_Rueckmeldungen.html'}
        ]
    },
    {
        'section': 'System',
        'category': 'system',
        'items': [
            {'id': 'dashboard', 'label': 'Dashboard', 'icon': '&#127968;', 'view': 'frm_Menuefuehrung1.html'},
            {'id': 'live_dashboard', 'label': 'Live-Dashboard', 'icon': '&#128202;', 'view': 'frm_N_Dashboard.html'},
            {'id': 'optimierung', 'label': 'Optimierung', 'icon': '&#9881;', 'view': 'frm_N_Optimierung.html'}
        ]
    }
]


def get_current_user():
    """
    Aktuellen Benutzer ermitteln.
    In Produktion: Session/Token auswerten
    Hier: Windows-Benutzer oder Fallback
    """
    # Windows-Benutzer als Fallback
    username = os.environ.get('USERNAME', 'Benutzer')

    # Simulierte Benutzer-Datenbank (in Produktion: DB-Abfrage)
    users = {
        'guenther.siegert': {'id': 1, 'name': 'Guenther Siegert', 'initials': 'GS', 'role': 'admin'},
        'admin': {'id': 2, 'name': 'Administrator', 'initials': 'AD', 'role': 'admin'},
        'planer': {'id': 3, 'name': 'Planer', 'initials': 'PL', 'role': 'planer'},
    }

    return users.get(username, {
        'id': 0,
        'name': username,
        'initials': username[:2].upper() if username else 'XX',
        'role': 'standard'
    })


def get_menu_for_role(role):
    """
    Menu-Struktur gefiltert nach Benutzerrolle zurueckgeben.
    """
    allowed_categories = ROLE_PERMISSIONS.get(role, ROLE_PERMISSIONS['standard'])

    filtered_menu = []
    for section in MENU_STRUCTURE:
        if section['category'] in allowed_categories:
            # Kopie ohne 'category' (internes Feld)
            menu_section = {
                'section': section['section'],
                'items': section['items']
            }
            filtered_menu.append(menu_section)

    return filtered_menu


def register_menu_routes(app):
    """
    Menu-Endpoints in Flask-App registrieren.

    Verwendung:
        from api.menu_endpoints import register_menu_routes
        register_menu_routes(app)
    """

    @app.route('/api/me', methods=['GET'])
    def api_get_current_user():
        """GET /api/me - Aktueller Benutzer"""
        user = get_current_user()
        return jsonify(user)

    @app.route('/api/menu', methods=['GET'])
    def api_get_menu():
        """GET /api/menu - Menu-Struktur basierend auf Benutzerrechten"""
        user = get_current_user()
        menu = get_menu_for_role(user['role'])
        return jsonify(menu)

    @app.route('/api/menu/full', methods=['GET'])
    def api_get_full_menu():
        """GET /api/menu/full - Vollstaendige Menu-Struktur (Admin only)"""
        user = get_current_user()
        if user['role'] != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        return jsonify(MENU_STRUCTURE)

    print("Menu-Endpoints registriert: /api/me, /api/menu, /api/menu/full")


# Standalone Test
if __name__ == '__main__':
    from flask import Flask
    app = Flask(__name__)
    register_menu_routes(app)

    # CORS fuer lokale Entwicklung
    @app.after_request
    def add_cors(response):
        response.headers['Access-Control-Allow-Origin'] = '*'
        return response

    print("Test-Server auf http://localhost:5001")
    app.run(port=5001, debug=True)
