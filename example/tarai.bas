Function Tarai(x,y,z)
  If x <= y Then
    Return y
  Else
    Return Tarai(Tarai(x-1, y, z), Tarai(y - 1, z, x), Tarai(z - 1, x , y))
  End If
End Function

Sub Main()
  Print Tarai(10, 5, 0)
End Sub
