%Autor Enrique Mendez Cabezas
:- use_module(library(record)). 
:- use_module(library(http/json)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_json)).

%json objet
  :- json_object estu(estu:list).


% %
%FACTS
% %

est(117390080,"Enrique Mendez Cabezas").
est(402420750,"Braslyn Rodriguez Ramirez"). 
est(117290193,"Phillip Gairaud Quesada").



json_test(_Request) :-listAllUsers(List),					
    prolog_to_json(estu(List), JSON_Object),
    reply_json(JSON_Object).

%lista de estudiantes
listAllUsers(List):- findall(([U1,U2]), (est(U1, U2)), L1),
append(L1, L2),
list_to_set(L2, List).