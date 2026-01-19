SELECT "Form_" & [Name] AS ObjName
FROM MSysObjects
WHERE (((MSysObjects.Type)=-32768) AND ((MSysObjects.Flags)=0) AND ((Left([Name],1))<>"~"))
ORDER BY "Form_" & [Name];

