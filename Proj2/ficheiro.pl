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
    get_groups(Participants, CanDrive, WillDrive, FriendsGroups, NemesisGroups, OutputGroups, []),
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

createGroup(_,[],_,_,_,_,_,_,_, GroupAux, Group):- Group = GroupAux. 
createGroup(_,_,_,_,_,_,_,_,5, GroupAux, Group):- Group = GroupAux.
createGroup(Element, Others, CanDrive, WillDrive, FriendsGroup, NemesisGroup, NewCanDrive, NewWillDrive, GroupSize, GroupAux, Group):-
    member(NewElement, Others), 
    (FriendsGroup \= [] -> 
        member(NewElement, FriendsGroup);
        \+member(NewElement, NemesisGroup)),
    delete(Others, NewElement, NewOthers),
    delete(FriendsGroup, NewElement, NewFriendsGroup),
    delete(CanDrive, NewElement, NewCanDriveAux),
    delete(WillDrive, NewElement, NewWillDriveAux),
    append(GroupAux, [NewElement], NewGroup),
    length(NewGroup, GroupSizeAux),
    createGroup(Element, NewOthers, CanDrive, WillDrive, NewFriendsGroup, NemesisGroup, NewCanDriveAux, NewWillDriveAux, GroupSizeAux, NewGroup, Group).
    
delete_elements(List,[],NewListAux):- NewListAux = List.
delete_elements(List, [Element | Others], NewList):-
    delete_elements(List, Others, NewListAux),
    delete(NewListAux, Element, NewList).

delete_elements_and_groups([],_,[],[],[],[],[]).
delete_elements_and_groups([Element | Others], Group, [FriendsGroup | OtherFriends], [NemesisGroups | OtherNemesis], NewElements, NewFriendsGroup, NewNemesisGroups):-
    delete_elements_and_groups(Others, Group, OtherFriends, OtherNemesis,NewElementsAux, NewFriendsGroupAux, NewNemesisGroupsAux),
    (\+member(Element, Group) -> 
        append(NewElementsAux, [Element], NewElements), append(NewFriendsGroupAux, [FriendsGroup], NewFriendsGroup), append(NewNemesisGroupsAux, [NemesisGroups], NewNemesisGroups);
        NewElements = NewElementsAux, NewFriendsGroup = NewFriendsGroupAux, NewNemesisGroups = NewNemesisGroupsAux).

get_groups([],_,_,_,_, OutputGroups, OutputGroupsAux):- OutputGroups = OutputGroupsAux.
get_groups([Element | Others], CanDrive, WillDrive, [FriendsGroup | OthersFriendsGroups], [NemesisGroup | OtherNemesisGroups], OutputGroups, OutputGroupsAux):-
    createGroup(Element, Others, CanDrive, WillDrive, FriendsGroup, NemesisGroup, _, _, 1, [Element], Group),
    delete_elements_and_groups(Others, Group, OthersFriendsGroups, OtherNemesisGroups, NewOthers, NewFriendsGroup, NewNemesisGroups),
    delete_elements(CanDrive, Group, NewCanDrive),
    delete_elements(WillDrive, Group, NewWillDrive),
    append(OutputGroupsAux, [Group], OutputGroups2),
    get_groups(NewOthers, NewCanDrive, NewWillDrive, NewFriendsGroup, NewNemesisGroups, OutputGroups, OutputGroups2).

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
    (member(Element, WillDrive) -> 
        ScoreDriver = 1; 
        (member(Element, CanDrive) -> 
            ScoreDriver = 0 ; 
            ScoreDriver = -1 )), 
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
        (ScoreDriverAux > NeutralValue -> ScoreDriver = 1; ScoreDriver = 0); fail),
    TotalScore is Score + ScoreDriver, 
    append(GroupsScoreAux, [TotalScore], GroupsScore).

  