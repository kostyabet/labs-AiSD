Program ReversPolandRecord;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  StrUtils,
  Classes,
  Windows;

Type
    PElem = ^Elem;

    Elem = Record
        Data: Char;
        Next: PElem;
    End;

    IntList = Record
        FirstElem: PElem;
        Length: Integer;
        Rang: Integer;
    End;

Function IsEmptyStack(Stack: IntList): Boolean;
Begin
    Result := Stack.FirstElem = Nil;
End;

Function Pop(Var Stack: IntList): Char;
Begin
    If IsEmptyStack(Stack) Then
        Result := #0
    Else
    Begin
        Result := Stack.FirstElem^.Data;
        Dec(Stack.Length);
        Stack.FirstElem := Stack.FirstElem^.Next;
    End;
End;

Function Peek(Stack: IntList): Char;
Begin
    If IsEmptyStack(Stack) Then
        Result := #0
    Else
        Result := Stack.FirstElem^.Data;
End;

Procedure Push(Var Stack: IntList; Data: Char);
Var
    NewElem: PElem;
Begin
    New(NewElem);
    NewElem^.Next := Stack.FirstElem;
    Stack.FirstElem := NewElem;
    Stack.FirstElem^.Data := Data;
    Inc(Stack.Length);
End;

Function GetStackPriority(Character: Char): Integer;
Begin
    Case Character Of
        '+', '-':
            Result := 2;
        '/', '*':
            Result := 4;
        '(':
            Result := 0;
        'a' .. 'z':
            Result := 8;
        '^':
            Result := 5;
    End;
End;

Function GetPriority(Character: Char): Integer;
Begin
    Case Character Of
        '+', '-':
            Result := 1;
        '/', '*':
            Result := 3;
        '(':
            Result := 9;
        'a' .. 'z':
            Result := 7;
        '^':
            Result := 6;
    End;
End;

Function Reverse(Expression: String): String;
Var
    Output: String;
    I: Integer;
Begin
    Output := AnsiReverseString(Expression);
    For I := 1 To Length(Output) Do
        If Output[I] = '(' Then
            Output[I] := ')'
        Else
            If Output[I] = ')' Then
                Output[I] := '(';
    Result := Output;
End;

Function ConvertToSuffix(Var Stack: IntList; Expression: String): String;
Var
    FinalAnswer: String;
    I, J, C, N: Integer;
    CurrentChar: Char;
    StackContents: TStringList;

Begin
    Stack.Rang := 0;
    Push(Stack, Expression[1]);
    FinalAnswer := '';
    StackContents := TStringList.Create;
    Write('Stack: ');
    Write(Expression[1]);
    Writeln;

    For I := 2 To Length(Expression) Do
    Begin
        CurrentChar := Expression[I];
        If CurrentChar = ')' Then
        Begin
            While Peek(Stack) <> '(' Do
            Begin
                FinalAnswer := Concat(FinalAnswer, Pop(Stack));
            End;
            Pop(Stack); //Pop '('
        End
        Else
        Begin
            If GetPriority(CurrentChar) > GetStackPriority(Peek(Stack)) Then
                Push(Stack, CurrentChar)
            Else
            Begin
                While (Not IsEmptyStack(Stack)) And (GetPriority(CurrentChar) <= GetStackPriority(Peek(Stack))) Do
                Begin
                    FinalAnswer := Concat(FinalAnswer, Pop(Stack));

                End;
                Push(Stack, CurrentChar);
            End;
        End;

        StackContents.Clear;
        Var
            Ptr: PElem;
        Ptr := Stack.FirstElem;
        While Ptr <> Nil Do
        Begin
            StackContents.Insert(0, Ptr^.Data);
            Ptr := Ptr^.Next;
        End;
        Write('Stack: ');

        For J := 0 To StackContents.Count - 1 Do
            Write(StackContents[J]);

        Write(#9#9'Текущая строка: ', FinalAnswer);
        Writeln;

    End;

    While Stack.FirstElem <> Nil Do
    Begin
        FinalAnswer := Concat(FinalAnswer, Pop(Stack));
    End;
    N := 0;
    For C := Low(FinalAnswer) To High(FinalAnswer) Do
        If FinalAnswer[C] In ['a' .. 'z'] Then
            Inc(N)
        Else
            Dec(N);

    Writeln('Rand expresion = ', N);
    Result := FinalAnswer;
    StackContents.Free;

End;

Function InputString: String;
Var
    Str: String;
    I: Integer;
    IsCorrect: Boolean;
    NumSet: Set Of Char;
Begin

    Repeat
        Readln(Str);
        IsCorrect := True;
        For I := Low(Str) To High(Str) Do
            If Str[I] In ['0' .. '9'] Then
            Begin
                IsCorrect := False;

            End;

        If Not IsCorrect Then
            Writeln('Error input.');

    Until IsCorrect;
    While Pos(' ', Str) <> 0 Do
        Delete(Str, Pos(' ', Str), 1);

    InputString := Str;
End;

Function CheckParentheses(Expression: String): Boolean;
Var
    OpenCount, CloseCount: Integer;
    I: Integer;
Begin
    OpenCount := 0;
    CloseCount := 0;

    For I := 1 To Length(Expression) Do
    Begin
        If Expression[I] = '(' Then
            Inc(OpenCount)
        Else
            If Expression[I] = ')' Then
                Inc(CloseCount);

        If CloseCount > OpenCount Then
            Exit(False);
    End;

    Result := OpenCount = CloseCount;
End;

Var
    Stack: IntList;
    Expression: String;

Begin

    Expression := InputString;

    If Not CheckParentheses(Expression) Then
    Begin
        Writeln('');
        Writeln('Rang equal = ', 0);
        Readln;
        Exit;
    End;
    Writeln;
    Writeln('Revers poland record = ', ConvertToSuffix(Stack, Expression));
    Writeln;

    Readln;

End.
