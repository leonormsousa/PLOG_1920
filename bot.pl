% Move tem o formato
% Move[player, line1, column1, line2, column2]

calculateCellWeight(Line, Column, Weight):- Weight is 2*abs(Line)+abs(Column).


%value(Board, Player, Value) :- .

generateMovesFromLine(_, [], _, _, _, _, []).
generateMovesFromLine(Board, [[CellBoard | _] | T],[Cell | Value], LineBoard, Line, Player, ValidMoves) :- generateMovesFromLine(Board, T, [Cell, Value], LineBoard, Line, Player, ValidMovesAux), (verifyMove(Board, Line, Cell, LineBoard, CellBoard), (Line =:= LineBoard, Cell =:=CellBoard -> fail;!) -> append(ValidMovesAux, [ [Line,Cell, LineBoard,  CellBoard] ], ValidMoves); ValidMoves = ValidMovesAux, !).

generateValidMovesCell(_, [], _, _, _, []).
generateValidMovesCell(Board, Board, [Cell, _], Line, _, ValidMoves):- cellColor(Line, Cell), cellEmpty(Board, Line, Cell), Line2 is -Line, Column2 is -Cell, ValidMoves = [[Line, Cell, Line2, Column2]].
generateValidMovesCell(Board, [[LineBoard | Cells ] | T], [Cell, Value], Line, Player, ValidMoves):- generateValidMovesCell(Board, T, [Cell, Value], Line, Player, ValidMovesAux), generateMovesFromLine(Board, Cells, [Cell, Value], LineBoard, Line, Player, ValidFromLine), append(ValidMovesAux, ValidFromLine, ValidMoves).

generateValidMovesLine(_, _, [], _, []).
generateValidMovesLine(Board, Line, [ Cell | T], Player, ValidMoves):- generateValidMovesLine(Board, Line, T, Player, ValidMovesAux), generateValidMovesCell(Board, Board, Cell, Line, Player, ValidInCell), append(ValidMovesAux, ValidInCell, ValidMoves).

generateValidMoves(_, [], _, []).
generateValidMoves(Board, [[Line| Cells] | T ], Player, ValidMoves):- generateValidMoves(Board, T, Player, ValidMovesAux), generateValidMovesLine(Board, Line, Cells, Player, ValidInLine), append(ValidMovesAux, ValidInLine, ValidMoves).

calculateMoveScore([], 0).
calculateMoveScore([Line1, Column1, Line2, Column2], Score) :- calculateCellWeight(Line1, Column1, Weight1), calculateCellWeight(Line2, Column2, Weight2), Score is Weight1+Weight2.

calculateBestMove([], []).
calculateBestMove([Move | T], BestMove) :- calculateBestMove(T,BestMoveAux), calculateMoveScore(Move, Score), calculateMoveScore(BestMoveAux, Score2), (Score >= Score2 -> BestMove = Move; BestMove= BestMoveAux).  

checkCellForIsolatedMove(_, _, [], []).
checkCellForIsolatedMove(Board, Line, [Cell | _], Move):- (cellEmpty(Board,Line, Cell)-> Move = [Line, Cell]; Move = []).

checkLineForIsolatedMove(_, [], _, []).
checkLineForIsolatedMove(Board, [Cell | T], Line, Move):- checkCellForIsolatedMove(Board, Line, Cell, CellMove), (CellMove \= [] -> Move = CellMove; checkLineForIsolatedMove(Board, T, Line, Move)).

generateIsolatedMove(_, [], []).
generateIsolatedMove(Board, [[Line | Cells] | T], Move):- checkLineForIsolatedMove(Board, Cells, Line, LineMoves), (LineMoves \= [] -> write(LineMoves), write(Move), append(LineMoves, [], Move),  write(3); generateIsolatedMove(Board, T,Move)).

%player nao existia aqui mas nao sei fazer sem ele soooooo
choose_move(Board, Player,_, Move):- generateValidMoves(Board, Board, Player, ValidMoves), (ValidMoves == [] -> generateIsolatedMove(Board, Board, ValidMoves); !),  calculateBestMove(ValidMoves, Move).