%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"
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
    int    ival;   /* TOK_INTEGER                  */
    double dval;   /* TOK_DECIMAL                  */
    char  *sval;   /* TOK_IDENTIFIER, TOK_STRING   */
}

/* ─── Tokens sem valor — espelhados exatamente do .l ────────────────────── */
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

/* Operadores */
%token TOK_PLUS
%token TOK_MINUS
%token TOK_MULT
%token TOK_DIVIDE
%token TOK_EQUAL

/* Booleanos */
%token TOK_TRUE
%token TOK_FALSE

/* Palavras-chave */
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

/* ─── Tokens com valor ───────────────────────────────────────────────────── */
%token <ival> TOK_INTEGER
%token <dval> TOK_DECIMAL
%token <sval> TOK_IDENTIFIER
%token <sval> TOK_STRING

/* ─── Tipos das regras (descomentar quando Bárbara adicionar AST) ────────── */
/* %type <node> program top_level_expr define_expr expr atom list_expr */
/* %type <node> lambda_expr if_expr cond_expr let_expr begin_expr set_expr call_expr */

/* ─── Precedência para resolver ambiguidade do sinal negativo ────────────
   TOK_UMINUS é um token fictício de alta precedência.
   Marca as regras de negative_number para que o Bison prefira shift
   (juntar - com número) em vez de reduce (tratar - como operador átomo). */
%right TOK_UMINUS

%%

/* ════════════════════════════════════════════════════════════════════════════
   PROGRAMA
   Sequência de expressões de nível superior.
   ════════════════════════════════════════════════════════════════════════════ */

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

top_level_expr
    : define_expr
        { printf("[parser] top-level: define\n"); }
    | expr
        { printf("[parser] top-level: expressao\n"); }
    | comment
        { printf("[parser] top-level: comentario ignorado\n"); }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   COMENTÁRIOS MULTILINE
   #| qualquer coisa |#  — ignorado semanticamente
   ════════════════════════════════════════════════════════════════════════════ */

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
   (define <id> <expr>)              → variável
   (define (<id> <params>) <body>)   → função
   ════════════════════════════════════════════════════════════════════════════ */

define_expr
    /* Bug fix: inserir variavel na tabela ao definir — parte integrada com symbol_table.h */
    : TOK_LPAREN TOK_DEFINE TOK_IDENTIFIER expr TOK_RPAREN
        {
            printf("[parser] define variavel: '%s'\n", $3);
            insert_symbol(table, $3, TYPE_NUMBER);
        }

    /* Bug fix: enter_scope antes dos params para que sejam visíveis no corpo — parte integrada com symbol_table.h */
    | TOK_LPAREN TOK_DEFINE TOK_LPAREN TOK_IDENTIFIER { enter_scope(table); } param_list TOK_RPAREN body TOK_RPAREN
        {
            printf("[parser] define funcao: '%s'\n", $4);
            insert_symbol(table, $4, TYPE_FUNCTION);
            exit_scope(table);
        }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   PARÂMETROS
   Lista de identificadores: (define (f x y z) ...)
   ════════════════════════════════════════════════════════════════════════════ */

param_list
    : /* vazio — (define (f) ...) */
    | param_list TOK_IDENTIFIER
        {
            printf("[parser] parametro: '%s'\n", $2);
            insert_symbol(table, $2, TYPE_NUMBER); /* parte integrada com symbol_table.h */
        }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   CORPO
   Uma ou mais expressões.
   ════════════════════════════════════════════════════════════════════════════ */

body
    : expr
    | body expr
    ;

/* ════════════════════════════════════════════════════════════════════════════
   EXPRESSÃO
   ════════════════════════════════════════════════════════════════════════════ */

expr
    : atom
    | list_expr
    ;

/* ─── Número com sinal opcional ──────────────────────────────────────────
   Trata: 123, 3.14
   O sinal negativo vem como TOK_MINUS separado do Flex, então precisamos
   de uma regra explícita para unificá-los num único valor numérico.        */

number
    : TOK_INTEGER
        { printf("[parser] numero inteiro: %d\n", $1); }
    | TOK_DECIMAL
        { printf("[parser] numero decimal: %f\n", $1); }
    ;

/* ─── Número negativo — só válido como átomo isolado ─────────────────────
   (- 123 456) → o TOK_MINUS é operador em call_expr, NÃO entra aqui
   -456 sozinho → TOK_MINUS + TOK_INTEGER reduz para negative_number
   A separação evita que (- 123 456) consuma o - junto com o 123.        */

negative_number
    : TOK_MINUS TOK_INTEGER %prec TOK_UMINUS
        { printf("[parser] numero inteiro negativo: -%d\n", $2); }
    | TOK_MINUS TOK_DECIMAL %prec TOK_UMINUS
        { printf("[parser] numero decimal negativo: -%f\n", $2); }
    ;

/* ─── Átomos ─────────────────────────────────────────────────────────────── */

atom
    : number
    | negative_number
    | TOK_STRING
        { printf("[parser] atom string: %s\n", $1); }
    | TOK_IDENTIFIER
        {
            printf("[parser] atom identificador: '%s'\n", $1);
            /* parte integrada com symbol_table.h */
            Symbol *s = search_symbol(table, $1);
            if (s == NULL) {
                fprintf(stderr, "[Erro Semantico] Linha %d: Variavel '%s' nao declarada.\n", yylineno, $1);
                exit(1);
            }
        }
    | TOK_TRUE
        { printf("[parser] atom: #t\n"); }
    | TOK_FALSE
        { printf("[parser] atom: #f\n"); }
    /* Operadores como átomos — necessário para (+ a b), (* x y), etc.
       TOK_MINUS removido daqui — tratado em negative_number para evitar
       conflito shift/reduce com "-456".                               */
    | TOK_PLUS
        { printf("[parser] atom operador: +\n"); }
    | TOK_MULT
        { printf("[parser] atom operador: *\n"); }
    | TOK_DIVIDE
        { printf("[parser] atom operador: /\n"); }
    | TOK_EQUAL
        { printf("[parser] atom operador: =\n"); }
    | TOK_LEFT_ARROW
        { printf("[parser] atom operador: <\n"); }
    | TOK_RIGHT_ARROW
        { printf("[parser] atom operador: >\n"); }
    ;

/* ─── Listas / Formas especiais ──────────────────────────────────────────── */
/* ATENÇÃO: call_expr deve vir por último — é o caso genérico */

list_expr
    : lambda_expr
    | if_expr
    | cond_expr
    | let_expr
    | begin_expr
    | set_expr
    | when_expr
    | and_or_expr
    | call_expr
    ;

/* ════════════════════════════════════════════════════════════════════════════
   LAMBDA
   (lambda (params) body)
   ════════════════════════════════════════════════════════════════════════════ */

lambda_expr
    : TOK_LPAREN TOK_LAMBDA TOK_LPAREN param_list TOK_RPAREN body TOK_RPAREN
        { printf("[parser] lambda\n"); }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   IF
   (if <cond> <then>)
   (if <cond> <then> <else>)
   ════════════════════════════════════════════════════════════════════════════ */

if_expr
    : TOK_LPAREN TOK_IF expr expr TOK_RPAREN
        { printf("[parser] if sem else\n"); }
    | TOK_LPAREN TOK_IF expr expr expr TOK_RPAREN
        { printf("[parser] if-else\n"); }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   COND
   (cond (<test> <expr>...) ... (else <expr>...))
   ════════════════════════════════════════════════════════════════════════════ */

cond_expr
    : TOK_LPAREN TOK_COND cond_clause_list TOK_RPAREN
        { printf("[parser] cond\n"); }
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
   LET / LETREC
   (let ((x 1) (y 2)) body)
   ════════════════════════════════════════════════════════════════════════════ */

let_expr
    /* Bug fix: enter_scope antes do binding_list — parte integrada com symbol_table.h */
    : TOK_LPAREN TOK_LET { enter_scope(table); } TOK_LPAREN binding_list TOK_RPAREN body TOK_RPAREN
        {
            printf("[parser] let\n");
            exit_scope(table);
        }
    /* Bug fix: letrec também precisa de enter_scope — parte integrada com symbol_table.h */
    | TOK_LPAREN TOK_LETREC { enter_scope(table); } TOK_LPAREN binding_list TOK_RPAREN body TOK_RPAREN
        {
            printf("[parser] letrec\n");
            exit_scope(table);
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
            insert_symbol(table, $2, TYPE_NUMBER); /* parte integrada com symbol_table.h */
        }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   BEGIN
   (begin expr expr ...)
   ════════════════════════════════════════════════════════════════════════════ */

begin_expr
    : TOK_LPAREN TOK_BEGIN expr_list TOK_RPAREN
        { printf("[parser] begin\n"); }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   SET!
   (set! <id> <expr>)
   ════════════════════════════════════════════════════════════════════════════ */

set_expr
    : TOK_LPAREN TOK_SET TOK_IDENTIFIER expr TOK_RPAREN
        { printf("[parser] set!: '%s'\n", $3); }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   WHEN
   (when <cond> <body>)
   ════════════════════════════════════════════════════════════════════════════ */

when_expr
    : TOK_LPAREN TOK_WHEN expr body TOK_RPAREN
        { printf("[parser] when\n"); }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   AND / OR
   (and expr...) / (or expr...)
   ════════════════════════════════════════════════════════════════════════════ */

and_or_expr
    : TOK_LPAREN TOK_AND expr_list TOK_RPAREN
        { printf("[parser] and\n"); }
    | TOK_LPAREN TOK_OR expr_list TOK_RPAREN
        { printf("[parser] or\n"); }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   CHAMADA DE FUNÇÃO GENÉRICA
   (operador arg arg ...)
   Cobre: (+ 1 2), (f x y), (display x), (< a b), etc.
   ════════════════════════════════════════════════════════════════════════════ */

call_expr
    : TOK_LPAREN expr_in_list_item expr_in_list TOK_RPAREN
        { printf("[parser] call\n"); }
    ;

/* ─── Lista de expressões dentro de parênteses (zero ou mais) ───────────────
   Usa expr_in_list em vez de expr para que TOK_MINUS seja sempre operador
   dentro de listas, nunca sinal de número negativo.                        */

expr_in_list
    : /* vazio */
    | expr_in_list expr_in_list_item
    ;

expr_in_list_item
    : number
    | TOK_STRING
        { printf("[parser] atom string: %s\n", $1); }
    | TOK_IDENTIFIER
                {
            printf("[parser] atom identificador: '%s'\n", $1);
            /* parte integrada com symbol_table.h */
            Symbol *s = search_symbol(table, $1);
            if (s == NULL) {
                fprintf(stderr, "[Erro Semantico] Linha %d: Variavel '%s' nao declarada.\n", yylineno, $1);
                exit(1);
            }
        }
    | TOK_TRUE
        { printf("[parser] atom: #t\n"); }
    | TOK_FALSE
        { printf("[parser] atom: #f\n"); }
    | TOK_PLUS
        { printf("[parser] atom operador: +\n"); }
    | TOK_MINUS
        { printf("[parser] atom operador: -\n"); }
    | TOK_MULT
        { printf("[parser] atom operador: *\n"); }
    | TOK_DIVIDE
        { printf("[parser] atom operador: /\n"); }
    | TOK_EQUAL
        { printf("[parser] atom operador: =\n"); }
    | TOK_LEFT_ARROW
        { printf("[parser] atom operador: <\n"); }
    | TOK_RIGHT_ARROW
        { printf("[parser] atom operador: >\n"); }
    | list_expr
    ;

/* ─── Lista de expressões (zero ou mais) ─────────────────────────────────── */

expr_list
    : /* vazio */
    | expr_list expr
    ;


%%

/* ════════════════════════════════════════════════════════════════════════════
   FUNÇÕES AUXILIARES
   ════════════════════════════════════════════════════════════════════════════ */

void yyerror(const char *s) {
    extern char* yytext;
    fprintf(stderr, "[parser] ERRO %d sintático (linha %d, coluna: %d): %s | ultimo token: '%s'\n",
            yynerrs, yylineno, yylloc.last_column, s, yytext);
}

int main(void) {
    printf("=== Parser Scheme ===\n");

    table = create_symbol_table(); /* parte integrada com symbol_table.h */

    int result = yyparse();
    if (result == 0)
        printf("=== Parsing concluido com sucesso ===\n");
    else
        printf("=== Parsing falhou ===\n");

    free(table); /* parte integrada com symbol_table.h */

        printf("Número de erros: %d", yynerrs);
    return result;
}