%{
#include "grammar.tab.h"
#include <string.h>
%}
%option noyywrap
%%

"define"        { return TOK_DEFINE; }

[a-zA-Z][a-zA-Z0-9_]*  { 
                    yylval.sval = strdup(yytext); 
                    return TOK_IDENTIFIER; 
                }

[0-9]+          { 
                    yylval.ival = atoi(yytext); 
                    return TOK_INTEGER; 
                }

\(              { return TOK_LPAREN; }
\)              { return TOK_RPAREN; }

[ \t\n]+        { /* ignora espaços */ }

.               { fprintf(stderr, "Erro léxico: '%s'\n", yytext); }

%%