/*
EIF400 loriacarlos@gmail.com
Tests the lexer  module
II-2020
*/

:- use_module(lexer, [tokenize_file/2  as tokenize,
                      tokenize_atom/2
]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONTROLLER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

default_test_file('./test/expr.test').

:- initialization
     writeln('*** Testing Lexer ***'),
    (current_prolog_flag(argv, [File | _]) -> true 
                                           ; default_test_file(File)
    ),
    catch(testLexer_from_file(_, File), Error,  handle_error(Error)) ,
    Atom = 'x != x+ 1',
    catch(testLexer_from_atom(Atom), Error,  handle_error(Error)) ,
    halt
.

handle_error(Error) :- format('>>> Error ~q <<<~n', [Error]).


testLexer_from_file(Tokens, File) :- 
    format('~n*** Testing lexer with file "~s" *** ~n', [File]),
    tokenize(File, Tokens),
    format('*** Tokens in ~q***~n',[File]),
    format('~n~q~n', [Tokens])
.


testLexer_from_atom(Atom):-
    format('~n*** Testing lexer with atom ~q *** ~n', [Atom]),
    tokenize_atom(Atom, Tokens),
    format('*** Tokens in atom ~q ***~n',[Atom]),
    format('~n~q~n', [Tokens])
.