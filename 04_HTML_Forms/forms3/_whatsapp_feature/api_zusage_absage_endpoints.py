# ============================================
# Zusage/Absage Endpoints für api_server.py
# ============================================
# Diese Endpoints wurden für die WhatsApp-Integration hinzugefügt
# Hinzugefügt am: 2026-01-10
#
# Einfügen in api_server.py nach dem /api/planungen Block
# ============================================

@app.route('/api/planungen/<int:id>/zusage', methods=['POST'])
def zusage_planung(id):
    """
    Zusage verarbeiten: MA wird von tbl_MA_VA_Planung in tbl_MA_VA_Zuordnung verschoben.

    Ablauf:
    1. Planung-Daten lesen
    2. Freien Slot in Zuordnung finden (MA_ID = 0, IstFraglich = False)
    3. Slot mit MA-Daten befüllen
    4. Planung-Eintrag löschen
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # 1. Planung-Daten lesen
        cursor.execute("""
            SELECT p.VA_ID, p.VADatum_ID, p.VAStart_ID, p.PosNr, p.MA_ID,
                   p.VADatum, p.MVA_Start, p.MVA_Ende
            FROM tbl_MA_VA_Planung p
            WHERE p.ID = ?
        """, [id])

        row = cursor.fetchone()
        if not row:
            release_connection(conn)
            return jsonify({'success': False, 'error': 'Planung nicht gefunden'}), 404

        va_id, vadatum_id, vastart_id, pos_nr, ma_id, vadatum, mva_start, mva_ende = row

        # 2. Freien Slot in Zuordnung finden
        # Suche Eintrag mit MA_ID = 0 (oder NULL) und IstFraglich = False für diese Schicht
        cursor.execute("""
            SELECT ID FROM tbl_MA_VA_Zuordnung
            WHERE VA_ID = ? AND VADatum_ID = ? AND VAStart_ID = ?
            AND (MA_ID = 0 OR MA_ID IS NULL)
            AND (IstFraglich = False OR IstFraglich IS NULL)
        """, [va_id, vadatum_id, vastart_id])

        slot = cursor.fetchone()

        if slot:
            # 3a. Existierenden Slot befüllen
            slot_id = slot[0]
            cursor.execute("""
                UPDATE tbl_MA_VA_Zuordnung
                SET MA_ID = ?, MA_Start = ?, MA_Ende = ?
                WHERE ID = ?
            """, [ma_id, mva_start, mva_ende, slot_id])
        else:
            # 3b. Neuen Eintrag erstellen
            cursor.execute("""
                INSERT INTO tbl_MA_VA_Zuordnung
                (VA_ID, VADatum_ID, VAStart_ID, MA_ID, VADatum, MA_Start, MA_Ende, IstFraglich)
                VALUES (?, ?, ?, ?, ?, ?, ?, False)
            """, [va_id, vadatum_id, vastart_id, ma_id, vadatum, mva_start, mva_ende])

        # 4. Planung-Eintrag löschen
        cursor.execute("DELETE FROM tbl_MA_VA_Planung WHERE ID = ?", [id])

        conn.commit()
        release_connection(conn)

        return jsonify({
            'success': True,
            'message': 'Zusage erfolgreich! Einsatz wurde in den Dienstplan eingetragen.'
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/planungen/<int:id>/absage', methods=['POST'])
def absage_planung(id):
    """
    Absage verarbeiten: Status_ID auf 4 setzen in tbl_MA_VA_Planung.
    MA bleibt in Planung mit Status "Abgesagt".
    """
    try:
        data = request.get_json() or {}
        grund = data.get('grund', '')

        conn = get_connection()
        cursor = conn.cursor()

        # Status auf 4 (Absage) setzen
        cursor.execute("""
            UPDATE tbl_MA_VA_Planung
            SET Status_ID = 4, Bemerkungen = ?
            WHERE ID = ?
        """, [grund, id])

        if cursor.rowcount == 0:
            release_connection(conn)
            return jsonify({'success': False, 'error': 'Planung nicht gefunden'}), 404

        conn.commit()
        release_connection(conn)

        return jsonify({
            'success': True,
            'message': 'Absage erfolgreich gespeichert.'
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500
