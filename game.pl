% Move tem o formato
% Move[player, line1, column1, line2, column2]

cellValue([[L|[[C, P]|T1]]|T], Line, Column, Value) :- (L=Line -> (C=Column -> Value=P; cellValue([[L|T1]|T], Line, Column, Value)); cellValue(T, Line, Column, Value)).
cellEmpty(Board, Line, Column) :- cellValue(Board, Line, Column, Value), Value='B'.

adjacentPieces(Line1, Column1, Line2, Column2) :- Line1 =:= Line2, Column1 =:= Column2 + 2.
adjacentPieces(Line1, Column1, Line2, Column2) :- Line1 =:= Line2, Column1 =:= Column2 - 2.
adjacentPieces(Line1, Column1, Line2, Column2) :- Line1 =:= Line2 + 1, Column1 =:= Column2 + 1.
adjacentPieces(Line1, Column1, Line2, Column2) :- Line1 =:= Line2 + 1, Column1 =:= Column2 - 1.
adjacentPieces(Line1, Column1, Line2, Column2) :- Line1 =:= Line2 - 1, Column1 =:= Column2 + 1.
adjacentPieces(Line1, Column1, Line2, Column2) :- Line1 =:= Line2 - 1, Column1 =:= Column2 - 1.

cellColor(Line, _) :- Line =:= -2.
cellColor(Line, _) :- Line =:= 2.
cellColor(Line, Column) :- abs(Line) + abs(Column) =:= 4.

verifyMove(Board, Line1, Column1, [], []) :- cellEmpty(Board, Line1, Column1), \+cellColor(Line1, Column1).
verifyMove(Board, Line1, Column1, Line2, Column2) :- cellEmpty(Board, Line1, Column1), cellEmpty(Board, Line2, Column2), cellColor(Line1, Column1), Line2 =:= -Line1, Column2 =:= -Column1.
verifyMove(Board, Line1, Column1, Line2, Column2) :- cellEmpty(Board, Line1, Column1), cellEmpty(Board, Line2, Column2), \+cellColor(Line1, Column1), \+cellColor(Line2, Column2), \+adjacentPieces(Line1, Column1, Line2, Column2).

verifyCellMoves(_, [], []).
verifyCellMoves(Board, [Line1, Column1, Line2, Column2], ValidMoves):- (verifyMove(Board,Line1, Column1, Line2, Column2) -> append([], [Line1, Column1, Line2, Column2], ValidMoves);!).
verifyCellMoves(Board, [ [Line1, Column1, Line2, Column2] | T], ValidMoves):- (verifyMove(Board, Line1, Column1, Line2, Column2)-> verifyCellMoves(Board, T, AuxValidMoves), append([Line1, Column1, Line2, Column2], AuxValidMoves, ValidMoves); verifyCellMoves(Board,T, AuxValidMoves)).

generateInnerMoves([], _, _, []).
generateInnerMoves([[Line | [[Cell, _] | T1] ] | T], Line1,Column1, Moves):- (T1 = [_|_] -> generateInnerMoves([Line, T1 | T], Line1,Column1,AuxMoves); generateInnerMoves(T, Line1, Column1, AuxMoves)), append([[Line1, Column1, Line, Cell]], AuxMoves, Moves).

generateCellMoves(Board, Line1, Column1, CellMoves):- (cellColor(Line1, Column1)->Line2 is -Line1, Column2 is -Column1, append([[Line1,Column1,Line2,Column2]], [], CellMoves); generateInnerMoves(Board, Line1, Column1, CellMoves)).

generateValidMoves([], _, []).
generateValidMoves([[Line | [[Cell, Value] | T1] ] | T], Player, Moves):- generateCellMoves([[Line | [[Cell, Value] | T1] ] | T], Line, Cell, AllMoves), verifyCellMoves([[Line | [[Cell, Value] | T1] ] | T],AllMoves, CellMoves), (T1 = [_|_] -> generateValidMoves([[Line |T1] |T], Player,AuxMoves);generateValidMoves(T, Player,AuxMoves)), append(CellMoves,AuxMoves,Moves).

valid_moves(Board, Player, ListOfMoves) :- generateValidMoves(Board, Player, ListOfMoves).

changeCell(_, _, [], []).
changeCell(Player, Column, [[H|T1]|T], NewLine) :- changeCell(Player, Column, T, AuxLine), (H=Column -> append([[Column, Player]], AuxLine, NewLine); append([[H|T1]], AuxLine, NewLine)).

implement_move(_, _, _, [], []).
implement_move(Player, Line, Column, [[H|T1]|T], NewBoard) :- implement_move(Player, Line, Column, T, AuxBoard), (H=Line -> changeCell(Player, Column, T1, NewLine), append([[H|NewLine]], AuxBoard, NewBoard); append([[H|T1]], AuxBoard, NewBoard)).

implement_moves([Player,Line1,Column1,Line2,Column2], Board, NewBoard) :- implement_move(Player, Line1, Column1, Board, BoardAux), implement_move(Player, Line2, Column2, BoardAux, NewBoard).

move([Player,Line1,Column1,Line2,Column2], Board, NewBoard) :- verifyMove(Board, Line1, Column1, Line2, Column2), implement_moves([Player, Line1, Column1, Line2, Column2], Board, NewBoard).

calculateCellsPlayer([], _, _, []).
calculateCellsPlayer([[Column, Value]|T], Line, Player, PlayerCells) :- (Value==Player -> calculateCellsPlayer(T, Line, Player, PlayerCellsAux), append(PlayerCellsAux, [[Line, Column]], PlayerCells); calculateCellsPlayer(T, Line, Player, PlayerCells)).

calculateCellsPlayerLines([], _, []).
calculateCellsPlayerLines([[Line|Cells]|T], Player, PlayerCells):- calculateCellsPlayerLines(T, Player, PlayerCellsAux), calculateCellsPlayer(Cells, Line, Player, PlayerCellsAuxx), append(PlayerCellsAux, PlayerCellsAuxx, PlayerCells).

calculateColored([], []).
calculateColored([[Line, Column]|T], ColoredCells) :- (cellColor(Line, Column) -> calculateColored(T, ColoredCellsAux), append(ColoredCellsAux, [[Line, Column]], ColoredCells); calculateColored(T, ColoredCells)).

calculateScore([], 0).
calculateScore([[Line,Column] | T], GroupPoints):- calculateScore(T, GroupPointsAux), (cellColor(Line, Column)-> GroupPoints = (GroupPointsAux+1); !).

calculateGroupsScore([], _).
calculateGroupsScore([Group|T], Points):- calculateGroupsScore(T, PointsAux), calculateScore(Group, PointsGroup), append(PointsAux, PointsGroup, Points).

calculatePoints(Board, Player, Points) :- 
        calculateCellsPlayerLines(Board, Player, PlayerCells), 
        calculateColored(PlayerCells, ColoredCells), 
        calculateGroups(PlayerCells, ColoredCells, [], FinalGroups, [], UsedCells),
        calculateGroupsScore(FinalGroups, Points).

%calculateGroup(+PlayerCells, +PlayerCellsToIterate, +StartingCell, +InitialGroup, -FinalGroup, +InitialUsedCells, -FinalUsedCells)
calculateGroup(_, [], _, InitialGroup, InitialGroup, InitialUsedCells, InitialUsedCells).
calculateGroup(PlayerCells, [[Line, Column]|T], [ColoredLine, ColoredColumn], Igroup, Fgroup, IusedCells, FusedCells) :- 
                                    (adjacentPieces(Line, Column, ColoredLine, ColoredColumn), \+ member([Line, Column], IusedCells) -> 
                                        append(IusedCells, [[Line, Column]], UsedCells1), 
                                        append(Igroup, [[Line, Column]], Group1), 
                                        calculateGroup(PlayerCells, T, [ColoredLine, ColoredColumn], Group1, Group2, UsedCells1, UsedCells2), 
                                        calculateGroup(PlayerCells, PlayerCells, [Line, Column], Group2, Fgroup, UsedCells2, FusedCells); 
                                        calculateGroup(PlayerCells, T, [ColoredLine, ColoredColumn], Igroup, Fgroup, IusedCells, FusedCells)).

%calculateGroups(+PlayerCells, +ColoredCells, +InitialGroups, -FinalGroups, +InitialUsedCells, -FinalUsedCells)
calculateGroups(_, [], InitialGroups, InitialGroups, InitialUsedCells, InitialUsedCells).
calculateGroups(PlayerCells, [[Line, Column]|T], Igroups, Fgroups, IusedCells, FusedCells) :- 
                            (member([Line,Column], IusedCells) ->
                                calculateGroups(PlayerCells, T, Igroups, Fgroups, IusedCells, FusedCells);
                                append(IusedCells, [[Line, Column]], UsedCells1),
                                calculateGroup(PlayerCells, PlayerCells, [Line, Column], [[Line, Column]], Group1, UsedCells1, UsedCells2),
                                append(Igroups, [Group1], Group2),
                                calculateGroups(PlayerCells, T, Group2, Fgroups, UsedCells2, FusedCells)).

lineFull([]).
lineFull([[_,Value] | T]) :- Value \= 'B', lineFull(T). 

boardFull([]).
boardFull([[_|TLine]|T]):- lineFull(TLine), boardFull(T).

deleteElement([], _, InitialList, InitialList).
deleteElement([Elem | T], Element, InitialList, NewList):- ( Element \= Elem -> append(InitialList, Elem, AuxList), deleteElement(T, Element, AuxList, NewList); append(InitialList, T, NewList)).

calculateWinner([], [], 0).
calculateWinner([], _, 1).
calculateWinner(_, [], 2).
calculateWinner(PointsP1, PointsP2, Winner):-  maxList(PointsP1, MaxP1), maxList(PointsP2, MaxP2),
                        (MaxP1 == MaxP2 -> 
                            deleteElement(PointsP1, MaxP1, [], NewPointsP1), 
                            deleteElement(PointsP2, MaxP2, [], NewPointsP2), 
                            calculateWinner(NewPointsP1,NewPointsP2, Winner); 
                            (MaxP2 > MaxP1 -> Winner = 2; Winner = 1)).
game_over(Board, Winner) :- (boardFull(Board) ->  write(2),
calculatePoints(Board,1,PointsP1), calculatePoints(Board,2,PointsP2), write(1), calculateWinner(PointsP1, PointsP2, Winner), fail; !) .

%value(Board, Player, Value) :- .

%choose_move(Board, Level, Move): .