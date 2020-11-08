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
   tokenize(File, Tokens),parseNanoTokens(Tokens, Tree ).

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
% main() vira porque que el main este correcto.

nanoFile( nanoProgram(declars(L),main(M)) ) --> declarationList(L),main(M).

%%%%%%%%%%%% Delcarations %%%%%%%%%%%%%%%%
declarationList([]) --> [].

declarationList([D|L]) --> declaration(D),declarationList(L).

declaration(dec(K,T,I,E)) --> dekKeyword(K), typeDeclaration(T), id(I),expresion(E).

typeDeclaration(declar(Type)) --> ['<'], type(Type) , ['>'].

type(arrow(S,L)) --> [S],{basicType(S)}, ['->'], [L],{basicType(L)}. % arrow -> [var,<,int,'->',int,>, foo]

type(S) --> [S],{basicType(S)}.%ok unit

type(list(S)) --> ['['],[S],{basicType(S)},[']']. % List 

basicType(S):-member(S,[int,string,float,double]),!.

dekKeyword(S)-->[S],{member(S, [var,val,method])},{!}.%ok

%%%%%%%%%%%%%%%%%%%% Expresions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

expresion([])-->[].
expresion(Exp)--> ['='] , [Exp].
if(if(X,Body,Else)) --> [if], predicate(X) , else(Else).
else([]) --> [].
else(Else)--> lines(Else). 
predicate(predicate(comp(X,S,Se))) --> [S] , comparator(X) , [Se].

%%%%%%%%%%%%%%%%%%%% Lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lines([])-->[].
lines([L|Li]) --> line(L),lines(Li).

line(L)--> if(L).

line(L)-->withExpr(L).


%%%%%%%%%%%%%%%%%%%%%%%%% Comparator %%%%%%%%%%%%%%%%%%%%%%%%%
comparator(X) --> [X],{member(X,['>','<','==','!','<=','>='])}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id(S)-->[S],{valid_id(S)}.%ok
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
valid_id(V) :- re_match("[a-zA-Z_][\\w]*", V).% +-


%%%%%%%%%%%%%%%%%%%%%%%%%  Main  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
main(main(Body)) --> [main], ['{'], body(Body), ['}'].

body([]),['}'] --> ['}'].


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

