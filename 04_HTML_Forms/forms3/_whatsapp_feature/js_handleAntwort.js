/**
 * handleAntwort() - Zusage/Absage Handler für Web-App Dashboard
 *
 * Diese Funktion nutzt die neuen /zusage und /absage Endpoints.
 *
 * Datei: 04_HTML_Forms/forms3/App/js/dashboard.js
 * Position: ca. Zeile 491
 * Hinzugefügt am: 2026-01-10
 */

/**
 * Antwort auf Anfrage senden (Zusage oder Absage)
 * NEU: Verwendet die speziellen /zusage und /absage Endpoints
 */
async function handleAntwort(anfrageId, istZusage) {
    const user = App.getUser();

    try {
        // Neuer Endpoint für Zusage/Absage
        const endpoint = istZusage
            ? `/planungen/${anfrageId}/zusage`
            : `/planungen/${anfrageId}/absage`;

        const response = await App.post(endpoint, {});

        if (response.success) {
            App.toast(
                response.message || (istZusage ? 'Zusage erfolgreich!' : 'Absage erfolgreich!'),
                istZusage ? 'success' : 'info'
            );
        } else {
            throw new Error(response.error || 'Unbekannter Fehler');
        }

        // Daten neu laden (Dienstplan aktualisiert sich automatisch)
        await Promise.all([
            loadEinsaetze(user.id),
            loadAnfragen(user.id)
        ]);

    } catch (error) {
        console.error('Error sending response:', error);
        App.toast(error.message || 'Fehler beim Senden der Antwort.', 'error');
    }
}

// Global verfügbar machen
window.handleAntwort = handleAntwort;
