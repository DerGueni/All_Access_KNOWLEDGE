Option Compare Database

Public Const Lokal = "C:\"
Public Const Server = "\\vConsys01-NBG\"
Public Const SYNCprod = "PHP_Sync.accdb"
Public Const SYNCtest = "PHP_Sync -Testumgebung.accdb"
Public Const FrontendsVTS = Lokal & "Frontends\"
Public Const Backend = "Consec_V1_BE_V1.55.accdb"
Public Const Archiv_BE = "Consec_V1_BE_ARCHIV.accdb"
Public Const PfadProd = Server & "Database\Backend\"
Public Const PfadProdLokal = Lokal & "Database\Backend\"
Public Const PfadTest = Server & "Database\Testumgebung\"
Public Const PfadTestLokal = Lokal & "Database\Testumgebung\"
Public Const SyncPfad = Server & "Database\"
Public Const Sync = "Sync"
Public Const CONSYS = Server & "Consys\"
Public Const PfadPlanungAktuell = CONSYS & "CONSEC\CONSEC PLANUNG AKTUELL\"
Public Const PfadZuBerechnen = PfadPlanungAktuell & "E - AUFTRÄGE 2015 NOCH ZU BERECHNEN\"
Public Const PfadRechnGestellt = PfadZuBerechnen & "D AUFTRÄGE 2015 RECHNUNG GESTELLT\"
Public Const PfadAwort = Server & "inetpub\wwwroot\mail\awort\"
Public Const PfadLog = Server & "Database\Log\"
'Public Const PfadTemp = CONSYS & "Temp\"
Public Const PfadTemp = Server & "Database\Temp\"
Public Const PfadTempFiles = PfadTemp & "files\"
Public Const PfadTempLog = PfadTemp & "log\"

'Public Const PfadZusage = Server & "inetpub\wwwroot\mail\zusage\"
Public Const PfadZusage = CONSYS & "Dokumente\Auftrag\Zusage\"
Public Const PfadZK = PfadZuBerechnen & "Zeitkonten"
'Public Const PfadZK = "C:\Users\johannes.kuypers\Desktop\Zeitkonten"

'Textdokumente mit HTML Body
Public Const TXTAnf = Server & "Database\HTMLBodies\HTML_Body_Anfrage.txt"
Public Const TXTConf = Server & "Database\HTMLBodies\HTML_Body_Confirm.txt"
Public Const TXTEinsatzliste = Server & "Database\HTMLBodies\HTML_Body_Einsatzliste.txt"
Public Const TXTEinsatzlisteKD = Server & "Database\HTMLBodies\HTML_Body_Einsatzliste_KD.txt"
Public Const TXTDienstPl = Server & "Database\HTMLBodies\HTML_Body_DienstPl.txt"
Public Const TXTAbrechnung = Server & "Database\HTMLBodies\HTML_Body_Abrechnung.txt"


'Tabellen
Public Const PLANUNG = "tbl_MA_VA_Planung"
Public Const ZUORDNUNG = "tbl_MA_VA_Zuordnung"
Public Const MASTAMM = "tbl_MA_Mitarbeiterstamm"
Public Const AUFTRAGSTAMM = "tbl_VA_Auftragstamm"
Public Const vaStart = "tbl_VA_Start"
Public Const anzTage = "tbl_VA_AnzTage"
Public Const NVERFUEG = "tbl_MA_NVerfuegZeiten"
Public Const VAAKTOKOPF = "tbl_VA_Akt_Objekt_Kopf"
Public Const VAAKTOPOS = "tbl_VA_Akt_Objekt_POS"
Public Const VAAKTOPOSM = "tbl_VA_Akt_Objekt_POS_MA"
Public Const VAKOSTALT = "tbl_VA_Kosten_alt"
Public Const SPREISE = "tbl_KD_Standardpreise"
Public Const KORR = "ztbl_MA_ZK_Korrekturen"
Public Const KDStamm = "tbl_KD_Kundenstamm"
Public Const ZUO_STD = "ztbl_ZUO_Stunden"
Public Const RCHKOPF = "tbl_Rch_Kopf"
Public Const RCHPOSAUF = "tbl_Rch_Pos_Auftrag"


Public Const PLANUNG_FE = "ztbl_MA_VA_Planung_FE"
Public Const ZUORDNUNG_FE = "ztbl_MA_VA_Zuordnung_FE"
Public Const ZUO_STD_FE = "ztbl_ZUO_Stunden_FE"
Public Const NVERFUEG_FE = "ztbl_MA_NVerfuegZeiten_FE"
Public Const LOHNARTEN = "zqry_ZK_Lohnarten_Zuschlag"

'MAIL
Public Const SendUserName = "97455f0f699bcd3a1cb8602299c3dadd"
Public Const SendPassword = "1dd9946e4f632343405471b1b700c52f"
Public Const SMTPServer = "in-v3.mailjet.com"


'Reports
Public Const rptDP As String = "rpt_MA_Dienstplan"


'Formulare
Public Const frmZKTop As String = "zfrm_MA_ZK_Top"