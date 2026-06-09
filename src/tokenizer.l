%{
    //Variáveis e outras definições vem aqui dentro
#include "grammar.tab.h"
#include <stdio.h>
#include <string.h>
%}

%option noyywrap
%option noinput
%option nounput
%%


\"(\\.|[^"\\])*\"    {
    /*
    \"       -> escape do caractere "
    \\.      -> aceitar qualquer caractere de escape
    [^"\\] -> aceitar qualquer caractere sem ser " ou \
    */
                                                                                                        printf("Flex: found string %s", yytext);
                                                                                                        yylval.sval = strdup(yytext);
                                                                                                        return TOK_STRING;
                                                                                                    }

"("             {printf("Flex: ( found!\n"); return TOK_LPAREN;}
")"             {printf("Flex: ) found!\n"); return TOK_RPAREN;}
","             {printf("Flex: , found!\n"); return TOK_COMMA;}
";"             {printf("Flex: ; found!\n"); return TOK_SEMICOLON;}
"\\"            {printf("Flex: \\ found!\n"); return TOK_BACKSLASH;}
"'"             {printf("Flex: ' found!\n"); return TOK_LITERAL_DELIM;}
"#|"            {printf("Flex: %s found!\n", yytext); return TOK_MULTILINE_COMMENT_START;}
"|#"            {printf("Flex: %s found!\n", yytext); return TOK_MULTILINE_COMMENT_END;}

"*"             {printf("Flex: %s found!\n", yytext); return TOK_MULT;}
"-"             {printf("Flex: %s found!\n", yytext); return TOK_MINUS;}
"+"             {printf("Flex: %s found!\n", yytext); return TOK_PLUS;}
"/"             {printf("Flex: %s found!\n", yytext); return TOK_DIVIDE;}
"="             {printf("Flex: %s found!\n", yytext); return TOK_EQUAL;}
"|"             {printf("Flex: %s found!\n", yytext); return TOK_VERTICAL_LINE;}
"<"             {printf("Flex: %s found!\n", yytext); return TOK_LEFT_ARROW;}
">"             {printf("Flex: %s found!\n", yytext); return TOK_RIGHT_ARROW;}

#t              {printf("Flex: %s found!\n", yytext); return TOK_TRUE;}
#true           {printf("Flex: %s found!\n", yytext); return TOK_TRUE;}
#f              {printf("Flex: %s found!\n", yytext); return TOK_FALSE;}
#false          {printf("Flex: %s found!\n", yytext); return TOK_FALSE;}


if              {printf("Flex: found  %s", yytext); return TOK_IF;}
else            {printf("Flex: found  %s", yytext); return TOK_ELSE;}
lambda          {printf("Flex: found  %s", yytext); return TOK_LAMBDA;}
define          {printf("Flex: found  %s", yytext); return TOK_DEFINE;}
cond            {printf("Flex: found  %s", yytext); return TOK_COND;}
case            {printf("Flex: found  %s", yytext); return TOK_CASE;}
and             {printf("Flex: found  %s", yytext); return TOK_AND;}
or              {printf("Flex: found  %s", yytext); return TOK_OR;}
when            {printf("Flex: found  %s", yytext); return TOK_WHEN;}
let             {printf("Flex: found  %s", yytext); return TOK_LET;}
letrec          {printf("Flex: found  %s", yytext); return TOK_LETREC;}
do              {printf("Flex: found  %s", yytext); return TOK_DO;}
delay           {printf("Flex: found  %s", yytext); return TOK_DELAY;}
guard           {printf("Flex: found  %s", yytext); return TOK_GUARD;}
export          {printf("Flex: found  %s", yytext); return TOK_EXPORT;}
rename          {printf("Flex: found  %s", yytext); return TOK_RENAME;}
only            {printf("Flex: found  %s", yytext); return TOK_ONLY;}
except          {printf("Flex: found  %s", yytext); return TOK_EXCEPT;}
not             {printf("Flex: found  %s", yytext); return TOK_NOT;}
loop            {printf("Flex: found  %s", yytext); return TOK_LOOP;}
set             {printf("Flex: found  %s", yytext); return TOK_SET;}


([[:alpha:]]|[!$%&*/:<=>?^_])([[:alnum:]]|[+-.@])*       {
                                                printf("Flex: found identifer \"%s\"\n", yytext); 
                                                yylval.sval = strdup(yytext);
                                                return TOK_IDENTIFIER;}
[0-9]*"."[0-9]+         {
                                                printf("Flex: found decimal \"%s\"\n", yytext); 
                                                yylval.dval = atof(yytext);
                                                return TOK_DECIMAL;}

[0-9]+          {
                            printf("Flex: found integer %s", yytext); 
                            yylval.ival = atoi(yytext);
                            return TOK_INTEGER;}

[ \t\n\r]+    { /* Pula newline, tabs e novas linhas de forma segura */ }
.               {fprintf(stderr, "Flex no token matches %s\n", yytext); return TOK_UNINDENTIFIED_TOKEN;}

%%