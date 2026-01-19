SELECT MSysObjects.Name AS ObjName
FROM MSysObjects
WHERE (((MSysObjects.flags)=0 Or (MSysObjects.flags)=8) AND ((MSysObjects.Type)=-32768) AND ((Left([Name],1))<>"~"))
ORDER BY MSysObjects.Name;

