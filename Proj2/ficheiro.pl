:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- use_module(library(random)).

displayResults(Participants, OutputGroups, TotalGroupsScore) :-
    write(' > PARTICIPANTS  GROUPS: '), write(Participants), nl,
    write(' > OUTPUT GROUPS: '), write(OutputGroups), nl,
    write(' > OUTPUT SCORE: '), write(TotalGroupsScore), nl.

carpooling(Participants, CanDrive, WillDrive, FriendsGroups, NemesisGroups) :-
    length(Participants, TotalParticipants),
    solve(Participants, TotalParticipants, CanDrive, WillDrive, FriendsGroups, NemesisGroups, OutputGroups, TotalGroupsScore),
    displayResults(Participants, OutputGroups, TotalGroupsScore).

solve(Participants, TotalParticipants, CanDrive, WillDrive, FriendsGroups, NemesisGroups, OutputGroups, TotalGroupsScore) :-
    statistics(walltime, [Start,_]),

    %Vari�veis de Decis�o
    MaxGroups is TotalParticipants div 2,
    domain(Participants, 1, TotalParticipants), 

    %Restri��es
    all_distinct(Participants),
    get_groups(Participants, CanDrive, WillDrive, FriendsGroups, NemesisGroups, 1, LastGroup, [], OutputGroupsAux, []),
    append(OutputGroupsAux, [LastGroup], OutputGroups),
    length(OutputGroups, GroupSize),
    GroupSize #=< TotalParticipants,

    %Fun��o de Avalia��o
    calculateScore(Participants, CanDrive, WillDrive, FriendsGroups, NemesisGroups, OutputGroups, GroupsScore),
    sum(GroupsScore, #=, TotalGroupsScore),
   
    %Labeling
    append(OutputGroups, Vars),
    labeling([maximize(TotalGroupsScore)], Vars),
    statistics(walltime, [End,_]),
	Time is End - Start,
    format(' > Duration: ~3d s~n', [Time]).
    %fd_statistics.

get_groups([],_,_,_,_,_,CurrentGroup, CurrentGroupAux, OutputGroups, OutputGroupsAux):- CurrentGroup = CurrentGroupAux, OutputGroups = OutputGroupsAux.

get_groups([Element | Others], CanDrive, WillDrive, FriendsGroups, NemesisGroups, AuxIndex, CurrentGroup, CurrentGroupAux, OutputGroups, OutputGroupsAux):-
    (Index is AuxIndex mod 2, Index \= 0 -> 
        append(CurrentGroupAux, [Element], CurrentGroupAux2), OutputGroups2 = OutputGroupsAux; 
        Index = 1, append(OutputGroupsAux, [CurrentGroupAux], OutputGroups2), CurrentGroupAux2 = [Element]),
    AuxIndex2 is AuxIndex +1,
    get_groups(Others, CanDrive, WillDrive, FriendsGroups, NemesisGroups, AuxIndex2, CurrentGroup, CurrentGroupAux2, OutputGroups, OutputGroups2).

calculateElementScore(_,_,_,_,_,_,[],0).
calculateElementScore(Participants, CanDrive, WillDrive, FriendsGroups, NemesisGroups, Element, [ Member | Group], Score):- 
    calculateElementScore(Participants, CanDrive, WillDrive, FriendsGroups, NemesisGroups, Element, Group, ScoreAux), 
    (member(Member, FriendsGroups) -> AuxScore = 1; (member(Member, NemesisGroups) -> AuxScore = -1; AuxScore = 0)),
    Score is AuxScore + ScoreAux.

calculateGroupScore(_,_,_,_,_,[],0).
calculateGroupScore(Participants, CanDrive, WillDrive, FriendsGroups, NemesisGroups, [Element | Group],  Score):- 
    calculateGroupScore(Participants, CanDrive, WillDrive, FriendsGroups, NemesisGroups, Group, ScoreAux),
    calculateElementScore(Participants, CanDrive, WillDrive, FriendsGroups, NemesisGroups, Element, Group, ElementScore),
    Score is ScoreAux + ElementScore.


findDriver([],_,_,0).
findDriver([Element | Group], CanDrive, WillDrive, FinalScore):-
    findDriver(Group, CanDrive,WillDrive, FinalScoreAux),
    (member(Element, WillDrive) -> ScoreDriver = 1; member(Element, CanDrive) -> ScoreDriver = 0; ScoreDriver = -1), 
    FinalScore is FinalScoreAux + ScoreDriver.
    

calculateScore(_,_,_,_,_,[], []).
calculateScore(Participants , CanDrive, WillDrive, FriendsGroups, NemesisGroups, [OutputGroup | T], GroupsScore) :-
    calculateScore(Participants, CanDrive, WillDrive, FriendsGroups, NemesisGroups, T, GroupsScoreAux), 
    calculateGroupScore(Participants, CanDrive, WillDrive, FriendsGroups, NemesisGroups, OutputGroup, Score), 
    findDriver(OutputGroup, CanDrive, WillDrive, ScoreDriverAux), 
    length(OutputGroup, GroupSize),
    ComparableValue is 0 - GroupSize,
    NeutralValue is 1 - GroupSize, 
    (ScoreDriverAux > ComparableValue -> 
        (ScoreDriverAux > NeutralValue -> ScoreDriver = 1; ScoreDriver = 0); ScoreDriver = -1),
    TotalScore is Score + ScoreDriver, 
    append(GroupsScoreAux, [TotalScore], GroupsScore).

  