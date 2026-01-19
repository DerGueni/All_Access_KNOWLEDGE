Option Compare Database   'Use database order for string comparisons
Option Explicit

' BeispielFormular zu der Umrechnungstabelle aus der NeatCd97.mdb von Microsoft
' ftp://ftp.microsoft.com/softlib/mslfiles/neatcd97.exe
' Benötigt die Tabelle  "_tblUnit"
' Wird in "frmHlp_Umrechnung" verwendet

' Some of the functions require data from the "_tblUnit" table.

' This is a recursive table.  Entries should not be deleted unless
' all dependant entries are also deleted.

' The list of fields is provided in case you want to add more conversions:
'
'   UnitCode      A 5-letter code that makes up the primary key.
'                 This can be lengthened or shortened but should be readable.
'
'   UnitName      The long name for the unit.
'
'   UnitType      Whether the unit is lengths, weights, volumes, etc.
'                 Conversions should be done only against units of the same
'                 type (len -> len, not len -> vol) or you will get nonsense
'                 results.  You can base units of one type on units of another
'                 type:
'                      "1 cc = 1 cm cubed" would be entered as:
'                      Unit="cc", ComposedOf="cm", Factor=1, Power=3
'
'   ComposedOf    What the other unit is based on.  e.g. "cc" composed of "cm".
'                 Leave blank if this is the 'Base Unit' - what all other units
'                 of that type are based on.
'
'                 Note: there is no 'Base Unit' for UnitType 'vol' or 'Wt'.  'Wt' is based on 'vol'
'                 via "kg" and "l" (assuming density of water at 4 degrees centigrade) and
'                 'vol' is based on 'len' via cubic measurements.
'
'   Factor        What's the conversion factor of the unit this is based on.
'                 e.g. 1 Pt = 2 cups
'
'   Power         Must be 1 if the ComposedOf is the same unit type.
'                 See UnitType (above) for example of different UnitType.

Function C2F(c As Double) As Double
' Converts temperature from Celcius/Centigrade to Farenheit
  C2F = 32 + c * 9 / 5
End Function

Function CalcUnitFactor(Unit As String) As Double
'
' Returns the scaling factor to multiply a measurement in
' to get the equivalent value in the base unit for that class.
'
' e.g.  ?CalcUnitFactor("cm") returns .01, since "m" is the base unit.
'
  Dim MyDB As DAO.Database, UnitTable As DAO.Recordset
  Set MyDB = CurrentDb
  Set UnitTable = MyDB.OpenRecordset("_tblUnit", dbOpenTable)
  CalcUnitFactor = RecurseTable(Unit, UnitTable)
End Function

Function F2C(f As Double) As Double
' Converts temperature from Farenheit to Celcius/Centigrade
  F2C = (f - 32) * 5 / 9
End Function

Private Function RecurseTable(U, UnitTable As DAO.Recordset) As Double
'
' Used by CalcUnitFactor and ScaleUnit to recursively convert measurements
' from one type unit into another.
'
  Dim result As Double, i As Integer, f As Double
  Dim comp As Variant, Factr As Double, Pwr As Integer
  UnitTable.Index = "PrimaryKey"
  UnitTable.Seek "=", U
  RecurseTable = 1#
  If UnitTable.NoMatch Then Exit Function
  comp = UnitTable![ComposedOf]
  Factr = UnitTable![Factor]
  Pwr = UnitTable![Power]
  If IsEmpty(comp) Then Exit Function
  If IsNull(comp) Then Exit Function
  If comp = "" Then Exit Function
  result = 1
  f = RecurseTable(comp, UnitTable)
  For i = 1 To Pwr
    result = result * f
  Next i
  RecurseTable = result * Factr
End Function

Function ScaleUnit(Value As Double, Unit As String, NewUnit As String) As Double
'
' Converts a measurement from one unit to another.
'
' e.g.  ?ScaleUnit(5,"cm","m") returns .05
' i.e   5 cm is the same as .05 m
'
' You should only do this between units of a similar UnitType
'
  Dim MyDB As DAO.Database, UnitTable As DAO.Recordset
  Set MyDB = CurrentDb
  Set UnitTable = MyDB.OpenRecordset("_tblUnit", dbOpenTable)
  ScaleUnit = Value * RecurseTable(Unit, UnitTable) / RecurseTable(NewUnit, UnitTable)
End Function