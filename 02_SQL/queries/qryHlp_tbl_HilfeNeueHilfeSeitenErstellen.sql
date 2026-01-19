INSERT INTO _tbl_Hilfe ( Formularname, SeiteNr, SpracheID )
SELECT qrymdbForm.ObjName, "1" AS Ausdr1, "DE" AS Ausdr
FROM qrymdbForm;

