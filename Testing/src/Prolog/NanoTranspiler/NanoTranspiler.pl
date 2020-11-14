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
    parse(ExprFile, Tree), !,
    transpileNano(Tree,OutStream)
.

transpileNano(nanoProgram(Declare,Main),Java):-transpileprogram(Tree,Java).
transpileprogram(_,'class A {}').