"""
CONSEC Email Proxy Server
Dieser Server läuft unabhängig und sendet E-Mails via Mailjet SMTP
Start: python email_proxy.py
"""

import http.server
import socketserver
import json
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import urllib.parse

PORT = 5002

# Mailjet SMTP Credentials (aus Access zmd_Const.bas)
MAILJET_USER = "97455f0f699bcd3a1cb8602299c3dadd"
MAILJET_PASSWORD = "1dd9946e4f632343405471b1b700c52f"
MAILJET_SERVER = "in-v3.mailjet.com"
MAILJET_PORT = 587

class EmailHandler(http.server.BaseHTTPRequestHandler):
    def _send_cors_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
    
    def do_OPTIONS(self):
        self.send_response(200)
        self._send_cors_headers()
        self.end_headers()
    
    def do_GET(self):
        if self.path == '/' or self.path == '/status':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self._send_cors_headers()
            self.end_headers()
            response = {'status': 'running', 'service': 'CONSEC Email Proxy', 'port': PORT}
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(404)
            self.end_headers()
    
    def do_POST(self):
        if self.path == '/api/email/send':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                data = json.loads(post_data.decode('utf-8'))
                
                to_email = data.get('to')
                subject = data.get('subject', 'CONSEC Anfrage')
                html_body = data.get('html_body', '')
                plain_body = data.get('plain_body', '')
                
                if not to_email:
                    self._send_error(400, 'Empfänger-E-Mail fehlt')
                    return
                
                print(f"[Email] Sende an: {to_email}")
                print(f"[Email] Betreff: {subject}")
                
                # E-Mail erstellen
                msg = MIMEMultipart('alternative')
                msg['Subject'] = subject
                msg['From'] = 'Consec Auftragsplanung <siegert@consec-nuernberg.de>'
                msg['To'] = to_email
                
                if plain_body:
                    msg.attach(MIMEText(plain_body, 'plain', 'utf-8'))
                if html_body:
                    msg.attach(MIMEText(html_body, 'html', 'utf-8'))
                
                # Senden via SMTP
                print(f"[Email] Verbinde mit {MAILJET_SERVER}:{MAILJET_PORT}...")
                with smtplib.SMTP(MAILJET_SERVER, MAILJET_PORT) as server:
                    server.starttls()
                    server.login(MAILJET_USER, MAILJET_PASSWORD)
                    server.sendmail('siegert@consec-nuernberg.de', to_email, msg.as_string())
                
                print(f"[Email] ✅ Erfolgreich gesendet!")
                
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self._send_cors_headers()
                self.end_headers()
                response = {'success': True, 'message': f'E-Mail an {to_email} gesendet'}
                self.wfile.write(json.dumps(response).encode())
                
            except smtplib.SMTPAuthenticationError as e:
                print(f"[Email] ❌ Auth Fehler: {e}")
                self._send_error(500, f'SMTP Auth Fehler: {str(e)}')
            except smtplib.SMTPException as e:
                print(f"[Email] ❌ SMTP Fehler: {e}")
                self._send_error(500, f'SMTP Fehler: {str(e)}')
            except Exception as e:
                print(f"[Email] ❌ Fehler: {e}")
                self._send_error(500, str(e))
        else:
            self.send_response(404)
            self.end_headers()
    
    def _send_error(self, code, message):
        self.send_response(code)
        self.send_header('Content-type', 'application/json')
        self._send_cors_headers()
        self.end_headers()
        response = {'success': False, 'error': message}
        self.wfile.write(json.dumps(response).encode())
    
    def log_message(self, format, *args):
        print(f"[HTTP] {args[0]}")

if __name__ == '__main__':
    print("=" * 50)
    print("CONSEC Email Proxy Server")
    print("=" * 50)
    print(f"Port: {PORT}")
    print(f"SMTP: {MAILJET_SERVER}:{MAILJET_PORT}")
    print("")
    print(f"Endpoint: http://localhost:{PORT}/api/email/send")
    print("=" * 50)
    
    with socketserver.TCPServer(("", PORT), EmailHandler) as httpd:
        print(f"Server läuft auf http://localhost:{PORT}")
        httpd.serve_forever()
