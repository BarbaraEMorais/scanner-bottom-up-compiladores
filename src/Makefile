compile: flex.yy.c
	gcc *.c -o main
flex.yy.c: bison
	flex --bison-bridge --bison-locations *.l 
bison:
	bison -H --locations *.y

clean:
	rm -f lex.yy.c main *.o