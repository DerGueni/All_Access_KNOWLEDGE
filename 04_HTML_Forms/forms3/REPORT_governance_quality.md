# Governance Quality Report: Access vs. HTML Berechtigungslogik

**Erstellt am:** 2026-01-07
**Scope:** Analyse der Button-Sichtbarkeit und Berechtigungen in Access-Formularen vs. HTML-Formularen

---

## 1. Executive Summary

### Kernbefunde

| Kategorie | Access | HTML | Status |
|-----------|--------|------|--------|
| Buttons gesamt | 181 | 314 | HTML hat mehr Buttons (UI-Erweiterungen) |
| Versteckte Buttons (Visible=false) | 36 | 0 | **ABWEICHUNG** |
| Deaktivierte Buttons (Enabled=false) | 7 | 0 | **ABWEICHUNG** |
| Mit Tag-Property (Rollen-Info) | 0 | 0 | Keine Rollen-Logik vorhanden |
| Mit data-required-role | N/A | 0 | Nicht implementiert |
| Mit data-required-permission | N/A | 0 | Nicht implementiert |
| Mit data-testid | N/A | 127 | Nur Testbarkeits-Attribute |

### Kritische Erkenntnis

**Es gibt KEINE rollenbasierte Berechtigungslogik** - weder in Access noch in HTML:
- Access steuert Sichtbarkeit rein ueber `Visible` und `Enabled` Properties
- Keine Tag-Properties mit Rollen-Informationen gefunden
- HTML-Formulare haben keine Berechtigungs-Attribute implementiert

---

## 2. Access-Analyse: Buttons mit Sichtbarkeits-/Aktivierungs-Einschraenkungen

### 2.1 Versteckte Buttons (Visible=false)

Diese 36 Buttons sind in Access standardmaessig unsichtbar und sollten im HTML NICHT angezeigt werden:

#### frm_va_auftragstamm (Auftragsverwaltung)
| Button | Enabled | Funktion (vermutet) |
|--------|---------|---------------------|
| btnAuftrBerech | false | Auftragsberechnung |
| btn_aenderungsprotokoll | false | Aenderungsprotokoll |
| btnmailpos | false | Mail Positionen |
| btn_Posliste_oeffnen | false | Positionsliste oeffnen |
| btnCheck | true | Check-Funktion |
| btnDruckZusage1 | false | Zusage drucken (Duplikat?) |
| btnMailCalc | false | Mail Kalkulation |
| btnXLAnfAbsGes | false | Excel Anfrage/Absage Gesamt |
| btnAutosend | false | Auto-Senden |
| btnELGesendet | true | EL gesendet (aber hidden?) |
| Befehl637 | true | Befehl 637 |
| btn_LM_Neu | true | LM Neu |
| btn_VA_AnzTage_loesch | false | VA AnzTage loeschen |
| btnNeueVeranst | false | Neue Veranstaltung |
| btnDruck_sub_Stunden | false | Druck Sub-Stunden |
| btnDeleteAttach | false | Attachment loeschen |

#### frm_MA_Mitarbeiterstamm (Mitarbeiterverwaltung)
| Button | Enabled | Funktion (vermutet) |
|--------|---------|---------------------|
| btnMADienstpl | true | MA Dienstplan |
| btnXLEinsUeber | true | Excel Einsatzuebersicht |
| btnRch | true | Rechnung |
| btnXLUeberhangStd | true | Excel Ueberhang Stunden |
| btnXLDiePl | true | Excel Dienstplan |
| btnXLNverfueg | true | Excel Nicht verfuegbar |

#### frm_KD_Kundenstamm (Kundenverwaltung)
| Button | Enabled | Funktion (vermutet) |
|--------|---------|---------------------|
| btnAlle | true | Alle anzeigen |

#### frm_OB_Objekt (Objektverwaltung)
| Button | Enabled | Funktion (vermutet) |
|--------|---------|---------------------|
| btnLB_Preise | true | Leistungsbeschreibung Preise |
| btnLB_ArtCopy | true | LB Artikel kopieren |
| btnLB_Pos_Del | true | LB Position loeschen |
| btnLB_Pos_Top | true | LB Position nach oben |
| btnLB_Pos_Down | true | LB Position nach unten |
| btn_Loesch | false | Loeschen |

#### frm_Menuefuehrung1 (Dashboard)
| Button | Enabled | Funktion (vermutet) |
|--------|---------|---------------------|
| btnFrei1 | false | Freier Button 1 |
| btnRpt_RG_Pos_Summe | true | Report RG Pos Summe |
| btnRpt_RG_Tag_Summe | true | Report RG Tag Summe |
| btnBewerber | true | Bewerber |

### 2.2 Deaktivierte Buttons (Enabled=false mit Visible=true)

Diese Buttons sind sichtbar aber nicht klickbar:

| Form | Button | Visible | Funktion |
|------|--------|---------|----------|
| frm_va_auftragstamm | btnAuftrBerech | false | Auftragsberechnung |
| frm_va_auftragstamm | btn_aenderungsprotokoll | false | Protokoll |
| frm_va_auftragstamm | btnmailpos | false | Mail Positionen |
| frm_va_auftragstamm | btn_Posliste_oeffnen | false | Positionsliste |
| frm_va_auftragstamm | btnDruckZusage1 | false | Zusage drucken |
| frm_OB_Objekt | btn_Loesch | false | Loeschen |
| frm_Menuefuehrung1 | btnFrei1 | false | Freier Button |

---

## 3. HTML-Analyse: Button-Implementierung

### 3.1 Buttons pro Formular

| HTML-Formular | Anzahl Buttons | Mit data-testid |
|---------------|----------------|-----------------|
| frm_va_Auftragstamm.html | 42 | 37 |
| frm_MA_Mitarbeiterstamm.html | 72 | 63 |
| frm_KD_Kundenstamm.html | 54 | 44 |
| frm_OB_Objekt.html | 32 | 26 |
| frm_Menuefuehrung1.html | 42 | 34 |
| frm_DP_Dienstplan_MA.html | 2 | 2 |
| frm_DP_Dienstplan_Objekt.html | 24 | 18 |
| frm_MA_Abwesenheit.html | 14 | 11 |
| frm_MA_VA_Schnellauswahl.html | 19 | 16 |
| shell.html | 13 | 10 |

### 3.2 Fehlende Berechtigungs-Attribute

Keines der HTML-Formulare verwendet:
- `data-required-role`
- `data-required-permission`
- `data-min-level`
- `disabled` (statisch)
- `hidden` (statisch)

### 3.3 Vorhandene Test-Attribute

Die `data-testid` Attribute sind gut implementiert und folgen einem konsistenten Schema:
```
{formular-prefix}-btn-{funktion}
Beispiel: auftrag-btn-aktualisieren, ma-btn-speichern
```

---

## 4. Abweichungen zwischen Access und HTML

### 4.1 Buttons die in HTML sichtbar sind, aber in Access versteckt

Die folgenden Buttons sollten im HTML NICHT angezeigt werden oder bedingt aktiviert werden:

| Access-Button | HTML-Aequivalent | Aktion erforderlich |
|---------------|------------------|---------------------|
| btnAuftrBerech | (nicht vorhanden) | OK - nicht implementiert |
| btn_aenderungsprotokoll | (nicht vorhanden) | OK - nicht implementiert |
| btnmailpos | (nicht vorhanden) | OK - nicht implementiert |
| btnMADienstpl | btnDienstplan | Pruefen ob korrekt |
| btnXLEinsUeber | (Excel Dropdown) | In Dropdown integriert |
| btnXLDiePl | (Excel Dropdown) | In Dropdown integriert |
| btnAlle (KD) | (nicht vorhanden) | OK - durch Filter ersetzt |

### 4.2 Zusaetzliche HTML-Buttons ohne Access-Pendant

HTML-Formulare haben Erweiterungen:
- Tab-Buttons (Einsatzliste, Antworten, Zusatzdateien, etc.)
- Navigationspfeile (Links/Rechts)
- Vollbild-Toggle
- Modal-Buttons (Confirm, Close)
- Dropdown-Menues (Excel Export)

---

## 5. Empfehlungen

### 5.1 Sofort-Massnahmen (Prioritaet HOCH)

1. **Versteckte Buttons implementieren**
   - Die 36 in Access versteckten Buttons sollten auch im HTML nicht angezeigt werden
   - Entweder komplett entfernen oder mit CSS `display: none` versehen
   - Alternativ: `hidden` Attribut oder bedingte Rendering-Logik

2. **Disabled-Zustand uebernehmen**
   - Buttons die in Access `Enabled=false` haben, sollten im HTML `disabled` sein
   - CSS-Klasse `.btn:disabled` ist bereits vorhanden

### 5.2 Mittelfristige Massnahmen (Prioritaet MITTEL)

3. **Einheitliches Berechtigungs-System einfuehren**

   Empfohlene Attribute:
   ```html
   <button
     data-required-role="disposition,personal,admin"
     data-min-level="2"
     data-permission="auftraege.bearbeiten"
   >...</button>
   ```

4. **Rollen definieren**

   Vorgeschlagene Rollen-Hierarchie:
   | Rolle | Level | Beschreibung |
   |-------|-------|--------------|
   | admin | 5 | Voller Zugriff |
   | management | 4 | Berichte, Statistiken |
   | abrechnung | 3 | Rechnungen, Zeitkonten |
   | personal | 2 | MA-Verwaltung, Dienstplaene |
   | disposition | 1 | Auftraege, Einsatzplanung |
   | readonly | 0 | Nur Lesezugriff |

5. **JavaScript-Modul fuer Berechtigungen**

   ```javascript
   // permission.js
   const Permission = {
     currentUser: { role: 'disposition', level: 1 },

     check(element) {
       const requiredRole = element.dataset.requiredRole;
       const minLevel = parseInt(element.dataset.minLevel) || 0;

       if (requiredRole && !requiredRole.split(',').includes(this.currentUser.role)) {
         return false;
       }
       if (this.currentUser.level < minLevel) {
         return false;
       }
       return true;
     },

     applyAll() {
       document.querySelectorAll('[data-required-role], [data-min-level]').forEach(el => {
         if (!this.check(el)) {
           el.hidden = true; // oder el.disabled = true;
         }
       });
     }
   };
   ```

### 5.3 Langfristige Massnahmen (Prioritaet NIEDRIG)

6. **Backend-Validierung**
   - API sollte Berechtigungen serverseitig pruefen
   - Token-basierte Authentifizierung
   - Rollen-Info im Session-Context

7. **Audit-Trail**
   - Protokollierung von Aktionen mit Benutzer und Zeitstempel
   - Access hat bereits `cls_TM_AenderungsProtokoll`

---

## 6. Technische Details

### 6.1 Access JSON-Struktur

```json
{
  "name": "frm_va_auftragstamm",
  "controls": [
    {
      "name": "btnSchnellPlan",
      "type": "CommandButton",
      "properties": {
        "Visible": "true",
        "Enabled": "true",
        "Tag": "",
        "Caption": "Schnellplanung"
      }
    }
  ]
}
```

### 6.2 Empfohlene HTML-Struktur

```html
<button
  class="btn"
  id="btnSchnellPlan"
  data-testid="auftrag-btn-schnellplan"
  data-required-role="disposition,admin"
  onclick="openMitarbeiterauswahl()"
>
  Schnellplanung
</button>
```

---

## 7. Checkliste fuer Implementierung

- [ ] Versteckte Access-Buttons im HTML ausblenden
- [ ] Disabled-Zustaende synchronisieren
- [ ] `data-required-role` Attribut definieren
- [ ] Permission-Modul erstellen
- [ ] Rollen-Konstanten definieren
- [ ] API-Endpoint fuer aktuelle Benutzer-Rolle
- [ ] Initiale Rollen-Zuweisung bei Page-Load
- [ ] CSS fuer versteckte/deaktivierte Buttons
- [ ] Unit-Tests fuer Berechtigungs-Logik

---

## 8. Anhang: Vollstaendige Button-Listen

### A. Access-Buttons mit Einschraenkungen

| Form | Button | Visible | Enabled |
|------|--------|---------|---------|
| frm_va_auftragstamm | btnAuftrBerech | false | false |
| frm_va_auftragstamm | btn_aenderungsprotokoll | false | false |
| frm_va_auftragstamm | btnmailpos | false | false |
| frm_va_auftragstamm | btn_Posliste_oeffnen | false | false |
| frm_va_auftragstamm | btnCheck | false | true |
| frm_va_auftragstamm | btnDruckZusage1 | false | false |
| frm_va_auftragstamm | btnMailCalc | false | false |
| frm_va_auftragstamm | btnXLAnfAbsGes | false | true |
| frm_va_auftragstamm | btnAutosend | false | true |
| frm_va_auftragstamm | btnELGesendet | false | true |
| frm_va_auftragstamm | Befehl637 | false | true |
| frm_va_auftragstamm | btn_LM_Neu | false | true |
| frm_va_auftragstamm | btn_VA_AnzTage_loesch | false | false |
| frm_va_auftragstamm | btnNeueVeranst | false | true |
| frm_va_auftragstamm | btnDruck_sub_Stunden | false | true |
| frm_va_auftragstamm | btnDeleteAttach | false | true |
| frm_MA_Mitarbeiterstamm | btnMADienstpl | false | true |
| frm_MA_Mitarbeiterstamm | btnXLEinsUeber | false | true |
| frm_MA_Mitarbeiterstamm | btnRch | false | true |
| frm_MA_Mitarbeiterstamm | btnXLUeberhangStd | false | true |
| frm_MA_Mitarbeiterstamm | btnXLDiePl | false | true |
| frm_MA_Mitarbeiterstamm | btnXLNverfueg | false | true |
| frm_KD_Kundenstamm | btnAlle | false | true |
| frm_OB_Objekt | btnLB_Preise | false | true |
| frm_OB_Objekt | btnLB_ArtCopy | false | true |
| frm_OB_Objekt | btnLB_Pos_Del | false | true |
| frm_OB_Objekt | btnLB_Pos_Top | false | true |
| frm_OB_Objekt | btnLB_Pos_Down | false | true |
| frm_OB_Objekt | btn_Loesch | false | false |
| frm_Menuefuehrung1 | btnFrei1 | false | false |
| frm_Menuefuehrung1 | btnRpt_RG_Pos_Summe | false | true |
| frm_Menuefuehrung1 | btnRpt_RG_Tag_Summe | false | true |
| frm_Menuefuehrung1 | btnBewerber | false | true |

### B. HTML-Buttons mit data-testid

Alle Buttons mit `data-testid` Attribut folgen dem Schema:
- `{formular}-btn-{aktion}`
- Beispiele: `auftrag-btn-aktualisieren`, `ma-btn-speichern`, `kd-btn-neu`

---

**Ende des Reports**
