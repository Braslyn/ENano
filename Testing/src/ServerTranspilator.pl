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

:- initialization
    (current_prolog_flag(argv, [SPort | _]) -> true ; SPort='8080'),
    atom_number(SPort, Port),
    format('*** Serving on port ~d *** ~n', [Port]),
    % Logging
    
    % CORS
    set_setting(http:cors, [*]), % WARNING! only for dev purposes
    server(Port).
	
	
:- http_handler('/Transpile', transpile_handler, []). 
	