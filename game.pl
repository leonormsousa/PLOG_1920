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

calculateColored([], _).
calculateColored([[H|T1]|T], ColoredCells):- (cellColor(H,T1) -> calculateColored(T,AuxColored), append([H|T1],AuxColored, ColoredCells); calculateColored(T,ColoredCells)).

calculatePoints( [[_|T1]|_], Points) :-  calculateColored(T1, ColoredCells), write(ColoredCells), Points is 1.

lineFull([]).
lineFull([_,[_,Value] | T]) :- Value \= 'B', lineFull(T). 

boardFull([]).
boardFull([Line|T]):- lineFull(Line), boardFull(T).

game_over(Board, Winner) :- (boardFull(Board) ->
(calculatePoints(Board,1,PointsP1), calculatePoints(Board,2,PointsP2), PointsP1 > PointsP2 -> Winner = 1; Winner = 2); !) .

%value(Board, Player, Value) :- .

%choose_move(Board, Level, Move): .