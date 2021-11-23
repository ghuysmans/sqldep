Option Explicit

Const adSchemaViews = 23


Dim inp
Set inp = CreateObject("ADODB.Connection")
On Error Resume Next
inp.Open "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & WScript.Arguments(0) & ";Persist Security Info=False"
If Err Then
	WScript.StdErr.WriteLine Err.Description
	WScript.Quit Err.number
End If
On Error GoTo 0

Dim sch
Set sch = inp.OpenSchema(adSchemaViews)
While Not sch.EOF
	WScript.Echo "CREATE VIEW " & sch("TABLE_NAME") & " AS " & sch("VIEW_DEFINITION")
	sch.MoveNext
Wend
