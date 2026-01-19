Attribute VB_Name = "mdl_Menu_Neu"
Option Compare Database
Option Explicit

Public Function F1_Tag()
DoCmd.OpenForm "frm_UE_Uebersicht"
Call Form_frm_UE_Uebersicht.WoUmsch(1)
End Function

Public Function F1_Woche()
DoCmd.OpenForm "frm_UE_Uebersicht"
Call Form_frm_UE_Uebersicht.WoUmsch(2)
End Function

Public Function F1_Monat()
DoCmd.OpenForm "frm_UE_Uebersicht"
Call Form_frm_UE_Uebersicht.WoUmsch(3)
End Function

Public Function F1_Dienstplan_Obj()
DoCmd.OpenForm "frm_DP_Dienstplan_Objekt"
End Function

Public Function F1_Dienstplan_MA()
DoCmd.OpenForm "frm_DP_Dienstplan_MA"
End Function

Function F2_NeuAuf()
On Error Resume Next
DoCmd.OpenForm "frm_VA_Auftragstamm"
Call Form_frm_VA_Auftragstamm.VAOpen_New
End Function

Public Function F2_Schnellplan()
DoCmd.OpenForm "frm_MA_VA_Schnellauswahl"
End Function

Public Function F2_eMailVorl()
DoCmd.OpenForm "frm_MA_Serien_eMail_Vorlage"
End Function

Public Function F2_frm_Objekt()
DoCmd.OpenForm "frm_OB_Objekt"
End Function

'frm_OB_Objekt

Public Function F2_All_eMail_Update()
Dim bOffen As Boolean
All_eMail_Update
bOffen = Manuelle_eMail_MA_Zuordnung
DoEvents
If Not bOffen Then
    MsgBox "Alle Zu- und Absagen erfolgreich importiert"
End If
End Function

Public Function F2_Manuelle_ZuAbsage()
DoCmd.OpenForm "frmTop_MA_ZuAbsage"
End Function

Public Function F2_Word_Dokumente()
DoCmd.OpenForm "frmTop_Textbaustein_Brief"
End Function

Public Function F2_Auftragsverwaltung()
DoCmd.OpenForm "frm_VA_Auftragstamm"
End Function

Public Function F2_Manuelle_eMails_Auftrag()
DoCmd.OpenForm "frm_MA_Serien_eMail_Auftrag"
End Function

Public Function F2_Selektive_Tagesuebersicht()
DoCmd.OpenForm "frm_auftragsuebersicht_neu"
End Function

Public Function F3_MA_eMail_Std()
' 1 = MA, 2 = Kunde
DoCmd.OpenForm "frmOff_Outlook_aufrufen"
Call Form_frmOff_Outlook_aufrufen.MailOpen(1)
End Function

Public Function F2_Auftragsuebersicht()
DoCmd.OpenForm "frm_auftragsuebersicht_neu", acFormDS
End Function



Public Function F3_Mitarbeiter()
DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
End Function

Public Function F3_MA_Dienstplan()
DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
Forms!frm_MA_Mitarbeiterstamm!pgPlan.SetFocus
End Function

Public Function F3_MA_Dienstkleidung()
DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
Forms!frm_MA_Mitarbeiterstamm!pgDienstKl.SetFocus
End Function

Public Function F3_MA_Einsatzuebersicht()
DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
Forms!frm_MA_Mitarbeiterstamm!pgAuftrUeb.SetFocus
End Function

Public Function F3_MA_Monatsuebersicht()
DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
Forms!frm_MA_Mitarbeiterstamm!pgMonat.SetFocus
End Function

Public Function F3_MA_Jahresuebersicht()
DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
Forms!frm_MA_Mitarbeiterstamm!pgJahr.SetFocus
End Function



Public Function f5_frm_Auswertung_Kunde_Jahr()
DoCmd.OpenForm "frm_Auswertung_Kunde_Jahr"
End Function

Public Function F3_Manuelle_Abwesenheiten()
DoCmd.OpenForm "frm_abwesenheitsuebersicht"
End Function

Public Function F3_Maintainance()
DoCmd.OpenForm "frm_MA_Maintainance"
End Function

Public Function F3_Word_Brf_Kd_MA()
DoCmd.OpenForm "frmTop_Textbaustein_Brief"
End Function

Public Function F3_Excel_Monatsuebersicht()
DoCmd.OpenForm "frmTop_Excel_Monatsuebersicht"
End Function


Public Function F7_Firmenstammdaten()
DoCmd.OpenForm "frmStamm_EigeneFirma"
End Function

Public Function F5_Kundennstammdaten()
DoCmd.OpenForm "frm_KD_Kundenstamm"
End Function

Public Function F5_Kunde_eMail_Std()
' 1 = MA, 2 = Kunde
DoCmd.OpenForm "frmOff_Outlook_aufrufen"
Call Form_frmOff_Outlook_aufrufen.MailOpen(2)
End Function

Public Function F6_Rch_erstellen()
DoCmd.OpenForm "frmTop_Rch_Berechnungsliste"
End Function
Public Function F6_Ang_erstellen()
DoCmd.OpenForm "frmTop_Rch_Berechnungsliste"
Forms!frmtop_rch_berechnungsliste!TaetigkeitArt = 2
Form_frmTop_Rch_Berechnungsliste.f_TaetArt_Upd
End Function

Public Function F6_frmtop_rechnungsstammm()
DoCmd.OpenForm "frmTop_RechnungsStamm"
End Function


Public Function F7_eMail_KD_MA_Templates()
DoCmd.OpenForm "frm_Outlook_eMail_template"
End Function


Public Function F7_Textbausteininfo()
DoCmd.OpenForm "frmHlp_TextbausteinInfo"
End Function


Public Function F7_Ausweisdruck()
DoCmd.OpenForm "frm_Ausweis_Create"
End Function
Public Function F2_frm_ma_va_positionszuordnung()
DoCmd.OpenForm "frm_ma_va_positionszuordnung"
End Function

Public Function F7_Adressarten()
DoCmd.OpenForm "frmTop_Adressart"
End Function


Public Function F7_Preisarten()
DoCmd.OpenForm "frmTop_KD_Preisarten"
End Function

'Public Function F7_Qualifikation()
'DoCmd.OpenForm "frm_Top_Einsatzart"
'End Function

Public Function F7_Zeittypen()
DoCmd.OpenForm "frmTop_Zeittyp"
End Function

Public Function F7_Linklist()
DoCmd.OpenForm "frmTop_Linkliste"
End Function

Public Function F7_Vorlagenverwaltung()
DoCmd.OpenForm "frmTop_Neue_Vorlagen"
End Function

Public Function F9_Jahreskalender()
DoCmd.OpenForm "_frmHlp_Kalender_Jahr"
End Function

Public Function F9_3Monatskalender()
DoCmd.OpenForm "_frmHlp_Kalender_3Mon"
End Function

Public Function F9_Sysinfo()
DoCmd.OpenForm "_frmHlp_SysInfo"
End Function

Public Function F9_LKZ()
DoCmd.OpenForm "_frmHlp_LKZ"
End Function



Public Function F9_Excel()
DoCmd.OpenForm "_frmHlp_Excel_Einbinden"
End Function

Public Function F9_MassGew()
DoCmd.OpenForm "_frmHlp_MasseGewichteUmrechnen"
End Function

Public Function F9_Tetris()
DoCmd.OpenForm "_frmHlp_Spiel_Tetris"
End Function

Public Function F9_Waehrung()
DoCmd.OpenForm "_frmHlp_Waehrungsumrechnung"
End Function

Public Function F9_WeitereMasken()
DoCmd.OpenForm "__frmHlpMenu_Weitere_Masken"
End Function

Public Function F9_Login()
DoCmd.OpenForm "frmTop_Login"
End Function

Public Function F3_MA_NverfuegZeiten()
DoCmd.OpenForm "frm_MA_NVerfuegZeiten_Si", acFormDS
End Function

Public Function F10_Hirschplan()
DoCmd.OpenForm "frm_einsatzplan_objekte_alle"
End Function

Public Function F10_Terminal90Plan()
DoCmd.OpenForm "frm_einsatzplan_objekte_alle"
End Function
Public Function F10_Green_GoosePlan()
DoCmd.OpenForm "frm_einsatzplan_objekte_alle"
End Function

Public Function F10_Plan()
DoCmd.OpenForm "frm_einsatzplan_objekte_alle"
End Function

Public Function F3_stundenuebersicht()
DoCmd.OpenForm "frm_stundenuebersicht"
End Function


