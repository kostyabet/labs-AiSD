(*
  Copyright 2024 divmone & invertedfool
  This file is part of aisd_hash.

  aisd_hash is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  aisd_hash is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with aisd_hash. If not, see <https://www.gnu.org/licenses/>
*)
Program Lab2;

{$APPTYPE CONSOLE}
{$R *.res}

Uses
    System.SysUtils,
    System.Classes;

Type
    PTerm = ^TTerm;

    PTermNode = ^TTermNode;

    ArrInteger = Array Of Integer;

    TTerm = Record
        Name: String;
        PageNumber: Integer;
        SubTerms: PTermNode;
        PageArray: ArrInteger;
        Hash: UInt64;
    End;

    TTermNode = Record
        Data: TTerm;
        Next: PTermNode;
    End;

Function Check(Hash: UInt64; Var Index: PTermNode): Boolean;
Var
    Current: PTermNode;
Begin
    Current := Index;
    Result := True;
    While Current <> Nil Do
    Begin
        If Current.Data.Hash = Hash Then
            Result := False;
        Current := Current^.Next;
    End;
End;

Function SimpleHash(Const Str: String): UInt64;
Var
    N, I, K: UInt64;
Begin
    K := 1;
    N := 0;
    For I := Low(Str) To High(Str) Do
    Begin
        N := N + Ord(Str[I]) * K;
        K := K Mod 40;
    End;

    SimpleHash := N;
End;

Function InputNumber: Integer;
Var
    N: Integer;
    IsCorrect: Boolean;
Begin
    Repeat
        IsCorrect := True;
        Try
            Readln(N);
        Except
            Writeln('Error!');
            IsCorrect := False
        End;

    Until IsCorrect;

    InputNumber := N;
End;

Function FindTermByHash(Const Index: PTermNode; Const Hash: Cardinal): PTermNode;
Var
    Current: PTermNode;
Begin
    Result := Nil;
    Current := Index;
    While Current <> Nil Do
    Begin
        If Current^.Data.Hash = Hash Then
        Begin
            Result := Current;
            Exit;
        End;
        Current := Current^.Next;
    End;
    Result := Nil;
End;

Function FindSubTermByHash(Const Index: PTermNode; Const Hash: Cardinal): PTermNode;
Var
    Current: PTermNode;
    I: Integer;
Begin
    Result := Nil;
    Current := Index;
    While Current <> Nil Do
    Begin
        While Current.Data.SubTerms <> Nil Do
        Begin
            If SimpleHash(Current^.Data.Name) = Hash Then
            Begin
                Writeln('subterm - ', Current^.Data.Name, 'page number');
                For I := Low(Current^.Data.PageArray) To High(Current^.Data.PageArray) Do
                    Write(Current^.Data.PageArray[I], '  ');
            End;
            Current.Data.SubTerms := Current^.Data.SubTerms.Next;
        End;
        Current := Current^.Next;
    End;
End;

Procedure AddSubTermToList(Var Head: PTermNode; Const Name: String; PageArr: ArrInteger);
Var
    NewNode, LastNode: PTermNode;
Begin
    New(NewNode);
    NewNode^.Data.Name := Name;
    NewNode^.Data.PageArray := PageArr;
    NewNode^.Data.Hash := SimpleHash(Name);
    NewNode^.Next := Nil;

    If Head = Nil Then
        Head := NewNode
    Else
    Begin
        LastNode := Head;
        While LastNode^.Next <> Nil Do
            LastNode := LastNode^.Next;
        LastNode^.Next := NewNode;
    End;
    NewNode.Data.SubTerms := Nil;
End;

Procedure AddSubTermToTermByName(Var Index: PTermNode);
Var
    TermName, SubTermName: String;
    TermNode: PTermNode;
    SubTermHead: PTermNode;
    Page: UInt64;
    PageArr: ArrInteger;
Begin

    Writeln('Enter the name of the term you want to add under the term: ');
    While True Do
    Begin
        Readln(TermName);
        TermNode := FindTermByHash(Index, SimpleHash(TermName));
        If TermNode = Nil Then
            Writeln('This term does not exist')
        Else
            Break;
    End;
    Writeln('Enter the name of the subterminal you want to add: ');
    While True Do
    Begin
        Readln(SubTermName);
        If Check(SimpleHash(SubTermName), TermNode^.Data.SubTerms) = True Then
            Break
        Else
            Writeln('Such a sub-term already exists');
    End;
    Page := 87654345678;
    Write('Enter the page numbers(0 output): ');
    While Page <> 0 Do
    Begin
        If Page <> 87654345678 Then
            Write('                                 ');
        Page := InputNUmber;
        If Page = 0 Then
            Break;
        SetLength(PageArr, Length(PageArr) + 1);
        PageArr[Length(PageArr) - 1] := Page;
    End;
    If TermNode <> Nil Then
    Begin
        SubTermHead := TermNode^.Data.SubTerms;
        AddSubTermToList(SubTermHead, SubTermName, PageArr);
        TermNode^.Data.SubTerms := SubTermHead;
    End
    Else
        Writeln('Term "', TermName, '" not found in the subject index.');
End;

Function InputName: String;
Var
    IsCorrect: Boolean;
    Str: String;
Begin
    Repeat
        IsCorrect := True;
        Readln(Str);
        If Length(Str) > 10 Then
        Begin
            IsCorrect := False;
            Writeln('The length of the term name should not exceed 10 characters repeat the input!');
        End;

    Until IsCorrect;

    InputName := Str;

End;

Procedure AddTerm(Var Index: PTermNode);
Var
    NewNode: PTermNode;
    Name: String;
    Page: UInt64;
    NameHash: UInt64;
Begin
    New(NewNode);
    Write('Enter the name of the term: ');
    While True Do
    Begin
        Name := InputName;
        NameHash := SimpleHash(Name);
        If Check(NameHash, Index) = True Then
            Break
        Else
            Writeln('The term already exists');
    End;

    NewNode^.Data.Hash := NameHash;

    NewNode^.Data.Name := Name;
    Page := 87654345678;
    Write('Enter the page numbers(0 output): ');
    While Page <> 0 Do
    Begin
        If Page <> 87654345678 Then
            Write('                                 ');
        Page := InputNUmber;

        If Page = 0 Then
            Break;
        SetLength(NewNode^.Data.PageArray, Length(NewNode^.Data.PageArray) + 1);
        NewNode^.Data.PageArray[Length(NewNode^.Data.PageArray) - 1] := Page;
    End;
    NewNode^.Data.SubTerms := Nil;
    NewNode^.Next := Index;
    Index := NewNode;

End;

Procedure DisplayIndex(Const Index: PTermNode);
Var
    Current: PTermNode;
    SubTermCurrent: PTermNode;
    SubTermSubTermCurrent: PTermNode;
    I: Integer;
Begin
    Current := Index;
    While Current <> Nil Do
    Begin
        Write('Term: ', Current^.Data.Name, #9, '   Page numbers : ');
        For I := Low(Current^.Data.PageArray) To High(Current^.Data.PageArray) Do
            Write(Current^.Data.PageArray[I], ' ');
        Writeln;
        SubTermCurrent := Current^.Data.SubTerms;
        While SubTermCurrent <> Nil Do
        Begin
            Write('   Subterminal: ', SubTermCurrent^.Data.Name, '            ', '   Page numbers : ');
            For I := Low(SubTermCurrent^.Data.PageArray) To High(SubTermCurrent^.Data.PageArray) Do
                Write(SubTermCurrent^.Data.PageArray[I], ' ');
            Writeln;
            SubTermSubTermCurrent := SubTermCurrent.Data.SubTerms;
            While SubTermSubTermCurrent <> Nil Do
            Begin
                Write('       Subterminal: ', SubTermSubTermCurrent^.Data.Name, #9, '   Page numbers : ');
                For I := Low(SubTermSubTermCurrent^.Data.PageArray) To High(SubTermSubTermCurrent^.Data.PageArray) Do
                    Write(SubTermSubTermCurrent^.Data.PageArray[I], ' ');
                Writeln;
                SubTermSubTermCurrent := SubTermSubTermCurrent^.Next;
            End;
            SubTermCurrent := SubTermCurrent^.Next;
        End;
        Current := Current^.Next;
    End;
End;

Function InputChoice(ExitSymb: String): Char;
Const
    MAX_MENU_CHOICE = '9';
    MIN_MENU_CHOICE = '1';
Var
    Ch: Char;
    IsCorrect: Boolean;
Begin
    Repeat
        Readln(Ch);
        Try
            IsCorrect := (Ch = ExitSymb) Or Not((Ch > MAX_MENU_CHOICE) Or (Ch < MIN_MENU_CHOICE));
        Except
            IsCorrect := False;
        End;
        If Not IsCorrect Then
            Writeln('Error! Input number from ', MIN_MENU_CHOICE, ' to ', MAX_MENU_CHOICE, ' or ', ExitSymb, '!');
    Until IsCorrect;
    InputChoice := Ch;
End;

Procedure AddSubTermToSubTerm(Var Index: PTermNode);
Var
    TermName, SubTermName, SubTermSubName: String;
    TermNode, SubTermNode: PTermNode;
    SubTermSubHead: PTermNode;
    PageArr: ArrInteger;
    Page: UInt64;
Begin

    Writeln('Enter the name of the term under which you want to add a subtermin: ');
    While True Do
    Begin
        Readln(TermName);
        TermNode := FindTermByHash(Index, SimpleHash(TermName));
        If TermNode = Nil Then
            Writeln('This term does not exist')
        Else
            Break;
    End;

    Writeln('Enter the name of the subtermin to which you want to add the subtermin: ');
    While True Do
    Begin
        Readln(SubTermName);
        SubTermNode := FindTermByHash(TermNode^.Data.SubTerms, SimpleHash(SubTermName));
        If SubTermNode = Nil Then
            Writeln('This subterminal does not exist')
        Else
            Break;
    End;

    Writeln('Enter the name of the subterminal you want to add: ');
    While True Do
    Begin
        Readln(SubTermSubName);
        If Check(SimpleHash(SubTermSubName), SubTermNode^.Data.SubTerms) = True Then
            Break
        Else
            Writeln('Such a sub-term already exists');
    End;
    Page := 176543;
    Write('Enter the page numbers(0 output): ');
    While Page <> 0 Do
    Begin
        If Page <> 176543 Then
            Write('                                 ');
        Page := InputNUmber;
        If Page = 0 Then
            Break;
        SetLength(PageArr, Length(PageArr) + 1);
        PageArr[Length(PageArr) - 1] := Page;
    End;
    If SubTermNode <> Nil Then
    Begin
        SubTermSubHead := SubTermNode^.Data.SubTerms;
        AddSubTermToList(SubTermSubHead, SubTermSubName, PageArr);
        SubTermNode^.Data.SubTerms := SubTermSubHead;
    End
    Else
        Writeln('Subterminal "', SubTermSubName, '" not found in the subject index.');
End;

Procedure BubbleSort(Var Arr: Array Of Integer);
Var
    I, J, Temp: Integer;
Begin
    For I := Low(Arr) To High(Arr) - 1 Do
        For J := Low(Arr) To High(Arr) - 1 Do
            If Arr[J] > Arr[J + 1] Then
            Begin
                Temp := Arr[J];
                Arr[J] := Arr[J + 1];
                Arr[J + 1] := Temp;
            End;
End;

Procedure EditSubTerm(Var Index: PTermNode);
Var
    N, I, J, Len, NewValue: Integer;
    Str: String;
    Found: Boolean;
    NameHash: UInt64;
    TermNode, TermSubNode: PTermNode;
Begin
    Writeln('Enter the name of the term in which you want to edit the subtermin: ');
    While True Do
    Begin
        Readln(Str);
        TermNode := FindTermByHash(Index, SimpleHash(Str));
        If TermNode = Nil Then
            Writeln('This term does not exist')
        Else
            Break;
    End;

    Writeln('Enter the name of the subterminal that you want to edit: ');
    While True Do
    Begin
        Readln(Str);
        If Not Check(SimpleHash(Str), TermNode^.Data.SubTerms) Then
            Break
        Else
            Writeln('There is no such subterminal');
    End;

    TermSubNode := FindTermByHash(TermNode^.Data.SubTerms, SimpleHash(Str));

    Writeln('Select what you want to edit: 1: title; 2: page number');
    N := InputNUmber;
    Case N Of
        1:
            Begin
                Writeln('Enter a new name for the subterminal');

                While True Do
                Begin
                    Str := InputName;
                    NameHash := SimpleHash(Str);
                    If Check(NameHash, Index) = True Then
                        Break
                    Else
                        Writeln('The term already exists');
                End;

                TermSubNode^.Data.Name := Str;
                TermSubNode^.Data.Hash := SimpleHash(Str);

            End;

        2:
            Begin
                Str := 'Choose what you want to do:' + #13#10 + '-1- add a page number' + #13#10 + '-2- delete the starnitsa number' +
                    #13#10 + '-3- change the page number' + #13#10;
                Writeln(Str);
                N := InputNUmber;

                Case N Of

                    1:
                        Begin
                            For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                                Write('  ', TermSubNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('Enter the number you want to add');
                            N := InputNUmber;

                            SetLength(TermSubNode^.Data.PageArray, Length(TermSubNode^.Data.PageArray) + 1);
                            TermSubNode^.Data.PageArray[High(TermSubNode^.Data.PageArray)] := N;
                            BubbleSort(TermSubNode^.Data.PageArray);

                        End;
                    2:
                        Begin
                            For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                                Write('  ', TermSubNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('Enter the number you want to delete');
                            N := InputNUmber;;
                            Len := Length(TermSubNode^.Data.PageArray);
                            Found := False;
                            For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                            Begin
                                If TermSubNode^.Data.PageArray[I] = N Then
                                Begin
                                    Found := True;

                                    For J := I To High(TermSubNode^.Data.PageArray) - 1 Do
                                        TermSubNode^.Data.PageArray[J] := TermSubNode^.Data.PageArray[J + 1];

                                    Dec(Len);
                                    SetLength(TermSubNode^.Data.PageArray, Len);
                                    Break;
                                End;
                            End;

                            If Not Found Then
                            Begin
                                Writeln('Error: The element was not found in the array.');
                                Exit;
                            End;

                            BubbleSort(TermSubNode^.Data.PageArray);

                        End;

                    3:
                        Begin

                            For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                                Write('  ', TermSubNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('   Enter the number you want to change');
                            N := InputNUmber;

                            Found := False;
                            For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                            Begin
                                If TermSubNode^.Data.PageArray[I] = N Then
                                Begin
                                    Found := True;
                                    Break;
                                End;
                            End;

                            If Not Found Then
                            Begin
                                Writeln('Error: The element was not found in the array.');
                                Exit;
                            End;

                            If Found Then
                            Begin

                                Writeln('Enter a new value for the page number: ');
                                NewValue := InputNUmber;
                                For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                                Begin
                                    If TermSubNode^.Data.PageArray[I] = N Then
                                    Begin
                                        TermSubNode^.Data.PageArray[I] := NewValue;

                                        Break;
                                    End;
                                End;
                            End;

                            BubbleSort(TermSubNode^.Data.PageArray);

                        End;

                End;

            End;
    End;

End;

Procedure EditSubSubTerm(Var Index: PTermNode);
Var
    N: Integer;
    Str: String;
    NameHash: UInt64;
    Found: Boolean;
    Len, NewValue, I, J: Integer;
    TermNode, TermSubNode, TermSubSubNode: PTermNode;
Begin
    Writeln('Enter the name of the term in which you want to edit the subtermin in the subtermin: ');
    While True Do
    Begin
        Readln(Str);
        TermNode := FindTermByHash(Index, SimpleHash(Str));
        If TermNode = Nil Then
            Writeln('This term does not exist')
        Else
            Break;
    End;

    Writeln('Enter the name of the subtermin in which you want to edit the subtermin: ');
    While True Do
    Begin
        Readln(Str);
        TermSubNode := FindTermByHash(TermNode^.Data.SubTerms, SimpleHash(Str));
        If TermSubNode = Nil Then
            Writeln('There is no such subterminal')
        Else
            Break;
    End;

    Writeln('Enter the name of the subterminal that you want to edit:');
    While True Do
    Begin
        Readln(Str);
        If Not Check(SimpleHash(Str), TermSubNode^.Data.SubTerms) Then
            Break
        Else
            Writeln('There is no such subterminal');
    End;

    TermSubNode := FindTermByHash(TermNode^.Data.SubTerms.Data.SubTerms, SimpleHash(Str));

    Writeln('Select what you want to edit: 1: title; 2: page number ');
    N := InputNUmber;
    Case N Of
        1:
            Begin
                Writeln('Enter a new name for the subterminal');

                While True Do
                Begin
                    Str := InputName;
                    NameHash := SimpleHash(Str);
                    If Check(NameHash, Index) = True Then
                        Break
                    Else
                        Writeln('The term already exists');
                End;

                TermSubNode^.Data.Name := Str;
                TermSubNode^.Data.Hash := SimpleHash(Str);

            End;

        2:
            Begin
                Str := 'Choose what you want to do:' + #13#10 + '-1- add a page number' + #13#10 + '-2- delete the starnitsa number' +
                    #13#10 + '-3- change the page number' + #13#10;
                Writeln(Str);
                N := InputNUmber;

                Case N Of

                    1:
                        Begin
                            For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                                Write('  ', TermSubNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('Enter the number you want to add');
                            N := InputNUmber;

                            SetLength(TermSubNode^.Data.PageArray, Length(TermSubNode^.Data.PageArray) + 1);
                            TermSubNode^.Data.PageArray[High(TermSubNode^.Data.PageArray)] := N;
                            BubbleSort(TermSubNode^.Data.PageArray);

                        End;
                    2:
                        Begin
                            For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                                Write('  ', TermSubNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('Enter the number you want to delete');
                            N := InputNUmber;
                            Len := Length(TermSubNode^.Data.PageArray);
                            Found := False;
                            For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                            Begin
                                If TermSubNode^.Data.PageArray[I] = N Then
                                Begin
                                    Found := True;

                                    For J := I To High(TermSubNode^.Data.PageArray) - 1 Do
                                        TermSubNode^.Data.PageArray[J] := TermSubNode^.Data.PageArray[J + 1];

                                    Dec(Len);
                                    SetLength(TermSubNode^.Data.PageArray, Len);
                                    Break;
                                End;
                            End;

                            If Not Found Then
                            Begin
                                Writeln('Error: The element was not found in the array.');
                                Exit;
                            End;

                            BubbleSort(TermSubNode^.Data.PageArray);

                        End;

                    3:
                        Begin

                            For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                                Write('  ', TermSubNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('   Enter the number you want to change');
                            N := InputNUmber;

                            Found := False;
                            For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                            Begin
                                If TermSubNode^.Data.PageArray[I] = N Then
                                Begin
                                    Found := True;
                                    Break;
                                End;
                            End;

                            If Not Found Then
                            Begin
                                Writeln('Error: The element was not found in the array.');
                                Exit;
                            End;

                            If Found Then
                            Begin

                                Writeln('Enter a new value for the page number: ');
                                NewValue := InputNUmber;
                                For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                                Begin
                                    If TermSubNode^.Data.PageArray[I] = N Then
                                    Begin
                                        TermSubNode^.Data.PageArray[I] := NewValue;

                                        Break;
                                    End;
                                End;
                            End;

                            BubbleSort(TermSubNode^.Data.PageArray);

                        End;

                End;

            End;
    End;

End;

Procedure EditTerm(Var Index: PTermNode);
Var
    N: Integer;
    Str: String;
    NameHash: UInt64;
    TermNode: PTermNode;
    I, J, Len, NewValue: Integer;
    Found: Boolean;
Begin
    Writeln('Select the term you want to edit: ');

    While True Do
    Begin
        Str := InputName;
        NameHash := SimpleHash(Str);
        If Not Check(NameHash, Index) Then
            Break
        Else
            Writeln('There is no such term.');
    End;

    TermNode := FindTermByHash(Index, SimpleHash(Str));

    Writeln('Select what you want to edit: 1: title; 2: page number ');
    N := InputNUmber;
    Case N Of
        1:
            Begin
                Writeln('Enter a new name for the term');

                While True Do
                Begin
                    Str := InputName;
                    NameHash := SimpleHash(Str);
                    If Check(NameHash, Index) = True Then
                        Break
                    Else
                        Writeln('The term already exists');
                End;
                TermNode^.Data.Name := Str;
                TermNode^.Data.Hash := SimpleHash(Str);

            End;

        2:
            Begin
                Str := 'Choose what you want to do:' + #13#10 + '-1- add a page number' + #13#10 + '-2- delete the starnitsa number' +
                    #13#10 + '-3- change the page number' + #13#10;
                Writeln(Str);
                N := InputNUmber;

                Case N Of

                    1:
                        Begin
                            For I := Low(TermNode^.Data.PageArray) To High(TermNode^.Data.PageArray) Do
                                Write('  ', TermNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('Enter the number you want to add');
                            N := InputNUmber;

                            SetLength(TermNode^.Data.PageArray, Length(TermNode^.Data.PageArray) + 1);
                            TermNode^.Data.PageArray[High(TermNode^.Data.PageArray)] := N;
                            BubbleSort(TermNode^.Data.PageArray);

                        End;
                    2:
                        Begin
                            For I := Low(TermNode^.Data.PageArray) To High(TermNode^.Data.PageArray) Do
                                Write('  ', TermNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('Enter the number you want to delete');
                            N := InputNUmber;
                            Len := Length(TermNode^.Data.PageArray);
                            Found := False;
                            For I := Low(TermNode^.Data.PageArray) To High(TermNode^.Data.PageArray) Do
                            Begin
                                If TermNode^.Data.PageArray[I] = N Then
                                Begin
                                    Found := True;

                                    For J := I To High(TermNode^.Data.PageArray) - 1 Do
                                        TermNode^.Data.PageArray[J] := TermNode^.Data.PageArray[J + 1];

                                    Dec(Len);
                                    SetLength(TermNode^.Data.PageArray, Len);
                                    Break;
                                End;
                            End;

                            If Not Found Then
                            Begin
                                Writeln('Error: The element was not found in the array.');
                                Exit;
                            End;

                            BubbleSort(TermNode^.Data.PageArray);

                        End;

                    3:
                        Begin

                            For I := Low(TermNode^.Data.PageArray) To High(TermNode^.Data.PageArray) Do
                                Write('  ', TermNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('   Enter the number you want to change');
                            N := InputNUmber;

                            Found := False;
                            For I := Low(TermNode^.Data.PageArray) To High(TermNode^.Data.PageArray) Do
                            Begin
                                If TermNode^.Data.PageArray[I] = N Then
                                Begin
                                    Found := True;
                                    Break;
                                End;
                            End;

                            If Not Found Then
                            Begin
                                Writeln('Error: The element was not found in the array.');
                                Exit;
                            End;

                            If Found Then
                            Begin

                                Writeln('Enter a new value for the page number: ');
                                NewValue := InputNUmber;
                                For I := Low(TermNode^.Data.PageArray) To High(TermNode^.Data.PageArray) Do
                                Begin
                                    If TermNode^.Data.PageArray[I] = N Then
                                    Begin
                                        TermNode^.Data.PageArray[I] := NewValue;

                                        Break;
                                    End;
                                End;
                            End;

                            BubbleSort(TermNode^.Data.PageArray);

                        End;

                End;

            End;
    End;

End;

Procedure Edit(Var Index: PTermNode);
Var
    Str: String;
    Choice: Integer;
Begin
    Str := 'Select what you want to edit:' + #13#10 + '- 1 - term' + #13#10 + '- 2 - subterminal' + #13#10 +
        '- 3 - subterminal subterminal' + #13#10;
    Writeln(Str);
    Choice := InputNUmber;
    Case Choice Of
        1:
            EditTerm(Index);
        2:
            EditSubTerm(Index);
        3:
            EditSubSubTerm(Index);

    End;

End;

Function TryToCompare(S1: String; S2: String): Boolean;
Var
    I: Integer;
    Size: Integer;
Begin
    If Length(S1) > Length(S2) Then
        Size := Length(S2)
    Else
        Size := Length(S1);

    For I := 1 To Size Do
        If S1[I] > S2[I] Then
        Begin
            Result := True;
            Exit
        End
        Else
            If S1[I] < S2[I] Then
            Begin
                Result := False;
                Exit;
            End;
    If Length(S1) > Length(S2) Then
    Begin
        Result := True;
        Exit;
    End
    Else
    Begin
        Result := False;
        Exit;
    End;
End;

Procedure SortTerm(Var Index: PTermNode);
Var
    ArrayOfStrings: Array [1 .. 10000] Of String;
    ArrayOfNumbers: Array [1 .. 10000] Of Integer;
    ArrayOfHash: Array [1 .. 10000] Of UInt64;
    ArrayOfPages: Array [1 .. 10000] Of Integer;
    ArrayOfPt: Array [1 .. 10000] Of PTermNode;
    ArrayOfNum: Array [1 .. 10000] Of ArrInteger;
    Temp1: String;
    Temp2: Integer;
    Current1, Current2: PTermNode;
    I, J, Count: Integer;
    IsNotSorted: Boolean;
Begin
    Current1 := Index;
    Current2 := Index;
    Count := 1;
    I := 1;
    J := 1;
    While Current1 <> Nil Do
    Begin
        ArrayOfNumbers[Count] := Count;
        ArrayOfStrings[Count] := Current1.Data.Name;
        ArrayOfPages[Count] := Current1.Data.PageNumber;
        ArrayOfHash[Count] := Current1.Data.Hash;
        ArrayOfPt[Count] := Current1.Data.SubTerms;
        ArrayOfNum[Count] := Current1.Data.PageArray;
        Inc(Count);
        Current1 := Current1.Next;
    End;
    IsNotSorted := True;
    While (IsNotSorted) Do
    Begin
        IsNotSorted := False;
        For I := 1 To Count - 2 Do
            For J := I + 1 To Count - 1 Do
                If TryToCompare(ArrayOfStrings[I], ArrayOfStrings[J]) Then
                Begin
                    IsNotSorted := True;
                    Temp1 := ArrayOfStrings[I];
                    ArrayOfStrings[I] := ArrayOfStrings[J];
                    ArrayOfStrings[J] := Temp1;

                    Temp2 := ArrayOfNumbers[I];
                    ArrayOfNumbers[I] := ArrayOfNumbers[J];
                    ArrayOfNumbers[J] := Temp2;
                End;
    End;
    I := 1;
    While Current2 <> Nil Do
    Begin
        Current2^.Data.Name := ArrayOfStrings[I];
        Current2^.Data.Hash := ArrayOfHash[ArrayOfNumbers[I]];
        Current2^.Data.PageNumber := ArrayOfPages[ArrayOfNumbers[I]];
        Current2^.Data.SubTerms := ArrayOfPt[ArrayOfNumbers[I]];
        Current2^.Data.PageArray := ArrayOfNum[ArrayOfNumbers[I]];
        Inc(I);
        Current2 := Current2.Next;
    End;
End;

Procedure SortSubTerm(Var Index: PTermNode);
Var
    TermName: String;
    TermNode: PTermNode;
Begin

    Writeln('Enter the name of the term in which you want to sort the subtermines ');
    Readln(TermName);
    TermNode := FindTermByHash(Index, SimpleHash(TermName));
    If TermNode = Nil Then
    Begin
        Writeln('This term does not exist');
        Exit;
    End;
    SortTerm(TermNode.Data.SubTerms);

End;

Procedure SortSubSubTerm(Var Index: PTermNode);
Var
    TermName: String;
    TermNode: PTermNode;
Begin

    Writeln('Enter the name of the term in the subtermines of which you want to sort the subtermines ');
    Readln(TermName);
    TermNode := FindTermByHash(Index, SimpleHash(TermName));
    If TermNode <> Nil Then
    Begin
        Writeln('Enter the name of the subterminal in which you want to sort the subterminals ');
        Readln(TermName);
        TermNode := FindTermByHash(TermNode^.Data.SubTerms, SimpleHash(TermName));
        If TermNode <> Nil Then
        Begin
            SortTerm(TermNode.Data.SubTerms);
        End
    End
    Else
    Begin
        Writeln('This term does not exist');
        Exit;
    End;

End;

Procedure SortSomethings(Var Index: PTermNode);
Var
    Str: String;
    Choice: Integer;
Begin
    Str := 'Select what you want to sort:' + #13#10 + '- 1 - terms' + #13#10 + '- 2 - subtermines' + #13#10 +
        '- 3 - subterminal subterminal' + #13#10;
    Writeln(Str);
    Choice := InputNUmber;
    Case Choice Of
        1:
            Begin
                SortTerm(Index);
            End;
        2:
            Begin
                SortSubTerm(Index);
            End;
        3:
            Begin
                SortSubSubTerm(Index);
            End;
    End;

End;

Procedure DeleteTermNode(Var Head: PTermNode; NodeToDelete: PTermNode);
Var
    CurrNode, PrevNode: PTermNode;
Begin
    If (Head = Nil) Or (NodeToDelete = Nil) Then
        Exit;

    CurrNode := Head;
    PrevNode := Nil;

    While (CurrNode <> Nil) And (CurrNode <> NodeToDelete) Do
    Begin
        PrevNode := CurrNode;
        CurrNode := CurrNode^.Next;
    End;

    If CurrNode = NodeToDelete Then
    Begin
        If PrevNode <> Nil Then
            PrevNode^.Next := CurrNode^.Next
        Else
            Head := CurrNode^.Next;

        Dispose(CurrNode);
    End;
End;

Procedure DeleteSubTermNode(Var Head: PTermNode; NodeToDelete: PTermNode);
Var
    CurrNode, PrevNode: PTermNode;
Begin
    If (Head = Nil) Or (NodeToDelete = Nil) Then
        Exit;

    CurrNode := Head.Data.SubTerms;
    PrevNode := Nil;

    While (CurrNode <> Nil) And (CurrNode <> NodeToDelete) Do
    Begin
        PrevNode := CurrNode;
        CurrNode := CurrNode^.Next;
    End;

    If CurrNode = NodeToDelete Then
    Begin
        If PrevNode <> Nil Then
            PrevNode^.Next := CurrNode^.Next
        Else
            Head := CurrNode^.Next;

        Dispose(CurrNode);
    End;
End;

Function RemoveSubTermFromList(Var SubTerms: PTermNode; SubTermToRemove: PTermNode): PTermNode;
Var
    CurrentNode, PreviousNode, TempNode: PTermNode;
Begin
    CurrentNode := SubTerms;
    PreviousNode := Nil;

    While CurrentNode <> Nil Do
    Begin
        If CurrentNode^.Data.SubTerms = SubTermToRemove Then
        Begin
            TempNode := CurrentNode;
            CurrentNode := CurrentNode^.Next;

            If PreviousNode = Nil Then
            Begin
                SubTerms := CurrentNode;
            End
            Else
            Begin
                PreviousNode^.Next := CurrentNode;
            End;

            Dispose(TempNode);
            Break;
        End
        Else
        Begin
            PreviousNode := CurrentNode;
            CurrentNode := CurrentNode^.Next;
        End;
    End;

    Result := SubTerms;
End;

Procedure DeleteSubTerm(Var Index: PTermNode);
Var
    Str: String;
    TermNode, TermSubNode: PTermNode;
Begin
    Writeln('Enter the name of the term in which you want to delete the subtermin: ');
    While True Do
    Begin
        Readln(Str);
        TermNode := FindTermByHash(Index, SimpleHash(Str));
        If TermNode = Nil Then
            Writeln('This term does not exist')
        Else
            Break;
    End;

    Writeln('Enter the name of the subterminal that you want to delete: ');
    While True Do
    Begin
        Readln(Str);
        If Not Check(SimpleHash(Str), TermNode^.Data.SubTerms) Then
            Break
        Else
            Writeln('There is no such subterminal');
    End;

    TermSubNode := FindTermByHash(TermNode^.Data.SubTerms, SimpleHash(Str));

    DeleteTermNode(TermNode^.Data.SubTerms, TermSubNode);

End;

Procedure DeleteSubSubTerm(Var Index: PTermNode);
Var
    Str: String;
    TermNode, TermSubNode: PTermNode;
Begin
    Writeln('Enter the name of the term in which you want to delete the subtermin in the subtermin: ');
    While True Do
    Begin
        Readln(Str);
        TermNode := FindTermByHash(Index, SimpleHash(Str));
        If TermNode = Nil Then
            Writeln('This term does not exist')
        Else
            Break;
    End;

    Writeln('Enter the name of the subtermin in which you want to delete the subtermin: ');
    While True Do
    Begin
        Readln(Str);
        TermSubNode := FindTermByHash(TermNode^.Data.SubTerms, SimpleHash(Str));
        If TermSubNode = Nil Then
            Writeln('There is no such subterminal')
        Else
            Break;
    End;

    Writeln('Enter the name of the subterminal that you want to delete: ');
    While True Do
    Begin
        Readln(Str);
        If Not Check(SimpleHash(Str), TermSubNode^.Data.SubTerms) Then
            Break
        Else
            Writeln('There is no such subterminal');
    End;

    TermSubNode := FindTermByHash(TermNode^.Data.SubTerms.Data.SubTerms, SimpleHash(Str));

    DeleteTermNode(TermNode^.Data.SubTerms.Data.SubTerms, TermSubNode);

End;

Procedure DeleteTerm(Var Index: PTermNode);
Var
    Str: String;
    NameHash: UInt64;
    TermNode: PTermNode;
Begin
    Writeln('Select the term you want to delete: ');

    While True Do
    Begin
        Str := InputName;
        NameHash := SimpleHash(Str);
        If Not Check(NameHash, Index) Then
            Break
        Else
            Writeln('There is no such term.');
    End;

    TermNode := FindTermByHash(Index, SimpleHash(Str));

    DeleteTermNode(Index, TermNode);

End;

Procedure DeleteEl(Var Index: PTermNode);
Var
    Str: String;
    Choice: Integer;
Begin
    Str := 'Select what you want to delete:' + #13#10 + '- 1 - term' + #13#10 + '- 2 - subterminal' + #13#10 +
        '- 3 - under the term subterminal' + #13#10;
    Writeln(Str);
    Choice := InputNUmber;
    Case Choice Of
        1:
            DeleteTerm(Index);
        2:
            DeleteSubTerm(Index);
        3:
            DeleteSubSubTerm(Index);

    End;

End;

Procedure FindForTermBySubTerm(Var Index: PTermNode);
Var
    Str2: String;
    NameHash2: UInt64;
    Curr: PTermNode;
    I: Integer;
Begin

    Writeln('Type under the term by which you want to find the term: ');
    Readln(Str2);
    NameHash2 := SimpleHash(Str2);
    Curr := Index;
    If Curr <> Nil Then
        While Curr <> Nil Do
        Begin
            If FindTermByHash(Curr^.Data.SubTerms, NameHash2) <> Nil Then
            Begin
                Write('Term: ', Curr^.Data.Name, #9, '   Page number : ');
                For I := Low(Curr^.Data.PageArray) To High(Curr^.Data.PageArray) Do
                    Write(Curr^.Data.PageArray[I], ' ');
                Writeln;
            End;
            Curr := Curr^.Next;
        End
    Else
    Begin
        Writeln('The term was not found under!');
        Exit;
    End;

    Writeln('--------------------------------------------------');

End;

Procedure FindForSubtermByTerm(Var Index: PTermNode);
Var
    Str1: String;
    NameHash1: UInt64;
    TempNode1, TempNode2: PTermNode;
    I: Integer;
Begin
    Writeln('Enter the term by which you want to find the subtermines: ');
    Readln(Str1);
    NameHash1 := SimpleHash(Str1);

    TempNode1 := FindTermByHash(Index, NameHash1);

    If TempNode1 <> Nil Then
    Begin
        Write('Term: ', TempNode1^.Data.Name, #9, '   Page number : ');
        For I := Low(TempNode1^.Data.PageArray) To High(TempNode1^.Data.PageArray) Do
            Write(TempNode1^.Data.PageArray[I], ' ');
        Writeln;
        TempNode2 := TempNode1^.Data.SubTerms;
        While TempNode2 <> Nil Do
        Begin

            Begin
                Write('    subterminal: ', TempNode2^.Data.Name, #9, '   Page Number : ');
                For I := Low(TempNode2^.Data.PageArray) To High(TempNode2^.Data.PageArray) Do
                    Write(TempNode2^.Data.PageArray[I], ' ');
            End;
            Writeln;

            TempNode2 := TempNode2.Next;
        End;

    End
    Else
    Begin
        Writeln('The term was not found under!');

    End;

    Writeln('--------------------------------------------------');

End;

Procedure SortByNumbers(Var Index: PTermNode);
Var
    ArrayOfStrings: Array[1..10000] Of String;
    ArrayOfNumbers: Array[1..10000] Of Integer;
    ArrayOfHash: Array[1..10000] Of UInt64;
    ArrayOfPages: Array[1..10000] Of Integer;
    ArrayOfPt: Array[1..10000] Of PTermNode;
    ArrayOfNum: Array[1..10000] Of ArrInteger;
    Temp1: String;
    Temp2: Integer;
    Temp3: UInt64;
    Current1, Current2: PTermNode;
    I, J, Count: Integer;
Begin
    Current1 := Index;
    Current2 := Index;
    Count := 1;
    I := 1;
    J := 1;
    While Current1 <> nil Do
    Begin
        ArrayOfNumbers[Count] := Count;
        ArrayOfStrings[Count] := Current1.Data.Name;
        ArrayOfPages[Count] := Current1.Data.PageNumber;
        ArrayOfHash[Count] := Current1.Data.Hash;
        ArrayOfPt[Count] := Current1.Data.SubTerms;
        ArrayOfNum[Count] := Current1.Data.PageArray;
        Inc(Count);
        Current1 := Current1.Next;
    End;
    For I := 1 To Count - 2 Do
        For J := I + 1 To Count - 1 Do
            If ArrayOfNum[I][0] > ArrayOfNum[J][0] Then
            Begin
                Temp2 := ArrayOfNumbers[I];
                ArrayOfNumbers[I] := ArrayOfNumbers[J];
                ArrayOfNumbers[J] := Temp2;
            End;
    I := 1;
    While Current2 <> nil Do
    Begin
        Current2^.Data.Name := ArrayOfStrings[ArrayOfNumbers[I]];
        Current2^.Data.Hash := ArrayOfHash[ArrayOfNumbers[I]];
        Current2^.Data.PageNumber := ArrayOfPages[ArrayOfNumbers[I]];
        Current2^.Data.SubTerms := ArrayOfPt[ArrayOfNumbers[I]];
        Current2^.Data.PageArray := ArrayOfNum[ArrayOfNumbers[I]];
        Inc(I);
        Current2 := Current2.Next;
    End;
End;

Var
    Choice: Char;
    Index: PTermNode;
    ExitSymb: String;

Begin
    ExitSymb := 'Q';
    WriteLn('Made by Kostya Betenya, gr. 351005.');
    //WriteLn('Copyrigth 2024 divmone & invertedfool '#13#10);
    Repeat
        WriteLn('Menu:', #13#10'1. Add a term;', #13#10'2. Add a subterminal;', #13#10'3. Add a subtermin for a subtermin;',
            #13#10'4. Sort by numbers;', #13#10'5. Alphabetically sorted;', #13#10'6. Search for a subterminal by term;',
            #13#10'7. Search for a term by subterminal;', #13#10'8. Editing;', #13#10'9. Removal. '#13#10, #13#10'', ExitSymb, '. Exit.',
            #13#10'Select an action: '#13#10);
        Choice := InputChoice(ExitSymb);
        Case Choice Of
            '1':
                AddTerm(Index);
            '2':
                AddSubTermToTermByName(Index);
            '3':
                AddSubTermToSubTerm(Index);
            '4':
                SortByNumbers(Index);
            '5':
                SortSomethings(Index);
            '6':
                FindForSubtermByTerm(Index);
            '7':
                FindForTermBySubTerm(Index);
            '8':
                Edit(Index);
            '9':
                DeleteEl(Index);
        End;
        DisplayIndex(Index);
    Until Choice = ExitSymb;

End.
