Program Lab1_3;

Uses
    Sysutils;

Type
    TMainMenu = (ExitButton, FByNumb, FByName);

    PAbonent = ^TAbonent;

    TAbonent = Record
        FullName: String;
        PhoneNumber: String;
        Next: PAbonent;
    End;

Var
    Head: PAbonent;

Procedure PrintTable();
Begin
    Writeln('------------------------');
    Writeln;
    Writeln(IntToStr(Integer(FByNumb)) + '         Find by number');
    Writeln(IntToStr(Integer(FByName)) + '         Find by name');
    Writeln(IntToStr(Integer(ExitButton)) + '         Exit');
    Writeln;
    Writeln('------------------------');
    Write('Choose function: ');
End;

Procedure AddAbonentToList(Var Head: PAbonent; FullName, PhoneNumber: String);
Var
    NewAbonent, CurrentAbonent, PrevAbonent: PAbonent;
Begin
    New(NewAbonent);
    NewAbonent^.FullName := FullName;
    NewAbonent^.PhoneNumber := PhoneNumber;
    NewAbonent^.Next := Nil;

    If Head = Nil Then
    Begin
        Head := NewAbonent;
    End
    Else
    Begin
        CurrentAbonent := Head;
        PrevAbonent := Nil;
        While (CurrentAbonent <> Nil) And (CompareText(CurrentAbonent^.FullName, FullName) < 0) Do
        Begin
            PrevAbonent := CurrentAbonent;
            CurrentAbonent := CurrentAbonent^.Next;
        End;

        If PrevAbonent = Nil Then
        Begin
            NewAbonent^.Next := Head;
            Head := NewAbonent;
        End
        Else
        Begin
            PrevAbonent^.Next := NewAbonent;
            NewAbonent^.Next := CurrentAbonent;
        End;
    End;
End;

Procedure FindAbonentByPhoneNumber(Head: PAbonent; PhoneNumber: String);
Var
    CurrentAbonent: PAbonent;
    IsFind: Boolean;
Begin
    IsFind := False;
    CurrentAbonent := Head;
    While CurrentAbonent <> Nil Do
    Begin
        If CurrentAbonent^.PhoneNumber = PhoneNumber Then
        Begin
            Writeln('Name of the subscriber with the phone number ', PhoneNumber, ' : ', CurrentAbonent^.FullName);
            IsFind := True;
        End;
        CurrentAbonent := CurrentAbonent^.Next;
    End;

    If Not IsFind Then
        Writeln('A subscriber with a phone number ', PhoneNumber, ' doesn''t find.');
End;

Procedure FindPhoneNumbersByLastName(Head: PAbonent; LastName: String);
Var
    CurrentAbonent: PAbonent;
    IsFind: Boolean;
Begin
    IsFind := False;
    CurrentAbonent := Head;
    While CurrentAbonent <> Nil Do
    Begin
        If LastName = CurrentAbonent^.FullName Then
        Begin
            Writeln('Subscribers phone number ', CurrentAbonent^.FullName, ' : ', CurrentAbonent^.PhoneNumber);
            IsFind := True;
        End;
        CurrentAbonent := CurrentAbonent^.Next;
    End;

    If Not IsFind Then
        Writeln('A subscriber with last name ', LastName, ' doesn''t find.');
End;

Function ReadCase(): TMainMenu;
Var
    Num: Integer;
    IsCorrect: Boolean;
Begin
    Num := 0;
    IsCorrect := False;
    Repeat
        Try
            Readln(Num);

            If (Num < Integer(ExitButton)) Or (Num > Integer(FByName)) Then
                Raise Exception.Create('Number out of range!');

            IsCorrect := True;
        Except
            Write('Error. Try again: ');
        End;
    Until IsCorrect;

    Case Num Of
        Integer(FByName):
            ReadCase := FByName;
        Integer(FByNumb):
            ReadCase := FByNumb;
    Else
        ReadCase := Exitbutton;
    End;
End;

Const
    ExitKey: String = 'end';

Var
    FullName, PhoneNumber, SearchPhoneNumber, SearchLastName: String;
    CurrentAbonent: PAbonent;
    Choose: TMainMenu;
    Prompt: String;

Begin
    Head := Nil;

    Prompt := 'Lab1.3 Betenya Kostya 351005' + #13#10 + ' "Subscriber list"' + #13#10 +
        '-----------------------------------------------------------' + #13#10;
    Write(Prompt);

    Repeat
        Write('Enter the subscribers name (or ' + ExitKey + ' to complete the input): ');
        Readln(FullName);

        If FullName <> ExitKey Then
        Begin
            Write('Enter the subscribers phone number: ');
            Readln(PhoneNumber);

            AddAbonentToList(Head, FullName, PhoneNumber);
        End;
    Until FullName = ExitKey;

    Writeln(#13#10'List of subscribers: ');
    CurrentAbonent := Head;
    While CurrentAbonent <> Nil Do
    Begin
        Writeln(CurrentAbonent^.FullName, ' - ', CurrentAbonent^.PhoneNumber);
        CurrentAbonent := CurrentAbonent^.Next;
    End;

    Repeat
        PrintTable();
        Choose := ReadCase();

        If (Choose = FByNumb) Then
        Begin
            Write('Enter the phone number to search for the name: ');
            Readln(SearchPhoneNumber);
            FindAbonentByPhoneNumber(Head, SearchPhoneNumber);

        End;

        If (Choose = FByName) Then
        Begin
            Write('Enter your name to search for phone numbers: ');
            Readln(SearchLastName);
            FindPhoneNumbersByLastName(Head, SearchLastName);
        End;

    Until Choose = ExitButton;

    Write(#13#10'Press any key to continue...');
    Readln;

End.
