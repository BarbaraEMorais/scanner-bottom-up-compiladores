%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"
#include "AST/ast.h"
#include "errors.h"

#define YYDEBUG 1

extern int  yylex(void);
extern int  yylineno;
extern char *yytext;

int num_errors = 0;

Error* error_list = NULL;

void yyerror(const char *s);

SymbolTable *table;

%}

%define parse.error verbose

/* ─── Tipos de valor dos tokens ─────────────────────────────────────────── */
%union {
    int      ival;
    double   dval;
    char    *sval;
    ASTNode *node;
    char     cval;
}

%token TOK_LPAREN
%token TOK_RPAREN
%token TOK_COMMA
%token TOK_SEMICOLON
%token TOK_BACKSLASH
%token TOK_LITERAL_DELIM
%token TOK_MULTILINE_COMMENT_START
%token TOK_MULTILINE_COMMENT_END
%token TOK_VERTICAL_LINE
%token TOK_LEFT_ARROW
%token TOK_RIGHT_ARROW
%token TOK_UNINDENTIFIED_TOKEN

%token TOK_PLUS
%token TOK_MINUS
%token TOK_MULT
%token TOK_DIVIDE
%token TOK_EQUAL

%token TOK_TRUE
%token TOK_FALSE

%token TOK_DEFINE
%token TOK_LAMBDA
%token TOK_IF
%token TOK_ELSE
%token TOK_COND
%token TOK_CASE
%token TOK_AND
%token TOK_OR
%token TOK_NOT
%token TOK_WHEN
%token TOK_LET
%token TOK_LETREC
%token TOK_BEGIN
%token TOK_SET
%token TOK_DO
%token TOK_DELAY
%token TOK_GUARD
%token TOK_LOOP
%token TOK_EXPORT
%token TOK_RENAME
%token TOK_ONLY
%token TOK_EXCEPT

%token <ival> TOK_INTEGER
%token <dval> TOK_DECIMAL
%token <sval> TOK_IDENTIFIER
%token <sval> TOK_STRING

/* ─── Regras com nó AST — parte integrada com ast.h ─────────────────────── */
%type <node> expr atom number negative_number define_expr if_expr call_expr
%type <node> expr_in_list_item top_level_expr

/* ─── Regras sem nó AST ainda ───────────────────────────────────────────── */
%type <node> list_expr lambda_expr cond_expr let_expr begin_expr set_expr when_expr and_or_expr

%right TOK_UMINUS

%%

program
    : top_level_list
        { printf("[parser] programa completo\n"); }
    | program error '\n' {yyerrok; }
    | program error <<EOF>> {yyerrok; }
    ;

top_level_list
    : top_level_expr
    | top_level_list top_level_expr
    ;

/* parte integrada com ast.h — imprime árvore do nó raiz */
top_level_expr
    : define_expr
        {
            printf("[parser] top-level: define\n");
            if ($1) print_ast($1, 0);
            $$ = $1;
        }
    | expr
        {
            printf("[parser] top-level: expressao\n");
            if ($1) print_ast($1, 0);
            $$ = $1;
        }
    | comment
        {
            printf("[parser] top-level: comentario ignorado\n");
            $$ = NULL;
        }
    ;

comment
    : TOK_MULTILINE_COMMENT_START token_seq TOK_MULTILINE_COMMENT_END {}
    ;

token_seq
    : /* vazio */
    | token_seq any_token
    ;

any_token
    : TOK_INTEGER | TOK_DECIMAL | TOK_STRING | TOK_IDENTIFIER
    | TOK_LPAREN  | TOK_RPAREN  | TOK_PLUS   | TOK_MINUS
    | TOK_MULT    | TOK_DIVIDE  | TOK_EQUAL  | TOK_TRUE | TOK_FALSE
    | TOK_IF      | TOK_ELSE    | TOK_DEFINE | TOK_LAMBDA
    ;

/* ════════════════════════════════════════════════════════════════════════════
   DEFINE
   (define x expr)        → NODE_DEFINE   — parte integrada com ast.h
   (define (f params) body) → sem nó ainda
   ════════════════════════════════════════════════════════════════════════════ */

define_expr
    : TOK_LPAREN TOK_DEFINE TOK_IDENTIFIER expr TOK_RPAREN
        {
            printf("[parser] define variavel: '%s'\n", $3);
            insert_symbol(table, $3, TYPE_NUMBER);
            $$ = create_define($3, $4); /* parte integrada com ast.h */
        }
    | TOK_LPAREN TOK_DEFINE TOK_LPAREN TOK_IDENTIFIER { enter_scope(table); } param_list TOK_RPAREN body TOK_RPAREN
        {
            printf("[parser] define funcao: '%s'\n", $4);
            insert_symbol(table, $4, TYPE_FUNCTION);
            exit_scope(table);
            $$ = NULL; /* NODE_DEFINE para função — sem nó AST ainda */
        }
    ;

param_list
    : /* vazio */
    | param_list TOK_IDENTIFIER
        {
            printf("[parser] parametro: '%s'\n", $2);
            insert_symbol(table, $2, TYPE_NUMBER);
        }
    ;

body
    : expr
    | body expr
    ;

expr
    : atom      { $$ = $1; }
    | list_expr { $$ = $1; }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   NUMBER — NODE_NUMBER — parte integrada com ast.h
   ════════════════════════════════════════════════════════════════════════════ */

number
    : TOK_INTEGER
        {
            printf("[parser] numero inteiro: %d\n", $1);
            $$ = create_number($1);
        }
    | TOK_DECIMAL
        {
            printf("[parser] numero decimal: %f\n", $1);
            $$ = create_number((int)$1);
        }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   NEGATIVE NUMBER — NODE_NUMBER com valor negativo — parte integrada com ast.h
   ════════════════════════════════════════════════════════════════════════════ */

negative_number
    : TOK_MINUS TOK_INTEGER %prec TOK_UMINUS
        {
            printf("[parser] numero inteiro negativo: -%d\n", $2);
            $$ = create_number(-$2);
        }
    | TOK_MINUS TOK_DECIMAL %prec TOK_UMINUS
        {
            printf("[parser] numero decimal negativo: -%f\n", $2);
            $$ = create_number(-(int)$2);
        }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   ATOM
   number/negative_number → NODE_NUMBER        — parte integrada com ast.h
   identifier             → NODE_IDENTIFIER    — parte integrada com ast.h
   #t / #f                → NODE_NUMBER (1/0)  — parte integrada com ast.h
   demais                 → NULL
   ════════════════════════════════════════════════════════════════════════════ */

atom
    : number         { $$ = $1; }
    | negative_number { $$ = $1; }
    | TOK_STRING
        {
            printf("[parser] atom string: %s\n", $1);
            $$ = NULL;
        }
    | TOK_IDENTIFIER
        {
            Symbol *s = search_symbol(table, $1);
            if (s == NULL) {
                yynerrs++;
                yyerror("[Erro Semantico]: Variável não declarada");
                //fprintf(stderr, "[Erro Semantico] Linha %d: Variavel '%s' nao declarada.\n", yylineno, $1);
            }
            printf("[parser] atom identificador: '%s'\n", $1);
            $$ = create_identifier($1); /* parte integrada com ast.h */
        }
    | TOK_TRUE
        {
            printf("[parser] atom: #t\n");
            $$ = create_number(1); /* parte integrada com ast.h */
        }
    | TOK_FALSE
        {
            printf("[parser] atom: #f\n");
            $$ = create_number(0); /* parte integrada com ast.h */
        }
    | TOK_PLUS   { printf("[parser] atom operador: +\n"); $$ = NULL; }
    | TOK_MULT   { printf("[parser] atom operador: *\n"); $$ = NULL; }
    | TOK_DIVIDE { printf("[parser] atom operador: /\n"); $$ = NULL; }
    | TOK_EQUAL  { printf("[parser] atom operador: =\n"); $$ = NULL; }
    | TOK_LEFT_ARROW  { printf("[parser] atom operador: <\n"); $$ = NULL; }
    | TOK_RIGHT_ARROW { printf("[parser] atom operador: >\n"); $$ = NULL; }
    ;

list_expr
    : lambda_expr { $$ = $1; }
    | if_expr     { $$ = $1; }
    | cond_expr   { $$ = $1; }
    | let_expr    { $$ = $1; }
    | begin_expr  { $$ = $1; }
    | set_expr    { $$ = $1; }
    | when_expr   { $$ = $1; }
    | and_or_expr { $$ = $1; }
    | call_expr   { $$ = $1; }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   LAMBDA — sem nó AST ainda
   ════════════════════════════════════════════════════════════════════════════ */

lambda_expr
    : TOK_LPAREN TOK_LAMBDA TOK_LPAREN param_list TOK_RPAREN body TOK_RPAREN
        {
            printf("[parser] lambda\n");
            $$ = NULL;
        }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   IF — NODE_IF — parte integrada com ast.h
   ════════════════════════════════════════════════════════════════════════════ */

if_expr
    : TOK_LPAREN TOK_IF expr expr TOK_RPAREN
        {
            printf("[parser] if sem else\n");
            $$ = create_if($3, $4, NULL);
        }
    | TOK_LPAREN TOK_IF expr expr expr TOK_RPAREN
        {
            printf("[parser] if-else\n");
            $$ = create_if($3, $4, $5);
        }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   COND — sem nó AST ainda
   ════════════════════════════════════════════════════════════════════════════ */

cond_expr
    : TOK_LPAREN TOK_COND cond_clause_list TOK_RPAREN
        {
            printf("[parser] cond\n");
            $$ = NULL;
        }
    ;

cond_clause_list
    : cond_clause
    | cond_clause_list cond_clause
    ;

cond_clause
    : TOK_LPAREN expr expr_list TOK_RPAREN
        { printf("[parser] cond clause\n"); }
    | TOK_LPAREN TOK_ELSE expr_list TOK_RPAREN
        { printf("[parser] cond else\n"); }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   LET / LETREC — sem nó AST ainda
   ════════════════════════════════════════════════════════════════════════════ */

let_expr
    : TOK_LPAREN TOK_LET { enter_scope(table); } TOK_LPAREN binding_list TOK_RPAREN body TOK_RPAREN
        {
            printf("[parser] let\n");
            exit_scope(table);
            $$ = NULL;
        }
    | TOK_LPAREN TOK_LETREC { enter_scope(table); } TOK_LPAREN binding_list TOK_RPAREN body TOK_RPAREN
        {
            printf("[parser] letrec\n");
            exit_scope(table);
            $$ = NULL;
        }
    ;

binding_list
    : /* vazio */
    | binding_list binding
    ;

binding
    : TOK_LPAREN TOK_IDENTIFIER expr TOK_RPAREN
        {
            printf("[parser] binding: '%s'\n", $2);
            insert_symbol(table, $2, TYPE_NUMBER);
        }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   BEGIN — sem nó AST ainda
   ════════════════════════════════════════════════════════════════════════════ */

begin_expr
    : TOK_LPAREN TOK_BEGIN expr_list TOK_RPAREN
        {
            printf("[parser] begin\n");
            $$ = NULL;
        }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   SET! — sem nó AST ainda
   ════════════════════════════════════════════════════════════════════════════ */

set_expr
    : TOK_LPAREN TOK_SET TOK_IDENTIFIER expr TOK_RPAREN
        {
            printf("[parser] set!: '%s'\n", $3);
            $$ = NULL;
        }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   WHEN — sem nó AST ainda
   ════════════════════════════════════════════════════════════════════════════ */

when_expr
    : TOK_LPAREN TOK_WHEN expr body TOK_RPAREN
        {
            printf("[parser] when\n");
            $$ = NULL;
        }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   AND / OR — sem nó AST ainda
   ════════════════════════════════════════════════════════════════════════════ */

and_or_expr
    : TOK_LPAREN TOK_AND expr_list TOK_RPAREN
        {
            printf("[parser] and\n");
            $$ = NULL;
        }
    | TOK_LPAREN TOK_OR expr_list TOK_RPAREN
        {
            printf("[parser] or\n");
            $$ = NULL;
        }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   CALL EXPR
   (op a b) onde op é binário → NODE_BINARY_OP — parte integrada com ast.h
   demais chamadas            → NULL por enquanto
   ════════════════════════════════════════════════════════════════════════════ */

/* ════════════════════════════════════════════════════════════════════════════
   CALL EXPR
   Não usamos binary_op separado pois conflita com expr_in_list_item.
   Em vez disso, call_expr usa sempre expr_in_list_item como operador.
   O NODE_BINARY_OP é criado na semântica quando detectamos um operador
   como primeiro elemento — via campo sval do token.
   ════════════════════════════════════════════════════════════════════════════ */

call_expr
    : TOK_LPAREN TOK_PLUS expr_in_list_item expr_in_list_item TOK_RPAREN
        { printf("[parser] call binario: +\n"); $$ = create_binary_operation('+', $3, $4); }
    | TOK_LPAREN TOK_MINUS expr_in_list_item expr_in_list_item TOK_RPAREN
        { printf("[parser] call binario: -\n"); $$ = create_binary_operation('-', $3, $4); }
    | TOK_LPAREN TOK_MULT expr_in_list_item expr_in_list_item TOK_RPAREN
        { printf("[parser] call binario: *\n"); $$ = create_binary_operation('*', $3, $4); }
    | TOK_LPAREN TOK_DIVIDE expr_in_list_item expr_in_list_item TOK_RPAREN
        { printf("[parser] call binario: /\n"); $$ = create_binary_operation('/', $3, $4); }
    | TOK_LPAREN TOK_EQUAL expr_in_list_item expr_in_list_item TOK_RPAREN
        { printf("[parser] call binario: =\n"); $$ = create_binary_operation('=', $3, $4); }
    | TOK_LPAREN TOK_LEFT_ARROW expr_in_list_item expr_in_list_item TOK_RPAREN
        { printf("[parser] call binario: <\n"); $$ = create_binary_operation('<', $3, $4); }
    | TOK_LPAREN TOK_RIGHT_ARROW expr_in_list_item expr_in_list_item TOK_RPAREN
        { printf("[parser] call binario: >\n"); $$ = create_binary_operation('>', $3, $4); }
    | TOK_LPAREN expr_in_list_item expr_in_list TOK_RPAREN
        { printf("[parser] call\n"); $$ = NULL; }
    ;

expr_in_list
    : /* vazio */
    | expr_in_list expr_in_list_item
    ;

/* ════════════════════════════════════════════════════════════════════════════
   EXPR_IN_LIST_ITEM
   number      → NODE_NUMBER      — parte integrada com ast.h
   identifier  → NODE_IDENTIFIER  — parte integrada com ast.h
   #t/#f       → NODE_NUMBER(1/0) — parte integrada com ast.h
   demais      → NULL
   ════════════════════════════════════════════════════════════════════════════ */

/* ─── expr_in_list_item ─────────────────────────────────────────────────────
   Operadores (TOK_PLUS, TOK_MINUS, etc.) foram removidos daqui para evitar
   conflito shift/reduce com as alternativas binárias de call_expr.
   Operadores agora só aparecem como primeiro token das alternativas
   explícitas em call_expr.                                                  */

expr_in_list_item
    : number { $$ = $1; }
    | TOK_STRING
        {
            printf("[parser] atom string: %s\n", $1);
            $$ = NULL;
        }
    | TOK_IDENTIFIER
        {
            Symbol *s = search_symbol(table, $1);
            if (s == NULL) {
                yynerrs++;
                yyerror("[Erro Semantico]: Variável não declarada");
                //fprintf(stderr, "[Erro Semantico] Linha %d: Variavel '%s' nao declarada.\n", yylineno, $1);
            }
            printf("[parser] atom identificador: '%s'\n", $1);
            $$ = create_identifier($1);
        }
    | TOK_TRUE  { printf("[parser] atom: #t\n"); $$ = create_number(1); }
    | TOK_FALSE { printf("[parser] atom: #f\n"); $$ = create_number(0); }
    | list_expr { $$ = $1; }
    | error TOK_RPAREN { yyerrok; $$ = NULL; }
    ;

expr_list
    : /* vazio */
    | expr_list expr
    ;


%%

void yyerror(const char *s) {
    extern char* yytext;
    fprintf(stderr, "[parser] ERRO %d (linha %d, coluna: %d):\n%s | ultimo token: '%s'\n",
            yynerrs, yylloc.last_line, yylloc.last_column, s, yytext);
}

int main(void) {
    printf("=== Parser Scheme ===\n");

    table = create_symbol_table();

    int result = yyparse();
    if (result == 0)
        printf("=== Parsing concluido com sucesso ===\n");
    else
        printf("=== Parsing falhou ===\n");

    free(table);

        printf("Número de erros: %d", yynerrs);
    return result;
}