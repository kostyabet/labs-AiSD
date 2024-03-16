Program lab1_4;

{$APPTYPE CONSOLE}
{$R *.res}

Uses
    SysUtils,
    Windows;

Type
    TString = String[30];

    DoubLinkPt = ^DoubLinkElem;

    DoubLinkElem = Record
        Data: Record
            Abonent, Number: TString;
        End;

        Next: DoubLinkPt;
        Prev: DoubLinkPt;
    End;

    SingLinkPt = ^SingLinkElem;

    SingLinkElem = Record
        Data: Record
            Abonent, Number: TString;
        End;

        Next: SingLinkPt;
    End;

Const
    MAX_SIZE: Integer = 1_000_000_000;
    MIN_SIZE: Integer = 1;
    ABONENT: Integer = 7;
    SERVICE: Integer = 3;

Var
    Counter: Integer = 0;

Function InputNumber(Const MAX, MIN: Integer): Integer;
Var
    IsCorrect: Boolean;
    Num: Integer;
Begin
    Repeat
        IsCorrect := True;
        Try
            Readln(Num);

            If ((Num > MAX) Or (Num < MIN)) Then
                Raise Exception.Create('Number out of range!');
        Except
            IsCorrect := False;
            Write('Error! Try again:  ');
        End;
    Until IsCorrect;
    InputNumber := Num;
End;

Procedure ConsditionOutput();
Var
    Res: String;
Begin
    Res := 'Lab 1.4 351005 Betenya K. S.' + #13#10'This program builds a bidirectional unordered list of phone numbers.' +
        #13#10'View the list from right to left and build an ordered unidirectional list' +
        #13#10'not including the phone numbers of the special services.'#13#10;
    Writeln(Res);
End;

Function PhoneNumInput(): Integer;
Var
    IsCorrect: Boolean;
    PhoneNum: Integer;
Begin
    PhoneNum := 0;
    Repeat
        IsCorrect := True;
        Try
            Readln(PhoneNum);

            If (Length(IntToStr(PhoneNum)) <> SERVICE) And (Length(IntToStr(PhoneNum)) <> ABONENT) Then
                Raise Exception.Create('Number out of range!');
        Except
            IsCorrect := False;
            Write('Error! Try again: ');
        End;

    Until IsCorrect;

    PhoneNumInput := PhoneNum;
End;

Procedure InputDoubleLinkedList(Var Head, DLTail: DoubLinkPt);
Var
    TempPt: DoubLinkPt;
    I, Size: Integer;
Begin
    Write('Enter the number of phone numbers: ');
    Size := InputNumber(MAX_SIZE, MIN_SIZE);

    New(TempPt);
    Head := TempPt;
    TempPt^.Prev := Nil;
    For I := 1 To Size Do
    Begin
        DLTail := TempPt;
        Write('Input phone number: ');
        DLTail^.Data.Number := IntToStr(PhoneNumInput());

        If I <> Size Then
        Begin
            New(TempPt);
            DLTail^.Next := TempPt;
            TempPt^.Prev := DLTail;
        End
        Else
            DLTail^.Next := Nil;
    End;
End;

Procedure DefaultOutput(Head: DoubLinkPt);
Begin
    Writeln(#13#10'Default phone numbers: ');
    While Head <> Nil Do
    Begin
        Writeln(' ', Head^.Data.Abonent, ' ', Head^.Data.Number);
        Head := Head^.Next;
    End;
End;

Procedure OutputFromRightToLeft(Tail: DoubLinkPt);
Begin
    Writeln(#13#10'From righ to left phone numbers: ');
    While Tail <> Nil Do
    Begin
        Writeln(' ', Tail^.Data.Abonent, ' ', Tail^.Data.Number);
        Tail := Tail^.Prev;
    End;
End;

Procedure CreateSingleLinkedList(Var DLHead: DoubLinkPt; Var SLHead: SingLinkPt; Var SLTail: SingLinkPt);
Begin
    New(SLHead);
    SLTail := SLHead;
    While DLHead <> Nil Do
    Begin
        If Length(DLHead^.Data.Number) = ABONENT Then
        Begin
            New(SLTail^.Next);
            SLTail := SLTail^.Next;
            SLTail^.Data.Abonent := DLHead^.Data.Abonent;
            SLTail^.Data.Number := DLHead^.Data.Number;
            Inc(Counter)
        End;
        DLHead := DLHead^.Next;
    End;
    SLTail^.Next := Nil;
End;

Procedure SortSingleLinkedList(Var Tail, Head: SingLinkPt); //tail, head
Var
    I, J: Integer;
    BufData: SingLinkElem;
Begin
    For J := 1 To Counter Do
    Begin
        Tail := Head;
        For I := 1 To Counter - J + 1 Do
        Begin
            If Tail^.Data.Number > Tail^.Next^.Data.Number Then
            Begin
                BufData := Tail^;
                Tail^.Data := Tail^.Next^.Data;
                Tail^.Next^.Data := BufData.Data;
            End;
            Tail := Tail^.Next;
        End;
    End;
End;

Procedure OutputSingleLinekdList(Var Head: SingLinkPt);
Var
    ResStr: String;
Begin
    ResStr := #13#10'Single list of abonents numbers: ';

    If Head = Nil Then
        ResStr := ResStr + 'empty...';

    While Head <> Nil Do
    Begin
        ResStr := ResStr + #13#10' ' + Head^.Data.Abonent + ' ' + Head^.Data.Number;
        Head := Head^.Next;
    End;

    Writeln(ResStr);
End;

Var
    DLTail: DoubLinkPt;
    DLHead: DoubLinkPt;
    SLTail: SingLinkPt;
    SLHead: SingLinkPt;

Begin
    ConsditionOutput;
    InputDoubleLinkedList(DLHead, DLTail);
    DefaultOutput(DLHead);
    OutputFromRightToLeft(DLTail);
    CreateSingleLinkedList(DLHead, SLHead, SLTail);
    SortSingleLinkedList(SLTail, SLHead);
    OutputSingleLinekdList(SLHead^.Next);
    Writeln(#13#10'Press any key for continue...');
    Readln;

End.
