/**
 * email_anfrage_template.js
 * HTML E-Mail-Template für Mitarbeiter-Anfragen
 * 
 * Platzhalter:
 * [A_URL_JA] - Zusage-Link mit MD5-Hash
 * [A_URL_NEIN] - Absage-Link mit MD5-Hash
 * [A_Auftr_Datum] - Einsatzdatum
 * [A_Auftrag] - Auftragsname
 * [A_Ort] - Einsatzort
 * [A_Objekt] - Objektname
 * [A_Start_Zeit] - Dienstbeginn
 * [A_End_Zeit] - Dienstende
 * [A_Treffpunkt] - Treffpunkt
 * [A_Treffp_Zeit] - Treffpunktzeit
 * [A_Dienstkleidung] - Dresscode
 * [A_Wochentag] - Wochentag
 * [A_Sender] - Absendername
 * [A_MA_Vorname] - Mitarbeiter-Vorname
 */

const EMAIL_ANFRAGE_TEMPLATE = `<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CONSEC Einsatzanfrage</title>
</head>
<body style="margin: 0; padding: 0; font-family: Arial, Helvetica, sans-serif; background-color: #f4f4f4;">
    <table role="presentation" style="width: 100%; border-collapse: collapse;">
        <tr>
            <td align="center" style="padding: 20px 0;">
                <table role="presentation" style="width: 600px; max-width: 100%; border-collapse: collapse; background-color: #ffffff; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
                    <!-- Header -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #000080 0%, #1a5276 100%); padding: 20px 30px; text-align: center;">
                            <h1 style="color: #ffffff; margin: 0; font-size: 24px; font-weight: bold;">
                                CONSEC Security
                            </h1>
                            <p style="color: #b0c4de; margin: 5px 0 0 0; font-size: 14px;">
                                Einsatzanfrage
                            </p>
                        </td>
                    </tr>
                    
                    <!-- Greeting -->
                    <tr>
                        <td style="padding: 30px 30px 20px 30px;">
                            <p style="margin: 0; font-size: 16px; color: #333;">
                                Hallo <strong>[A_MA_Vorname]</strong>,
                            </p>
                            <p style="margin: 15px 0 0 0; font-size: 14px; color: #555; line-height: 1.5;">
                                wir haben einen neuen Einsatz für Dich. Bitte prüfe die Details und gib uns schnellstmöglich Bescheid, ob Du verfügbar bist.
                            </p>
                        </td>
                    </tr>
                    
                    <!-- Event Details Box -->
                    <tr>
                        <td style="padding: 0 30px 20px 30px;">
                            <table role="presentation" style="width: 100%; border-collapse: collapse; background-color: #f8f9fa; border: 1px solid #dee2e6; border-radius: 8px;">
                                <tr>
                                    <td style="padding: 20px;">
                                        <h2 style="margin: 0 0 15px 0; font-size: 18px; color: #000080; border-bottom: 2px solid #000080; padding-bottom: 10px;">
                                            📋 Einsatzdetails
                                        </h2>
                                        <table role="presentation" style="width: 100%; border-collapse: collapse;">
                                            <tr>
                                                <td style="padding: 8px 0; width: 130px; color: #666; font-size: 13px; vertical-align: top;">
                                                    <strong>Auftrag:</strong>
                                                </td>
                                                <td style="padding: 8px 0; color: #333; font-size: 13px;">
                                                    [A_Auftrag]
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 8px 0; color: #666; font-size: 13px; vertical-align: top;">
                                                    <strong>Objekt:</strong>
                                                </td>
                                                <td style="padding: 8px 0; color: #333; font-size: 13px;">
                                                    [A_Objekt]
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 8px 0; color: #666; font-size: 13px; vertical-align: top;">
                                                    <strong>Ort:</strong>
                                                </td>
                                                <td style="padding: 8px 0; color: #333; font-size: 13px;">
                                                    [A_Ort]
                                                </td>
                                            </tr>
                                            <tr style="background-color: #e8f4f8;">
                                                <td style="padding: 8px 0; padding-left: 10px; color: #666; font-size: 13px; vertical-align: top;">
                                                    <strong>📅 Datum:</strong>
                                                </td>
                                                <td style="padding: 8px 0; color: #000080; font-size: 14px; font-weight: bold;">
                                                    [A_Wochentag], [A_Auftr_Datum]
                                                </td>
                                            </tr>
                                            <tr style="background-color: #e8f4f8;">
                                                <td style="padding: 8px 0; padding-left: 10px; color: #666; font-size: 13px; vertical-align: top;">
                                                    <strong>⏰ Dienstzeit:</strong>
                                                </td>
                                                <td style="padding: 8px 0; color: #000080; font-size: 14px; font-weight: bold;">
                                                    [A_Start_Zeit] - [A_End_Zeit] Uhr
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 8px 0; color: #666; font-size: 13px; vertical-align: top;">
                                                    <strong>📍 Treffpunkt:</strong>
                                                </td>
                                                <td style="padding: 8px 0; color: #333; font-size: 13px;">
                                                    [A_Treffpunkt] ([A_Treffp_Zeit] Uhr)
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 8px 0; color: #666; font-size: 13px; vertical-align: top;">
                                                    <strong>👔 Kleidung:</strong>
                                                </td>
                                                <td style="padding: 8px 0; color: #333; font-size: 13px;">
                                                    [A_Dienstkleidung]
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    
                    <!-- Action Buttons -->
                    <tr>
                        <td style="padding: 0 30px 30px 30px;">
                            <p style="margin: 0 0 15px 0; font-size: 14px; color: #555; text-align: center;">
                                Bitte antworte mit einem Klick:
                            </p>
                            <table role="presentation" style="width: 100%; border-collapse: collapse;">
                                <tr>
                                    <td style="padding: 5px; text-align: center; width: 50%;">
                                        <a href="[A_URL_JA]" style="display: inline-block; padding: 15px 40px; background: linear-gradient(135deg, #28a745 0%, #1e7e34 100%); color: #ffffff; text-decoration: none; font-size: 16px; font-weight: bold; border-radius: 5px; box-shadow: 0 3px 6px rgba(40,167,69,0.3);">
                                            ✓ JA, ich bin dabei!
                                        </a>
                                    </td>
                                    <td style="padding: 5px; text-align: center; width: 50%;">
                                        <a href="[A_URL_NEIN]" style="display: inline-block; padding: 15px 40px; background: linear-gradient(135deg, #dc3545 0%, #bd2130 100%); color: #ffffff; text-decoration: none; font-size: 16px; font-weight: bold; border-radius: 5px; box-shadow: 0 3px 6px rgba(220,53,69,0.3);">
                                            ✗ Leider nicht möglich
                                        </a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    
                    <!-- Alternative -->
                    <tr>
                        <td style="padding: 0 30px 20px 30px;">
                            <p style="margin: 0; font-size: 12px; color: #888; text-align: center;">
                                Falls die Buttons nicht funktionieren, kannst Du auch direkt auf diese E-Mail antworten.
                            </p>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #f8f9fa; padding: 20px 30px; border-top: 1px solid #dee2e6;">
                            <p style="margin: 0; font-size: 12px; color: #666; text-align: center;">
                                Mit freundlichen Grüßen<br>
                                <strong>[A_Sender]</strong><br>
                                CONSEC Auftragsplanung
                            </p>
                            <p style="margin: 15px 0 0 0; font-size: 11px; color: #999; text-align: center;">
                                CONSEC Security Nürnberg<br>
                                Diese E-Mail wurde automatisch generiert.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>`;

// Plain-Text Version für mailto-Fallback
const EMAIL_ANFRAGE_PLAINTEXT = `Hallo [A_MA_Vorname],

wir haben einen neuen Einsatz für Dich:

=== EINSATZDETAILS ===

Auftrag:      [A_Auftrag]
Objekt:       [A_Objekt]
Ort:          [A_Ort]
Datum:        [A_Wochentag], [A_Auftr_Datum]
Dienstzeit:   [A_Start_Zeit] - [A_End_Zeit] Uhr
Treffpunkt:   [A_Treffpunkt] ([A_Treffp_Zeit] Uhr)
Kleidung:     [A_Dienstkleidung]

======================

Bitte gib uns Bescheid, ob Du verfügbar bist:

ZUSAGE: [A_URL_JA]

ABSAGE: [A_URL_NEIN]

Mit freundlichen Grüßen
[A_Sender]
CONSEC Auftragsplanung`;

// Export für Module
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { EMAIL_ANFRAGE_TEMPLATE, EMAIL_ANFRAGE_PLAINTEXT };
}
