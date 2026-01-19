TRANSFORM Count(*) AS Anz_Urlaub
SELECT T.[MA_ID] AS MA_ID
FROM tbl_MA_NVerfuegZeiten AS T
WHERE T.[Zeittyp_ID] = "Urlaub"
    AND Year(T.[vonTag]) = [Bitte Jahr eingeben:]
GROUP BY T.[MA_ID]
PIVOT Month(T.[vonTag]) IN
    (1,2,3,4,5,6,7,8,9,10,11,12);

