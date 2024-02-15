Program Lab1;

{$APPTYPE CONSOLE}
{$R *.res}

Uses
    Velthuis.Sizes In 'Source/Velthuis.Sizes.pas',
    Velthuis.FloatUtils In 'Source/Velthuis.FloatUtils.pas',
    Velthuis.StrConsts In 'Source/Velthuis.StrConsts.pas',
    Velthuis.Numerics In 'Source/Velthuis.Numerics.pas',
    CompilerAndRTLVersions In 'Source/CompilerAndRTLVersions.pas',
    Velthuis.RandomNumbers In 'Source/Velthuis.RandomNumbers.pas',
    Velthuis.BigIntegers In 'Source/Velthuis.BigIntegers.pas',
    System.SysUtils;

Type
    Pt = ^Elem; { * Pointer on first element of list * }

    Elem = Record
        Degree: Integer; { * Degree of x in qurent position* }
        Data: Integer; { * Qurent free point * }
        Next: Pt; { * Next point adress * }
    End;

    MainMenu = (FuncEquality = 1, FuncMeaning, ProcAdd, ExitButton); { * Main menu button enum * }

Const
    MIN_SIZE: Integer = 1;
    MAX_SIZE: Integer = 50;
    MIN_X: Integer = -100_000_000;
    MAX_X: Integer = 100_000_000;

    { * Input number * }
Function InputNum(Prompt: String; Const MIN, MAX: Integer): Integer;
Var
    N: Integer;
    IsCorrect: Boolean;
Begin
    Write(Prompt);
    N := 0;
    IsCorrect := False;
    Repeat
        Try
            Read(N);

            IsCorrect := (N >= MIN) And (N <= MAX);
        Except
            IsCorrect := False;
        End;
        If Not IsCorrect Then
            Write('Number shell be from ', MIN, ' to ', MAX, '. Try again: ');
    Until IsCorrect;

    InputNum := N;
End;

{ * Create list * }
Function Make(X: Pt; Size: Integer; Const MIN, MAX: Integer): Elem;
Var
    I, Temp: Integer;
    Prompt: String;
Begin
    For I := Size DownTo 1 Do
    Begin
        Prompt := 'Write your a' + IntToStr(I) + ': ';
        Temp := InputNum(Prompt, MIN, MAX);
        If (Temp <> 0) Then
        Begin
            New(X^.Next);
            X := X^.Next;
            X^.Degree := I;
            X^.Data := Temp;
        End;
    End;
    X^.Next := Nil;
End;

{ * Out put list * }
Procedure Print(X: Pt);
Begin
    While X <> Nil Do
    Begin
        If X^.Data > 0 Then
        Begin
            Write('+');
            Write(X^.Data);
        End
        Else
            Write(X^.Data);

        Write('*x^', X^.Degree);
        X := X^.Next;
    End;
    Write(#13#10);
End;

Function Equality(P, Q: Pt): Boolean;
Begin
    While (P <> Nil) And (Q <> Nil) Do
    Begin
        If (P^.Data <> Q^.Data) Or (P^.Degree <> Q^.Degree) Then
        Begin
            Equality := False;
            Exit;
        End;
        P := P^.Next;
        Q := Q^.Next;
    End;

    Equality := Not(((P <> Nil) And (Q = Nil)) Or ((P = Nil) And (Q <> Nil)));
End;

Function Meaning(P: Pt; X: Integer): BigInteger;
Var
    Res, InterimRes: BigInteger;
    I: Integer;
Begin
    Res := 0;
    While P <> Nil Do
    Begin
        InterimRes := P^.Data;
        For I := 1 To P^.Degree Do
            InterimRes := InterimRes * X;

        Res := Res + InterimRes;
        P := P^.Next;
    End;
    Meaning := Res;
End;

Procedure Add(P, Q, R: Pt);
Begin
    While (P <> Nil) And (Q <> Nil) Do
    Begin
        New(R^.Next);
        R := R^.Next;

        If (P^.Degree > Q^.Degree) Then
        Begin
            R^.Degree := P^.Degree;
            R^.Data := P^.Data;
            P := P^.Next;
        End
        Else
            If (P^.Degree < Q^.Degree) Then
            Begin
                R^.Degree := Q^.Degree;
                R^.Data := Q^.Data;
                Q := Q^.Next;
            End
            Else
                If (P^.Degree = Q^.Degree) Then
                Begin
                    R^.Degree := Q^.Degree;
                    R^.Data := Q^.Data + P^.Data;
                    P := P^.Next;
                    Q := Q^.Next;
                End;
    End;

    While (P = Nil) ANd (Q <> Nil) Do
    Begin
        New(R^.Next);
        R := R^.Next;
        R^.Degree := Q^.Degree;
        R^.Data := Q^.Data;
        Q := Q^.Next;
    End;

    While (P <> Nil) And (Q = Nil) Do
    Begin
        New(R^.Next);
        R := R^.Next;
        R^.Degree := P^.Degree;
        R^.Data := P^.Data;
        P := P^.Next;
    End;
End;

Procedure ClickLoager;
Begin
    Writeln('Press any key to continue...');
    Readln;
    Readln;
End;

Procedure EqualityFuncProcces;
Var
    P1, P2: Pt; { * Pointer on first element of list * }
    Size: Integer; { * Number of elements * }
Begin
    Size := InputNum(#13#10'Input number of P1 elements: ', MIN_SIZE, MAX_SIZE);
    New(P1);
    Writeln('Input P1.');
    Make(P1, Size, MIN_X, MAX_X);
    Size := InputNum(#13#10'Input number of P2 elements: ', MIN_SIZE, MAX_SIZE);
    New(P2);
    Writeln('Input P2.');
    Make(P2, Size, MIN_X, MAX_X);
    Write(#13#10'P1: ');
    Print(P1^.Next);
    Write('P2: ');
    Print(P2^.Next);
    Writeln('Equality of P1 And P2: ', Equality(P1^.Next, P2^.Next));
End;

Procedure MeaningFuncProcess;
Var
    P1, P2: Pt; { * Pointer on first element of list * }
    Size: Integer; { * Number of elements * }
    X: Integer;
    P1Result: BigInteger;
Begin
    Size := InputNum(#13#10'Input number of P1 elements: ', MIN_SIZE, MAX_SIZE);
    New(P1);
    Writeln('Input P1.');
    Make(P1, Size, MIN_X, MAX_X);
    X := InputNum(#13#10'Input X-Pointer for P1: ', MIN_X, MAX_X);
    P1Result := Meaning(P1^.Next, X);
    Write(#13#10'P1: ');
    Print(P1^.Next);
    Writeln('At X=', X, ' the result is: ', P1Result.ToString);
End;

Procedure AddProcProcess;
Var
    P1, P2, P3: Pt; { * Pointer on first element of list * }
    Size: Integer; { * Number of elements * }
    X: Integer;
    P1Result: BigInteger;
Begin
    Size := InputNum(#13#10'Input number of P1 elements: ', MIN_SIZE, MAX_SIZE);
    New(P1);
    Writeln('Input P1.');
    Make(P1, Size, MIN_X, MAX_X);
    Size := InputNum(#13#10'Input number of P2 elements: ', MIN_SIZE, MAX_SIZE);
    New(P2);
    Writeln('Input P2.');
    Make(P2, Size, MIN_X, MAX_X);
    New(P3);
    Add(P1^.Next, P2^.Next, P3);
    Write(#13#10'P1: ');
    Print(P1^.Next);
    Write('P2: ');
    Print(P2^.Next);
    Write('P1 + P2: ');
    Print(P3^.Next);
End;

Procedure WorkWithMethod(CurentMethod: Integer; Var CurentButton: MainMenu);
Begin
    Case CurentMethod Of
        Integer(FuncEquality):
            Begin
                CurentButton := FuncEquality;
                EqualityFuncProcces;
                ClickLoager;
            End;
        Integer(FuncMeaning):
            Begin
                CurentButton := FuncMeaning;
                MeaningFuncProcess;
                ClickLoager;
            End;
        Integer(ProcAdd):
            Begin
                CurentButton := ProcAdd;
                AddProcProcess;
                ClickLoager;
            End;
    Else
        CurentButton := ExitButton;
    End;
End;

Var
    CurentNumOfRow: Integer;
    CurentButton: MainMenu;

    //AiSD Lab 1
Begin
    Repeat
        Write('Laboratory 1, Variant 1.', #13#10, #13#10, Integer(FuncEquality), ' - Function Equality;', #13#10, Integer(FuncMeaning),
            ' - Function Meaning;', #13#10, Integer(ProcAdd), ' - Procedure Add;', #13#10, Integer(ExitButton), ' - Exit;');
        CurentNumOfRow := InputNum(#13#10'Choose your varient of work: ', 1, 4);
        WorkWithMethod(CurentNumOfRow, CurentButton);
    Until CurentButton = ExitButton;
    ClickLoager;

End.
