%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONTROLLER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- use_module(parser, [
    parseNanoFile/2
]).
:- initialization 
     format('*** Testing Nano Parser ***~n'),
     testParserExpr,
     halt
.
default_test_file('./test/expr.test').

testParserExpr :- 
    (current_prolog_flag(argv, [File | _]) -> true 
                                           ; default_test_file(File)
    ),
    format('~n*** Testing parser with file "~s" *** ~n', [File]),
    catch(parseNanoFile(File, Tree), Error, handle_error(Error)), !,
    format('~n*** File="~s" parsed to AST=~w ***~n',[File, Tree])
.
testParserExpr :- format('~n***  --> PARSING FAILED! ***~n').

handle_error(Error) :- format('>>> Error ~q <<<~n', [Error]).