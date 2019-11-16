% Move tem o formato
% Move[player, line1, column1, line2, column2]

calculateCellWeight([], [], 0).
calculateCellWeight(Line, Column, Weight):- Weight is 2*abs(Line)+abs(Column).

generateMovesFromLine(_, [], _, _, _, _, []).
generateMovesFromLine(Board, [[CellBoard | _] | T],[Cell | Value], LineBoard, Line, Player, ValidMoves) :- generateMovesFromLine(Board, T, [Cell, Value], LineBoard, Line, Player, ValidMovesAux), (verifyMove(Board, Line, Cell, LineBoard, CellBoard), (Line =:= LineBoard, Cell =:=CellBoard -> fail;!) -> append(ValidMovesAux, [ [Line,Cell, LineBoard,  CellBoard] ], ValidMoves); ValidMoves = ValidMovesAux, !).

generateValidMovesCell(_, [], _, _, _, []).
generateValidMovesCell(Board, Board, [Cell, _], Line, _, ValidMoves):- cellColor(Line, Cell), cellEmpty(Board, Line, Cell), Line2 is -Line, Column2 is -Cell, ValidMoves = [[Line, Cell, Line2, Column2]].
generateValidMovesCell(Board, [[LineBoard | Cells ] | T], [Cell, Value], Line, Player, ValidMoves):- generateValidMovesCell(Board, T, [Cell, Value], Line, Player, ValidMovesAux), generateMovesFromLine(Board, Cells, [Cell, Value], LineBoard, Line, Player, ValidFromLine), append(ValidMovesAux, ValidFromLine, ValidMoves).

generateValidMovesLine(_, _, [], _, []).
generateValidMovesLine(Board, Line, [ Cell | T], Player, ValidMoves):- generateValidMovesLine(Board, Line, T, Player, ValidMovesAux), generateValidMovesCell(Board, Board, Cell, Line, Player, ValidInCell), append(ValidMovesAux, ValidInCell, ValidMoves).

generateValidMoves(_, [], _, []).
generateValidMoves(Board, [[Line| Cells] | T ], Player, ValidMoves):- generateValidMoves(Board, T, Player, ValidMovesAux), generateValidMovesLine(Board, Line, Cells, Player, ValidInLine), append(ValidMovesAux, ValidInLine, ValidMoves).

%valid_moves(+Board, +Player, -ListOfMoves)
valid_moves(Board, Player, ListOfMoves):-generateValidMoves(Board, Board, Player, ListOfMoves).

calculateMoveScore([], 0).
calculateMoveScore([Line1, Column1, Line2, Column2], Score) :- calculateCellWeight(Line1, Column1, Weight1), calculateCellWeight(Line2, Column2, Weight2), Score is Weight1+Weight2.

calculateBestMove([], []).
calculateBestMove([Move | T], BestMove) :- calculateBestMove(T, BestMoveAux), calculateMoveScore(Move, Score), calculateMoveScore(BestMoveAux, Score2), (Score >= Score2 -> BestMove = Move; BestMove= BestMoveAux).  

checkCellForIsolatedMove(_, _, [], []).
checkCellForIsolatedMove(Board, Line, [Cell | _], Move):- (cellEmpty(Board,Line, Cell)-> Move = [[Line, Cell, [], []]]; Move = []).

checkLineForIsolatedMove(_, [], _, []).
checkLineForIsolatedMove(Board, [Cell | T], Line, Moves):- checkLineForIsolatedMove(Board, T, Line, MovesAux), checkCellForIsolatedMove(Board, Line, Cell, CellMove), append(MovesAux, CellMove, Moves).

generateIsolatedMove(_, [], []).
generateIsolatedMove(Board, [[Line | Cells] | T], Moves):- generateIsolatedMove(Board, T, MovesAux), checkLineForIsolatedMove(Board, Cells, Line, LineMoves), append(MovesAux, LineMoves, Moves).

generateAllMoves(Board, Player, ValidMoves) :- valid_moves(Board, Player, ValidMoves1), generateIsolatedMove(Board, Board, ValidMoves2), append(ValidMoves1, ValidMoves2, ValidMoves).

applyEveryMove(_, [], _, []).
applyEveryMove(Board, [Move|Moves], Player, Boards) :- applyEveryMove(Board, Moves, Player, BoardsAux), append([Player], Move, MoveComplete), write(5), write(MoveComplete), move(MoveComplete, Board, NewBoard1), write(6), append(BoardsAux, [NewBoard1], Boards).

calculateBoardsWeight([], _, []).
calculateBoardsWeight([Board|Boards], Player, Weights) :- calculateBoardsWeight(Boards, Weight), value(Board, Player, Value), append(Weight, [Value], Weights).

calculateBestBoard([Board], [Weight], Board, Weight).
calculateBestBoard([Board|Boards], [Weight|Weights], NewBoard, NewWeight):- calculateBestBoard(Boards, Weights, NewBoardAux, NewWeightAux), (Weight>NewWeightAux -> NewWeight=Weight, NewBoard=Board; NewWeight=NewWeightAux, NewBoard=NewBoardAux).

calculateBestBoard([Board], [Weight], [Move],  Board, Weight, Move).
calculateBestBoard([Board|Boards], [Weight|Weights], [Move|Moves], NewBoard, NewWeight, NewMove):- calculateBestBoard(Boards, Weights, Moves, NewBoardAux, NewWeightAux, NewMoveAux), (Weight>NewWeightAux -> NewWeight=Weight, NewBoard=Board, NewMove=Move; NewWeight=NewWeightAux, NewBoard=NewBoardAux, NewMove=NewMoveAux).

generatesAllBoards(Boards, 0, Player, NewBoard) :- calculateBoardsWeight(Boards, Player, Weights), calculateBestBoard(Boards, Weights, NewBoard, NewWeight).
generatesAllBoards([], _, _, []).
generatesAllBoards([Board| Boards], NumberPlays, Player, BestBoards):- generatesAllBoards(Boards, NumberPlays, Player, BestBoards1), generateAllMoves(Board, ValidMoves), applyEveryMove(Board, ValidMoves, Player, NewBoards1),
                        NumberPlays1 is NumberPlays-1, (Player==1 -> Player1 is 2; Player1 is 1), generatesAllBoards(NewBoards1, NumberPlays1, Player1, BestBoardsAux), calculateBoardsWeight(BestBoardsAux, Player, Weights), calculateBestBoard(BestBoardsAux, Weights, BestBoard, BestWeight),
                        append(BestBoards1, [BestBoard], BestBoards).
chooseBestBoard(Board, NumberPlays, Player, BestMove):- generateAllMoves(Board, ValidMoves), applyEveryMove(Board, ValidMoves, Player, NewBoards1),
                        write(2), NumberPlays1 is NumberPlays-1, (Player==1 -> Player1 is 2; Player1 is 1), generatesAllBoards(NewBoards1, NumberPlays1, Player1, BestBoards),
                        write(3), calculateBoardsWeight(BestBoards, Player, Weights), calculateBestBoard(BestBoards, Weights, ValidMoves, BestBoard, BestWeight, BestMove).

%choose_move(+Board, +Level, +Player, -Move)
choose_move(Board, 1, Player, Move):- generateAllMoves(Board, Player, ValidMoves), calculateBestMove(ValidMoves, Move).
choose_move(Board, 2, Player, Move):- write(0), chooseBestBoard(Board, 3, Player, Move), write(1).
choose_move(Board, 3, Player, Move):- chooseBestBoard(Board, 5, Player, Move).

calculateCellsWeight([], 0).
calculateCellsWeight([[Line, Column] | T], Weight) :- calculateCellsWeight(T, WeightAux), calculateCellWeight(Line, Column, WeightCell), Weight is WeightAux + WeightCell.

%value(Board, Player, Value)
value(Board, Player, Value) :- calculateCellsPlayerLines(Board, Player, PlayerCells), calculateCellsWeight(PlayerCells, Value).