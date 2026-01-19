-- Query: qrymdbQuery
-- Type: 0
SELECT MSysObjects.Name AS ObjName
FROM MSysObjects
WHERE (((MSysObjects.Flags)<>3) AND ((MSysObjects.Type)=5) AND ((Left([Name],1))<>"~"))
ORDER BY MSysObjects.Flags, MSysObjects.Name;

