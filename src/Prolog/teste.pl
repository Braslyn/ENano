%Autor Braslyn Rodriguez Ramirez 402420750
%Autor Enrique Mendez Cabezas 117390080
%Autor Phillipe Gairaud Quezada 117290193
:- use_module(library(record)). 
:- use_module(library(http/json)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_json)).

%json objet
  :- json_object estu(text).


% %
%FACTS
% %

est("Enrique Mendez Cabezas 117390080").
est("Braslyn Rodriguez Ramirez 402420750"). 
est("Philippe Gairaud Quesada 117290193").
est("50058").
est("06").
est("1").
est("https://github.com/Braslyn/ENano").
est("9/14/2020").


json_test(_Request) :-listAllUsers(List),					
    prolog_to_json(estu(List), JSON_Object),
    reply_json(JSON_Object).

%lista de estudiantes
listAllUsers(List):- findall(([U1]), (est(U1)), L1),
append(L1, L2),
list_to_set(L2, List).