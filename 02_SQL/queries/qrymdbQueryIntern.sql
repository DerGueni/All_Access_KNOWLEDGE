SELECT MSysObjects.Name AS ObjName
FROM MSysObjects
WHERE (((MSysObjects.Type)=5) AND ((MSysObjects.flags)=3))
ORDER BY MSysObjects.Name;

