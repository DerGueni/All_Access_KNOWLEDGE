-- Query: qrymdbMacro
-- Type: 0
SELECT MSysObjects.Name AS ObjName
FROM MSysObjects
WHERE (((MSysObjects.Type)=-32766) AND ((MSysObjects.Flags)=0 Or (MSysObjects.Flags)=8))
ORDER BY MSysObjects.Name;

