/*
Servidor de transpilacion
author: Braslyn Rodriguez Ramirez 402420750
Based on: Carlos Loria's Prolog  proyects Web Demo and Enano transpiler demo
since: 2020
*/

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_files)).
:- use_module(library(http/html_head)).
%:- use_module(library(http/mimetype)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_cors)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_json)).
:- use_module('./NanoLexer/lexer', [tokenize_file/2 as parse
                 ]).


:- initialization
    (current_prolog_flag(argv, [SPort | _]) -> true ; SPort='3030'),
    atom_number(SPort, Port),
    format('*** Serving on port ~d *** ~n', [Port]),
    % Logging
    
    % CORS
    set_setting(http:cors, [*]), % WARNING! only for dev purposes
    server(Port).
	
	
server(Port) :-                                            % (2)
http_server(http_dispatch, [port(Port)]).

:- http_handler('/transpile', transpile_handler ,[method(post)]). 


transpile_handler(Request) :- cors_enable,
http_parameters(Request,[text(Text)],
         [attribute_declarations(param), 'application/x-www-form-urlencoded; charset=UTF-8']
        ),post(Text,Json),reply_json(Json).



post(Text,Reply) :- save_text('./private/File.no', Text),
        parse('./private/File.no',Result),write(Result),
        http_post('http://localhost:9090/compile', 
                  atom('text/plain;charset=utf-8', Text), 
                  Reply,
                  [method(post)]). 


param(text, [optional(true)]).

save_text(Path, Text) :-
    open(Path, write, S),
    write(S, Text),
    close(S).



a('/*
Demo1
Asuma archivo se llama Demo1.no
*/

val <int> x = 666
val < int -> int > abs = x -> x if x >= 0 else - x

method <int -> int > fact(n) = 1 if n == 0 else n * fact(n - 1)

main { // Main del programa
 println(String.format("abs(%d)=%d", -x, this.abs.apply(-x)))
 println(String.format("fact(%d)=%d", 5, fact(5)))
 val <int> x = 999 
 val < [ int ] > list = [1, -2, 3, x + x]
 println(list) 
}').

%probar ?- post('texto en general',Json). 
%probar con a a(R),post(a,Json).