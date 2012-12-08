' 自動的にコンパイル時に読み込まれます

' 整数を表示し、改行します。
Sub Print(x)
  __VM_PUSH x
  __VM "PUTINT"
  __VM "PUSH 10"
  __VM "PUTCHAR"
End Sub

Function Max(x,y)
  If x <= y Then
    Return y
  Else
    Return x
  End If
End Function

Function Min(x,y)
  If x <= y Then
    Return x
  Else
    Return y
  End If
End Function

Function Abs(x)
  If x <= 0 Then
    Return -x
  End If
  Return x
End Function
