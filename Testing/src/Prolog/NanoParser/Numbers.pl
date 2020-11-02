
snum([S,L])--> sign(S),unum(L).
unum([D|R]) --> digit(D),restnum(R).

restnum([]) --> [].
restnum([D|R]) --> digit(D),restnum(R).
restnum([D|R]) --> exponents(D),expo(R).
restnum([D|R]) --> dot(D),fract(R).


expo([D|R]) --> sign(D),finalexp(R). 
finalexp([D|R]) --> digit(D),finalexp(R).

fract([D|R]) --> digit(D),fract(R).

digit(D) --> [D] , { D @>='0' ,D @=< '9'}.
dot('.') --> ['.'].

sign(S)-->[S],{member(S, ['+','-'])}.
exponents(E)-->[E],{member(E,['E','e'])}.

convert_to_decimal(L,Dec) :- atomic_list_concat(L, '',Anum),atom_number(Anum,Dec).
decimal(dec(Num)) --> (snum(L)|unum(L)),{convert_to_decimal(L,Num)}.

test(A,Num):- re_split('//d'/a,A,L),delete(L,'',Tokens),decimal(dec(Num),Tokens,[]),!.
