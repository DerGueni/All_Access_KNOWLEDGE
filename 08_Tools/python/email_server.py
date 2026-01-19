"""
Standalone Email Server - sendet E-Mails via Mailjet SMTP
Läuft auf Port 5001, um den Haupt-API-Server nicht zu stören
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

app = Flask(__name__)
CORS(app)

# Mailjet SMTP Credentials (aus Access zmd_Const.bas)
MAILJET_USER = "97455f0f699bcd3a1cb8602299c3dadd"
MAILJET_PASSWORD = "1dd9946e4f632343405471b1b700c52f"
MAILJET_SERVER = "in-v3.mailjet.com"
MAILJET_PORT = 587  # TLS Port

@app.route('/')
def index():
    return jsonify({
        'service': 'CONSEC Email Server',
        'status': 'running',
        'endpoint': '/api/email/send (POST)'
    })

@app.route('/api/email/send', methods=['POST', 'OPTIONS'])
def send_email():
    """E-Mail über Mailjet SMTP senden"""
    
    # Handle CORS preflight
    if request.method == 'OPTIONS':
        return jsonify({'status': 'ok'})
    
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'success': False, 'error': 'Keine Daten übergeben'}), 400
        
        to_email = data.get('to')
        subject = data.get('subject', 'CONSEC Anfrage')
        html_body = data.get('html_body', '')
        plain_body = data.get('plain_body', '')
        
        if not to_email:
            return jsonify({'success': False, 'error': 'Empfänger-E-Mail fehlt'}), 400
        
        print(f"[Email] Sende an: {to_email}")
        print(f"[Email] Betreff: {subject}")
        
        # E-Mail erstellen
        msg = MIMEMultipart('alternative')
        msg['Subject'] = subject
        msg['From'] = 'Consec Auftragsplanung <siegert@consec-nuernberg.de>'
        msg['To'] = to_email
        
        # Plain Text und HTML hinzufügen
        if plain_body:
            part1 = MIMEText(plain_body, 'plain', 'utf-8')
            msg.attach(part1)
        
        if html_body:
            part2 = MIMEText(html_body, 'html', 'utf-8')
            msg.attach(part2)
        
        # Über SMTP senden
        print(f"[Email] Verbinde mit {MAILJET_SERVER}:{MAILJET_PORT}...")
        with smtplib.SMTP(MAILJET_SERVER, MAILJET_PORT) as server:
            server.starttls()  # TLS aktivieren
            print("[Email] TLS aktiviert, login...")
            server.login(MAILJET_USER, MAILJET_PASSWORD)
            print("[Email] Eingeloggt, sende...")
            server.sendmail(
                'siegert@consec-nuernberg.de',
                to_email,
                msg.as_string()
            )
        
        print(f"[Email] ✅ Erfolgreich gesendet an {to_email}")
        
        return jsonify({
            'success': True,
            'message': f'E-Mail an {to_email} gesendet'
        })
        
    except smtplib.SMTPAuthenticationError as e:
        print(f"[Email] ❌ Auth Fehler: {e}")
        return jsonify({'success': False, 'error': f'SMTP Auth Fehler: {str(e)}'}), 500
    except smtplib.SMTPException as e:
        print(f"[Email] ❌ SMTP Fehler: {e}")
        return jsonify({'success': False, 'error': f'SMTP Fehler: {str(e)}'}), 500
    except Exception as e:
        print(f"[Email] ❌ Fehler: {e}")
        import traceback
        return jsonify({'success': False, 'error': str(e), 'trace': traceback.format_exc()}), 500


if __name__ == '__main__':
    print("=" * 50)
    print("CONSEC Email Server (Mailjet SMTP)")
    print("=" * 50)
    print(f"SMTP: {MAILJET_SERVER}:{MAILJET_PORT}")
    print("")
    print("Starte Server auf http://localhost:5001")
    print("=" * 50)
    
    app.run(host='0.0.0.0', port=5001, debug=True)
