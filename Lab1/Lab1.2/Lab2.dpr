Program Lab2;

{$APPTYPE CONSOLE}
{$R *.res}

Uses
    System.SysUtils;

Type
    Pt = ^TListElement;

    TListElement = Record
        Data: Integer; { * Curent data * }
        Next: Pt; { * Link to the next record * }
    End;

Const
    MIN_K: Integer = 1;
    MAX_K: Integer = 64;
    MIN_N: Integer = 1;
    MAX_N: Integer = 64;

Procedure Make(N: Integer; Var F: Pt);
Var
    I: Integer;
    Temp: Pt;
Begin
    New(F);
    Temp := F;
    F^.Data := 1;
    New(F^.Next);
    F := F^.Next;
    For I := 2 To N Do
    Begin
        New(F^.Next);
        F^.Data := I;

        If (I = N) Then
            F^.Next := Temp
        Else
            F := F^.Next;
    End;
End;

Procedure OutputTable(N, K: Integer);
Var
    Count: Pt;
    Meter: Integer;
Begin
    If N = MIN_N Then
    Begin
        Writeln(' ', 1, ':', ' ', ' ', '|', 1);
        Exit;
    End;

    New(Count);
    Make(N, Count);
    Meter := 1;
    Write(N:2, ':', ' ');
    While (Count^.Next <> Count) Do
    Begin
        If (Meter = K) Then
        Begin
            Write(Count^.Next.Data, ' ');
            Count^.Next := Count^.Next^.Next;
            Meter := 0;
        End
        Else
            Count := Count^.Next;
        Inc(Meter);

    End;
    Write(' ', '|');
    Writeln(Count^.Data);
End;

Var
    I, K: Integer;
    IsCorrect: Boolean;
    Str: String;

Begin
    Str := 'Lab 1.2 Betenya Kostya 351005'#13#10 + '"A little counting"' + #13#10 +
        '--------------------------------------------------------' + #13#10 + '1. N guys are arranged in a circle;' + #13#10 +
        '2. Starting from the first one, every K-th is removed' + #13#10 + '   closing the circle at the same time;' + #13#10 +
        '3. K integer value from ' + IntToStr(MIN_K) + ' to ' + IntToStr(MAX_K) + ';' + #13#10 +
        '4. The problem is investigated for N from ' + IntToStr(MIN_N) + ' to ' + IntToStr(MAX_N) + ';' + #13#10 +
        '5. A table of the remaining guys is displayed.' + #13#10 + '--------------------------------------------------------'#13#10;
    Writeln(Str);

    K := 0;
    Write('Wrire K: ');
    Repeat
        IsCorrect := True;
        Try
            Readln(K);
        Except
            IsCorrect := False;
            Write('Error! Write number! Try again: ');
        End;

        If IsCorrect And ((K > MAX_K) Or (K < MIN_K)) Then
        Begin
            IsCorrect := False;
            Write('Error! K from 64 to 1! Try again: ');
        End;

    Until IsCorrect;

    Writeln(' --------------------------------------------------------');
    Writeln('           TABLE OF THE REMAINING GUYS                   ');
    Writeln(' --------------------------------------------------------');
    For I := MIN_N To MAX_N Do
        OutputTable(I, K);

    Writeln(#13#10, 'Press any key to continue...');
    Readln;

End.
