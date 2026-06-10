compile: bison
	gcc -g -Wall -Wextra *.c AST/*.c -o main 
bison: flex
	bison -H --locations -t *.y
flex:
	flex  *.l

clean:
	rm -f lex.yy.c main *.o

test-compile:
	bison -d grammar.y 
	flex tokenizer.l  
	gcc -Wall -o compiler grammar.tab.c lex.yy.c symbol_table.c AST/print_tree.c AST/ast_constructors.c
	./compiler < teste.scm  