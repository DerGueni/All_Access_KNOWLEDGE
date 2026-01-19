Option Compare Database
Option Explicit

Public Function ListOBTables() As String
    Dim tdf As DAO.TableDef
    Dim strResult As String
    
    For Each tdf In CurrentDb.TableDefs
        If Left(tdf.Name, 6) = "tbl_OB" Then
            strResult = strResult & tdf.Name & vbCrLf
        End If
    Next
    
    ListOBTables = strResult
End Function