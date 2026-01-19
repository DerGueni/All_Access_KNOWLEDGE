/**
 * show_requestlog() - Geänderte Version für WhatsApp
 *
 * Diese Funktion ersetzt die E-Mail-Logik durch WhatsApp-Versand.
 *
 * Datei: frm_MA_VA_Schnellauswahl.html
 * Position: ca. Zeile 1485
 * Hinzugefügt am: 2026-01-10
 */

async function show_requestlog(selectedOnly) {
    if (!formState.VA_ID || !formState.VADatum_ID) {
        alert('Bitte Auftrag und Datum wählen');
        return;
    }

    const lstPlan = document.getElementById('lstMA_Plan_Body');
    const rows = selectedOnly
        ? lstPlan?.querySelectorAll('.listbox-row.selected')
        : lstPlan?.querySelectorAll('.listbox-row');

    if (!rows || rows.length === 0) {
        alert('Keine Mitarbeiter zum Anfragen vorhanden');
        return;
    }

    const maIds = Array.from(rows).map(r => parseInt(r.dataset.maid)).filter(Boolean);

    if (!confirm(`${maIds.length} Mitarbeiter anfragen?`)) return;

    // WebView2-Modus: Anfragen erstellen + WhatsApp via API senden
    if (window.chrome && window.chrome.webview && window.Bridge) {
        // Zuerst Anfragen erstellen via Bridge
        Bridge.sendEvent('anfragen_erstellen', {
            ma_ids: maIds,
            va_id: formState.VA_ID,
            vadatum_id: formState.VADatum_ID,
            vastart_id: formState.VAStart_ID
        });

        showToast(`${maIds.length} Anfragen erstellt...`, 'success');

        // Dann WhatsApp via REST API senden
        try {
            const waResponse = await fetch('http://localhost:5000/api/whatsapp/anfragen', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    va_id: formState.VA_ID,
                    ma_ids: maIds
                })
            });
            const waResult = await waResponse.json();
            if (waResult.success && waResult.sent > 0) {
                showToast(`${waResult.sent} WhatsApp-Nachrichten gesendet`, 'success');
            }
        } catch (waErr) {
            console.warn('WhatsApp-Versand:', waErr);
        }

        // Nach Anfrage zum Auftragstamm wechseln (wie VBA)
        setTimeout(() => {
            navigateToForm('frm_va_Auftragstamm', formState.VA_ID);
        }, 1000);
    } else {
        // Browser-Modus: REST API verwenden
        try {
            showToast('Erstelle Anfragen...', 'info');

            const response = await fetch('http://localhost:5000/api/anfragen/create', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    ma_ids: maIds,
                    va_id: formState.VA_ID,
                    vadatum_id: formState.VADatum_ID,
                    vastart_id: formState.VAStart_ID
                })
            });

            const result = await response.json();

            if (result.success) {
                showToast(`${result.created} Anfragen erstellt`, 'success');

                // WhatsApp-Benachrichtigungen senden
                try {
                    const waResponse = await fetch('http://localhost:5000/api/whatsapp/anfragen', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            va_id: formState.VA_ID,
                            ma_ids: maIds
                        })
                    });

                    const waResult = await waResponse.json();

                    if (waResult.success) {
                        if (waResult.sent > 0) {
                            showToast(`${waResult.sent} WhatsApp-Nachrichten gesendet`, 'success');
                        } else if (waResult.errors && waResult.errors.length > 0) {
                            // API nicht konfiguriert oder Fehler
                            const errorMsg = waResult.errors[0]?.error || 'WhatsApp nicht konfiguriert';
                            console.warn('WhatsApp-Versand:', errorMsg);

                            // Fallback: E-Mail anbieten
                            if (result.ma_data && result.ma_data.length > 0) {
                                const emails = result.ma_data.filter(m => m.eMail).map(m => m.eMail);
                                if (emails.length > 0 && confirm('WhatsApp nicht verfügbar. Per E-Mail senden?')) {
                                    const auftragInfo = await getAuftragInfo(formState.VA_ID);
                                    const subject = encodeURIComponent(
                                        `Einsatzanfrage: ${auftragInfo?.Auftrag || 'Auftrag'} am ${formatDate(auftragInfo?.VADatum)}`
                                    );
                                    const body = encodeURIComponent(
                                        `Hallo,\n\nDu hast neue Nachrichten in Deiner Consec App.\n\n` +
                                        `Öffne die App, um Deine Einsatzanfragen zu sehen:\n` +
                                        `https://webapp.consec-security.selfhost.eu/index.php?page=dashboard\n\n` +
                                        `Mit freundlichen Grüßen\nCONSEC Auftragsplanung`
                                    );
                                    window.open(`mailto:${emails.join(',')}?subject=${subject}&body=${body}`);
                                }
                            }
                        }
                    } else {
                        console.error('WhatsApp-Fehler:', waResult.error);
                    }
                } catch (waErr) {
                    console.warn('WhatsApp-Versand nicht möglich:', waErr);
                }

                // Listen aktualisieren
                refreshPlanungListe();
                zf_MA_Selektion();

            } else {
                showToast('Fehler: ' + result.error, 'error');
            }
        } catch (err) {
            console.error('Anfragen-Fehler:', err);
            showToast('Fehler beim Erstellen der Anfragen', 'error');
        }
    }
}
