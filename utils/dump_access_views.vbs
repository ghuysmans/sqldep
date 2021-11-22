Option Explicit

Const adSchemaViews = 23


Dim inp
Set inp = CreateObject("ADODB.Connection")
inp.Open "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & WScript.Arguments(0) & ";Persist Security Info=False"

Dim sch
Set sch = inp.OpenSchema(adSchemaViews)
While Not sch.EOF
	WScript.Echo "CREATE VIEW " & sch("TABLE_NAME") & " AS " & sch("VIEW_DEFINITION")
	sch.MoveNext
Wend
