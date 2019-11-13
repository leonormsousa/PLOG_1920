initialBoard([[1,2,1,1,2,1,2,2],[2,1,2,2,1,2,1,2,1], [2,1,1,2,2,1,2,2,1,2], [1,2,1,1,2,1,1,2,1,2,1], [1,2,2,2,2,2,2,2,1,2,1,1],  [2,1,2,2,1,1,1,2,1,1,1,2,1], [1,2,1,2,1,2,1,1,1,2,1,2,2,1], [2,1,2,1,1,2,1,1,2,2,1,2,1,2,2], [1,2,2,1,1,2,1,1,1,2,2,1,2,2],[2,1,1,2,1,2,1,2,2,1,1,2,1], [2,1,2,2,2,2,1,2,2,1,1,2], [1,1,2,1,2,1,1,1,2,2,2], [1,2,2,1,1,2,2,2,1,1], [1,2,2,1,1,2,2,1,2],[2,2,1,2,1,1,2,1]]).

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
   
piece(1) :- write('1 ').
piece(b) :- write('B ').
piece(2) :- write('2 ').
drawSeparator(1) :- write('       /').
drawSeparator(2) :- write('      /').
drawSeparator(3) :- write('     /').
drawSeparator(4) :- write('    /').
drawSeparator(5) :- write('   /').
drawSeparator(6) :- write('  /').
drawSeparator(7) :- write(' /').
drawSeparator(8) :- write('|').
drawSeparator(9) :- write(' \\').
drawSeparator(10) :- write('  \\').
drawSeparator(11) :- write('   \\').
drawSeparator(12) :- write('    \\').
drawSeparator(13) :- write('     \\').
drawSeparator(14) :- write('      \\').
drawSeparator(15) :- write('       \\').
drawLine([], 1) :- write('\\ \n').
drawLine([], 2) :- write('| \n').
drawLine([], 3) :- write('/ \n').
drawLine([H | T], N) :- piece(H), drawLine(T, N).

parseInput(1, Board) :- !, displayBoard(Board, 1).

displayBoard([H|T], N):- drawSeparator(N), N1 is N+1, (N1 == 9 -> drawLine(H,2);(N1 >= 9 -> drawLine(H,3); drawLine(H,1))) , displayBoard(T, N1).
display_game(Board, Player) :- displayMenu, write('--> Insert your option: '), read(Input), \+parseInput(Input, Board).
