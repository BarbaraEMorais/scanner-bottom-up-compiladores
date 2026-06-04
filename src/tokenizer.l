%{
    //Variáveis e outras definições vem aqui dentro
#include "grammar.tab.h"
%}

%option noyywrap
%%
"("      {printf("Flex: ( found!\n"); return TOK_LPAREN;}
")"      {printf("Flex: ) found!\n"); return TOK_RPAREN;}
","      {printf("Flex: , found!\n"); return TOK_COMMA;}
";"      {printf("Flex: , found!\n"); return TOK_COMMA;}
"\\"      {printf("Flex: , found!\n"); return TOK_COMMA;}
"\""      {printf("Flex: , found!\n"); return TOK_COMMA;}
"'"      {printf("Flex: , found!\n"); return TOK_COMMA;}


"if"      {printf("Flex: \"if\" found!\n"); return TOK_IF;}
"else"      {printf("Flex: \"else\" found!\n"); return TOK_ELSE;}
"lambda"      {printf("Flex: \"lambda\" found!\n"); return TOK_LAMBDA;}


[0-9]* {printf("%s is a number\n", yytext);}
\n     {/*Pula newline*/} 
.     {printf("%s is not a number\n", yytext);}

%%