/*
Servidor de transpilacion
author: Braslyn Rodriguez Ramirez 402420750
        Enrique Mendez Cabezas 117390080
        Philippe Gairaud Quesada 117290193
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
:- use_module('./NanoTranspiler/NanoTranspiler', [transpileExprStream/3 as transpile
                 ]).


:- initialization
    (current_prolog_flag(argv, [SPort | _]) -> true ; SPort='3030'),
    atom_number(SPort, Port),
    format('*** Serving on port ~d *** ~n', [Port]),
    % Logging
    
    % CORS
    set_setting(http:cors, [*]), % WARNING! only for dev purposes
    server(Port).

:- set_setting(http:cors, [*]).

server(Port) :-                                            % (2)
http_server(http_dispatch, [port(Port)]).

:- http_handler('/transpile', transpile_handler ,[method(post)]). 


transpile_handler(Request) :-cors_enable,
http_parameters(Request,[name(Name),text(Text)],
         [attribute_declarations(param), 'application/x-www-form-urlencoded; charset=UTF-8']
        ),post(Text,Name,R),reply_json(json([result=R])).


post(Text,N,Result) :- format(atom(Name),'./private/~s.no',[N]), 
        save_text(Name, Text),
        transpile(Name,N,Result),!,
        http_post('http://localhost:9090/compile', 
                  atom('text/plain;charset=utf-8', Result), 
                  _,
                  [method(post)]).

evaluate_handler(Request):- cors_enable,http_parameters(Request,[name(Name)],[attribute_declarations(param), 
                    'application/x-www-form-urlencoded; charset=UTF-8']),evaluate(Name,Json),reply_json(Json).
        

evaluate(Name,Json):- http_post('http://localhost:9090/evaluate', 
    atom('text/plain;charset=utf-8', Name), 
    Json,
    [method(post)]),reply_json(Json). 

param(text, [optional(true)]).
param(name, [optional(true)]).

save_text(Path, Text) :-
    open(Path, write, S),
    write(S, Text),
    close(S).



allFile('/*
    Demo1
    Asuma archivo se llama Demo1.no
  */
  
  val <int> x = 66

  val < int -> int > abs = x -> x if x >= 0 else -x
  
  method <int -> int > fact(n) = 1 if n == 0 else n*fact(n - 1)
  
  main { // Main del programa
     println(String.format("abs(%d)=%d", -x, this.abs.apply(x) ) )
     println(String.format("fact(%d)=%d", 5, fact(5)))
     val <int> x = 999 
     val < [ int ] > list = [1, -2, 3, x + x]
     println(list) 
}').


simpleTest('/*
    Demo1
    Asuma archivo se llama Demo1.no
  */
  val < int -> int > abs = x -> x if x >= 0 else -x
  main { // Main del programa
     var<int> x= 12
     x = x*x
     println(String.format("abs(%d)=%d", -x, this.abs.apply(5)))
}'). 



simpleTest2('val < double > PI = 3.14
    var <String> name = "Brazza"
    val <int -> int > func = x -> x*x
    val < int -> int > abs = x -> x if x >= 0 else x
    var < [int] > L
    method <int -> int > fact(n) = 1 if n == 0 else n*fact(n-1)
    main {
        var <int> k = 6
        println(fact(5))
    }').


file(' ').


%probar ?- post('texto en general',Json). 
%probar con a a(R),post(a,Json).