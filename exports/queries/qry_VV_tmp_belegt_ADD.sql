-- Query: qry_VV_tmp_belegt_ADD
-- Type: 64
INSERT INTO tbltmp_VV_Belegt
SELECT qry_VV_tmp_belegt.*
FROM qry_VV_tmp_belegt;

