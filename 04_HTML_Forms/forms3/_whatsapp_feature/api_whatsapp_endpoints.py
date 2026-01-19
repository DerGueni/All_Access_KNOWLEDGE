# ============================================
# WhatsApp Business API (Meta Cloud API)
# ============================================
# Diese Datei enthält die neuen Endpoints für api_server.py
# Hinzugefügt am: 2026-01-10
#
# Einfügen in api_server.py vor "# Server starten" Block
# ============================================

import requests as http_requests  # Umbenannt um Konflikt mit Flask request zu vermeiden

# WhatsApp-Konfiguration (aus Umgebungsvariablen oder Config laden)
WHATSAPP_CONFIG = {
    'phone_number_id': os.environ.get('WA_PHONE_NUMBER_ID', ''),  # Meta Phone Number ID
    'access_token': os.environ.get('WA_ACCESS_TOKEN', ''),         # Meta Graph API Token
    'sender_number': '+4991140997799',                             # Absender-Nummer
    'api_version': 'v18.0',
    'webapp_url': 'https://webapp.consec-security.selfhost.eu/index.php?page=dashboard'
}

def send_whatsapp_message(recipient_phone: str, message_text: str) -> dict:
    """
    Sendet eine WhatsApp-Nachricht über die Meta Cloud API.

    Args:
        recipient_phone: Empfänger-Telefonnummer (mit Ländercode, z.B. +491234567890)
        message_text: Nachrichtentext

    Returns:
        dict mit success/error
    """
    if not WHATSAPP_CONFIG['phone_number_id'] or not WHATSAPP_CONFIG['access_token']:
        return {'success': False, 'error': 'WhatsApp API nicht konfiguriert (WA_PHONE_NUMBER_ID / WA_ACCESS_TOKEN fehlen)'}

    # Telefonnummer normalisieren (nur Ziffern)
    phone = ''.join(filter(str.isdigit, recipient_phone))
    if not phone.startswith('49'):
        phone = '49' + phone.lstrip('0')  # Deutschland

    url = f"https://graph.facebook.com/{WHATSAPP_CONFIG['api_version']}/{WHATSAPP_CONFIG['phone_number_id']}/messages"

    headers = {
        'Authorization': f"Bearer {WHATSAPP_CONFIG['access_token']}",
        'Content-Type': 'application/json'
    }

    payload = {
        'messaging_product': 'whatsapp',
        'recipient_type': 'individual',
        'to': phone,
        'type': 'text',
        'text': {
            'preview_url': True,
            'body': message_text
        }
    }

    try:
        response = http_requests.post(url, headers=headers, json=payload, timeout=30)
        response_data = response.json()

        if response.status_code == 200:
            logger.info(f"WhatsApp gesendet an {phone}: {message_text[:50]}...")
            return {'success': True, 'message_id': response_data.get('messages', [{}])[0].get('id')}
        else:
            error_msg = response_data.get('error', {}).get('message', 'Unbekannter Fehler')
            logger.error(f"WhatsApp Fehler: {error_msg}")
            return {'success': False, 'error': error_msg}

    except Exception as e:
        logger.error(f"WhatsApp Exception: {e}")
        return {'success': False, 'error': str(e)}


@app.route('/api/whatsapp/send', methods=['POST'])
def whatsapp_send():
    """
    Sendet eine einzelne WhatsApp-Nachricht.
    Body: { "phone": "+491234...", "message": "Text..." }
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'error': 'Keine Daten gesendet'}), 400

        phone = data.get('phone')
        message = data.get('message')

        if not phone or not message:
            return jsonify({'success': False, 'error': 'phone und message erforderlich'}), 400

        result = send_whatsapp_message(phone, message)
        return jsonify(result), 200 if result['success'] else 500

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/whatsapp/anfragen', methods=['POST'])
def whatsapp_anfragen():
    """
    Sendet WhatsApp-Benachrichtigungen an alle MA mit offenen Anfragen.
    Body: { "va_id": 123, "ma_ids": [1,2,3] } oder leer für alle offenen

    Nachricht: "Hi, Du hast neue Nachrichten in Deiner Consec App" + Link
    """
    try:
        data = request.get_json() or {}
        va_id = data.get('va_id')
        ma_ids = data.get('ma_ids', [])

        conn = get_connection()
        cursor = conn.cursor()

        # Offene Anfragen abfragen (Status_ID = 1 oder 2)
        query = """
            SELECT DISTINCT p.MA_ID, m.Vorname, m.Tel_Mobil,
                   a.Auftrag, p.VADatum
            FROM tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID
            WHERE p.Status_ID IN (1, 2)
            AND m.Tel_Mobil IS NOT NULL AND m.Tel_Mobil <> ''
        """
        params = []

        if va_id:
            query += " AND p.VA_ID = ?"
            params.append(va_id)

        if ma_ids:
            placeholders = ','.join(['?' for _ in ma_ids])
            query += f" AND p.MA_ID IN ({placeholders})"
            params.extend(ma_ids)

        cursor.execute(query, params)
        rows = cursor.fetchall()

        if not rows:
            release_connection(conn)
            return jsonify({'success': True, 'message': 'Keine offenen Anfragen gefunden', 'sent': 0})

        # Nachrichten senden
        sent_count = 0
        errors = []

        for row in rows:
            ma_id, vorname, tel_mobil, auftrag, va_datum = row

            # Nachricht erstellen
            message = f"Hi {vorname},\n\nDu hast neue Nachrichten in Deiner Consec App.\n\n"
            message += f"Öffne die App, um Deine Einsatzanfragen zu sehen:\n{WHATSAPP_CONFIG['webapp_url']}"

            result = send_whatsapp_message(tel_mobil, message)

            if result['success']:
                sent_count += 1
                # Status auf "Benachrichtigt" (2) setzen falls noch nicht
                cursor.execute("""
                    UPDATE tbl_MA_VA_Planung
                    SET Status_ID = 2
                    WHERE MA_ID = ? AND Status_ID = 1
                """, [ma_id])
            else:
                errors.append({'ma_id': ma_id, 'error': result.get('error')})

        conn.commit()
        release_connection(conn)

        return jsonify({
            'success': True,
            'sent': sent_count,
            'total': len(rows),
            'errors': errors if errors else None
        })

    except Exception as e:
        logger.error(f"WhatsApp Anfragen Fehler: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/whatsapp/status')
def whatsapp_status():
    """Zeigt den WhatsApp-Konfigurationsstatus"""
    configured = bool(WHATSAPP_CONFIG['phone_number_id'] and WHATSAPP_CONFIG['access_token'])
    return jsonify({
        'configured': configured,
        'sender_number': WHATSAPP_CONFIG['sender_number'],
        'webapp_url': WHATSAPP_CONFIG['webapp_url'],
        'hint': 'Setze WA_PHONE_NUMBER_ID und WA_ACCESS_TOKEN als Umgebungsvariablen' if not configured else None
    })
