/**board([
    [7, [-7, 'B'], [-5, 'B'], [-3, 'B'], [-1, 'B'], [1, 'B'], [3, 'B'], [5, 'B'], [7, 'B']],
    [6, [-8, 'B'], [-6, 'B'], [-4, 'B'], [-2, 'B'], [0, 'B'], [2, 'B'], [4, 'B'], [6, 'B'], [8, 'B']],
    [5, [-9, 'B'], [-7, 'B'], [-5, 'B'], [-3, 'B'], [-1, 'B'], [1, 'B'], [3, 'B'], [5, 'B'], [7, 'B'], [9, 'B']],
    [4, [-10, 'B'], [-8, 'B'], [-6, 'B'], [-4, 'B'], [-2, 'B'], [0, 'B'], [2, 'B'], [4, 'B'], [6, 'B'], [8, 'B'], [10, 'B']],
    [3, [-11, 'B'], [-9, 'B'], [-7, 'B'], [-5, 'B'], [-3, 'B'], [-1, 'B'], [1, 'B'], [3, 'B'], [5, 'B'], [7, 'B'], [9, 'B'], [11, 'B']],
    [2, [-12, 'B'], [-10, 'B'], [-8, 'B'], [-6, 'B'], [-4, 'B'], [-2, 'B'], [0, 'B'], [2, 'B'], [4, 'B'], [6, 'B'], [8, 'B'], [10, 'B'], [12, 'B']],
    [1, [-13, 'B'], [-11, 'B'], [-9, 'B'], [-7, 'B'], [-5, 'B'], [-3, 'B'], [-1, 'B'], [1, 'B'], [3, 'B'], [5, 'B'], [7, 'B'], [9, 'B'], [11, 'B'], [13, 'B']],
    [0, [-14, 'B'], [-12, 'B'], [-10, 'B'], [-8, 'B'], [-6, 'B'], [-4, 'B'], [-2, 'B'], [0, 'B'], [2, 'B'], [4, 'B'], [6, 'B'], [8, 'B'], [10, 'B'], [12, 'B'], [14, 'B']],
    [-1, [-13, 'B'], [-11, 'B'], [-9, 'B'], [-7, 'B'], [-5, 'B'], [-3, 'B'], [-1, 'B'], [1, 'B'], [3, 'B'], [5, 'B'], [7, 'B'], [9, 'B'], [11, 'B'], [13, 'B']],
    [-2, [-12, 'B'], [-10, 'B'], [-8, 'B'], [-6, 'B'], [-4, 'B'], [-2, 'B'], [0, 'B'], [2, 'B'], [4, 'B'], [6, 'B'], [8, 'B'], [10, 'B'], [12, 'B']],
    [-3, [-11, 'B'], [-9, 'B'], [-7, 'B'], [-5, 'B'], [-3, 'B'], [-1, 'B'], [1, 'B'], [3, 'B'], [5, 'B'], [7, 'B'], [9, 'B'], [11, 'B']],
    [-4, [-10, 'B'], [-8, 'B'], [-6, 'B'], [-4, 'B'], [-2, 'B'], [0, 'B'], [2, 'B'], [4, 'B'], [6, 'B'], [8, 'B'], [10, 'B']],
    [-5, [-9, 'B'], [-7, 'B'], [-5, 'B'], [-3, 'B'], [-1, 'B'], [1, 'B'], [3, 'B'], [5, 'B'], [7, 'B'], [9, 'B']],
    [-6, [-8, 'B'], [-6, 'B'], [-4, 'B'], [-2, 'B'], [0, 'B'], [2, 'B'], [4, 'B'], [6, 'B'], [8, 'B']],
    [-7, [-7, 'B'], [-5, 'B'], [-3, 'B'], [-1, 'B'], [1, 'B'], [3, 'B'], [5, 'B'], [7, 'B']]
]).*/

board([
    [2, [-2, 'B'], [0, 'B'], [2, 'B']],
    [1, [-3, 'B'], [-1, 'B'], [1, 'B'], [3, 'B']],
    [0, [-4, 'B'], [-2, 'B'], [0, 'B'], [2, 'B'], [4, 'B']],
    [-1, [-3, 'B'], [-1, 'B'], [1, 'B'], [3, 'B']],
    [-2, [-2, 'B'], [0, 'B'], [2, 'B']]
]).

displayMenu :-
    write('|                                                       |\n'),
    write('|                  ___  __   ___   ___                  |\n'),
    write('|                   |  |  |   |   |                     |\n'),
    write('|                   |  | _|   |   |__                   |\n'),
    write('|                   |  |\\     |      |                  |\n'),
    write('|                  _|_ | \\_  _|_  ___|                  |\n'),
    write('|                                                       |\n'),
    write('|                                                       |\n'),
    write('|              ___________________________              |\n'),
    write('|              |                         |              |\n'),
    write('|              |   1. Player vs Player   |              |\n'),
    write('|              |_________________________|              |\n'),
    write('|              |                         |              |\n'),
    write('|              |  2. Player vs Computer  |              |\n'),
    write('|              |_________________________|              |\n'),
    write('|              |                         |              |\n'),
    write('|              | 3. Computer vs Computer |              |\n'),
    write('|              |_________________________|              |\n'),
    write('|                                                       |\n'),
    write('|                                                       |\n').

drawSpace(0).
drawSpace(N) :- write(' '), N1 is N-1, drawSpace(N1).

displayCell([_|[P]]):- write(P), write(' ').
displayLineCells([]).
displayLineCells([H|T]):- displayCell(H), displayLineCells(T).
displayLine([H|T]) :- (H<0 -> write(H); write('0'), write(H)), (H>0 -> N1 is H+1, drawSpace(N1); N1 is -H+1, drawSpace(N1)), (H<0 -> write('\\ '); (H>0 -> write('/ '); write('| '))), displayLineCells(T), (H<0 -> write('/ \n'); (H>0 -> write('\\ \n'); write('| \n'))).
displayBoard([]).
displayBoard([H|T]) :- displayLine(H), displayBoard(T).

parseInput(1, Board) :- displayBoard(Board), implement_moves(['1', 1, -3, -2, 2], Board, NewBoard), displayBoard(NewBoard), adjacentPieces(2, -2, -2, -2), displayBoard(NewBoard).
%display_game(Board, Player).

play :- board(Board), displayMenu, write('--> Insert your option: '), read(Input), \+parseInput(Input, Board).


% Move tem o formato
% Move[player, line1, column1, line2, column2]

cellFull([[L|[[C, P]|T1]]|T], Line, Column) :- (L=Line -> (C=Column -> P='B'; cellFull([[L|T1]|T], Line, Column)); cellFull(T, Line, Column)).

adjacentPieces(Line1, Column1, Line2, Column2) :- (Line1 =:= Line2, Column1 =:= Column2 + 2);
                                                    (Line1 =:= Line2, Column1 =:= Column2 - 2);
                                                    (Line1 =:= Line2 + 1, Column1 =:= Column2 + 1);
                                                    (Line1 =:= Line2 + 1, Column1 =:= Column2 - 1);
                                                    (Line1 =:= Line2 - 1, Column1 =:= Column2 + 1);
                                                    (Line1 =:= Line2 - 1, Column1 =:= Column2 - 1).

%verifyMove(Board, Line1, Column1, Line2, Column2) :-
%valid_moves(Board, Player, ListOfMoves) :- .

changeCell(Player, Column, [], []).
changeCell(Player, Column, [[H|T1]|T], NewLine) :- changeCell(Player, Column, T, AuxLine), (H=Column -> append([[Column, Player]], AuxLine, NewLine); append([[H|T1]], AuxLine, NewLine)).

implement_move(Player, Line, Column, [], []).
implement_move(Player, Line, Column, [[H|T1]|T], NewBoard) :- implement_move(Player, Line, Column, T, AuxBoard), (H=Line -> changeCell(Player, Column, T1, NewLine), append([[H|NewLine]], AuxBoard, NewBoard); append([[H|T1]], AuxBoard, NewBoard)).

implement_moves([Player|[Line1|[Column1|[Line2|[Column2]]]]], Board, NewBoard) :- implement_move(Player, Line1, Column1, Board, BoardAux), implement_move(Player, Line2, Column2, BoardAux, NewBoard).

move([Player|Cells], Board, NewBoard) :- valid_moves(Board, Player, ListOfMoves), member([Player|Cells], ListOfMoves), implement_moves([Player|Cells], Board, NewBoard).

%game_over(Board, Winner) :- .

%value(Board, Player, Value) :- .

%choose_move(Board, Level, Move): .