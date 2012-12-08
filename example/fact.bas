Function Fact(n)
  If n <= 1 Then
    Return 1
  End If

  Return Fact(n - 1) * n
End Function

Sub Main(x)
  Print Fact(30)
End Sub 

