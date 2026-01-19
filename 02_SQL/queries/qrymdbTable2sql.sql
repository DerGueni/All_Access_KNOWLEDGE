SELECT MSysObjects.Name AS ObjName, conn_dbname([Connect],"SERVER=") & " - " & conn_dbname([Connect],"DATABASE=") AS [Database], MSysObjects.Type
FROM MSysObjects
WHERE (((MSysObjects.Type)=4) AND ((MSysObjects.Flags)=1048576) AND ((Left([Name],1))<>"~"))
ORDER BY MSysObjects.Type, MSysObjects.Name;

