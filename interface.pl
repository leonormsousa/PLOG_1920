play(Board, Player) :- write('\n--> P'), write(Player), write(': Choose a Line for Piece1 '), read(Line1),
                ( \+ number(Line1)  ->  (Player == '1' -> play(Board, '2'); play(Board, '1')),fail;!),
                (abs(Line1) > 2 -> writeError('Piece1 out of bounds'), play(Board, Player), fail; !),
                write('--> P'), write(Player), write(': Choose a Column for Piece1 '), read(Column1), 
                (abs(Line1) + abs(Column1) > 4 -> writeError('Piece1 out of bounds'), play(Board, Player), fail; !),
                ((abs(Line1) + abs(Column1)) mod 2 =:= 1 -> writeError('Piece1 doesnt exist'), play(Board, Player), fail;!),
                write('--> P'), write(Player), write(': Choose a Line for Piece2 '), read(Line2),
                (\+ number(Line2) -> 
                    (move([Player, Line1, Column1, [], []], Board, NewBoard) ->
                        displayBoard(NewBoard),
                        game_over(NewBoard, Winner),
                        (Player == '1' -> play(NewBoard, '2'); play(NewBoard, '1'));
                        writeError, displayBoard(Board), play(Board, Player));
                (abs(Line2) > 2 -> writeError('Piece2 out of bounds'), play(Board, Player), fail;!),
                write('--> P'), write(Player), write(': Choose a Column for Piece2 '), read(Column2),
                (abs(Line2) + abs(Column2) > 4 -> writeError('Piece2 out of bounds'), play(Board, Player), fail;!),
                ((abs(Line2) + abs(Column2)) mod 2 =:= 1 -> writeError('Piece2 doesnt exit'), play(Board, Player), fail; !),
                (Line1 =:= Line2, Column1 =:= Column2 -> writeError('Pieces are the same'), play(Board, Player), fail; !)),
                displayBoard(Board),
                (move([Player, Line1, Column1, Line2, Column2], Board, NewBoard) ->
                    displayBoard(NewBoard),
                    game_over(NewBoard, Winner),
                    (Player == '1' -> play(NewBoard, '2'); play(NewBoard, '1'));
                    writeError, displayBoard(Board), play(Board, Player)).

firstPlay(Board) :- write('\n--> P1: Choose a Line'), read(Line1),
                    (abs(Line1) > 2 -> writeError('Piece1 out of bounds'), firstPlay(Board), fail;
                    write('--> P1: Choose a Column'), read(Column1), 
                    (abs(Line1) + abs(Column1) > 4 -> writeError('Piece1 out of bounds'), firstPlay(Board), fail;
                    ((abs(Line1) + abs(Column1)) mod 2 =:= 1 -> writeError('Piece1 doesnt exist'), firstPlay(Board), fail;
                    (move(['1', Line1, Column1, [], []], Board, NewBoard) -> 
                        displayBoard(NewBoard), play(NewBoard, '2');
                        writeError, displayBoard(Board), firstPlay(Board))))).


startGame(Board) :- displayBoard(Board), firstPlay(Board).

parseInput(1, Board) :- startGame(Board).

play :- board(Board), displayMenu, write('--> Insert your option: '), read(Input), \+parseInput(Input, Board).