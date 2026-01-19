# Nächste Schritte (Etappe B+C+D)

## Etappe B: Bridge Integration ✅ (DONE)

### Fertiggestellt:
1. ✅ **VBA-Modul `mod_N_WebForm_Handler.bas`**
   - LoadForm() → Daten laden
   - NavigateRecord() → Datensatz wechseln
   - DeleteRecord() → Löschen (mit nächstem Datensatz laden)
   - FieldChanged() → Feldänderungen verarbeiten
   - SaveRecord() → Speichern (Placeholder)

2. ✅ **form.js aktualisiert**
   - `Bridge.callAccess('LoadForm', {...})` beim Init
   - `Bridge.on('loadForm', (payload) => {...})` für Daten
   - Navigation über Bridge-Calls
   - Field-Change Events mit Real-time Validierung (Email)

3. ✅ **Bridge-Events implementiert**
   - loadForm → Form + List füllen
   - recordChanged → Navigation
   - recordSaved → Bestätigung
   - recordDeleted → Löschen + nächster Datensatz
   - error → Error-Toast

4. ✅ **import_webform_module.py erstellt**
   - VBA-Import via AccessBridge
   - Modul-Verifikation
   - Error-Handling

### Testing (noch nötig):
- [ ] VBA-Modul mit `import_webform_module.py` testen
- [ ] LoadForm-Event in Browser-Konsole prüfen
- [ ] Navigation (first/prev/next/last) testen
- [ ] Field-Change Events validieren
- [ ] Delete mit Bestätigung testen

---

## Etappe C: SubForms & Validierung

6. **frm_Menuefuehrung integrieren**
   - HTML: `<iframe src="frm_Menuefuehrung.html"></iframe>` in Sidebar
   - PostMessage: Parent ↔ Subform Kommunikation
   - Menu-Items klickbar → andere Formen öffnen

7. **sub_MA_ErsatzEmail integrieren**
   - HTML-Subform als Tabelle (Email-Einträge)
   - CRUD: Hinzufügen/Bearbeiten/Löschen
   - PostMessage an Parent bei Änderungen

8. **Formularvalidierung**
   - Nachname/Vorname: nicht leer
   - Email: Format-Check via Regex
   - Daten-Typen: Date-Fields vs. Text

9. **Error-Handling verbessern**
   - Try/Catch in Bridge-Calls
   - Benachrichtigungen bei Fehler/Erfolg

---

## Etappe D: Polish & Tests

10. **Foto-Upload**
    - File-Input für MA_Bild
    - Base64-Konvertierung
    - Preview vor Speichern

11. **Performance optimieren**
    - Lazy-Loading für Images
    - VirtualScroller für große Listen (>500)
    - CSS minifizieren + inlinen (Critical Path)

12. **Smoke-Tests mit Playwright**
    - Form-Load Test
    - Field-Population Test
    - Navigation Test
    - Save/Delete Test

13. **Production Build**
    - HTML minifizieren
    - JS bundeln (wenn mehrere Dateien)
    - Output zu `006_HTML_FERTIG/`

---

## Abhängigkeiten & Blockers

- [ ] WebView2 verfügbar im Access-Frontend? (ProPlus2021 hat typisch nicht WebView2)
- [ ] API Server läuft? (`localhost:5000`)
- [ ] JSON-Exporte aktuell? (letzte: 08 Nov, regelmäßig synchen)
- [ ] Backend-DB erreichbar? (Consec_BE_V1.55ANALYSETEST.accdb)

---

## Formular-Reihenfolge für nächste Formen

Nach Mitarbeiterstamm empfohlen:
1. **frm_KD_Kundenstamm** – Ähnliche Struktur, Kunde-Liste
2. **frm_va_Auftragstamm** – Auftrags-Verwaltung
3. **frm_OB_Objekt** – Objekt/Schicht-Verwaltung
4. **frm_Menuefuehrung** – Navigation selbst als WebForm
