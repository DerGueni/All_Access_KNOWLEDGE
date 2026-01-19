-- Query: zqry_ZK_Stunden_prepare
-- Type: 0
SELECT ztbl_ZK_Stunden_prepare.*, [MA_ID] & [ZUO_ID] & [NV_ID] & [Korr_ID] & [Lohnart_ID] AS Delta_KEY
FROM ztbl_ZK_Stunden_prepare;

