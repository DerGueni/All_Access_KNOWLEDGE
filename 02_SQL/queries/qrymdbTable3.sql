SELECT qrymdbTable2.Database, qrymdbTable2.Type
FROM qrymdbTable2
GROUP BY qrymdbTable2.Database, qrymdbTable2.Type
HAVING (((qrymdbTable2.Type)>1));

