/*
  loriacarlos@gmail.com
  II-2020
  Transpiler of Expressions demo
  modify by Braslyn Rodriguez Ramirez 402420750
*/
:- module(transpile, [transpileExprFile/1,
                      transpileExprFile/2,
                      transpileExprStream/2                      
                      ]).
:- use_module('../NanoParser/parser', [
   parseNanoFile/2 as parse
]).

%:- use_module('../util/util', [yieldClassName/2]).

transpileExprFile(ExprFile) :-
   current_output(OutStream),
   transpileExprStream(ExprFile, OutStream)
.
transpileExprFile(ExprFile, OutFile):-
   open(OutFile, write, OutStream),
   transpileExprStream(ExprFile, OutStream) 
.
transpileExprStream(ExprFile, OutStream) :- 
    parse(ExprFile, Tree),write(Tree),!,
    transpileNano(Tree,OutStream),write(OutStream)
.

%%%%%%%%%%%%%%%%%%%%%%% import manage %%%%%%%%%%%%%%%%
:-dynamic imports/1.
:-dynamic unary/1.


unarImport:- (retract(unary(X)),assert(unary(X)),X==fail) -> (retract(unary(_)),assert(unary(true)),retract(imports(R)),format(atom(F),'~simport java.util.function.UnaryOperator;\n',[R])
,assert(imports(F))).

listImport:- fail.

initImports:- retractall(unary(_)),retractall(imports(_)),assert(imports('')),assert(unary(fail)).


%%%%%%%%%%%%%%%%%%%%%%%%% Transpile Init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
transpileNano(nanoProgram(Declare,Main),Java):- initImports ,C='public class Simple {~s
   public static void main(String args[]){~s
   }}',
transpileprogram(Declare,Main,Decs,Lines) , format(atom(Class),C,[Decs,Lines]),retract(imports(Imports)),format(atom(Java),'~s ~s',[Imports,Class]).

transpileprogram(declars(List1),main(List2),R1,R2):- dLines(List1,'',R1),blines(List2,'',R2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Dclarations Lines %%%%%%%%%%%%%%%%%%%%%%%%%%%

dLines([F|R],Acc,Result):- declareMethod(F,Re1), format(atom(X),'~s \n ~s',[Acc,Re1]) , dLines(R,X,Result).
dLines([F|R],Acc,Result):- declare(F,Re1), format(atom(X),'~s \n ~s',[Acc,Re1]) , dLines(R,X,Result).
dLines([],R1,R):-format(atom(R),'~s',[R1]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Declarations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareMethod(dec(method,Type,funct(Id,Param),Body),R ):- mbody(Body,R1),dtype2(Type,Ty),paramtype(Type,TP),params(Param,'',P),format(atom(R),'static ~s ~s(~s ~s) ~s',[Ty,Id,TP,P,R1]).
declare(dec(val,Type,Id,Body),R ):-  dbody(Body,R1),dtype(Type,Ty),format(atom(R),'final ~s ~s ~s; ',[Ty,Id,R1]).
declare(dec(var,Type,Id,Body),R ):-  dbody(Body,R1),dtype(Type,Ty),format(atom(R),'~s ~s ~s; ',[Ty,Id,R1]).
%dec(method, type( arrow(int,int) ) , funct( fact,[n] ) , dIf( [1],n==0,funct(f,[n-1] ) ) )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% type for declaration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dtype(type(arrow(X,X)),R):- changeInt(X,Y),format(atom(R),'UnaryOperator<~s>',[Y]), (unarImport;true).
dtype(type(arrow(X,Y)),R):- format(atom(R),'BinaryOperator<~s,~s>',[X,Y]).
dtype(type(Type),Type).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%method body %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%mbody(dIf([F],P,B),R):- params(Param,'',P2) , format(atom(R),'{ return ( ~q )? ~q : ~q(~s); }',[P,F,Funct,P2]).
mbody(dIf([F],P,funct(Funct,Param)),R):- params(Param,'',P2) , format(atom(R),'{ return ( ~q )? ~q : ~q(~s); }',[P,F,Funct,P2]).
mbody(dIf([F],P,B),R):- simplify(B,B1),format(atom(R),'{ return ( ~q )? ~q : ~s; }',[P,F,B1]).
dtype2(type(arrow(_,Y)),Y).
paramtype(type(arrow(X,_)),X).
%%%%%%%%%%%%%%%%%%%%%%%%%% change types %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
changeInt(X,Y):- (X==int -> Y='Integer');Y=X.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% declaration Body %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dbody([],' ').
dbody(lambda(Id,body(dIf([F],P,[B]))),R):-simplify(B,B1), format(atom(R),'= ~s -> ( ~q )? ~q : ~s',[Id,P,F,B1]).
dbody(lambda(Id,body(B)),R):- simplify(B,B1) ,format(atom(R),'= ~s -> ~s',[Id,B1]).
dbody(X,R):- atom(X),format(atom(R),'= ~s',[X]).
dbody(X,R):- format(atom(R),'= ~q',[X]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Params %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params([],'','').
params([F|R],Acc,Result):- object(F,L) ,format(atom(R1),'~s~q',[Acc,L]), params2(R,R1,Result).
params([F|R],Acc,Result):- format(atom(R1),'~s~q',[Acc,F]), params2(R,R1,Result).
params2([],Acc,Acc).
params2([F|R],Acc,Result):- object(F,L) ,format(atom(R1),'~s~q',[Acc,L]), params2(R,R1,Result).
params2([F|R],Acc,Result):- format(atom(R1),'~s,~q',[Acc,F]),params2(R,R1,Result).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main Lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
blines([],Acc,Acc).
blines([F|R],Acc,Result):- line(F,N),format(atom(R1),'~s \n ~s',[Acc,N]),blines(R,R1,Result).


%line(X,R):-declare(D,R).
line(X,R):- print(X,R).

%%%%%%%%%%%%%%%%%%%% Trees simplify %%%%%%%%%%%%%%%%%%%%%%%%%%%
simplify(V,R):- funct(V,R).
simplify(V,R):- atom(V),format(atom(R),'~s',[V]).
simplify(V,R):- number(V),format(atom(R),'~d',[V]).
simplify(V,R):- V=..[Oper,X],format(R,'~s~s',[Oper,X]).
simplify(V,T):- V=..[Oper,X,Y], simplify(X,X1),simplify(Y,Y1),format(atom(T),'~s~s~s',[X1,Oper,Y1]).


%%%%%%%%%%%%%%%%%%%% Print statment %%%%%%%%%%%%%%%%%%%%%%%%%%%%
print(print(format(String,Param)),R):- params(Param,'',P) ,format(atom(R),'System.out.println(~q,~s);',[String,P]).
print(print(format(String,Param)),R):- params(Param,'',P), format(atom(R),'System.out.println(~q,~s);',[String,P]).
print(print(funct(Id,Param)),R):- params(Param,'',P) , format(atom(R),'System.out.println(~s(~s));',[Id,P]).
print(print(X),R):- atom(X),format(atom(R),'System.out.println(~s);',[X]).
print(print(X),R):- format(atom(R),'System.out.println(~q);',[X]).

%%%%%%%%%%%%%%%%%%%% utils Methods %%%%%%%%%%%%%%%%%%%%%%%%
funct(funct(Id,Param),R):- params(Param,'',P),format(atom(R),'~s(~s)',[Id,P]).
object(obj(Id,funct(Funct,Param)),R):- params(Param,'',P) ,format(atom(R),'this.~s.~s(~s);',[Id,Funct,P]).

/*
   dIf([1],n==0,[funct(fact,[n-1])]))])
   dec(val,type(arrow(int,int)),abs,lambda(x,body(dIf([x],x>=0,[x]))))

   dec(method, type( arrow(int,int) ) , funct( fact,[n] ) , dIf( [1],n==0,funct(f,[n-1] ) ) )
*/