Option Compare Database
Option Explicit

'The data for each datasheet's settings are stored in the Windows Registry under a key with the name
'of the datasheet. The LoadUserColumnSetup pulls that data and applies it, while the
'SaveUserColumnSetup writes the latest data back to the Registry. Each of those
'functions take an Access.Form variable, which can be identified by the Me object to
'simplify the application of the code. Below is a listing of all the code involved.
'Comments interspersed will explain the process.

' Author: Danny Lesandrini

'The code
  
  Public Sub LoadUserColumnSetup(ByRef frm As Form)
      Dim ctl As control
      Dim strBlob As String
      Dim strColumns() As String
      Dim intColumns As Integer
      Dim intColumn As Integer
      Dim strValues() As String
      Const cDatasheetView As Long = 2
      
      On Error Resume Next
      
      ' Only apply to forms in datasheet view.
      ' Otherwise, exit the sub to cease processing
      If frm.CurrentView <> cDatasheetView Then Exit Sub
      
      ' Grab previous settings from Registry as a blob of data
      strBlob = GetSetting("Demo", "Settings", frm.Name, "")
      
      ' Blob data looks like this:
      '    name : postion : hidden : size
      '    ------------------------------
      '    fname:1:False:855
      '    lname:3:False:870
      '    hire_date:4:False:3090
      '    minit:2:False:840
      ' Only continue if blob contains data.
      If strBlob <> "" Then
        ' This is the clever bit.  For the code to work right,
        ' the columns must be assigned in correct order.  This
        ' method reorders the blob entries.
        Call GetOrderedColumns(strBlob, strColumns)
        
        ' Loop through the columns (if any exist) and set the
        ' properties of the corresponding control
        intColumns = UBound(strColumns) + 1
        If intColumns <> 0 Then
          For intColumn = 0 To intColumns - 1
            If Trim(strColumns(intColumn)) <> "" Then
               ' Split the line into values and assign properties
               strValues = Split(strColumns(intColumn), ":")
               Set ctl = frm.Controls(strValues(0))
               
               ctl.ColumnOrder = CInt(strValues(1))
               ctl.ColumnHidden = CBool(strValues(2))
               ctl.ColumnWidth = CLng(strValues(3))
            End If
          Next
        End If
      End If
  End Sub
  Private Sub GetOrderedColumns(ByVal strData As String, _
                                ByRef strColumns() As String)
      
      ' The data is passed, along with the empty array.
      ' I tried returning an array, but couldn't get it
      ' to work, so fell back to passing the array ByRef.
      
      Dim strTemp() As String
      Dim intCols As Integer
      Dim intCol As Integer
      Dim intCurr As Integer
      Dim strValues() As String
      
      On Error Resume Next
      
      ' Each datasheet control's info is on its own line,
      ' so split the blob by Line Feed/Carriage Returns
      strTemp = Split(strData, vbCrLf)
      intCols = UBound(strTemp) - 1
      ReDim strColumns(intCols)
      
      ' Loop through the unordered array and convert it into a
      ' sorted list: Col 1 at the top and Col n at the bottom.
      For intCol = 0 To intCols
          For intCurr = 0 To intCols
              strValues = Split(strTemp(intCurr), ":")
              If CInt(strValues(1)) = intCol + 1 Then
                  strColumns(intCol) = strTemp(intCurr)
                  Exit For
              End If
          Next
      Next
      
  End Sub
  Public Sub SaveUserColumnSetup(ByRef frm As Form)
      Dim ctl As control
      Dim strBlob As String
      Dim strCtl As String
      Const cDatasheetView As Long = 2
      
      On Error Resume Next
      
      ' Only apply to forms in datasheet view.
      If frm.CurrentView <> cDatasheetView Then Exit Sub
      
      ' Loop through the controls, processing only those that matter.
      For Each ctl In frm.Controls
        Select Case ctl.ControlType ' 108 acTextbox
          Case acLabel, acLine, acSubform, acCommandButton
              ' do nothing for these controls.
          Case Else
            strCtl = ctl.Name & ":" & _
                     ctl.ColumnOrder & ":" & _
                     ctl.ColumnHidden & ":" & _
                     ctl.ColumnWidth & vbCrLf
            strBlob = strBlob & strCtl
        End Select
      Next
      
      SaveSetting "Demo", "Settings", frm.Name, strBlob
  End Sub


'Conclusion
'This code took a little tinkering to get it to work, but once it was working, it was a simple matter
'to apply it and my users are happy again. True, it is an obscure little problem, but if it happens
'to be a problem you're currently facing then this little block of code will be a welcome
'addition to your toolbox.