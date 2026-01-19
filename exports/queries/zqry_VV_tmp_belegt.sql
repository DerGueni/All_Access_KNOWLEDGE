-- Query: zqry_VV_tmp_belegt
-- Type: 0
SELECT [ID], [Beginn], [Ende], [Grund]
FROM zqry_MA_Verfuegbarkeit
WHERE istVerfuegbar = 0;

