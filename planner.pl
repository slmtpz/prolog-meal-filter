:-include('plannerData.pl').
%findAllergyMeals(+AllergyList, ?InitialList, -MealList)
%To find meals which the customer is allergic to.
findAllergyMeals([],_,ML):-
	ML=[].
findAllergyMeals(AL,IL,ML):-
	findall(A,( member(B,AL), member(A,IL), meal(A,Ing,_,_,_), foodGroup(B,Mat), member(Y,Ing), member(Y,Mat)), List),
	rmvDup(List,ML).

%findLikeMeals(+Likes, ?InitialList, -MealList)
%To find meals which the customer likes.
findLikeMeals([],_,ML):-
	ML=[].
findLikeMeals(LL,IL,ML):-
	findall(A,( member(B,LL), member(A,IL), meal(A,Ing,_,_,_), member(B,Ing)), List),
	rmvDup(List,ML).

%findNotEatingTypeMeals(+EatingTypeList, ?InitialList, -MealList)
%To find meals which the eating	type of the customer allows.
findNotEatingTypeMeals(ET,IL,ML):-
	findall(A,( member(A,IL), member(B,ET), cannotEatGroup(B,C,_), member(D,C), meal(A,Ing,_,_,_), foodGroup(D,Mat), member(Y,Mat), member(Y,Ing)), List1),
	findall(A,( member(A,IL), member(B,ET), cannotEatGroup(B,_,C), meal(A,_,D,_,_), C<D, C\=0), List2), %<= ????
	append(List1,List2,List),
	rmvDup(List,ML).

%findMealsForTime(+TimeInHand, ?InitialList, -MealList)
% To find meals in order for their preperation time which the customer
% can wait for.
findMealsForTime(T,IL,ML):-
	findall(A,( member(A,IL), meal(A,_,_,P,_), T>=P), ML).

%findMealsForMoney(+MoneyInHand, ?InitialList, -MealList)
%To find meals in order for their price which the customer can afford.
findMealsForMoney(M,IL,ML):-
	findall(A,( member(A,IL), meal(A,_,_,_,P), M>=P), ML).

%orderLikedList(+LikeMeals, ?InitialList, -MealList)
%Reorders the menu such that the meals customer likes come first.
orderLikedList(LM,IL,ML):-
	append(LM,IL,List),
	rmvDup(List,ML).

%listPersonalList(+CustomerName, -PersonalList)
%Extracts the suitable menu for a customer.
listPersonalList(CN,IL):-
	findall(A, meal(A,_,_,_,_), L),
	customer(CN,AL,ET,DL,LL,T,M),
	findAllergyMeals(AL,L,ML1),
        findall(A1,( member(A1,L), \+member(A1,ML1)), L1),
	findNotEatingTypeMeals(ET,L1,ML2),
	findall(A2,( member(A2,L1), \+member(A2,ML2)), L2),
	findLikeMeals(DL,L2,ML3),
	findall(A3,( member(A3,L2), \+member(A3,ML3)), L3),
	findMealsForTime(T,L3,ML4),
	findall(A4,( member(A4,L3), member(A4,ML4)), L4),
	findMealsForMoney(M,L,ML5),
	findall(A5,( member(A5,L4), member(A5,ML5)), L5),
	findLikeMeals(LL,L5,ML6),
	orderLikedList(ML6,L5,IL).

%Removes an atom from a list.
rmv(_,[],[]).
rmv(X,[X|T],T1):-
	rmv(X,T,T1).
rmv(X,[H|T],[H|T1]):-
	X\=H, rmv(X,T,T1).

%Removes consecutive atoms from a list.
rmvDup([],[]).
rmvDup([H|T],[H|T1]):-
	rmv(H,T,T2),
	rmvDup(T2,T1).
