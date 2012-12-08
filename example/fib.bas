Function Fib(x)
  If x <= 1 Then
    Return 1
  Else
    Return Fib(x - 2) + Fib(x - 1)
  End If
End Function

Sub Main()
  Print Fib(5)
End Sub
