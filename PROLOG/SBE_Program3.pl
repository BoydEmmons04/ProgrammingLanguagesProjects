%!  SBE_Program3.pl
%   @author Boyd Emmons <sbe0007@uah.edu>
%   @date 2026-07-01
%   @copyright 2026, Boyd Emmons
%   @license MIT
%   @version 1.0
%   @description The SBE_Program3.pl module defines rules for
%   determining if two lists are disjoint, counting occurrences
%   of a value, and converting numeric grades to letter equivalents.

%!  disjoint(+List1:list, +List2:list) is semidet.
%
%   True if List1 and List2 have no common elements.
%   Fails immediately if any element exists in both.
%
%   @param List1 The first list to compare.
%   @param List2 The second list to compare.

% Base case if list is empty
disjoint([], _).

% If the head of the list is not a member of the second list, recurse
disjoint([H|T], L2) :- \+ member(H, L2), disjoint(T, L2).

%!  countValues (+Value:any, +List:list, -Count:int) is det.
%
%   Counts the number of occurrences of Values in List
%
%   @param Value The value to count.
%   @param List The list to search.
%   @param Count The number of occurrences of Value in List.

% Base case: empty list has 0 occurrences of any value
countValues(_, [], 0). 

% If the first value is the one were looking for add 1 and recurse
countValues(X, [X|T], N) :- countValues(X, T, N1), N is N1 + 1.

% If the first value is not the one were looking for
countValues(X, [H|T], N) :- X \= H, countValues(X, T, N).

%!  letter(+Score:int, -Letter:atom) is semidet.
%
%   Converts a numeric score to a letter grade.
%   
%   @param Score The numeric score to convert.
%   @param Letter The corresponding letter grade.

% Base case
letter(0, 0).

% ==============
% TODO: validate input is number
% ==============

% Return A if score is >= 90 and <= 100
letter(Score, 'A') :- Score >= 90, Score =< 100.
letter(Score, 'B') :- Score >= 80, Score < 90.
letter(Score, 'C') :- Score >= 70, Score < 80.
letter(Score, 'D') :- Score >= 65, Score < 70.
letter(Score, 'F') :- Score >= 0, Score < 65.

% Catch all other values
letter(_, unknown_grade_value).