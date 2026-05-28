%{
    //Variáveis e outras definições vem aqui dentro
#include "grammar.tab.h"
%}

%option noyywrap
%%
\(      {return TOK_LPAREN;}
[0-9]* {printf("%s is a number\n", yytext);}
\n     {/*Pula newline*/} 
.     {printf("%s is not a number\n", yytext);}

%%