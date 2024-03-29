/*  $Id$

    Part of SWI-Prolog

    Author:        Jan Wielemaker and Richard O'Keefe
    E-mail:        J.Wielemaker@cs.vu.nl
    WWW:           http://www.swi-prolog.org
    Copyright (C): 1985-2011, University of Amsterdam
			      VU University Amsterdam

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/

:- module(lists,
	[ member/2,			% ?X, ?List
	  append/2,			% +ListOfLists, -List
	  append/3,			% ?A, ?B, ?AB
	  prefix/2,			% ?Part, ?Whole
	  select/3,			% ?X, ?List, ?Rest
	  selectchk/3,			% ?X, ?List, ?Rest
	  select/4,			% ?X, ?XList, ?Y, ?YList
	  selectchk/4,			% ?X, ?XList, ?Y, ?YList
	  nextto/3,			% ?X, ?Y, ?List
	  delete/3,			% ?List, ?X, ?Rest
	  nth0/3,			% ?N, ?List, ?Elem
	  nth1/3,			% ?N, ?List, ?Elem
	  nth0/4,			% ?N, ?List, ?Elem, ?Rest
	  nth1/4,			% ?N, ?List, ?Elem, ?Rest
	  last/2,			% +List, -Element
	  proper_length/2,		% @List, -Length
	  same_length/2,		% ?List1, ?List2
	  reverse/2,			% +List, -Reversed
	  permutation/2,		% ?List, ?Permutation
	  flatten/2,			% +Nested, -Flat

					% Ordered operations
	  max_member/2,			% -Max, +List
	  min_member/2,			% -Min, +List

					% Lists of numbers
	  sumlist/2,			% +List, -Sum
	  max_list/2,			% +List, -Max
	  min_list/2,			% +List, -Min
	  numlist/3,			% +Low, +High, -List

					% set manipulation
	  is_set/1,			% +List
	  list_to_set/2,		% +List, -Set
	  intersection/3,		% +List1, +List2, -Intersection
	  union/3,			% +List1, +List2, -Union
	  subset/2,			% +SubSet, +Set
	  subtract/3			% +Set, +Delete, -Remaining
	]).
:- use_module(library(error)).

:- set_prolog_flag(generate_debug_info, false).

/** <module> List Manipulation

This library provides  commonly  accepted   basic  predicates  for  list
manipulation in the Prolog community. Some additional list manipulations
are built-in. See e.g., memberchk/2, length/2.

The implementation of this library  is   copied  from many places. These
include: "The Craft of Prolog", the   DEC-10  Prolog library (LISTRO.PL)
and the YAP lists library. Some   predicates  are reimplemented based on
their specification by Quintus and SICStus.

@compat	Virtually every Prolog system has library(lists), but the set
	of provided predicates is diverse.  There is a fair agreement
	on the semantics of most of these predicates, although error
	handling may vary.
*/

%%	member(?Elem, ?List)
%
%	True if Elem is a  member   of  List.  The SWI-Prolog definition
%	differs from the classical one.  Our definition avoids unpacking
%	each list element twice and  provides   determinism  on the last
%	element.  E.g. this is deterministic:
%
%	    ==
%		member(X, [One]).
%	    ==
%
%	@author Gertjan van Noord

member(El, [H|T]) :-
    member_(T, El, H).

member_(_, El, El).
member_([H|T], El, _) :-
    member_(T, El, H).

%%	append(?List1, ?List2, ?List1AndList2)
%
%	List1AndList2 is the concatination of List1 and List2

append([], L, L).
append([H|T], L, [H|R]) :-
	append(T, L, R).

%%	append(+ListOfLists, ?List)
%
%	Concatenate a list of lists.  Is  true   if  Lists  is a list of
%	lists, and List is the concatenation of these lists.
%
%	@param	ListOfLists must be a list of -possibly- partial lists

append(ListOfLists, List) :-
	must_be(list, ListOfLists),
	append_(ListOfLists, List).

append_([], []).
append_([L|Ls], As) :-
	append(L, Ws, As),
	append_(Ls, Ws).


%%	prefix(?Part, ?Whole)
%
%	True iff Part is a leading substring of Whole.  This is the same
%	as append(Part, _, Whole).

prefix([], _).
prefix([E|T0], [E|T]) :-
	prefix(T0, T).


%%	select(?Elem, ?List1, ?List2)
%
%	Is true when List1, with Elem removed results in List2.

select(X, [X|Tail], Tail).
select(Elem, [Head|Tail], [Head|Rest]) :-
	select(Elem, Tail, Rest).


%%	selectchk(+Elem, +List, -Rest) is semidet.
%
%	Semi-deterministic removal of first element in List that unifies
%	Elem.

selectchk(Elem, List, Rest) :-
	select(Elem, List, Rest0), !,
	Rest = Rest0.


%%	select(?X, ?XList, ?Y, ?YList) is nondet.
%
%	Is true when select(X, XList) and   select(Y, YList) are true, X
%	and Y appear in the same locations of their respective lists and
%	same_length(XList, YList) is  true.  A   typical  use  for  this
%	predicate is to _replace_ an element:
%
%	==
%	?- select(b, [a,b,c], 2, X).
%	X = [a, 2, c] ;
%	X = [a, b, c].
%	==

select(X, XList, Y, YList) :-
	select_(XList, X, Y, YList).

select_([], _, _, []).
select_([X|XList], X, Y, [Y|YList]) :-
	select_(XList, X, Y, YList).
select_([X0|XList], X, Y, [X0|YList]) :-
	select_(XList, X, Y, YList).

%%	selectchk(X, XList, Y, YList) is semidet.
%
%	Semi-deterministic version of select/4.

selectchk(X, XList, Y, YList) :-
	select(X, XList, Y, YList), !.

%%	nextto(?X, ?Y, ?List)
%
%	True of Y follows X in List.

nextto(X, Y, [X,Y|_]).
nextto(X, Y, [_|Zs]) :-
	nextto(X, Y, Zs).

%%	delete(?List1, ?Elem, ?List2) is det.
%
%	Is true when Lis1, with all occurences of Elem deleted results in
%	List2.
%
%	@deprecated There are too many ways in which one might want to
%		    delete elements from a list to justify the name.
%		    Think of matching (= vs. ==), delete first/all,
%		    be deterministic or not.
%	@see select/3, subtract/3.

delete([], _, []) :- !.
delete([Elem|Tail], Elem, Result) :- !,
	delete(Tail, Elem, Result).
delete([Head|Tail], Elem, [Head|Rest]) :-
	delete(Tail, Elem, Rest).

/*  nth0/3, nth1/3 are improved versions from
    Martin Jansche <martin@pc03.idf.uni-heidelberg.de>
*/

%%	nth0(?Index, ?List, ?Elem)
%
%	True when Elem is the Index-th  element of List. Counting starts
%	at 0.
%
%	@error	type_error(integer, Index) if Index is not an integer or
%		unbound.
%	@see nth1/3.

nth0(Index, List, Elem) :-
        (   integer(Index)
	->  nth0_det(Index, List, Elem)		% take nth deterministically
	;   var(Index)
	->  List = [H|T],
	    nth_gen(T, Elem, H, 0, Index)	% match
	;   must_be(integer, Index)
	).

nth0_det(0, [Elem|_], Elem) :- !.
nth0_det(1, [_,Elem|_], Elem) :- !.
nth0_det(2, [_,_,Elem|_], Elem) :- !.
nth0_det(3, [_,_,_,Elem|_], Elem) :- !.
nth0_det(4, [_,_,_,_,Elem|_], Elem) :- !.
nth0_det(5, [_,_,_,_,_,Elem|_], Elem) :- !.
nth0_det(N, [_,_,_,_,_,_   |Tail], Elem) :-
        M is N - 6,
	M >= 0,
        nth0_det(M, Tail, Elem).

nth_gen(_, Elem, Elem, Base, Base).
nth_gen([H|Tail], Elem, _, N, Base) :-
        succ(N, M),
        nth_gen(Tail, Elem, H, M, Base).


%%	nth1(?Index, ?List, ?Elem)
%
%	Is true when Elem is  the   Index'th  element  of List. Counting
%	starts at 1.
%
%	@see nth0/3.

nth1(Index, List, Elem) :-
	(   integer(Index)
	->  Index0 is Index - 1,
	    nth0_det(Index0, List, Elem)	% take nth deterministically
	;   var(Index)
	->  List = [H|T],
	    nth_gen(T, Elem, H, 1, Index)	% match
	;   must_be(integer, Index)
	).

%%	nth0(?N, ?List, ?Elem, ?Rest) is det.
%
%	Select/insert element at index.  True  when   Elem  is  the N-th
%	(0-based) element of List and Rest is   the  remainder (as in by
%	select/3) of List.  For example:
%
%	  ==
%	  ?- nth0(I, [a,b,c], E, R).
%	  I = 0, E = a, R = [b, c] ;
%	  I = 1, E = b, R = [a, c] ;
%	  I = 2, E = c, R = [a, b] ;
%	  false.
%	  ==
%
%	  ==
%	  ?- nth0(1, L, a1, [a,b]).
%	  L = [a, a1, b].
%	  ==

nth0(V, In, Element, Rest) :-
	var(V), !,
        generate_nth(0, V, In, Element, Rest).
nth0(V, In, Element, Rest) :-
	must_be(nonneg, V),
	find_nth0(V, In, Element, Rest).

%%	nth1(?N, ?List, ?Elem, ?Rest) is det.
%
%	As nth0/4, but counting starts at 1.

nth1(V, In, Element, Rest) :-
	var(V), !,
        generate_nth(1, V, In, Element, Rest).
nth1(V, In, Element, Rest) :-
	must_be(positive_integer, V),
	succ(V0, V),
	find_nth0(V0, In, Element, Rest).

generate_nth(I, I, [Head|Rest], Head, Rest).
generate_nth(I, IN, [H|List], El, [H|Rest]) :-
        I1 is I+1,
	generate_nth(I1, IN, List, El, Rest).

find_nth0(0, [Head|Rest], Head, Rest) :- !.
find_nth0(N, [Head|Rest0], Elem, [Head|Rest]) :-
        M is N-1,
        find_nth0(M, Rest0, Elem, Rest).


%%	last(?List, ?Last)
%
%	Succeeds when `Last'  is  the  last   element  of  `List'.  This
%	predicate is =semidet= if List is a  list and =multi= if List is
%	a partial list.
%
%	@compat	There is no de-facto standard for the argument order of
%		last/2.  Be careful when porting code or use
%		append(_, [Last], List) as a portable alternative.

last([X|Xs], Last) :-
    last_(Xs, X, Last).

last_([], Last, Last).
last_([X|Xs], _, Last) :-
    last_(Xs, X, Last).


%%	proper_length(@List, -Length) is semidet.
%
%	True when Length is the number of   elements  in the proper list
%	List.  This is equivalent to
%
%	  ==
%	  proper_length(List, Length) :-
%		is_list(List),
%		length(List, Length).
%	  ==

proper_length(List, Length) :-
	'$skip_list'(Length0, List, Tail),
	Tail == [],
	Length = Length0.


%%	same_length(?List1, ?List2)
%
%	Is true when List1 and List2 are   lists with the same number of
%	elements. The predicate is deterministic if  at least one of the
%	arguments is a proper list.  It   is  non-deterministic  if both
%	arguments are partial lists.
%
%	@see length/2

same_length([], []).
same_length([_|T1], [_|T2]) :-
	same_length(T1, T2).


%%	reverse(?List1, ?List2)
%
%	Is true when the elements of List2 are in reverse order compared to
%	List1.

reverse(Xs, Ys) :-
	reverse(Xs, [], Ys, Ys).

reverse([], Ys, Ys, []).
reverse([X|Xs], Rs, Ys, [_|Bound]) :-
	reverse(Xs, [X|Rs], Ys, Bound).


%%	permutation(?Xs, ?Ys) is nondet.
%
%	permutation(Xs, Ys) is true when Xs is a permutation of Ys. This
%	can solve for Ys given Xs or Xs   given Ys, or even enumerate Xs
%	and  Ys  together.  The  predicate  permutation/2  is  primarily
%	intended to generate permutations. Note that  a list of length N
%	has N! permutations and unbounded permutation generation becomes
%	prohibitively expensive, even for  rather   short  lists  (10! =
%	3,628,800).
%
%	If both Xs and Ys are provided  and both lists have equal length
%	the order is |Xs|^2. Simply testing  whether Xs is a permutation
%	of Ys can be  achieved  in   order  log(|Xs|)  using  msort/2 as
%	illustrated below with the =semidet= predicate is_permutation/2:
%
%	  ==
%	  is_permutation(Xs, Ys) :-
%	    msort(Xs, Sorted),
%	    msort(Ys, Sorted).
%	  ==
%
%	The example below illustrate that Xs   and Ys being proper lists
%	is not a sufficient condition to use the above replacement.
%
%	  ==
%	  ?- permutation([1,2], [X,Y]).
%	  X = 1, Y = 2 ;
%	  X = 2, Y = 1 ;
%	  false.
%	  ==
%
%	@error	type_error(list, Arg) if either argument is not a proper
%		or partial list.

permutation(Xs, Ys) :-
	'$skip_list'(Xlen, Xs, XTail),
	'$skip_list'(Ylen, Ys, YTail),
	(   XTail == [], YTail == []		% both proper lists
	->  Xlen == Ylen
	;   var(XTail), YTail == []		% partial, proper
	->  length(Xs, Ylen)
	;   XTail == [], var(YTail)		% proper, partial
	->  length(Ys, Xlen)
	;   var(XTail), var(YTail)		% partial, partial
	->  length(Xs, Len),
	    length(Ys, Len)
	;   must_be(list, Xs),			% either is not a list
	    must_be(list, Ys)
	),
	perm(Xs, Ys).

perm([], []).
perm(List, [First|Perm]) :-
        select(First, List, Rest),
        perm(Rest, Perm).

%%	flatten(+List1, ?List2) is det.
%
%	Is true it List2 is a non nested version of List1.
%
%	@deprecated	Ending up needing flatten/3 often indicates,
%			like append/3 for appending two lists, a bad
%			design.  Efficient code that generates lists
%			from generated small lists must use difference
%			lists, often possible through grammar rules for
%			optimal readability.
%	@see append/2

flatten(List, FlatList) :-
	flatten(List, [], FlatList0), !,
	FlatList = FlatList0.

flatten(Var, Tl, [Var|Tl]) :-
	var(Var), !.
flatten([], Tl, Tl) :- !.
flatten([Hd|Tl], Tail, List) :- !,
	flatten(Hd, FlatHeadTail, List),
	flatten(Tl, Tail, FlatHeadTail).
flatten(NonList, Tl, [NonList|Tl]).


		 /*******************************
		 *	 ORDER OPERATIONS	*
		 *******************************/

%%	max_member(-Max, +List) is semidet.
%
%	True when Max is the largest  member   in  the standard order of
%	terms.  Fails if List is empty.
%
%	@see compare/3
%	@see max_list/2 for the maximum of a list of numbers.

max_member(Max, [H|T]) :-
	max_member_(T, H, Max).

max_member_([], Max, Max).
max_member_([H|T], Max0, Max) :-
	(   H @=< Max0
	->  max_member_(T, Max0, Max)
	;   max_member_(T, H, Max)
	).


%%	min_member(-Min, +List) is semidet.
%
%	True when Min is the smallest member   in  the standard order of
%	terms. Fails if List is empty.
%
%	@see compare/3
%	@see min_list/2 for the minimum of a list of numbers.

min_member(Min, [H|T]) :-
	min_member_(T, H, Min).

min_member_([], Min, Min).
min_member_([H|T], Min0, Min) :-
	(   H @>= Min0
	->  min_member_(T, Min0, Min)
	;   min_member_(T, H, Min)
	).


		 /*******************************
		 *	 LISTS OF NUMBERS	*
		 *******************************/

%%	sumlist(+List, -Sum) is det.
%
%	Sum is the result of adding all numbers in List.

sumlist(Xs, Sum) :-
	sumlist(Xs, 0, Sum).

sumlist([], Sum, Sum).
sumlist([X|Xs], Sum0, Sum) :-
	Sum1 is Sum0 + X,
	sumlist(Xs, Sum1, Sum).

%%	max_list(+List:list(number), -Max:number) is semidet.
%
%	True if Max is the largest number in List.  Fails if List is
%	empty.
%
%	@see max_member/2.

max_list([H|T], Max) :-
	max_list(T, H, Max).

max_list([], Max, Max).
max_list([H|T], Max0, Max) :-
	Max1 is max(H, Max0),
	max_list(T, Max1, Max).


%%	min_list(+List:list(number), -Min:number) is semidet.
%
%	True if Min is the largest number in List.  Fails if List is
%	empty.
%
%	@see min_member/2.

min_list([H|T], Min) :-
	min_list(T, H, Min).

min_list([], Min, Min).
min_list([H|T], Min0, Min) :-
	Min1 is min(H, Min0),
	min_list(T, Min1, Min).


%%	numlist(+Low, +High, -List) is semidet.
%
%	List is a list [Low, Low+1, ... High].  Fails if High < Low.
%
%	@error type_error(integer, Low)
%	@error type_error(integer, High)

numlist(L, U, Ns) :-
	must_be(integer, L),
	must_be(integer, U),
	L =< U,
	numlist_(L, U, Ns).

numlist_(U, U, List) :- !,
	List = [U].
numlist_(L, U, [L|Ns]) :-
	L2 is L+1,
	numlist_(L2, U, Ns).


		/********************************
		*       SET MANIPULATION        *
		*********************************/

%%	is_set(@Set) is det.
%
%	True if Set is a proper  list without duplicates. Equivalence is
%	based on ==/2. The  implementation   uses  sort/2, which implies
%	that the complexity is N*log(N) and   the  predicate may cause a
%	resource-error. There are no other error conditions.

is_set(Set) :-
	'$skip_list'(Len, Set, Tail),
	Tail == [],				% Proper list
	sort(Set, Sorted),
	length(Sorted, Len).


%%	list_to_set(+List, ?Set) is det.
%
%	True when Set has the same element   as  List in the same order.
%	The left-most copy of the duplicate  is retained. The complexity
%	of this operation is |List|^2.
%
%	@see sort/2.

list_to_set(List, Set) :-
	list_to_set_(List, Set0),
	Set = Set0.

list_to_set_([], R) :-
	close_list(R).
list_to_set_([H|T], R) :-
	memberchk(H, R), !,
	list_to_set_(T, R).

close_list([]) :- !.
close_list([_|T]) :-
	close_list(T).


%%	intersection(+Set1, +Set2, -Set3) is det.
%
%	True if Set3 unifies with the intersection of Set1 and Set2.
%	The complexity of this predicate is |Set1|*|Set2|
%
%	@see ord_intersection/3.

intersection([], _, []) :- !.
intersection([X|T], L, Intersect) :-
	memberchk(X, L), !,
	Intersect = [X|R],
	intersection(T, L, R).
intersection([_|T], L, R) :-
	intersection(T, L, R).


%%	union(+Set1, +Set2, -Set3) is det.
%
%	True if Set3 unifies with the union of Set1 and Set2.
%	The complexity of this predicate is |Set1|*|Set2|
%
%	@see ord_union/3.

union([], L, L) :- !.
union([H|T], L, R) :-
	memberchk(H, L), !,
	union(T, L, R).
union([H|T], L, [H|R]) :-
	union(T, L, R).


%%	subset(+SubSet, +Set) is semidet.
%
%	True if all elements of SubSet belong to Set as well. Membership
%	test is based on memberchk/2.  The complexity is |SubSet|*|Set|.
%
%	@see ord_subset/2.

subset([], _) :- !.
subset([E|R], Set) :-
	memberchk(E, Set),
	subset(R, Set).


%%	subtract(+Set, +Delete, -Result) is det.
%
%	Delete all elements from `Set' that   occur  in `Delete' (a set)
%	and unify the  result  with  `Result'.   Deletion  is  based  on
%	unification using memberchk/2. The complexity is |Delete|*|Set|.
%
%	@see ord_subtract/3.

subtract([], _, []) :- !.
subtract([E|T], D, R) :-
	memberchk(E, D), !,
	subtract(T, D, R).
subtract([H|T], D, [H|R]) :-
	subtract(T, D, R).
