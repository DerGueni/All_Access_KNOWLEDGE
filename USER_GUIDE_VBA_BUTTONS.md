# USER GUIDE - VBA-HTML Button Integration

**Version:** 1.0
**Datum:** 15.01.2026
**Zielgruppe:** Endbenutzer (CONSEC Mitarbeiter)

---

## ÜBERSICHT

Diese Anleitung beschreibt die Verwendung der neuen HTML-Buttons in 3 Access-Formularen:

1. **Schnellauswahl** (`frm_MA_VA_Schnellauswahl`) - Button "Anfragen"
2. **Serien-E-Mail Auftrag** (`frm_MA_Serien_eMail_Auftrag`) - Button "Mail senden"
3. **Serien-E-Mail Dienstplan** (`frm_MA_Serien_eMail_dienstplan`) - Button "Mail senden"

### Was ist neu?

- **Moderne HTML-Oberfläche** - Schneller, schöner, benutzerfreundlicher
- **Echtzeit-Feedback** - Toast-Benachrichtigungen bei jeder Aktion
- **Bessere Performance** - Schnellere Datenverarbeitung
- **Identische Funktion** - Alles funktioniert wie bisher, nur besser!

---

## VORAUSSETZUNGEN

### Automatischer Start (Empfohlen)

Wenn das System korrekt eingerichtet ist, starten die Server automatisch:
- Beim Öffnen von Access werden alle benötigten Server gestartet
- Sie müssen nichts manuell tun!

### Manueller Start (Falls erforderlich)

Falls Sie eine Fehlermeldung bekommen ("Server nicht erreichbar"):

1. **Öffnen Sie eine Eingabeaufforderung** (cmd.exe)
2. **Starten Sie die Server:**

```batch
REM API Server starten (Datenzugriff)
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
start "API Server" python api_server.py

REM VBA Bridge Server starten (E-Mail-Funktion)
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api"
start "VBA Bridge" python vba_bridge_server.py
```

3. **Warten Sie 5 Sekunden** bis die Server gestartet sind
4. **Versuchen Sie es erneut** im Access-Formular

---

## FORMULAR 1: Schnellauswahl (Anfragen senden)

### Wo finde ich es?

**Access-Navigation:**
- Menü: Planung > Mitarbeiter-Auftragszuordnung > Schnellauswahl
- Oder: Direkt `frm_MA_VA_Schnellauswahl` öffnen

### Schritt-für-Schritt Anleitung

#### Schritt 1: Formular öffnen

1. Öffnen Sie das Formular `frm_MA_VA_Schnellauswahl`
2. Wählen Sie einen **Auftrag** aus der Liste
3. Wählen Sie ein **Datum** (VADatum)
4. Wählen Sie eine **Schicht** (VAStart)

**WICHTIG:** Alle 3 Felder müssen ausgefüllt sein!

#### Schritt 2: HTML-Ansicht öffnen

1. Klicken Sie auf den Button **"HTML-Ansicht"** (oben rechts)
2. Ein Browser-Fenster öffnet sich mit der modernen Oberfläche
3. Warten Sie kurz, bis die Mitarbeiter-Liste geladen ist

**Was Sie sehen:**
- Liste aller verfügbaren Mitarbeiter
- Checkbox vor jedem Namen
- Button "Anfragen" oben rechts

#### Schritt 3: Mitarbeiter auswählen (Optional)

Sie haben 2 Möglichkeiten:

**Option A: Bestimmte Mitarbeiter**
- Klicken Sie auf die **Checkboxen** der gewünschten Mitarbeiter
- Nur ausgewählte Mitarbeiter erhalten die Anfrage

**Option B: Alle Mitarbeiter**
- Lassen Sie **alle Checkboxen leer**
- ALLE Mitarbeiter in der Liste erhalten die Anfrage

#### Schritt 4: Anfragen senden

1. Klicken Sie auf den Button **"Anfragen"** (oben rechts)
2. Eine Meldung erscheint: "E-Mail-Anfrage wird gesendet..."
3. Nach 2-3 Sekunden: "E-Mail-Anfrage erfolgreich gesendet an X Mitarbeiter"
4. **Outlook öffnet sich automatisch** mit der E-Mail

#### Schritt 5: E-Mail prüfen und senden

1. In Outlook sehen Sie die vorbereitete E-Mail
2. **Empfänger:** Alle ausgewählten Mitarbeiter (BCC)
3. **Betreff:** "Anfrage für Auftrag: [VA-Nummer] - [Objekt] am [Datum]"
4. **Text:** Enthält alle Details (Datum, Uhrzeit, Objekt, etc.)
5. **Prüfen Sie die E-Mail** und klicken Sie auf "Senden"

### Häufige Fragen

**F: Was bedeutet die grüne Meldung oben rechts?**
A: Das ist eine "Toast"-Benachrichtigung. Sie zeigt den Status Ihrer Aktion (Erfolg, Fehler, Warnung).

**F: Ich habe keine Mitarbeiter ausgewählt - was passiert?**
A: Dann erhalten ALLE Mitarbeiter in der Liste die Anfrage. Das ist gewollt!

**F: Kann ich die E-Mail noch bearbeiten?**
A: Ja! Die E-Mail öffnet sich in Outlook und Sie können alles ändern bevor Sie auf "Senden" klicken.

**F: Die Meldung zeigt "3 Mitarbeiter", aber ich sehe nur 1 E-Mail?**
A: Das ist korrekt! Alle Empfänger stehen im BCC-Feld (Blindkopie). So sieht niemand die anderen Empfänger.

---

## FORMULAR 2: Serien-E-Mail Auftrag

### Wo finde ich es?

**Access-Navigation:**
- Menü: Planung > E-Mail > Serien-E-Mail Auftrag
- Oder: Direkt `frm_MA_Serien_eMail_Auftrag` öffnen

### Schritt-für-Schritt Anleitung

#### Schritt 1: Formular öffnen

1. Öffnen Sie das Formular `frm_MA_Serien_eMail_Auftrag`
2. Wählen Sie einen **Auftrag** aus der Liste

**WICHTIG:** Der Auftrag muss Mitarbeiter-Zuordnungen haben!

#### Schritt 2: HTML-Ansicht öffnen

1. Klicken Sie auf den Button **"HTML-Ansicht"** (oben rechts)
2. Ein Browser-Fenster öffnet sich
3. Warten Sie, bis die Mitarbeiter-Liste geladen ist

**Was Sie sehen:**
- Liste aller Mitarbeiter dieses Auftrags
- Button "Mail senden" oben rechts

#### Schritt 3: E-Mail senden

1. Klicken Sie auf den Button **"Mail senden"** (oben rechts)
2. Eine Meldung erscheint: "Serien-E-Mail wird gesendet..."
3. Nach 2-3 Sekunden: "E-Mails erfolgreich gesendet an X Mitarbeiter"
4. **Outlook öffnet sich automatisch** mit der E-Mail

#### Schritt 4: E-Mail prüfen und senden

1. In Outlook sehen Sie die vorbereitete E-Mail
2. **Empfänger:** Alle Mitarbeiter des Auftrags (BCC)
3. **Betreff:** Enthält Auftragsnummer und Details
4. **Text:** Enthält alle Auftragsinformationen
5. **Prüfen Sie die E-Mail** und klicken Sie auf "Senden"

### Häufige Fragen

**F: Der Auftrag hat 20 Mitarbeiter - werden 20 E-Mails gesendet?**
A: Nein! Es wird EINE E-Mail mit allen 20 Empfängern im BCC-Feld erstellt.

**F: Was passiert wenn ein Mitarbeiter keine E-Mail-Adresse hat?**
A: Dieser Mitarbeiter wird übersprungen. Sie erhalten eine Warnung in der Meldung.

---

## FORMULAR 3: Serien-E-Mail Dienstplan

### Wo finde ich es?

**Access-Navigation:**
- Menü: Dienstplan > E-Mail > Serien-E-Mail Dienstplan
- Oder: Direkt `frm_MA_Serien_eMail_dienstplan` öffnen

### Schritt-für-Schritt Anleitung

#### Schritt 1: Formular öffnen

1. Öffnen Sie das Formular `frm_MA_Serien_eMail_dienstplan`
2. Wählen Sie einen **Zeitraum** (Von/Bis Datum)

**WICHTIG:** Der Zeitraum muss Dienstplan-Einträge enthalten!

#### Schritt 2: HTML-Ansicht öffnen

1. Klicken Sie auf den Button **"HTML-Ansicht"** (oben rechts)
2. Ein Browser-Fenster öffnet sich
3. Warten Sie, bis die Mitarbeiter-Liste geladen ist

**Was Sie sehen:**
- Liste aller Mitarbeiter im Dienstplan
- Button "Mail senden" oben rechts

#### Schritt 3: E-Mail senden

1. Klicken Sie auf den Button **"Mail senden"** (oben rechts)
2. Eine Meldung erscheint: "Serien-E-Mail wird gesendet..."
3. Nach 2-3 Sekunden: "E-Mails erfolgreich gesendet an X Mitarbeiter"
4. **Outlook öffnet sich automatisch** mit der E-Mail

#### Schritt 4: E-Mail prüfen und senden

1. In Outlook sehen Sie die vorbereitete E-Mail
2. **Empfänger:** Alle Mitarbeiter des Dienstplans (BCC)
3. **Betreff:** Enthält Dienstplan-Zeitraum
4. **Text:** Enthält Dienstplan-Informationen
5. **Prüfen Sie die E-Mail** und klicken Sie auf "Senden"

---

## TOAST-BENACHRICHTIGUNGEN VERSTEHEN

Die farbigen Meldungen oben rechts im Browser zeigen den Status Ihrer Aktion:

### Grüne Meldung (Erfolg)
✅ **Beispiel:** "E-Mail-Anfrage erfolgreich gesendet an 5 Mitarbeiter"
- **Bedeutung:** Alles hat funktioniert!
- **Aktion:** Prüfen Sie die E-Mail in Outlook und senden Sie diese ab

### Gelbe Meldung (Warnung)
⚠️ **Beispiel:** "2 Mitarbeiter ohne E-Mail-Adresse übersprungen"
- **Bedeutung:** Es gab ein kleines Problem, aber die Aktion wurde durchgeführt
- **Aktion:** Notieren Sie die Warnung und prüfen Sie die betroffenen Mitarbeiter

### Blaue Meldung (Information)
ℹ️ **Beispiel:** "E-Mail-Anfrage wird gesendet..."
- **Bedeutung:** Die Aktion wird gerade durchgeführt
- **Aktion:** Warten Sie kurz (2-3 Sekunden)

### Rote Meldung (Fehler)
❌ **Beispiel:** "Fehler beim Senden: Verbindung zum Server fehlgeschlagen"
- **Bedeutung:** Etwas ist schiefgelaufen!
- **Aktion:** Siehe Abschnitt "Fehlerbehebung"

---

## FEHLERBEHEBUNG

### Fehler: "Verbindung zum VBA-Server fehlgeschlagen"

**Ursache:** Der VBA Bridge Server (Port 5002) läuft nicht.

**Lösung:**
1. Öffnen Sie eine Eingabeaufforderung (cmd.exe)
2. Führen Sie aus:
   ```
   cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api"
   python vba_bridge_server.py
   ```
3. Warten Sie 5 Sekunden
4. Versuchen Sie es erneut

### Fehler: "Fehlende Daten: VA_ID, VADatum_ID oder VAStart_ID"

**Ursache:** Im Access-Formular wurden nicht alle Pflichtfelder ausgefüllt.

**Lösung:**
1. Schließen Sie die HTML-Ansicht
2. Prüfen Sie im Access-Formular:
   - Ist ein Auftrag ausgewählt?
   - Ist ein Datum ausgewählt?
   - Ist eine Schicht ausgewählt?
3. Füllen Sie alle Felder aus
4. Öffnen Sie die HTML-Ansicht erneut

### Fehler: "Access ist nicht geöffnet"

**Ursache:** Das Access-Frontend `0_Consys_FE_Test.accdb` ist nicht geöffnet.

**Lösung:**
1. Öffnen Sie das Access-Frontend
2. Versuchen Sie es erneut

### Fehler: "Keine Mitarbeiter gefunden"

**Ursache:** Für den gewählten Auftrag/Zeitraum gibt es keine Mitarbeiter-Zuordnungen.

**Lösung:**
1. Prüfen Sie im Access-Formular ob Mitarbeiter zugeordnet sind
2. Wählen Sie einen anderen Auftrag/Zeitraum
3. Oder: Weisen Sie zuerst Mitarbeiter zu

### HTML-Ansicht lädt nicht / Weiße Seite

**Ursache:** Der API Server (Port 5000) läuft nicht.

**Lösung:**
1. Öffnen Sie eine Eingabeaufforderung (cmd.exe)
2. Führen Sie aus:
   ```
   cd "C:\Users\guenther.siegert\Documents\Access Bridge"
   python api_server.py
   ```
3. Warten Sie 5 Sekunden
4. Drücken Sie F5 im Browser (Seite neu laden)

### Button reagiert nicht / Nichts passiert

**Lösung 1: Cache leeren**
1. Drücken Sie **Strg + Shift + Entf** im Browser
2. Wählen Sie "Cache" oder "Zwischengespeicherte Bilder"
3. Klicken Sie auf "Löschen"
4. Laden Sie die Seite neu (F5)

**Lösung 2: Browser-Console prüfen**
1. Drücken Sie **F12** im Browser
2. Klicken Sie auf "Console"
3. Suchen Sie nach roten Fehlermeldungen
4. Notieren Sie die Fehler und kontaktieren Sie den Support

---

## TIPPS & TRICKS

### Tipp 1: Schneller Zugriff
Erstellen Sie Tastenkombinationen für häufig genutzte Formulare:
- Extras > Optionen > Tastatur > Formular zuweisen

### Tipp 2: Mehrere Browser-Fenster
Sie können mehrere HTML-Ansichten gleichzeitig öffnen:
- Ein Fenster für Schnellauswahl
- Ein Fenster für Serien-E-Mail
- Beide arbeiten unabhängig voneinander

### Tipp 3: E-Mail-Vorlagen
Wenn Sie immer den gleichen Text verwenden:
- Erstellen Sie eine Outlook-Vorlage
- Kopieren Sie den Text vor dem Senden

### Tipp 4: Große Mitarbeiter-Listen
Bei >50 Mitarbeitern:
- Nutzen Sie die Suchfunktion im Browser (Strg+F)
- Oder: Filtern Sie in Access vor dem Öffnen der HTML-Ansicht

---

## SUPPORT & KONTAKT

### Bei Problemen

**1. Prüfen Sie zuerst:**
- [ ] Sind beide Server gestartet? (Siehe Fehlerbehebung)
- [ ] Ist Access geöffnet?
- [ ] Sind alle Pflichtfelder ausgefüllt?
- [ ] Haben Sie den Browser-Cache geleert?

**2. Notieren Sie:**
- Welches Formular? (Schnellauswahl / Serien-E-Mail Auftrag / Serien-E-Mail Dienstplan)
- Was haben Sie gemacht?
- Welche Fehlermeldung erschien? (Screenshot!)
- Browser-Console (F12 > Console) - Screenshot!

**3. Kontaktieren Sie:**
- IT-Support: [E-Mail/Telefon]
- Oder: Administrator Günther Siegert

### Feedback

Wir freuen uns über Ihr Feedback:
- Was gefällt Ihnen?
- Was könnte besser sein?
- Welche Funktionen fehlen?

Senden Sie Ihre Vorschläge an: [E-Mail]

---

## CHANGELOG (Was ist neu?)

### Version 1.0 (15.01.2026)

**Neue Features:**
- ✨ Moderne HTML-Oberfläche für 3 Formulare
- ✨ Toast-Benachrichtigungen für Echtzeit-Feedback
- ✨ Schnellere Datenverarbeitung
- ✨ Bessere Performance bei großen Mitarbeiter-Listen

**Verbesserte Funktionen:**
- ⚡ Schnelleres Laden der Mitarbeiter-Listen
- ⚡ Zuverlässigere Outlook-Integration
- ⚡ Bessere Fehlerbehandlung

**Bekannte Einschränkungen:**
- Server müssen manuell gestartet werden (wird in Zukunft automatisiert)
- Nur Edge/Chrome Browser unterstützt

---

## FAQ (Häufig gestellte Fragen)

### Allgemeine Fragen

**F: Kann ich die alte Access-Ansicht weiterhin verwenden?**
A: Ja! Die alten Buttons funktionieren weiterhin. Die HTML-Ansicht ist eine zusätzliche Option.

**F: Sind meine Daten sicher?**
A: Ja! Alle Daten bleiben lokal auf Ihrem PC. Nichts wird ins Internet gesendet.

**F: Muss ich etwas installieren?**
A: Nein! Alles ist bereits eingerichtet. Sie benötigen nur einen modernen Browser (Edge/Chrome).

**F: Kann ich die HTML-Ansicht auf mehreren PCs nutzen?**
A: Ja, aber die Server müssen auf jedem PC separat laufen.

### Technische Fragen

**F: Welcher Browser wird empfohlen?**
A: Microsoft Edge oder Google Chrome (neueste Version).

**F: Kann ich Firefox verwenden?**
A: Grundsätzlich ja, aber Edge/Chrome sind besser getestet.

**F: Was sind diese "Server" die gestartet werden müssen?**
A: Das sind kleine Programme die im Hintergrund laufen und die Verbindung zwischen HTML und Access herstellen.

**F: Warum muss ich zwei Server starten?**
A: Server 1 (Port 5000) = Datenzugriff, Server 2 (Port 5002) = E-Mail-Funktionen. Beide sind nötig.

### Workflow-Fragen

**F: Kann ich mehrere E-Mails gleichzeitig vorbereiten?**
A: Ja! Öffnen Sie mehrere Browser-Fenster und bereiten Sie alle E-Mails vor. Senden Sie dann alle in Outlook.

**F: Werden die E-Mails sofort gesendet?**
A: Nein! Die E-Mails werden in Outlook vorbereitet. SIE entscheiden wann Sie auf "Senden" klicken.

**F: Kann ich die Empfänger noch ändern?**
A: Ja! In Outlook können Sie Empfänger hinzufügen oder entfernen bevor Sie auf "Senden" klicken.

---

**Ende des User Guides**

Bei Fragen oder Problemen wenden Sie sich bitte an den Support!
