:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- use_module(library(random)).

displayResults(Participants, OutputGroups, TotalGroupsScore) :-
    write(' > PARTICIPANTS: '), write(Participants), nl,
    write(' > OUTPUT GROUPS: '), write(OutputGroups), nl,
    write(' > OUTPUT SCORE: '), write(TotalGroupsScore), nl.

%Participants -> [number, [friends], [nemesis]].
getParticipants([],[]).
getParticipants([[Element | _] |Others], Participants):-
    getParticipants(Others, ParticipantsAux),
    append([Element], ParticipantsAux, Participants).

carpooling(Participants, CanDrive, WillDrive) :-
    length(Participants, TotalParticipants),
    solve(Participants, TotalParticipants, CanDrive, WillDrive, OutputGroups, TotalGroupsScore),
    getParticipants(Participants, Numbers),
    displayResults(Numbers, OutputGroups, TotalGroupsScore).

solve(Participants, TotalParticipants, CanDrive, WillDrive, OutputGroups, TotalGroupsScore) :-
    statistics(walltime, [Start,_]),

    %Variáveis de Decisão
    MaxGroups is TotalParticipants div 2,
    getParticipants(Participants, Numbers),
    domain(Numbers, 1, TotalParticipants), 

    %Restrições
    get_groups(Participants, CanDrive, WillDrive, OutputGroups, []),
    length(OutputGroups, GroupSize),
    GroupSize #=< MaxGroups,
    append(OutputGroups, Vars),
    all_distinct(Vars),

    %Função de Avaliação
    calculateScore(Participants, CanDrive, WillDrive, OutputGroups, GroupsScore),
    sum(GroupsScore, #=, TotalGroupsScore),
   
    labeling([maximize(TotalGroupsScore), minimize(GroupSize)], Vars),
    
    statistics(walltime, [End,_]),
	Time is End - Start,
    format(' > Duration: ~3d s~n', [Time]).

delete_element([],_,[]).
delete_element([[Element | T] | Others], ElementToDel, NewList):-
    delete_element(Others, ElementToDel, NewListAux),
    (Element \= ElementToDel ->
        append(NewListAux,[[Element|T]], NewList); NewList = NewListAux).

delete_occurencies([],_,[]).
delete_occurencies([[Element, FriendsGroup, NemesisGroup] | Others], ElementToDel, NewOthers):-
    delete_occurencies(Others, ElementToDel, NewOthersAux),
    delete(FriendsGroup, ElementToDel, NewFriendsGroup),
    append(NewOthersAux,[[Element, NewFriendsGroup, NemesisGroup]], NewOthers).

delete_friends([],_,[]).
delete_friends([ Element | Others], ElementToDel, NewList):-
    delete_friends(Others, ElementToDel, NewListAux),
    (Element \= ElementToDel ->
        append(NewListAux,[Element], NewList); NewList = NewListAux).

findFriendsAndNemesis([[Participant , Friends, Nemesis] | Others], Element, FriendsGroup, NemesisGroup):-
    (Element == Participant -> 
        FriendsGroup = Friends, NemesisGroup = Nemesis;
        findFriendsAndNemesis(Others, Element, FriendsGroup, NemesisGroup)).

verifyNotMember(_,[],_,_).
verifyNotMember(Others, [Element | Group], NewElement, Nemesis):-
    findFriendsAndNemesis(Others, Element, _Friends, NemesisElement), 
    \+member(NewElement, NemesisElement), 
    \+member(Element, Nemesis),
    verifyNotMember(Others, Group, NewElement, Nemesis).

createGroup(_,_,Others,NewOthers,[],_,_,_, GroupAux, Group):- Group = GroupAux, NewOthers = Others. 
createGroup(_,_,Others,NewOthers,_,_,_,5, GroupAux, Group):- Group = GroupAux, NewOthers = Others.
createGroup([Element, FriendsGroup, NemesisGroup], Others, OthersAux, NewOthers, Participants, CanDrive, WillDrive, GroupSize, GroupAux, Group):-
    member(NewElement, Participants), 
    (FriendsGroup \= [] -> 
        member(NewElement, FriendsGroup);
        \+member(NewElement, NemesisGroup)),
    findFriendsAndNemesis(OthersAux, NewElement, _Friends, Nemesis), 
    (\+verifyNotMember([[Element, FriendsGroup, NemesisGroup] | Others], GroupAux, NewElement, Nemesis) -> 
        delete(FriendsGroup, NewElement, NewFriendsGroup), 
        delete(Participants, NewElement, NewParticipants),
        createGroup([Element, NewFriendsGroup, NemesisGroup], Others, OthersAux, NewOthers, NewParticipants, CanDrive, WillDrive, GroupSize, GroupAux, Group);
        delete_element(OthersAux, NewElement, NewOthersAux),
        delete_occurencies(NewOthersAux, NewElement, NewOthers2),
        delete_friends(FriendsGroup, NewElement, NewFriendsGroup),
        delete(CanDrive, NewElement, NewCanDriveAux),
        delete(Participants, NewElement, NewParticipants),
        delete(WillDrive, NewElement, NewWillDriveAux),
        append(GroupAux, [NewElement], NewGroup),
        length(NewGroup, GroupSizeAux),
        createGroup([Element, NewFriendsGroup, NemesisGroup], Others, NewOthers2, NewOthers, NewParticipants, NewCanDriveAux, NewWillDriveAux, GroupSizeAux, NewGroup, Group)).
    
delete_elements(_,[],Aux, Elements):- Elements = Aux.
delete_elements(Participants, [Element | Group], NewElementsAux, NewElements):-
    delete_element(NewElementsAux, Element, NewElementsAux2),
    delete_elements(Participants, Group, NewElementsAux2, NewElements).

delete_drivers([],_,[]).
delete_drivers([Driver | Others], Group, NewDrivers):-
    delete_drivers(Others, Group, NewDriversAux),
    (\+member(Driver, Group)->
        append(NewDriversAux, [Driver], NewDrivers);
        NewDrivers = NewDriversAux).

get_groups([],_,_, OutputGroups, OutputGroupsAux):- OutputGroups = OutputGroupsAux.
get_groups([ [Element, FriendsGroup, NemesisGroup] | Others], CanDrive, WillDrive, OutputGroups, OutputGroupsAux):-
    getParticipants(Others, Participants),
    delete_occurencies(Others, Element, NewOthers2),
    createGroup([Element ,FriendsGroup, NemesisGroup], NewOthers2, NewOthers2, NewOthers, Participants, CanDrive, WillDrive, 1, [Element], Group),
    delete_drivers(CanDrive, Group, NewCanDrive),
    delete_drivers(WillDrive, Group, NewWillDrive),
    append(OutputGroupsAux, [Group], OutputGroups2),
    get_groups(NewOthers, NewCanDrive, NewWillDrive, OutputGroups, OutputGroups2).

calculateElementScore(_,_,_,_,_,_,[],0).
calculateElementScore(Participants, CanDrive, WillDrive, Element, FriendsGroups, NemesisGroups, [ Member | Group], Score):- 
    calculateElementScore(Participants, CanDrive, WillDrive, Element, FriendsGroups, NemesisGroups, Group, ScoreAux), 
    (member(Member, FriendsGroups) -> AuxScore = 1; (member(Member, NemesisGroups) -> AuxScore = -1; AuxScore = 0)),
    Score is AuxScore + ScoreAux.

calculateGroupScore(_,_,_,[],0).
calculateGroupScore(Participants, CanDrive, WillDrive, [Element | Group],  Score):- 
    calculateGroupScore(Participants, CanDrive, WillDrive, Group, ScoreAux),
    findFriendsAndNemesis(Participants, Element, FriendsGroups, NemesisGroups),
    calculateElementScore(Participants, CanDrive, WillDrive, Element, FriendsGroups, NemesisGroups, Group, ElementScore),
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

calculateScore(_,_,_,[], []).
calculateScore(Participants , CanDrive, WillDrive,[OutputGroup | T], GroupsScore) :-
    calculateScore(Participants, CanDrive, WillDrive, T, GroupsScoreAux), 
    calculateGroupScore(Participants, CanDrive, WillDrive, OutputGroup, Score), 
    findDriver(OutputGroup, CanDrive, WillDrive, ScoreDriverAux), 
    length(OutputGroup, GroupSize),
    ComparableValue is 0 - GroupSize,
    NeutralValue is 1 - GroupSize, 
    (ScoreDriverAux > ComparableValue -> 
        (ScoreDriverAux > NeutralValue -> ScoreDriver = 1; ScoreDriver = 0); fail),
    TotalScore is Score + ScoreDriver, 
    append(GroupsScoreAux, [TotalScore], GroupsScore).

  