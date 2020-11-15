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

parseNanoTokens(Tokens, Tree) :- nanoFile(Tree,Tokens,[])
.


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

nanoFile( nanoProgram(declars(L),M) ) --> declarationList(L),main(M).

%%%%%%%%%%%% Delcarations %%%%%%%%%%%%%%%%
declarationList([]) --> [].

declarationList([D|L]) --> declaration(D),declarationList(L).

declaration(dec(K,T,I,E)) --> dekKeyword(K), typeDeclaration(T), identificator(I),expresion(E).

typeDeclaration(type(Type)) --> ['<'], type(Type) , ['>'].

type(arrow(S,L)) --> [S],{basicType(S)}, ['->'], [L],{basicType(L)}. % arrow -> [var,<,int,'->',int,>, foo]

type(S) --> [S],{basicType(S)}.%ok unit

type(list(S)) --> ['['],[S],{basicType(S)},[']']. % List 

basicType(S):- member(S,[int,'String',float,double]),!. %%%%%%%%%%%%%%%%% types

dekKeyword(S)-->[S],{member(S, [var,val,method])},{!}.%ok %%%%%%%%%%%% key words

%%%%%%%%%%%%%%%%%%%% Expresions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


expresion(Exp)--> ['='] ,vstring(Exp).
expresion(Exp)--> ['='] ,numbs(Exp).
expresion(Exp)-->['='], lambda(Exp).
expresion(Exp)-->['='], declarativeIf(Exp).
expresion(Exp)-->['='], list(Exp).
expresion([])-->[],!.


vstring(X) --> [X],{isString(X)}.
%%%%%%%%%%%%%%%%%%%%%%%%% list exp %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

list(L)--> ['['], listBody(L) ,[']'].
listBody(body([V|R])) --> (generalVariable(V)|operation(V)), listBody2(R).
listBody([])--> [],!.
listBody2([V|R]) --> [','], (generalVariable(V)|operation(V)),listBody2(R). 
listBody2([])-->[],!.
%%%%%%%%%%%%%%%%%%%%%%%%% Lambda %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/*

  X -> ????, X -> X , x -> x+1 , X -> X 'x' R , X -> 1 if (predicado) else -X 

*/
lambda(lambda(X,body(N))) --> id(X) , ['->'], declarativeIf(N). 

lambda(lambda(X,body(N)))--> id(X) , ['->'] , variable(N).

lambda(lambda(X,body(N)))--> id(X) , ['->'] , operation(N).

%modificar ----------------------------------------------------------------------------------------------
operation(T)--> function(T).
operation(T)--> negationNumber(X),generalVariable(K),{(atom_number(K,V)|V=K),unary_tree(X,V,T)}.
operation(T) --> generalVariable(K),{(atom_number(K,X)|X=K)},operations(Oper),operation(Y),{build_tree(Oper,[X|Y],T)} .
operation(T) --> ['('], operation(T), [')'].
operation(T),[')'] --> generalVariable(T),[')'].
operation([T]) --> generalVariable(X),{(atom_number(X,T)|T=X)}.
%%%%%%%%%%%%%%%%%%%%%%%% if -- ternario %%%%%%%%%%%%%%%%%%%%%%%

if(if(X,Body,Else)) --> [if], ['('],predicate(X),[')'],['{'],lines(Body),['}'], else(Else).
else([]) --> [].
else(elif(X,Body,Else))-->[elif], ['('],predicate(X),[')'],['{'],lines(Body),['}'],else(Else).
else(Else)-->[else],['{'],lines(Else),['}'].

predicate2(T)--> generalVariable(J),{(atom_number(J,S)|S=J)},comparator(X), generalVariable(K),{(atom_number(K,V)|V=K),build_tree(X,[S,V],T)}.
predicate(T) --> predicate2(T).

declarativeIf(dIf(X,N,Y)) --> operation(X) , [if] , predicate(N) , [else], operation(Y).

%%%%%%%%%%%%%%%%%%%% numbers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
generalVariable(GV)-->(function(GV)|variable(GV)|sObjects(GV)). 

variable(V)-->(id(V)|numbs(V)|vstring(V)),!.


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


%%%%%%%%%%%%%%%%%%%%%%% Objects %%%%%%%%%%%%%%%%%%%%%%%%%%%

sObjects(obj(X,Y))--> [this],['.'],id(X),method(Y).
method(M)--> ['.'],function(M).
method([])-->[].

sformat(format(S,P)) --> ['String'],['.'],['format'],['('],vstring(S),[','],params(P),[')'].


%%%%%%%%%%%%%%%%%%%%%%% Println() %%%%%%%%%%%%%%%%%%%%%%%%%%
println(print(G))--> [println], ['('],generalVariable(G),[')'].
println(print(X)) --> [println] , ['('],operation(X),[')'].
println(print(M)) --> [println] , ['('],sObjects(M),[')'].
println(print(F)) --> [println] , ['('],sformat(F),[')'].

%%%%%%%%%%%%%%%%%%%% Lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lines([])-->[].

lines([L|Li]) --> line(L),lines(Li).

line(L)--> if(L).

line(L)--> declaration(L).

line(L)--> withExpr(L).

line(L)--> println(L).

line(L)--> sformat(L).

%%%%%%%%%%%%%%%%%%%%%%%%% Comparators & operators %%%%%%%%%%%%%%%%%%%%%%%%%
comparator(X) --> [X],{isComparator(X)}.
operations(X) --> [X],{isOperation(X)}.
logic(X)-->[X],{isLogic(X)}.

negationNumber('-') --> ['-'].
not('!')-->['!'].
isLogic(X):-member(X,['&&','||']).
isComparator(X):- member(X,['>','<','==','!','<=','>=']),!.
isOperation(X):- member(X,['+','-','*','/','**']),!.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

identificator(X)--> (id(X)|function(X)).

function(funct(Nom,Vars))--> variable(Nom),['('], params(Vars),[')'].

params([V|R]) --> operation(V),params2(R).
params([V|R]) --> generalVariable(V),params2(R).
params(V) --> operation(V).
params(V) --> generalVariable(V).
params([])-->[].
params2([V|R]) --> [','] ,operation(V),params2(R).
params2([V|R])--> [','] , generalVariable(V),!,params2(R).
params2(V)-->generalVariable(V).
params2(V)-->operation(V).
params2([])-->[].

id(S)-->[S],{!,valid_id(S)}.%ok

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
valid_id(V) :- re_match("^[a-zA-Z_]+[\\w]*$", V).% ok
isString(S) :- re_match("^\".*\"$",S).% ok 

%%%%%%%%%%%%%%%%%%%%%%%%%  Main  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
main(main(Body)) --> [main], ['{'], body(Body), ['}'].

body([]),['}'] --> ['}'].
body([L|R]) --> line(L),lines(R). 

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Semantic Helpers %%%%%%%%%%%%%%%%%%%%%%%%%%%%
build_tree(_, [Left], Left).
build_tree(Oper, [Left, Right], T) :- T =.. [Oper, Left, Right].
unary_tree(Oper,One,T):- T=.. [Oper,One].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

