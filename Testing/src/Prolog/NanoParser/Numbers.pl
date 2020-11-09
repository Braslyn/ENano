


%cicloHamiltoneano(_,_,[]).%La idea era que si encontraba vacio hiciera uno almenos , mi teoria esque encuentra el vacio en vacio y por eso el prinmer caso, no avanza
cicloHamiltoneano(A,N,R):- cicloHamiltoneano2(A,[N,N],R).

cicloHamiltoneano2([],_,[]):-fail.
cicloHamiltoneano2(A,[N,M],[M,Y]):- member([M,Y],A) ,Y=N,!. 
cicloHamiltoneano2(A,[N,M],[M|R]):- member([M,Y],A),!,cicloHamiltoneano2(A,[N,Y],R).


subpalindrome([],[]).
subpalindrome(Hilera,L):- reverse(Hilera, L), Hilera=L,!.

subpalindrome(Hilera,LI):- sublist(Hilera,Li), subpalindrome(Li,R).

sublist([H|R],[[H],R]).
