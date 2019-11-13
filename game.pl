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

cellColor(Line, Column) :- Line =:= -2.
cellColor(Line, Column) :- Line =:= 2.
cellColor(Line, Column) :- abs(Line) + abs(Column) =:= 4.

verifyMove(Board, Line1, Column1, [], []) :- cellEmpty(Board, Line1, Column1), \+cellColor(Line1, Column1).
verifyMove(Board, Line1, Column1, Line2, Column2) :- cellEmpty(Board, Line1, Column1), cellEmpty(Board, Line2, Column2), cellColor(Line1, Column1), Line2 =:= -Line1, Column2 =:= -Column1.
verifyMove(Board, Line1, Column1, Line2, Column2) :- cellEmpty(Board, Line1, Column1), cellEmpty(Board, Line2, Column2), \+cellColor(Line1, Column1), \+cellColor(Line2, Column2), \+adjacentPieces(Line1, Column1, Line2, Column2).
%valid_moves(Board, Player, ListOfMoves) :- .

changeCell(Player, Column, [], []).
changeCell(Player, Column, [[H|T1]|T], NewLine) :- changeCell(Player, Column, T, AuxLine), (H=Column -> append([[Column, Player]], AuxLine, NewLine); append([[H|T1]], AuxLine, NewLine)).

implement_move(Player, Line, Column, [], []).
implement_move(Player, Line, Column, [[H|T1]|T], NewBoard) :- implement_move(Player, Line, Column, T, AuxBoard), (H=Line -> changeCell(Player, Column, T1, NewLine), append([[H|NewLine]], AuxBoard, NewBoard); append([[H|T1]], AuxBoard, NewBoard)).

implement_moves([Player,Line1,Column1,Line2,Column2], Board, NewBoard) :- implement_move(Player, Line1, Column1, Board, BoardAux), implement_move(Player, Line2, Column2, BoardAux, NewBoard).

move([Player,Line1,Column1,Line2,Column2], Board, NewBoard) :- verifyMove(Board, Line1, Column1, Line2, Column2), implement_moves([Player, Line1, Column1, Line2, Column2], Board, NewBoard).

%game_over(Board, Winner) :- .

%value(Board, Player, Value) :- .

%choose_move(Board, Level, Move): .