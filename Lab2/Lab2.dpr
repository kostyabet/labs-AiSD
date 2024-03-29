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
    PageNumber: Integer;
    HashName, Page: UInt64;
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
    Writeln('Введите название подтермина который Вы хотите добавть: ');
    While True Do
    Begin
        Readln(SubTermName);
        If Check(SimpleHash(SubTermName), TermNode^.Data.SubTerms) = True Then
            Break
        Else
            Writeln('Такой подтермин уже существует');
    End;
    Page := 87654345678;
    Write('Введите номера страниц(0 выход): ');
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
        Writeln('Термин "', TermName, '" не найден в предметном указателе.');
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
            Writeln('Длина названия термина не должна превышать 10 символов повторите ввод!');
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
    Write('Введите название термина: ');
    While True Do
    Begin
        Name := InputName;
        NameHash := SimpleHash(Name);
        If Check(NameHash, Index) = True Then
            Break
        Else
            Writeln('Термин уже существует');
    End;

    NewNode^.Data.Hash := NameHash;

    NewNode^.Data.Name := Name;
    Page := 87654345678;
    Write('Введите номера страниц(0 выход): ');
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
        Write('Термин: ', Current^.Data.Name, #9, '   Номера страниц : ');
        For I := Low(Current^.Data.PageArray) To High(Current^.Data.PageArray) Do
            Write(Current^.Data.PageArray[I], ' ');
        Writeln;
        SubTermCurrent := Current^.Data.SubTerms;
        While SubTermCurrent <> Nil Do
        Begin
            Write('   Подтермин: ', SubTermCurrent^.Data.Name, '            ', '   Номера страниц : ');
            For I := Low(SubTermCurrent^.Data.PageArray) To High(SubTermCurrent^.Data.PageArray) Do
                Write(SubTermCurrent^.Data.PageArray[I], ' ');
            Writeln;
            SubTermSubTermCurrent := SubTermCurrent.Data.SubTerms;
            While SubTermSubTermCurrent <> Nil Do
            Begin
                Write('       Подтермин: ', SubTermSubTermCurrent^.Data.Name, #9, '   Номера страниц : ');
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
            Writeln('Error! Input number from ', MIN_MENU_CHOICE, ' до ', MAX_MENU_CHOICE, ' или ', ExitSymb, '!');
    Until IsCorrect;
    InputChoice := Ch;
End;

Procedure AddSubTermToSubTerm(Var Index: PTermNode);
Var
    TermName, SubTermName, SubTermSubName: String;
    TermNode, SubTermNode: PTermNode;
    SubTermHead, SubTermSubHead: PTermNode;
    PageNumber: Integer;
    HashName: UInt64;
    PageArr: ArrInteger;
    Page: UInt64;
Begin

    Writeln('Введите название термина в подтермин которого Вы хотите добавть подтермин: ');
    While True Do
    Begin
        Readln(TermName);
        TermNode := FindTermByHash(Index, SimpleHash(TermName));
        If TermNode = Nil Then
            Writeln('Данного термина не существует')
        Else
            Break;
    End;

    Writeln('Введите название подтермина в который Вы хотите добавить подтермин: ');
    While True Do
    Begin
        Readln(SubTermName);
        SubTermNode := FindTermByHash(TermNode^.Data.SubTerms, SimpleHash(SubTermName));
        If SubTermNode = Nil Then
            Writeln('Данного подтермина не существует')
        Else
            Break;
    End;

    Writeln('Введите название подтермина который Вы хотите добавить: ');
    While True Do
    Begin
        Readln(SubTermSubName);
        If Check(SimpleHash(SubTermSubName), SubTermNode^.Data.SubTerms) = True Then
            Break
        Else
            Writeln('Такой подтермин уже существует');
    End;
    Page := 176543;
    Write('Введите номера страниц(0 выход): ');
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
        Writeln('ПодТермин "', SubTermSubName, '" не найден в предметном указателе.');
End;

Procedure BubbleSort(Var Arr: Array Of Integer);
Var
    I, J, Temp: Integer;
Begin
    For I := Low(Arr) To High(Arr) - 1 Do
    Begin
        For J := Low(Arr) To High(Arr) - 1 Do
        Begin
            If Arr[J] > Arr[J + 1] Then
            Begin
                Temp := Arr[J];
                Arr[J] := Arr[J + 1];
                Arr[J + 1] := Temp;
            End;
        End;
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
    Writeln('Введите название термина в котором Вы хотите отредактировать подтермин: ');
    While True Do
    Begin
        Readln(Str);
        TermNode := FindTermByHash(Index, SimpleHash(Str));
        If TermNode = Nil Then
            Writeln('Данного термина не существует')
        Else
            Break;
    End;

    Writeln('Введите название подтермина который Вы хотите отредактировать: ');
    While True Do
    Begin
        Readln(Str);
        If Not Check(SimpleHash(Str), TermNode^.Data.SubTerms) Then
            Break
        Else
            Writeln('Такого подтермина не существует');
    End;

    TermSubNode := FindTermByHash(TermNode^.Data.SubTerms, SimpleHash(Str));

    Writeln('Выберите что Вы хотите отредактировать:  1: название; 2: номер страницы ');
    N := InputNUmber;
    Case N Of
        1:
            Begin
                Writeln('Введите новое название подтермина');

                While True Do
                Begin
                    Str := InputName;
                    NameHash := SimpleHash(Str);
                    If Check(NameHash, Index) = True Then
                        Break
                    Else
                        Writeln('Подтермин уже существует');
                End;

                TermSubNode^.Data.Name := Str;
                TermSubNode^.Data.Hash := SimpleHash(Str);

            End;

        2:
            Begin
                Str := 'Выберите что Вы хотите делать:' + #13#10 + '-1- добавить номер страницы' + #13#10 + '-2- удалить номер старницы' +
                    #13#10 + '-3- изменить номер страницы' + #13#10;
                Writeln(Str);
                N := InputNUmber;

                Case N Of

                    1:
                        Begin
                            For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                                Write('  ', TermSubNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('Введите номер который вы хотите добавить');
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
                            Writeln('Введите номер который вы хотите удалить');
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
                                Writeln('Ошибка: Элемент не найден в массиве.');
                                Exit;
                            End;

                            BubbleSort(TermSubNode^.Data.PageArray);

                        End;

                    3:
                        Begin

                            For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                                Write('  ', TermSubNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('   Введите номер который вы хотите изменить');
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
                                Writeln('Ошибка: Элемент не найден в массиве.');
                                Exit;
                            End;

                            If Found Then
                            Begin

                                Writeln('Введите новое значение номера страницы: ');
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
    Writeln('Введите название термина в котором Вы хотите отредактировать подтермин в подтермине: ');
    While True Do
    Begin
        Readln(Str);
        TermNode := FindTermByHash(Index, SimpleHash(Str));
        If TermNode = Nil Then
            Writeln('Данного термина не существует')
        Else
            Break;
    End;

    Writeln('Введите название подтермина в которым Вы хотите отредактировать подтермин: ');
    While True Do
    Begin
        Readln(Str);
        TermSubNode := FindTermByHash(TermNode^.Data.SubTerms, SimpleHash(Str));
        If TermSubNode = Nil Then
            Writeln('Такого подтермина не существует')
        Else
            Break;
    End;

    Writeln('Введите название подтермина который Вы хотите отредактировать: ');
    While True Do
    Begin
        Readln(Str);
        If Not Check(SimpleHash(Str), TermSubNode^.Data.SubTerms) Then
            Break
        Else
            Writeln('Такого подтермина не существует');
    End;

    TermSubNode := FindTermByHash(TermNode^.Data.SubTerms.Data.SubTerms, SimpleHash(Str));

    Writeln('Выберите что Вы хотите отредактировать:  1: название; 2: номер страницы ');
    N := InputNUmber;
    Case N Of
        1:
            Begin
                Writeln('Введите новое название подтермина');

                While True Do
                Begin
                    Str := InputName;
                    NameHash := SimpleHash(Str);
                    If Check(NameHash, Index) = True Then
                        Break
                    Else
                        Writeln('Подтермин уже существует');
                End;

                TermSubNode^.Data.Name := Str;
                TermSubNode^.Data.Hash := SimpleHash(Str);

            End;

        2:
            Begin
                Str := 'Выберите что Вы хотите делать:' + #13#10 + '-1- добавить номер страницы' + #13#10 + '-2- удалить номер старницы' +
                    #13#10 + '-3- изменить номер страницы' + #13#10;
                Writeln(Str);
                N := InputNUmber;

                Case N Of

                    1:
                        Begin
                            For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                                Write('  ', TermSubNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('Введите номер который вы хотите добавить');
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
                            Writeln('Введите номер который вы хотите удалить');
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
                                Writeln('Ошибка: Элемент не найден в массиве.');
                                Exit;
                            End;

                            BubbleSort(TermSubNode^.Data.PageArray);

                        End;

                    3:
                        Begin

                            For I := Low(TermSubNode^.Data.PageArray) To High(TermSubNode^.Data.PageArray) Do
                                Write('  ', TermSubNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('   Введите номер который вы хотите изменить');
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
                                Writeln('Ошибка: Элемент не найден в массиве.');
                                Exit;
                            End;

                            If Found Then
                            Begin

                                Writeln('Введите новое значение номера страницы: ');
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
    Writeln('Выберите термин который Вы хотите отредактировать: ');

    While True Do
    Begin
        Str := InputName;
        NameHash := SimpleHash(Str);
        If Not Check(NameHash, Index) Then
            Break
        Else
            Writeln('Такого термина не существует.');
    End;

    TermNode := FindTermByHash(Index, SimpleHash(Str));

    Writeln('Выберите что Вы хотите отредактировать:  1: название; 2: номер страницы ');
    N := InputNUmber;
    Case N Of
        1:
            Begin
                Writeln('Введите новое название термина');

                While True Do
                Begin
                    Str := InputName;
                    NameHash := SimpleHash(Str);
                    If Check(NameHash, Index) = True Then
                        Break
                    Else
                        Writeln('Термин уже существует');
                End;
                TermNode^.Data.Name := Str;
                TermNode^.Data.Hash := SimpleHash(Str);

            End;

        2:
            Begin
                Str := 'Выберите что Вы хотите делать:' + #13#10 + '-1- добавить номер страницы' + #13#10 + '-2- удалить номер старницы' +
                    #13#10 + '-3- изменить номер страницы' + #13#10;
                Writeln(Str);
                N := InputNUmber;

                Case N Of

                    1:
                        Begin
                            For I := Low(TermNode^.Data.PageArray) To High(TermNode^.Data.PageArray) Do
                                Write('  ', TermNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('Введите номер который вы хотите добавить');
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
                            Writeln('Введите номер который вы хотите удалить');
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
                                Writeln('Ошибка: Элемент не найден в массиве.');
                                Exit;
                            End;

                            BubbleSort(TermNode^.Data.PageArray);

                        End;

                    3:
                        Begin

                            For I := Low(TermNode^.Data.PageArray) To High(TermNode^.Data.PageArray) Do
                                Write('  ', TermNode^.Data.PageArray[I]);
                            Writeln;
                            Writeln('   Введите номер который вы хотите изменить');
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
                                Writeln('Ошибка: Элемент не найден в массиве.');
                                Exit;
                            End;

                            If Found Then
                            Begin

                                Writeln('Введите новое значение номера страницы: ');
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
    Str := 'Выберите что Вы хотите редактировать:' + #13#10 + '- 1 - термин' + #13#10 + '- 2 - подтермин' + #13#10 +
        '- 3 - педтермин педтермина' + #13#10;
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
    I: Integer;
Begin

    Writeln('Введите название термина в котором вы хотите отсортировать подтермины ');
    Readln(TermName);
    TermNode := FindTermByHash(Index, SimpleHash(TermName));
    If TermNode = Nil Then
    Begin
        Writeln('Данного термина не существует');
        Exit;
    End;
    SortTerm(TermNode.Data.SubTerms);

End;

Procedure SortSubSubTerm(Var Index: PTermNode);
Var
    TermName: String;
    TermNode: PTermNode;
    I: Integer;
Begin

    Writeln('Введите название термина в подтерминах которого вы хотите отсортировать подтермины ');
    Readln(TermName);
    TermNode := FindTermByHash(Index, SimpleHash(TermName));
    If TermNode <> Nil Then
    Begin
        Writeln('Введите название подтермина в котором вы хотите отсортировать подтермины ');
        Readln(TermName);
        TermNode := FindTermByHash(TermNode^.Data.SubTerms, SimpleHash(TermName));
        If TermNode <> Nil Then
        Begin
            SortTerm(TermNode.Data.SubTerms);
        End
    End
    Else
    Begin
        Writeln('Данного термина не существует');
        Exit;
    End;

End;

Procedure SortSomethings(Var Index: PTermNode);
Var
    Str: String;
    Choice: Integer;
    I: Integer;
Begin
    Str := 'Выберите что Вы хотите  отсортировать:' + #13#10 + '- 1 - термины' + #13#10 + '- 2 - подтермины' + #13#10 +
        '- 3 - подтермины подтермина' + #13#10;
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
    N: Integer;
    Str: String;
    NameHash: UInt64;
    TermNode, TermSubNode: PTermNode;
Begin
    Writeln('Введите название термина в котором Вы хотите удалить подтермин: ');
    While True Do
    Begin
        Readln(Str);
        TermNode := FindTermByHash(Index, SimpleHash(Str));
        If TermNode = Nil Then
            Writeln('Данного термина не существует')
        Else
            Break;
    End;

    Writeln('Введите название подтермина который Вы хотите удалить: ');
    While True Do
    Begin
        Readln(Str);
        If Not Check(SimpleHash(Str), TermNode^.Data.SubTerms) Then
            Break
        Else
            Writeln('Такого подтермина не существует');
    End;

    TermSubNode := FindTermByHash(TermNode^.Data.SubTerms, SimpleHash(Str));

    DeleteTermNode(TermNode^.Data.SubTerms, TermSubNode);

End;

Procedure DeleteSubSubTerm(Var Index: PTermNode);
Var
    N: Integer;
    Str: String;
    NameHash: UInt64;
    TermNode, TermSubNode, TermSubSubNode: PTermNode;
Begin
    Writeln('Введите название термина в котором Вы хотите удалить подтермин в подтермине: ');
    While True Do
    Begin
        Readln(Str);
        TermNode := FindTermByHash(Index, SimpleHash(Str));
        If TermNode = Nil Then
            Writeln('Данного термина не существует')
        Else
            Break;
    End;

    Writeln('Введите название подтермина в котором Вы хотите удалить подтермин: ');
    While True Do
    Begin
        Readln(Str);
        TermSubNode := FindTermByHash(TermNode^.Data.SubTerms, SimpleHash(Str));
        If TermSubNode = Nil Then
            Writeln('Такого подтермина не существует')
        Else
            Break;
    End;

    Writeln('Введите название подтермина который Вы хотите удалить: ');
    While True Do
    Begin
        Readln(Str);
        If Not Check(SimpleHash(Str), TermSubNode^.Data.SubTerms) Then
            Break
        Else
            Writeln('Такого подтермина не существует');
    End;

    TermSubNode := FindTermByHash(TermNode^.Data.SubTerms.Data.SubTerms, SimpleHash(Str));

    DeleteTermNode(TermNode^.Data.SubTerms.Data.SubTerms, TermSubNode);

End;

Procedure DeleteTerm(Var Index: PTermNode);
Var
    N: Integer;
    Str: String;
    NameHash: UInt64;
    TermNode: PTermNode;
Begin
    Writeln('Выберите термин который Вы хотите удалить: ');

    While True Do
    Begin
        Str := InputName;
        NameHash := SimpleHash(Str);
        If Not Check(NameHash, Index) Then
            Break
        Else
            Writeln('Такого термина не существует.');
    End;

    TermNode := FindTermByHash(Index, SimpleHash(Str));

    DeleteTermNode(Index, TermNode);

End;

Procedure DeleteEl(Var Index: PTermNode);
Var
    Str: String;
    Choice: Integer;
Begin
    Str := 'Выберите что Вы хотите удалить:' + #13#10 + '- 1 - термин' + #13#10 + '- 2 - подтермин' + #13#10 +
        '- 3 - подтермин подтермина' + #13#10;
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
    Str1, Str2: String;
    NameHash1, NameHash2: UInt64;
    TempNode1, TempNode2, Curr: PTermNode;
    I: Integer;
Begin

    Writeln('Введите подтермин по которому вы хотите найти термин: ');
    Readln(Str2);
    NameHash2 := SimpleHash(Str2);
    Curr := Index;
    If Curr <> Nil Then
        While Curr <> Nil Do
        Begin
            If FindTermByHash(Curr^.Data.SubTerms, NameHash2) <> Nil Then
            Begin
                Write('Термин: ', Curr^.Data.Name, #9, '   Номер страниц : ');
                For I := Low(Curr^.Data.PageArray) To High(Curr^.Data.PageArray) Do
                    Write(Curr^.Data.PageArray[I], ' ');
                Writeln;
            End;
            Curr := Curr^.Next;
        End
    Else
    Begin
        Writeln('Подтермин не найден!');
        Exit;
    End;

    Writeln('--------------------------------------------------');

End;

Procedure FindForSubtermByTerm(Var Index: PTermNode);
Var
    Str1, Str2: String;
    NameHash1, NameHash2: UInt64;
    TempNode1, TempNode2: PTermNode;
    I: Integer;
Begin
    Writeln('Введите термин по которому Вы хотите найти подтермины: ');
    Readln(Str1);
    NameHash1 := SimpleHash(Str1);

    TempNode1 := FindTermByHash(Index, NameHash1);

    If TempNode1 <> Nil Then
    Begin
        Write('Термин: ', TempNode1^.Data.Name, #9, '   Номер страниц : ');
        For I := Low(TempNode1^.Data.PageArray) To High(TempNode1^.Data.PageArray) Do
            Write(TempNode1^.Data.PageArray[I], ' ');
        Writeln;
        TempNode2 := TempNode1^.Data.SubTerms;
        While TempNode2 <> Nil Do
        Begin

            Begin
                Write('    подтермин: ', TempNode2^.Data.Name, #9, '   Номер страницы : ');
                For I := Low(TempNode2^.Data.PageArray) To High(TempNode2^.Data.PageArray) Do
                    Write(TempNode2^.Data.PageArray[I], ' ');
            End;
            Writeln;

            TempNode2 := TempNode2.Next;
        End;

    End
    Else
    Begin
        Writeln('Подтермин не найден!');

    End;

    Writeln('--------------------------------------------------');

End;

Procedure SortByNumber(Index: PTermNode);
Var
    MaxPage: Integer;
    Curr, CurrSub, CurrSubSub: PTermNode;
    I, J, K: Integer;
    PageArr: Array Of Array Of String;
    IsWrite: Boolean;
Begin
    //поиск максимальной страницы
    Curr := Index;
    While Curr <> Nil Do
    Begin
        For I := Low(Curr^.Data.PageArray) To High(Curr^.Data.PageArray) Do
            If MaxPage < Curr^.Data.PageArray[I] Then
                MaxPage := Curr^.Data.PageArray[I];

        CurrSub := Curr^.Data.SubTerms;
        While CurrSub <> Nil Do
        Begin
            For I := Low(CurrSub^.Data.PageArray) To High(CurrSub^.Data.PageArray) Do
                If MaxPage < CurrSub^.Data.PageArray[I] Then
                    MaxPage := CurrSubSub^.Data.PageArray[I];

            CurrSubSub := CurrSub^.Data.SubTerms;
            While CurrSubSub <> NIl Do
            Begin
                For I := Low(CurrSubSub^.Data.PageArray) To High(CurrSubSub^.Data.PageArray) Do
                    If MaxPage < CurrSubSub^.Data.PageArray[I] Then
                        MaxPage := CurrSubSub^.Data.PageArray[I];
                CurrSubSub := CurrSubSub^.Next;
            End;

            CurrSub := CurrSub^.Next;
        End;

        Curr := Curr^.Next;
    End;

    SetLength(PageArr, MaxPage, 0);

    //запись терминов в массив где индексы -- страницы, элементы -- массивы с терминами
    Curr := Index;
    While Curr <> Nil Do
    Begin
        For I := Low(Curr^.Data.PageArray) To High(Curr^.Data.PageArray) Do
        Begin
            //расширение и вставка термина
            SetLength(PageArr[Curr^.Data.PageArray[I]], Length(PageArr[Curr^.Data.PageArray[I]]) + 1);
            PageArr[Curr^.Data.PageArray[I]][Length(PageArr[Curr^.Data.PageArray[I]]) - 1] := Curr^.Data.Name;
        End;

        CurrSub := Curr^.Data.SubTerms;
        While CurrSub <> Nil Do
        Begin
            For I := Low(CurrSub^.Data.PageArray) To High(CurrSub^.Data.PageArray) Do
            Begin
                //расширение и вставка термина
                SetLength(PageArr[CurrSub^.Data.PageArray[I]], Length(PageArr[CurrSub^.Data.PageArray[I]]) + 1);
                PageArr[CurrSub^.Data.PageArray[I]][Length(PageArr[CurrSub^.Data.PageArray[I]]) - 1] := CurrSub^.Data.Name;
            End;

            CurrSubSub := CurrSub^.Data.SubTerms;
            While CurrSubSub <> NIl Do
            Begin
                For I := Low(CurrSubSub^.Data.PageArray) To High(CurrSubSub^.Data.PageArray) Do
                Begin
                    //расширение и вставка термина
                    SetLength(PageArr[CurrSubSub^.Data.PageArray[I]], Length(PageArr[CurrSubSub^.Data.PageArray[I]]) + 1);
                    PageArr[CurrSubSub^.Data.PageArray[I]][Length(PageArr[CurrSubSub^.Data.PageArray[I]]) - 1] := CurrSubSub^.Data.Name;
                End;
                CurrSubSub := CurrSubSub^.Next;
            End;

            CurrSub := CurrSub^.Next;
        End;

        Curr := Curr^.Next;
    End;

    //вывод по строкам
    For I := Low(PageArr) To High(PageArr) Do
        For J := Low(PageArr[I]) To High(PageArr[I]) Do
            If J = 0 Then
                //можно графически вывод поменять
                Writeln(IntToStr(I), ' стр. -- ', PageArr[I][J])
            Else
            Begin
                IsWrite := True;
                For K := 0 To J - 1 Do
                    If PageArr[I][J] = PageArr[I][K] Then
                        IsWrite := False;
                If IsWrite Then
                    //можно графически вывод поменять
                    Writeln(IntToStr(I), ' стр. -- ', PageArr[I][J]);
            End;

    Writeln('--------------------------------------------------');

End;

Var
    Choice: Char;
    Index: PTermNode;
    I: Integer;
    Str, ExitSymb: String;

Begin
    ExitSymb := 'Q';
    WriteLn('Made by Kostya Betenya, gr. 351005.');
    WriteLn('Copyrigth 2024 divmone & invertedfool '#13#10);
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
                SortByNumber(Index);
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
