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

declaration(dec(K,T,I,E)) --> dekKeyword(K), typeDeclaration(T), identificator(I),expresion(E).

typeDeclaration(declar(Type)) --> ['<'], type(Type) , ['>'].

type(arrow(S,L)) --> [S],{basicType(S)}, ['->'], [L],{basicType(L)}. % arrow -> [var,<,int,'->',int,>, foo]

type(S) --> [S],{basicType(S)}.%ok unit

type(list(S)) --> ['['],[S],{basicType(S)},[']']. % List 

basicType(S):-member(S,[int,string,float,double]),!. %%%%%%%%%%%%%%%%% types

dekKeyword(S)-->[S],{member(S, [var,val,method])},{!}.%ok %%%%%%%%%%%% key words

%%%%%%%%%%%%%%%%%%%% Expresions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

expresion([])-->[].
expresion(Exp)--> ['='] , numbs(Exp).
expresion(Exp)-->['='], lamda(Exp).

%%%%%%%%%%%%%%%%%%%%%%%%% Lambda %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/*

  X -> ????, X -> X , x -> x+1 , X -> X 'x' R , X -> 1 if (predicado) else -X 

*/

lamda(lambda(X,body(N)))--> id(X) , ['->'] , variable(N).

lamda(lambda(X,body(N)))--> id(X) , ['->'] , operation(N).

operation(T) --> variable(X) , operations(Oper), variable(Y),{build_tree(Oper,[X|Y],T)}. %modificar

%%%%%%%%%%%%%%%%%%%%%%%% if -- ternario %%%%%%%%%%%%%%%%%%%%%%%

if(if(X,Body,Else)) --> [if], predicate(X) ,lines(Body), else(Else).
else([]) --> [].
else(Else)--> lines(Else). 
predicate(predicate(comp(X,S,Se))) --> variable(S) , comparator(X) , variable(Se).

declarativeIf(dIf(X,N,Y)) --> variable(X) , [if] , predicate(N) , [else], variable(Y).

%%%%%%%%%%%%%%%%%%%% numbers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
variable(V)--> (numbs(V)|id(V)).


numbs(N) --> (snum(X)|num(X)),{atomic_list_concat(X, N)}. %ok


num([N|Next])--> digits(N),!,anum(Next). %ok          1.xxxx
num([D|N])--> [D],{dot(D)},!,fract(N). % ok    .123(e10)


anum([D|N])--> [D],{dot(D)}, !,fract(N).
anum([E|R])--> eExponent(E), !,exponential(R). %ok
anum([])-->[],!.

snum([S|N])--> sign(S),num(N). %ok


fract([E|N])--> eExponent(E),exponential(N),!. %ok
fract([N|E])--> digits(N),exponents(E),!.%ok
fract([N]) --> digits(N),!. %ok
fract([])-->[],!. %ok

exponents([E|R])--> eExponent(E),exponential(R). %ok
exponential([S,N])--> sign(S) , {!} ,digits(N).%ok
exponential([N])--> digits(N). %ok

%%%%%%%%%%%%%%%%%% special for numbers %%%%%%%%%%%%%%%%&&&
digits(D)-->[D],{atom_number(D,Num),number(Num)}.%ok
sign(S)-->[S],{member(S,['-','+']),!}. %ok
dot('.'). %ok
eExponent(E)--> [E],{member(E,['E','e']),!}.%ok


%%%%%%%%%%%%%%%%%%%% Lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lines([])-->[].

lines([L|Li]) --> line(L),lines(Li).

line(L)--> if(L).

line(L)--> withExpr(L).


%%%%%%%%%%%%%%%%%%%%%%%%% Comparator %%%%%%%%%%%%%%%%%%%%%%%%%
comparator(X) --> [X],{member(X,['>','<','==','!','<=','>='])}.
operations(X) --> [X],{member(X,['+','-','*','/','**'])}.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

identificator(X)--> (id(X)|function(X)).

function(funct(Nom,Vars))--> variable(Nom),['('], params(Vars),[')'].

params([F|R]) --> id(F),!,params(R).
params([])-->[].

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

