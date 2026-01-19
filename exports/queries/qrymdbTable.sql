-- Query: qrymdbTable
-- Type: 0
SELECT MSysObjects.Name AS ObjName, MSysObjects.Database, MSysObjects.Type
FROM MSysObjects
WHERE (((MSysObjects.Type)=1) AND ((MSysObjects.flags)=0) AND ((Left([Name],1))<>"~")) OR (((MSysObjects.Type)=4) AND ((MSysObjects.flags)=1048576) AND ((Left([Name],1))<>"~")) OR (((MSysObjects.Type)=6) AND ((MSysObjects.flags)=2097152) AND ((Left([Name],1))<>"~"))
ORDER BY MSysObjects.Type, MSysObjects.Name;

