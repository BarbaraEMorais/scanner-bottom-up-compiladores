#include "grammar.tab.h"
#include "token.h"
#include <stdio.h>
#include <stdlib.h>

extern int yylex (void);
extern char* yyval;

int main(int argc, char *argv[])
{
    int token;
    Token* token_list = NULL;
    do{
        token = yyparse();
    } while (token != -2);
    return 0;
}