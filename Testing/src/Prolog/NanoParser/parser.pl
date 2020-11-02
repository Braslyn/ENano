/*
  loriacarlos@gmail.com
  II-2020
  
*/

:- module(parser, [ parseNanoFile/2,
                    parseNanoTokens/2,
                    parseNanoAtom/2
]).
:- use_module('../NanoLexer/lexer', 
                     [tokenize_file/2  as tokenize,
                      tokenize_stream/2,
                      tokenize_atom/2
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Entry Point %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parseNanoFile(File, Tree) :-
   tokenize(File, Tokens),
   parseNanoTokens(Tokens, Tree ).

parseNanoTokens(Tokens, Tree) :- nanoFile(Tree,Tokens,[]).


parseNanoAtom(Atom, Tree) :-
   tokenize_atom(Atom , Tokens),
   parseNanoTokens(Tokens, Tree).

parseExprStream(Stream, Tree) :- 
   tokenize_stream(Stream , Tokens),
   parseNanoTokens(Tokens, Tree). 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Init Parse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nanoFile -> Incia el proceso
% declarationList -> Vela por la lista de declaraciones

nanoFile( nanoProgram( decs(L),main(M)) ) --> declarationList(L),main(M).
declarationList([]) --> [].
declarationList([D|L]) --> declaration(D),declarationList(L).
main(main(Body)) --> [main], ['{'] , body(Body) , [']'].
body([]).
declaration(dec()) --> dekKeyword(KeyWord), typeDeclaration(Type),id(I).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GRAMMAR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
withExpr(with(L, E)) --> ['with'], ['{'], listAssignments(L), ['}'], [eval], expr(E).

listAssignments([]), ['}'] --> ['}'].
listAssignments([A]), ['}'] --> assign(A), ['}'].
listAssignments([A, B| R]) --> assign(A), [and], listAssignments([B|R]).

assign(X=V) --> [X], {atom(X)}, ['='], expr(V).

expr(E) --> monomAdd(E).

monomAdd(T) --> monom(M), restMonomAdd(RM), {build_tree('+', [M | RM], T)}.
restMonomAdd([]) --> [].
restMonomAdd([RM]) --> ['+'], monomAdd(RM).

monom(M) --> factorMult(M).

factorMult(T) --> factorExpr(F), restFactorMult(RF), {build_tree('*', [F | RF], T)}.
restFactorMult([]) --> [].
restFactorMult([RM]) --> ['*'], monom(RM).


factorExpr(E) --> ['('], expr(E), [')'].
factorExpr(N) --> [A], {atom_number(A, N), !}.
factorExpr(A) --> [A], {atomic(A), !}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Semantic Helpers %%%%%%%%%%%%%%%%%%%%%%%%%%%%
build_tree(_, [Left], Left).
build_tree(Oper, [Left, Right], T) :- T =.. [Oper, Left, Right].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

