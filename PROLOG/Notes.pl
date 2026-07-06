% This is a comment


% Define Facts as relationships
% siblings(adam, john)

% Define rules which can be recursive

% :-  if
% ,   and
% ;   or
% not not
% =   unify
% \=  not equal condition
% ==  exactly equal condition
% \+  negates the following

% Variables only start with capital or underscore
% Example: X, Y, _Variable

% Facts are written like a function
% period is needed
% fat(johny).
% brown(dog).
% friends(julien, bob).

% Rules start with a relationship
% friendship(X, Y) :- likes(X,Y); likes(Y,X).
% This reads as
% There is a friendship between X and Y 
% if X likes Y or Y likes X

% queries start with ?- and end with period
% ?- likes(dan,sally).
% ========================================================================