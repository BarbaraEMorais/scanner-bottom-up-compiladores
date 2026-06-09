compile: flex.yy.c
	gcc -g -Wall -Wextra *.c -o main
flex.yy.c: bison
	flex  *.l 
bison:
	bison -H --locations *.y

clean:
	rm -f lex.yy.c main *.o

test-compile:
	bison -d grammar.y 
	flex tokenizer.l  
	gcc -Wall -o compiler grammar.tab.c lex.yy.c symbol_table.c
	./compiler < teste.scm  