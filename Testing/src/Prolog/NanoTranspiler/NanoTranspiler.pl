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
    parse(ExprFile, Tree),!,
    transpileNano(Tree,OutStream),write(OutStream)
.

transpileNano(nanoProgram(Declare,Main),Java):- C='public class Simple{~s 
   public static void main(String args[]){  
   ~s
   }
}  ',transpileprogram(Declare,Main,Decs,Lines) , format(atom(Java),C,[Decs,Lines]).

transpileprogram(declars(List1),main(List2),R1,R2):- dLines(List1,' ',R1),lines(List2,R2).

dLines([F|R],Acc,Result):- declare(F,Re1), format(atom(X),'~s \n ~s;',[Acc,Re1]) , dLines(R,X,Result).
dLines([],R1,R):-format(atom(R),'~s',[R1]).


declare(dec(method,Type,funct(Id,Param),Body),R ):- mbody(Body,R1),dtype2(Type,Ty),params(Param,'',P),format(atom(R),'~s ~s(~s) ~s',[Ty,Id,P,R1]).
declare(dec(val,Type,Id,Body),R ):-  dbody(Body,R1),dtype(Type,Ty),format(atom(R),'final ~s ~s ~s',[Ty,Id,R1]).
declare(dec(var,Type,Id,Body),R ):-  dbody(Body,R1),dtype(Type,Ty),format(atom(R),'~s ~s ~s',[Ty,Id,R1]).
%dec(method, type( arrow(int,int) ) , funct( fact,[n] ) , dIf( [1],n==0,funct(f,[n-1] ) ) )

params([],'','').
params([F|R],Acc,Result):-format(atom(R1),'~s ~s',[Acc,F]), params2(R,R1,Result).
params2([],Acc,Acc).
params2([F|R],Acc,Result):- format(atom(R1),'~s,~s',[Acc,F]),params2(R,R1,Result).

dtype(type(arrow(X,X)),R):- format(atom(R),'UnaryOperator<~s>',[X]).
dtype(type(arrow(X,Y)),R):- format(atom(R),'BinaryOperator<~s,~s>',[X,Y]).
dtype(type(Type),R):- format(atom(R),'~s',[Type]).

mbody(dIf([F],P,B),R):- format(atom(R),'{ return ( ~q )? ~q : ~q; }',[P,F,B]).
dtype2(type(arrow(_,Y)),Y).

dbody([],' ').
dbody(lambda(Id,body(dIf([F],P,B))),R):- format(atom(R),'= ~s -> ( ~q )? ~q : ~q',[Id,P,F,B]).
dbody(lambda(Id,body(B)),R):- format(atom(R),'= ~s -> ~q',[Id,B]).
dbody(X,R):- format(atom(R),'= ~s',[X]).


%lines([F|R],Result):- lines(D,Result).
lines([],' ').

/*
   dIf([1],n==0,[funct(fact,[n-1])]))])
   dec(val,type(arrow(int,int)),abs,lambda(x,body(dIf([x],x>=0,[x]))))

   dec(method, type( arrow(int,int) ) , funct( fact,[n] ) , dIf( [1],n==0,funct(f,[n-1] ) ) )
*/