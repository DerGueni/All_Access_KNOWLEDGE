"""
Event-Daten Web-Scraper Endpoint für api_server.py
Füge diesen Code in api_server.py ein (am besten vor dem letzten Endpoint)
"""

# ============================================
# Zusätzliche Imports für Web-Scraping
# ============================================
# Füge diese Imports am Anfang der Datei hinzu:
"""
import requests
from bs4 import BeautifulSoup
from urllib.parse import quote_plus
import re
"""

# ============================================
# API: Event-Daten Web-Scraper
# ============================================

@app.route('/api/eventdaten/<int:va_id>', methods=['GET'])
def get_eventdaten(va_id):
    """
    Web-Scraper für Event-Informationen
    Sucht automatisch nach Einlass, Beginn, Ende basierend auf Auftragsdaten
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # 1. Auftragsdaten aus Datenbank laden
        cursor.execute("""
            SELECT
                a.Auftrag,
                a.Objekt,
                a.Dat_VA_Von,
                a.Dat_VA_Bis,
                k.kun_Firma as Kunde,
                o.Ob_Ort as Ort,
                o.Ob_PLZ as PLZ,
                o.Ob_Stadt as Stadt
            FROM tbl_VA_Auftragstamm a
            LEFT JOIN tbl_KD_Kundenstamm k ON a.Veranstalter_ID = k.kun_Id
            LEFT JOIN tbl_OB_Objekt o ON a.Objekt_ID = o.ID
            WHERE a.ID = ?
        """, (va_id,))

        row = cursor.fetchone()
        release_connection(conn)

        if not row:
            return jsonify({
                'success': False,
                'error': f'Auftrag mit ID {va_id} nicht gefunden'
            }), 404

        auftrag_data = row_to_dict(cursor, row)

        # 2. Suchbegriffe zusammenbauen
        auftrag_name = auftrag_data.get('Auftrag', '')
        objekt = auftrag_data.get('Objekt', '')
        kunde = auftrag_data.get('Kunde', '')
        ort = auftrag_data.get('Ort', '') or auftrag_data.get('Stadt', '')
        datum_von = auftrag_data.get('Dat_VA_Von')

        # Datum formatieren
        datum_str = ''
        if datum_von:
            if isinstance(datum_von, str):
                try:
                    datum_obj = datetime.strptime(datum_von, '%Y-%m-%d')
                    datum_str = datum_obj.strftime('%d.%m.%Y')
                except:
                    datum_str = datum_von
            elif isinstance(datum_von, (datetime, date)):
                datum_str = datum_von.strftime('%d.%m.%Y')

        # Suchbegriffe kombinieren
        suchbegriffe = ' '.join(filter(None, [
            auftrag_name,
            objekt,
            ort,
            datum_str,
            kunde
        ]))

        logger.info(f"Suche Event-Daten für VA_ID {va_id}: '{suchbegriffe}'")

        # 3. Web-Scraping durchführen
        event_info = scrape_event_data(suchbegriffe, auftrag_name, objekt)

        # 4. Ergebnis zurückgeben
        return jsonify({
            'success': True,
            'data': {
                'einlass': event_info.get('einlass', 'Keine Infos verfügbar'),
                'beginn': event_info.get('beginn', 'Keine Infos verfügbar'),
                'ende': event_info.get('ende', 'Keine Infos verfügbar'),
                'infos': event_info.get('infos', 'Keine Infos verfügbar'),
                'weblink': event_info.get('weblink', ''),
                'suchbegriffe': suchbegriffe,
                'timestamp': datetime.now().isoformat()
            }
        })

    except Exception as e:
        logger.error(f"Fehler beim Laden der Event-Daten: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


def scrape_event_data(suchbegriffe, auftrag_name, objekt):
    """
    Scraping-Logik für Event-Informationen
    Sucht auf mehreren Plattformen nach relevanten Daten
    """
    result = {
        'einlass': None,
        'beginn': None,
        'ende': None,
        'infos': None,
        'weblink': None
    }

    try:
        # Google-Suche (erste Anlaufstelle)
        google_result = search_google(suchbegriffe)
        if google_result:
            result.update(google_result)

        # Eventim (wenn nicht gefunden)
        if not result['beginn']:
            eventim_result = search_eventim(suchbegriffe)
            if eventim_result:
                result.update(eventim_result)

        # Stadionwelt (Fußball-spezifisch)
        if not result['beginn'] and ('bundesliga' in auftrag_name.lower() or 'fußball' in auftrag_name.lower()):
            stadion_result = search_stadionwelt(suchbegriffe)
            if stadion_result:
                result.update(stadion_result)

        # Zusammenfassung
        if not any([result['einlass'], result['beginn'], result['ende']]):
            result['infos'] = f"Keine Event-Informationen gefunden für: {suchbegriffe}"
        else:
            infos = []
            if result['einlass']:
                infos.append(f"Einlass: {result['einlass']}")
            if result['beginn']:
                infos.append(f"Beginn: {result['beginn']}")
            if result['ende']:
                infos.append(f"Ende: {result['ende']}")
            result['infos'] = ' | '.join(infos)

    except Exception as e:
        logger.error(f"Scraping-Fehler: {e}")
        result['infos'] = f"Fehler beim Scraping: {str(e)}"

    return result


def search_google(query):
    """Google-Suche nach Event-Informationen"""
    try:
        # Google-Suche (ohne API - einfaches Scraping)
        search_url = f"https://www.google.com/search?q={quote_plus(query + ' einlass beginn')}"

        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }

        response = requests.get(search_url, headers=headers, timeout=5)

        if response.status_code != 200:
            return None

        soup = BeautifulSoup(response.text, 'html.parser')

        # Suche nach Zeit-Patterns
        text_content = soup.get_text()

        result = {}

        # Pattern für Einlass/Einlasszeit
        einlass_pattern = r'(?:Einlass|Einlasszeit|Doors)[:\s]+(\d{1,2}[:.\s]?\d{2})'
        einlass_match = re.search(einlass_pattern, text_content, re.IGNORECASE)
        if einlass_match:
            result['einlass'] = einlass_match.group(1).replace('.', ':')

        # Pattern für Beginn/Start/Anpfiff
        beginn_pattern = r'(?:Beginn|Start|Anpfiff|Kickoff)[:\s]+(\d{1,2}[:.\s]?\d{2})'
        beginn_match = re.search(beginn_pattern, text_content, re.IGNORECASE)
        if beginn_match:
            result['beginn'] = beginn_match.group(1).replace('.', ':')

        # Pattern für Ende
        ende_pattern = r'(?:Ende|bis)[:\s]+(\d{1,2}[:.\s]?\d{2})'
        ende_match = re.search(ende_pattern, text_content, re.IGNORECASE)
        if ende_match:
            result['ende'] = ende_match.group(1).replace('.', ':')

        # Erster Link als Weblink
        first_link = soup.select_one('div.g a')
        if first_link and first_link.get('href'):
            result['weblink'] = first_link['href']

        return result if result else None

    except Exception as e:
        logger.error(f"Google-Suche Fehler: {e}")
        return None


def search_eventim(query):
    """Eventim.de Suche"""
    try:
        search_url = f"https://www.eventim.de/search/?search={quote_plus(query)}"

        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }

        response = requests.get(search_url, headers=headers, timeout=5)

        if response.status_code != 200:
            return None

        soup = BeautifulSoup(response.text, 'html.parser')

        result = {}

        # Eventim-spezifische Selektoren
        time_elements = soup.select('.event-time, .event-date, [class*="time"]')

        for elem in time_elements:
            text = elem.get_text(strip=True)

            # Einlass
            if 'einlass' in text.lower():
                time_match = re.search(r'(\d{1,2}[:.\s]?\d{2})', text)
                if time_match:
                    result['einlass'] = time_match.group(1).replace('.', ':')

            # Beginn
            if 'beginn' in text.lower() or 'start' in text.lower():
                time_match = re.search(r'(\d{1,2}[:.\s]?\d{2})', text)
                if time_match:
                    result['beginn'] = time_match.group(1).replace('.', ':')

        # Event-Link
        event_link = soup.select_one('a[href*="/event/"]')
        if event_link:
            result['weblink'] = 'https://www.eventim.de' + event_link['href']

        return result if result else None

    except Exception as e:
        logger.error(f"Eventim-Suche Fehler: {e}")
        return None


def search_stadionwelt(query):
    """Stadionwelt.de Suche (für Fußball-Events)"""
    try:
        # Vereinfachte Stadionwelt-Suche
        search_url = f"https://www.stadionwelt.de/?s={quote_plus(query)}"

        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }

        response = requests.get(search_url, headers=headers, timeout=5)

        if response.status_code != 200:
            return None

        soup = BeautifulSoup(response.text, 'html.parser')
        text_content = soup.get_text()

        result = {}

        # Anpfiff-Pattern
        anpfiff_pattern = r'(?:Anpfiff|Anstoß)[:\s]+(\d{1,2}[:.\s]?\d{2})'
        anpfiff_match = re.search(anpfiff_pattern, text_content, re.IGNORECASE)
        if anpfiff_match:
            result['beginn'] = anpfiff_match.group(1).replace('.', ':')

        # Link zum Artikel
        article_link = soup.select_one('article a')
        if article_link and article_link.get('href'):
            result['weblink'] = article_link['href']

        return result if result else None

    except Exception as e:
        logger.error(f"Stadionwelt-Suche Fehler: {e}")
        return None


# ============================================
# INSTALLATION ANWEISUNGEN
# ============================================
"""
1. Installiere benötigte Python-Pakete:
   pip install requests beautifulsoup4

2. Füge die Imports am Anfang von api_server.py hinzu:
   import requests
   from bs4 import BeautifulSoup
   from urllib.parse import quote_plus
   import re

3. Füge den gesamten Endpoint-Code in api_server.py ein
   (am besten vor dem letzten Endpoint, nach den anderen API-Routen)

4. Server neu starten:
   python api_server.py

5. Testen:
   http://localhost:5000/api/eventdaten/12345
"""
