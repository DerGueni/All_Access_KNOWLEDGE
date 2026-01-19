SELECT tbl_MA_Dokumente.ID, tbl_MA_Dokumente.MA_ID, tbl_MA_Dokumente.Dokumenttyp, tbl_MA_Dokumente.Dateiname, tbl_MA_Dokumente.Dateipfad, tbl_MA_Dokumente.UploadDatum, tbl_MA_Dokumente.UploadVon, tbl_MA_Dokumente.Dateigroesse, tbl_MA_Dokumente.Beschreibung, tbl_MA_Dokumente.IstAktiv
FROM tbl_MA_Dokumente
WHERE tbl_MA_Dokumente.IstAktiv = True
ORDER BY tbl_MA_Dokumente.UploadDatum DESC;

