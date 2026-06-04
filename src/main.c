#include "grammar.tab.h"
#include <stdio.h>
#include <stdlib.h>

extern int yylex (void);
extern char* yyval;

int main(int argc, char *argv[])
{
    int token;
    do{
        token = yyparse();
    } while (token != YYEOF);
    return 0;
}