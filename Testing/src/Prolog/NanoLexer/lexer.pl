/*
EIF400 loriacarlos@gmail.com
Simple recursive lexer Demo
modify by Braslyn Rodriguez Ramirez 402420750
          Enrique Mendez Cabezas 117390080
          Philippe Gairaud Quesada 117290193
II-2020
*/

:- module(lexer, [tokenize_file/2, 
                  tokenize_stream/2,
                  tokenize_atom/2
                 ]).
                  
:- use_module(library(pcre)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Entry Point %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tokenize_stream(Stream, Tokens) :-
   read_stream_to_codes(Stream, Codes),
   close(Stream),
   codes_to_chars(Codes, Chars),
   getTokens(Chars, Tokens)
.
tokenize_file(File, Tokens) :- open(File, read, Stream),
                               tokenize_stream(Stream, Tokens)
                          
.

tokenize_atom(Atom, Tokens):-
   atom_to_memory_file(Atom, Handle), 
   open_memory_file(Handle, read, Stream), 
   tokenize_stream(Stream, Tokens)
.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tokens becomes the list of atoms conforming the tokens occurring in list of chars Input
getTokens(Input, Tokens) :- extractTokens(Input, ExTokens), 
                            delete(ExTokens, [], Tokens) % delete empty tokens
.
% Extracts one by one the tokens delimited by whitespaces
extractTokens([], []) :- !.
extractTokens(Input, [Token | Tokens]) :-       skipWhiteSpace(Input, InputNWS),
                                                startOneToken(InputNWS, Token, Rest),
                                                extractTokens(Rest, Tokens)
.
% Skip White Space(s)
skipWhiteSpace([C | Input], Output) :- isWhiteSpace(C), !, 
                                       skipWhiteSpace(Input, Output)
.
skipWhiteSpace(Input, Input)
.
% START LEXING TOKEN
startOneToken(Input, Token, Rest) :- startOneToken(Input, [], Token, Rest)
.
startOneToken([], P, P, []).
startOneToken([C | Input], Partial, Token, Rest) :- isDigit(C), !,
                                                    finishNumber(Input, [ C | Partial], Token, Rest)
.

startOneToken([C | Input], Partial, Token, Rest) :- isLetter(C), !,
                                                    finishId(Input, [ C | Partial], Token, Rest)
.



startOneToken([C | Input], Partial, Token, Rest) :- isSpecial(C), !,
                                                    finishSpecial(Input, [ C | Partial], Token, Rest)
.
startOneToken([C | Input], Partial, Token, Rest) :- isQuote(C), !,
                                                    finishQuote(Input, [ C | Partial], Token, Rest)
.
startOneToken([C | _] , _, _, _)                  :- report_invalid_symbol(C)
.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
report_invalid_symbol(C) :-
    Msg='*** >>> "~s": invalid symbol found in input stream ***',
    format(atom(A), Msg, C),
    throw(A)
. 

% NUMBER
finishNumber(Input, Partial, Token, Rest) :- finishToken(Input, isDigit, Partial, Token, Rest)
.
% ID
finishId(Input, Partial, Token, Rest) :- finishToken(Input, isLetterOrDigit, Partial, Token, Rest)
.
% DOUBLE QUOTE
finishQuote([C | Input],[Q|Partial], Token, Input) :- Q\=='\\',isQuote(C), !,
                                                   convertToAtom([C,Q | Partial], Token) 
.
finishQuote([C | Input], Partial, Token, Rest) :- finishQuote(Input, [C |Partial], Token, Rest)
.
finishQuote([] , _Partial, _Token, _Input) :- throw('opened and not closed string') 
.
% SPECIAL

finishSpecial([C | Input], [PC | Partial], Token, Input) :- doubleSpecial(PC, C), !, 
                                                         convertToAtom([C, PC | Partial], Token) 
. 

finishSpecial([C | Input], [PC | _], _ , Rest) :- comment(PC, C),!, 
                                                         skipLines( Input,Rest) %mal
.


finishSpecial([C | Input], [PC | _], _, Rest) :- commentLine(PC, C),!, 
                                          skipLine(Input,Rest)
. %ok


finishSpecial(Input, Partial, Token, Input) :- convertToAtom(Partial, Token) 
. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% skipLines([A,s,u,m,a,' ',a,r,c,h,i,v,o,' ',s,e,' ',l,l,a,m,a,' ',D,e,m,o,1,.,n,o,' ',*,/,' ',s,a],[' '],R).
%skip words

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Comentarios de una linea

skipLine(['\n'|Rest],Rest):-!.%ok
skipLine([_|Input],Rest) :- skipLine(Input,Rest),!. %ok


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Comentarios de multiple linea
skipLines([C|Input],Rest):- skipLines2(Input,[C],Rest),!.
skipLines2(['/'|Rest],['*'],Rest):-!.
skipLines2([C|Input],_,Rest):-skipLines2(Input,[C],Rest),!.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% a(R),post(R,Json).  write(C),write(PC),write('\n')

% FINISH TOKEN
finishToken([C | Input], Continue, Partial, Token, Rest) :- call(Continue, C), !, 
                                                            finishToken(Input, Continue, [ C | Partial], Token, Rest)
.

finishToken(Input, _, Partial, Token, Input) :- convertToAtom(Partial, Token) 
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHARACTER CLASSES (ONLY ASCII)
isWhiteSpace(C) :- member(C, ['\r', '\n', '\t', ' '])
.
isDigit(D)   :- D @>= '0', D @=< '9'.

isLetter('_') :- !. 
isLetter('$') :- !. 
isLetter(D)  :- D @>='a', D @=< 'z', !.  % a .. z
isLetter(D)  :- D @>= 'A', D @=< 'Z'.    % A .. Z

isLetterOrDigit(C) :- isLetter(C),!.
isLetterOrDigit(D) :- isDigit(D),!.

isQuote('"'). 

isSpecial(O)    :- member(O, ['=', '<', '>', '*', '-','/', '+','\\', '.', '(', ')','[',']']), !.
isSpecial(O)    :- member(O, ['{', '}', '&', '|', '%', '!', ';', ',']), !.
isSpecial(O)    :- member(O, ['@', ':']), !.

doubleSpecial('!', '='). % !=
doubleSpecial('=', '='). % ==
doubleSpecial('<', '='). % <=
doubleSpecial('>', '='). % >=
doubleSpecial('&', '&'). % &&
doubleSpecial('|', '|'). % &&
doubleSpecial('-', '>'). % ->
comment('/', '*'). % /*
finishcomment('*', '/'). % */
commentLine('/', '/'). % //


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classify_token(Token, num(Token)) :- re_match("^\\d+(\\.\\d+)?$", Token),!.
classify_token(Token, id(Token))  :- re_match("^[a-zA-Z]+[\\w$]*$", Token),!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UTIL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertToAtom(Partial, Token) :- reverse(Partial, TokenCodes), 
                                 atom_codes(Token, TokenCodes)
. 

codes_to_chars(Lcodes, Lchars):-
    atom_codes(Atom_from_codes, Lcodes), 
    atom_chars(Atom_from_codes, Lchars).




