


decimal(dec(Num)) --> (snum(L);num(L)),{convert_to_decimal(L,Num)}.

snum([D|R])--> sign(D),restnum(R). 
num([D|R]) -->digit(D),restnum(R).

restnum([]) --> [].
restnum([D|R]) --> digit(D),restnum(R).
%restnum([D|R]) --> exponents(D),expo(R).
restnum([D|R]) --> dot(D),fract(R).


%expo([D|R]) --> sign(D),finalexp(R). 
%finalexp([D|R]) --> digit(D),finalexp(R).

fract([]) --> [].
fract([D|R]) --> digit(D),fract(R).

digit(D) --> [D] , { D @>='0' ,D @=< '9'}.

dot('.') --> ['.'].

sign(S)--> [S],{is_sign(S)}.

is_sign('+').
is_sign('-').

%exponents(E)-->[E],{member(E,['E','e'])}.

convert_to_decimal(L,Dec) :- atomic_list_concat(L, '',Anum),atom_number(Anum,Dec).

test(A,Num):- re_split('//w'/a,A,L),delete(L,'',Tokens),write(Tokens),decimal(dec(Num),Tokens,[]),!.