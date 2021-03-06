%Autor Braslyn Rodriguez Ramirez 402420750
%Autor Enrique Mendez Cabezas 117390080
%Autor Phillipe Gairaud Quezada 117290193
:- use_module(library(http/http_parameters)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_cors)).
:- use_module(library(http/http_error)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_log)).
:- use_module(library(http/json)).         % provides support for the core JSON object serialization.
:- use_module(library(http/json_convert)). % converts between the primary representation of JSON terms in Prolog 
                                           % and more application oriented Prolog terms. 
										   % E.g. point(X,Y) vs. object([x=X,y=Y]).
:- use_module(library(http/http_json)). 
:- use_module(library(http/http_client)). 
:- [teste].

:- initialization(server).

server :- server(3000).
:- set_setting(http:cors, [*]).
server(Port) :-
        http_server(http_dispatch, [port(Port)]).
stop_server(Port) :- http_stop_server(Port,[]).

:- http_handler('/teste', say_teste, []).


say_teste(_Request):-cors_enable,listAllUsers(List),					
prolog_to_json(estu(List), JSON_Object),
reply_json(JSON_Object).

default_port(3000).