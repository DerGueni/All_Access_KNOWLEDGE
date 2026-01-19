# INVENTORY: Access-Menüs - Sichtbare Buttons

## Quellen
- **Menü 1:** frm_Menuefuehrung (dynamisch via tbl_Menuefuehrung_Neu)
- **Menü 2:** frm_Menuefuehrung1 (statische Buttons)

---

## MENÜ 2 (frm_Menuefuehrung1) - Statische Buttons

### Section: Navigation
| Button | onclick | Ziel | SICHTBAR | Begründung |
|--------|---------|------|----------|------------|
| Dienstplanübersicht | navigateTo('frm_N_Dienstplanübersicht') | frm_N_Dienstplanuebersicht.html | JA | Visible=Wahr, highlight |
| Planungsübersicht | navigateTo('frm_VA_Planungsübersicht') | frm_VA_Planungsuebersicht.html | JA | Visible=Wahr, highlight |
| Auftragsverwaltung | navigateTo('frm_va_Auftragstamm') | frm_va_Auftragstamm.html | JA | Visible=Wahr |
| Mitarbeiterverwaltung | navigateTo('frm_MA_Mitarbeiterstamm') | frm_MA_Mitarbeiterstamm.html | JA | Visible=Wahr |
| Kundenverwaltung | navigateTo('frm_KD_Kundenstamm') | frm_KD_Kundenstamm.html | JA | Visible=Wahr |
| Objektverwaltung | navigateTo('frm_OB_Objekt') | frm_OB_Objekt.html | JA | Visible=Wahr |

### Section: Personal
| Button | onclick | Ziel | SICHTBAR | Begründung |
|--------|---------|------|----------|------------|
| Zeitkonten | navigateTo('frm_MA_Zeitkonten') | frm_MA_Zeitkonten.html | JA | Visible=Wahr |
| Abwesenheiten | navigateTo('frm_Abwesenheiten') | frm_MA_Abwesenheit.html | JA | Visible=Wahr |
| Stundenauswertung | navigateTo('frm_N_Stundenauswertung') | frm_N_Stundenauswertung.html | JA | Visible=Wahr |
| Lohnabrechnungen | navigateTo('frm_N_Lohnabrechnungen') | frm_N_Lohnabrechnungen.html | JA | Visible=Wahr |
| Dienstausweis | navigateTo('frm_Dienstausweis') | frm_Ausweis_Create.html | JA | Visible=Wahr |

### Section: Extras & Tools
| Button | onclick | Ziel | SICHTBAR | Begründung |
|--------|---------|------|----------|------------|
| Schnellauswahl / Mail-Anfragen | navigateTo('frm_MA_VA_Schnellauswahl') | frm_MA_VA_Schnellauswahl.html | JA | Visible=Wahr |
| Verrechnungssätze | navigateTo('frm_Verrechnungssaetze') | frm_KD_Verrechnungssaetze.html | JA | Visible=Wahr |
| Sub Rechnungen | navigateTo('frm_SubRechnungen') | - | JA | Ziel fehlt |
| E-Mail | navigateTo('frm_Email') | frm_N_Email_versenden.html | JA | Visible=Wahr |
| E-Mail Vorlagen | btn_mailvorlage_Click() | frm_ma_serien_email_vorlage | JA | Visible=Wahr |
| Mitarbeiterstamm Excel | exportMAStamm() | Excel-Export | JA | Visible=Wahr |
| Telefonliste drucken | openReport('rpt_telefonliste') | Report | JA | Visible=Wahr |
| Monatsstunden drucken | openReport('rpt_monatsstunden') | Report | JA | Visible=Wahr |
| Jahresübersicht MA | openReport('rpt_jahresübersicht_mitarbeiter') | Report | JA | Visible=Wahr |
| Stunden MA Kreuztabelle | btnStundenMA_Click() | Query | JA | Visible=Wahr |
| Stunden Sub Export | btn_stunden_sub_Click() | Excel-Export | JA | Visible=Wahr |

### Section: Automatisierung
| Button | onclick | Ziel | SICHTBAR | Begründung |
|--------|---------|------|----------|------------|
| Loewensaal Sync (Excel) | btn_LoewensaalSync_Click() | VBA | JA | Visible=Wahr |
| Loewensaal Sync (Homepage) | btn_Loewensaal_Sync_HP_Click() | VBA | JA | Visible=Wahr |
| Auto-Zuordnung Minijobber | btnAutoZuordnungSport_Click() | VBA | JA | Visible=Wahr |
| Festangestellte zuordnen | btn_FA_eintragen_Click() | VBA | JA | Visible=Wahr |
| E-Mail zu Auftrag | btn_Stawa_Click() | VBA | JA | Visible=Wahr |
| Hirsch Import | btn_Hirsch_Click() | VBA | JA | Visible=Wahr |
| BOS Mail-Import | btn_BOS_Click() | VBA | JA | Visible=Wahr |

### Section: Spezial
| Button | onclick | Ziel | SICHTBAR | Begründung |
|--------|---------|------|----------|------------|
| Namensliste Fuerth | btnNamensliste_Click() | VBA | JA | Visible=Wahr |
| FCN Meldeliste | btnFCN_Meldeliste_Click() | VBA | JA | Visible=Wahr |
| Weitere Masken | btn_weitere_Masken_Click() | Access-Form | JA | Visible=Wahr |
| Lohnarten / Zuschläge | btnLohnarten_Click() | zfrm_ZK_Lohnarten_Zuschlag | JA | Visible=Wahr |
| Abwesenheiten (Urlaub/Krank) | btn_Abwesenheiten_Click() | frm_MA_Abwesenheiten | JA | Visible=Wahr |
| Letzter Einsatz MA | btnLetzterEinsatz_Click() | Query | JA | Visible=Wahr |
| Positionslisten (Objekte) | btnPositionslisten_Click() | frm_OB_Objekt | JA | Visible=Wahr |

### Section: System
| Button | onclick | Ziel | SICHTBAR | Begründung |
|--------|---------|------|----------|------------|
| System Info | navigateTo('frm_SystemInfo') | frm_Systeminfo.html | JA | Visible=Wahr |
| Datenbank wechseln | navigateTo('frm_DBWechseln') | - | JA | Ziel fehlt |
| Auswahl-Master | btn_masterbtn_Click() | frm_N_AuswahlMaster | JA | Visible=Wahr |

---

## MENÜ 1 (sub_Menuefuehrung) - Dynamische ComboBoxen

Das Menü 1 verwendet ComboBoxen die aus der Tabelle `tbl_Menuefuehrung_Neu` befüllt werden.

### Menü-Kategorien (MenueNr)
| MenueNr | ComboBox | Beschreibung |
|---------|----------|--------------|
| 1 | cboF1 | Hauptnavigation |
| 2 | cboF2 | Stammdaten |
| 3 | cboF3 | Planung |
| 4 | cboF4 | Personal |
| 5 | cboF5 | Abrechnung |
| 6 | cboF6 | Reports |
| 7 | cboF7 | Tools |
| 9 | cboF9 | System |

Alle ComboBoxen sind sichtbar (Visible=Wahr).
Die Einträge werden dynamisch aus der Datenbank geladen.

---

## NICHT SICHTBARE BUTTONS (AUSGESCHLOSSEN)

### frm_Menuefuehrung1
| Button | Visible | Begründung |
|--------|---------|------------|
| Befehl24 | Falsch | Explizit ausgeblendet |
| Btn_Personalvorlagen | Falsch | Explizit ausgeblendet |

---

## ZUSAMMENFASSUNG

### Sichtbare Buttons für MenuMaster
- **Navigation:** 6 Buttons
- **Personal:** 5 Buttons
- **Extras & Tools:** 11 Buttons
- **Automatisierung:** 7 Buttons
- **Spezial:** 7 Buttons
- **System:** 3 Buttons

**GESAMT: 39 sichtbare Buttons**

### Fehlende HTML-Ziele
- frm_SubRechnungen → Ziel fehlt
- frm_DBWechseln → Ziel fehlt
- frm_N_AuswahlMaster → Ziel fehlt
- zfrm_ZK_Lohnarten_Zuschlag → Ziel fehlt

---

## Changelog
| Datum | Änderung |
|-------|----------|
| 2026-01-07 | Initiale Inventarisierung |
