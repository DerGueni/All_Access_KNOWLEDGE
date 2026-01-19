-- Query: qrymdbModul
-- Type: 0
SELECT MSysObjects.Name AS ObjName
FROM MSysObjects
WHERE (((MSysObjects.Type)=-32761) AND ((MSysObjects.flags)=0 Or (MSysObjects.flags)=256 Or (MSysObjects.flags)=8))
ORDER BY MSysObjects.Name;

