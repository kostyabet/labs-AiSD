Program Lab1;

{$APPTYPE CONSOLE}
{$R *.res}

Uses
    System.SysUtils;

Type
    Pt = ^Elem; { * Pointer on first element of list * }

    Elem = Record
        Degree: Integer; { * Degree of x in qurent position* }
        Data: Integer; { * Qurent free point * }
        Next: Pt; { * Next point adress * }
    End;

Function Make(X: Pt; Size: Integer): Elem;
Var
    I, Temp: Integer;
Begin
    For I := Size DownTo 1 Do
    Begin
        Write('Write your a' + IntToStr(I) + ': ');
        Readln(Temp);
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

Procedure Print(X: Pt);
Begin
    While X <> Nil Do
    Begin
        If X^.Data > 0 Then
        Begin
            Write('+');
            Write(Format('%.d', [X^.Data]));
        End
        Else
            Write(Format('(%.d)', [X^.Data]));

        Write('*x^', X^.Degree);
        X := X^.Next;
    End;
    Write(#13#10);
End;

Function InputNum(Prompt: String): Integer;
Var
    N: Integer;
Begin
    Write(Prompt);
    Read(N);

    InputNum := N;
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

Function Meaning(P: Pt; X: Integer): Integer;
Var
    Res, InterimRes: Integer;
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
        End;

        If (P^.Degree < Q^.Degree) Then
        Begin
            R^.Degree := Q^.Degree;
            R^.Data := Q^.Data;
            Q := Q^.Next;
        End;

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

Var
    P1, P2, P3: Pt; { * Pointer on first element of list * }
    Size: Integer; { * Number of elements * }
    X, P1Result, P2Result: Integer;

    //AiSD Lab 1
Begin
    Writeln('Laboratory 1, Variant 1:');

    Size := InputNum(#13#10'Input number of P1 elements: ');
    New(P1);
    Writeln('Input P1.');
    Make(P1, Size);

    Size := InputNum(#13#10'Input number of P2 elements: ');
    New(P2);
    Writeln('Input P2.');
    Make(P2, Size);

    Write(#13#10'P1: ');
    Print(P1^.Next);

    Write(#13#10'P2: ');
    Print(P2^.Next);

    Writeln('Equality of P1 And P2: ', Equality(P1^.Next, P2^.Next));

    X := InputNum(#13#10'Input X-Pointer for P1: ');
    P1Result := Meaning(P1^.Next, X);
    Writeln('At X=', X, ' the result is: ', P1Result);

    X := InputNum(#13#10'Input X-Pointer for P1: ');
    P2Result := Meaning(P2^.Next, X);
    Writeln('At X=', X, ' the result is: ', P2Result);

    New(P3);
    Add(P1^.Next, P2^.Next, P3);
    Write(#13#10'P1 + P2: ');
    Print(P3^.Next);
    Readln;
    Readln;

End.
