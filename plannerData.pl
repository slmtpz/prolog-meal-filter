
%foodGroup(GroupName, FoodList).
foodGroup(vegetable, [cauliflower, spinach, potato, zucchini, onion, lettuce]).
foodGroup(meat, [chicken, beef, lamb, fish, egg]).
foodGroup(cheese, [feta, mozeralla, parmesan, gouda, edam, emmental, kasar, ezine]).
foodGroup(fruit, [lemon, banana, tomato, eggplant, pineapple, strawberry, blueberry, raspbery, grape, cucumber, orange, lemon, cranberry]).
foodGroup(grain,[wheat, flour, rice, oat, barley, bread, pasta, corn, bakingPowder]).
foodGroup(nut, [peanut, hazelnut, walnut, pistachio, pecan, cashew]).
foodGroup(oil, [oliveOil, butter]).
foodGroup(confection, [sugar, brownSugar, candy, chocolate, cocoa, honey]).
foodGroup(spice, [salt, pepper, curry, ginger, cinnamon, thyme]).
foodGroup(dairy, [milk, yogurt, cream, butter, iceCream, feta, mozeralla, parmesan, gouda, edam, emmental, kasar, ezine]).
foodGroup(drinks, [water, tea, soda, cola, fruitJuice]).

%cannotEatGroup(EatingType, CannotEatFoodGroupList, CalorieLimit). If CalorieLimit is different than 0, then the group cannot eat meals with
%Calorie > CalorieLimit,
%else if CalorieLimit is 0, there is no limit to Calorie intake. CannotEatFoodGroupList consists of the list of foodGroups that the EatingType cannot eat.
cannotEatGroup(normal,[], 0).
cannotEatGroup(vegetarian,[meat], 0).
cannotEatGroup(vegan,[meat, dairy], 0).
cannotEatGroup(diabetic, [confection], 0).
cannotEatGroup(diet, [], 220).

%meal(MealName, IngredientList, Calorie (in kcal), PrepTime (in minutes), Price (in TL)).
meal(muesli, [wheat, oat, honey, hazelnut, cranberry, grape, milk], 220, 8, 6).
meal(bananaOatmeal, [oat, milk, cinnamon, banana, walnut], 150, 10, 5).
meal(cheeseCrepe, [flour, egg, milk, oliveOil, emmental, feta, kasar, salt], 134, 18, 10).
meal(eggSandwich, [egg, flour, salt, thyme, pepper, lettuce, corn, tomato], 170, 16, 12).
meal(saladWithNuts, [peanut, walnut, pecan, cashew, tomato, cucumber, corn, lettuce], 120, 15, 18).
meal(tomatoSoup, [tomato, flour, milk, butter, kasar, salt], 150, 15, 5).
meal(friedZucchini, [zucchini, tomato, oliveOil, salt], 295, 20, 14).
meal(karniyarik, [eggplant, onion, tomato, beef, oliveOil, salt], 270, 20, 15).
meal(chickenWrap, [chicken, lettuce, corn, tomato, cucumber, yogurt, flour, salt], 180, 20, 15).
meal(fishSticks, [fish, oliveOil, flour, egg], 250, 12, 13).
meal(salmon, [fish, lemon, salt, pepper], 100, 40, 30).
meal(bananaCake, [flour, banana, salt, butter, sugar, egg], 192, 6, 7).
meal(hazelnutBrownie, [hazelnut, butter, sugar, egg, flour, salt, bakingPowder, honey], 350, 12, 8).
meal(chocolateBrownie, [chocolate, cocoa, butter, sugar, egg, flour, salt, bakingPowder, honey], 450, 12, 8).
meal(tea, [tea], 0, 5, 1).
meal(ayran, [yogurt, water, salt], 76, 0, 2).

%customer(CustomerName, AllergyList (should be a foodGroup), EatingType (vegetarian, vegan, diabetic, diet, normal), Dislikes (food list), Likes (food list), TimeInHand, MoneyInHand).
customer(amy, [], [normal], [], [], 50, 100). %list all meals
customer(jack, [nut], [normal], [], [], 40, 80). %check allergy
customer(melanie, [], [vegetarian], [], [], 40, 70). %check eating type
customer(wendy, [], [diet], [], [], 40, 60). %check eating type
customer(john, [], [vegan, diabetic], [], [], 40, 50). %check eating type
customer(bailey, [], [normal], [zucchini, peanut], [], 40, 40). %check dislikes
customer(sarah, [], [normal], [], [chocolate, banana], 40, 30). %check likes
customer(brad, [], [normal], [], [], 15, 12). %check time+money in hand
customer(alison, [], [vegan], [tea], [], 40, 10). %should return []
customer(nick, [cheese], [diet], [fish, tomato], [chicken, walnut], 15, 20). %check all

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
