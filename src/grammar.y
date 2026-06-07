%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Declarações externas do scanner (gerado pelo Flex) */
extern int  yylex(void);
extern int  yylineno;
extern char *yytext;

void yyerror(const char *s);
%}

/* ─── Tipos de valor dos tokens ─────────────────────────────────────────── */
%union {
    int    ival;   /* TOK_INTEGER              */
    double dval;   /* TOK_FLOAT (futuro)       */
    char  *sval;   /* TOK_IDENTIFIER, TOK_STRING */
}

/* ─── Tokens sem valor ───────────────────────────────────────────────────── */
%token TOK_LPAREN
%token TOK_RPAREN
%token TOK_DEFINE
%token TOK_LAMBDA
%token TOK_IF
%token TOK_ELSE
%token TOK_COND
%token TOK_LET
%token TOK_LETREC
%token TOK_BEGIN
%token TOK_AND
%token TOK_OR
%token TOK_NOT
%token TOK_SET
%token TOK_CONS
%token TOK_EQ
%token TOK_TRUE
%token TOK_FALSE
%token TOK_PLUS
%token TOK_MINUS
%token TOK_MULT
%token TOK_DIV

/* ─── Tokens com valor ───────────────────────────────────────────────────── */
%token <ival> TOK_INTEGER
%token <dval> TOK_FLOAT
%token <sval> TOK_IDENTIFIER
%token <sval> TOK_STRING

/* ─── Tipos das regras (para quando a Bárbara adicionar AST) ─────────────── */
/*
 * Quando a AST for implementada, adicionar aqui:
 *   %type <node> program expr expr_list define ...
 * e incluir "ASTNode *node" na union acima.
 */

%%

/* ════════════════════════════════════════════════════════════════════════════
   PROGRAMA
   Um programa Scheme é uma sequência de uma ou mais expressões de nível
   superior (top-level). Ex: vários (define ...) seguidos.
   ════════════════════════════════════════════════════════════════════════════ */

program
    : top_level_list
    ;

top_level_list
    : top_level_expr
    | top_level_list top_level_expr
    ;

/* Uma expressão de topo pode ser um define ou uma expressão comum */
top_level_expr
    : define_expr       { printf("[parser] define reconhecido\n"); }
    | expr              { printf("[parser] expressao reconhecida\n"); }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   DEFINE
   Duas formas:
     (define <id> <expr>)               → variável
     (define (<id> <params>) <body>)    → função
   ════════════════════════════════════════════════════════════════════════════ */

define_expr
    /* (define x 10) */
    : TOK_LPAREN TOK_DEFINE TOK_IDENTIFIER expr TOK_RPAREN
        { printf("[parser] define variavel: %s\n", $3); }

    /* (define (f x y) corpo...) */
    | TOK_LPAREN TOK_DEFINE TOK_LPAREN TOK_IDENTIFIER param_list TOK_RPAREN body TOK_RPAREN
        { printf("[parser] define funcao: %s\n", $4); }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   PARÂMETROS
   Lista de identificadores usada na definição de função.
   Ex: (define (f x y z) ...)  →  param_list = x y z
   ════════════════════════════════════════════════════════════════════════════ */

param_list
    : /* vazio — função sem parâmetros: (define (f) ...) */
    | param_list TOK_IDENTIFIER
    ;

/* ════════════════════════════════════════════════════════════════════════════
   CORPO (body)
   Um ou mais expressões no corpo de um define/lambda/let.
   Ex: (define (f x) (+ x 1))           → uma expressão
       (define (f x) (display x) (+ x 1)) → duas expressões
   ════════════════════════════════════════════════════════════════════════════ */

body
    : expr
    | body expr
    ;

/* ════════════════════════════════════════════════════════════════════════════
   EXPRESSÃO
   Núcleo da gramática. Toda construção Scheme é uma expressão.
   ════════════════════════════════════════════════════════════════════════════ */

expr
    : atom
    | list_expr
    ;

/* ─── Átomos ────────────────────────────────────────────────────────────────
   Valores primitivos que não precisam de parênteses.                        */
atom
    : TOK_INTEGER     { printf("[parser] inteiro: %d\n", $1); }
    | TOK_FLOAT       { printf("[parser] float: %f\n", $1); }
    | TOK_STRING      { printf("[parser] string: %s\n", $1); }
    | TOK_IDENTIFIER  { printf("[parser] identificador: %s\n", $1); }
    | TOK_TRUE        { printf("[parser] #t\n"); }
    | TOK_FALSE       { printf("[parser] #f\n"); }
    ;

/* ─── Listas / Formas especiais ─────────────────────────────────────────────
   Tudo entre parênteses.
   A ordem das alternativas importa: formas especiais antes de call_expr.    */
list_expr
    : lambda_expr
    | if_expr
    | cond_expr
    | let_expr
    | begin_expr
    | set_expr
    | call_expr       /* chamada de função genérica — deve vir por último */
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
        { printf("[parser] if (sem else)\n"); }
    | TOK_LPAREN TOK_IF expr expr expr TOK_RPAREN
        { printf("[parser] if-else\n"); }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   COND
   (cond (<test> <expr>) ... (else <expr>))
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
    /* (teste expr...) */
    : TOK_LPAREN expr expr_list TOK_RPAREN
    /* (else expr...) */
    | TOK_LPAREN TOK_ELSE expr_list TOK_RPAREN
    ;

/* ════════════════════════════════════════════════════════════════════════════
   LET / LETREC
   (let ((x 1) (y 2)) body)
   ════════════════════════════════════════════════════════════════════════════ */

let_expr
    : TOK_LPAREN TOK_LET TOK_LPAREN binding_list TOK_RPAREN body TOK_RPAREN
        { printf("[parser] let\n"); }
    | TOK_LPAREN TOK_LETREC TOK_LPAREN binding_list TOK_RPAREN body TOK_RPAREN
        { printf("[parser] letrec\n"); }
    ;

binding_list
    : /* vazio */
    | binding_list binding
    ;

binding
    : TOK_LPAREN TOK_IDENTIFIER expr TOK_RPAREN
        { printf("[parser] binding: %s\n", $2); }
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
        { printf("[parser] set!: %s\n", $3); }
    ;

/* ════════════════════════════════════════════════════════════════════════════
   CHAMADA DE FUNÇÃO GENÉRICA
   (operador arg arg ...)
   Cobre: (+ 1 2), (f x y), (display x), etc.
   ════════════════════════════════════════════════════════════════════════════ */

call_expr
    : TOK_LPAREN expr expr_list TOK_RPAREN
        { printf("[parser] chamada de funcao\n"); }
    ;

/* ─── Lista de expressões (zero ou mais) ─────────────────────────────────── */
expr_list
    : /* vazio */
    | expr_list expr
    ;

lparen :TOK_LPAREN {}

%%

/* ════════════════════════════════════════════════════════════════════════════
   FUNÇÕES AUXILIARES
   ════════════════════════════════════════════════════════════════════════════ */

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático (linha %d): %s\n", yylineno, s);
}

int main(void) {
    printf("=== Parser Scheme ===\n");
    int result = yyparse();
    if (result == 0)
        printf("=== Parsing concluido com sucesso ===\n");
    else
        printf("=== Parsing falhou ===\n");
    return result;
}