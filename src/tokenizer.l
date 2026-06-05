%{
    //Variáveis e outras definições vem aqui dentro
#include "grammar.tab.h"
%}

%option noyywrap
%%
"("             {printf("Flex: ( found!\n"); return TOK_LPAREN;}
")"             {printf("Flex: ) found!\n"); return TOK_RPAREN;}
","             {printf("Flex: , found!\n"); return TOK_COMMA;}
";"             {printf("Flex: ; found!\n"); return TOK_SEMICOLON;}
"\\"            {printf("Flex: \\ found!\n"); return TOK_BACKSLASH;}
"\""            {printf("Flex: \" found!\n"); return TOK_STRING_DELIM;}
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


[a-zA-Z]+       {printf("Flex: found character string \"%s\"", yytext); return TOK_CHARACTER_STRING;}
[0-9]+          {printf("Flex: found number %s", yytext); return TOK_NUMBER;}
\n              {/*Pula newline*/} 
" "+            {printf("Flex: Whitespace"); return TOK_WHITESPACE;}
.               {fprintf(stderr, "Flex no token matches %s\n", yytext); return TOK_UNINDENTIFIED_TOKEN;}

%%