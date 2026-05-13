%{
    //Variáveis e outras definições vem aqui dentro
#include "token.h"
#include <stdlib.h>
%}

%option noyywrap
%%
[0-9]* {printf("%s is a number\n", yytext);}
\n     {return 0;}
.     {printf("%s is not a number\n", yytext);}

%%