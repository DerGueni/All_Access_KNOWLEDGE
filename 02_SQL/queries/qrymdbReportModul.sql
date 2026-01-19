SELECT "Report_" & [Name] AS ObjName
FROM MSysObjects
WHERE (((MSysObjects.Type)=-32764) AND ((MSysObjects.Flags)=0))
ORDER BY "Report_" & [Name];

