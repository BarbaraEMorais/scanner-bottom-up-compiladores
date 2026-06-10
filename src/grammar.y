%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"
#include "AST/ast.h"

#define YYDEBUG 1

extern int   yylex(void);
extern int   yylineno;
extern char *yytext;

int num_errors = 0;

Error* error_list = NULL;

void yyerror(const char *s);

SymbolTable *table;
ASTNode     *ast_root = NULL;

%}

/* CORRIGIDO: %locations necessário para usar yylloc em yyerror */
%locations
%define parse.error verbose

/* ─── União de tipos ─────────────────────────────────────── */
%union {
    int      ival;
    double   dval;
    char    *sval;
    ASTNode *node;
}

/* ─── Tokens sem valor ───────────────────────────────────── */
%token TOK_LPAREN TOK_RPAREN TOK_COMMA TOK_SEMICOLON
%token TOK_BACKSLASH TOK_LITERAL_DELIM
%token TOK_MULTILINE_COMMENT_START TOK_MULTILINE_COMMENT_END
%token TOK_VERTICAL_LINE TOK_LEFT_ARROW TOK_RIGHT_ARROW
%token TOK_UNINDENTIFIED_TOKEN
%token TOK_PLUS TOK_MINUS TOK_MULT TOK_DIVIDE TOK_EQUAL
%token TOK_TRUE TOK_FALSE
%token TOK_DEFINE TOK_LAMBDA TOK_IF TOK_ELSE TOK_COND TOK_CASE
%token TOK_AND TOK_OR TOK_NOT TOK_WHEN TOK_LET TOK_LETREC
%token TOK_BEGIN TOK_SET TOK_DO TOK_DELAY TOK_GUARD TOK_LOOP
%token TOK_EXPORT TOK_RENAME TOK_ONLY TOK_EXCEPT

/* ─── Tokens com valor ───────────────────────────────────── */
%token <ival> TOK_INTEGER
%token <dval> TOK_DECIMAL
%token <sval> TOK_IDENTIFIER
%token <sval> TOK_STRING

/* ─── Tipos das regras com nó AST ────────────────────────── */
%type <node> program top_level_list top_level_expr define_expr
%type <node> expr atom list_expr number negative_number
%type <node> body param_list lambda_expr if_expr let_expr
%type <node> binding_list binding begin_expr set_expr call_expr
%type <node> expr_in_list expr_in_list_item

/* CORRIGIDO: comment/cond_expr/when_expr/and_or_expr não carregam nó —
   declarados sem %type (valor padrão $$ não é usado nessas regras)     */

/* ─── Precedência para número negativo literal ───────────── */
%right TOK_UMINUS

%%

/* ════════════════════════════════════════════════════════════
   PROGRAMA
   ════════════════════════════════════════════════════════════ */

program
    : top_level_list
        { ast_root = $1; $$ = $1; }
    | program error '\n'
        { yyerrok; $$ = $1; }
    /* CORRIGIDO: <<EOF>> é sintaxe inválida no Bison — removido.
       O Bison trata EOF automaticamente ao encontrar YYEOF.     */
    ;

top_level_list
    : top_level_expr
        { $$ = $1; }
    | top_level_list top_level_expr
        { $$ = append_node($1, $2); }
    ;

top_level_expr
    : define_expr   { $$ = $1; }
    | expr          { $$ = $1; }
    | comment       { $$ = NULL; }  /* comment não tem nó, NULL é seguro */
    ;

/* ════════════════════════════════════════════════════════════
   COMENTÁRIOS MULTILINE  #| ... |#
   ════════════════════════════════════════════════════════════ */

comment
    : TOK_MULTILINE_COMMENT_START token_seq TOK_MULTILINE_COMMENT_END
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

/* ════════════════════════════════════════════════════════════
   DEFINE
   ════════════════════════════════════════════════════════════ */

define_expr
    : TOK_LPAREN TOK_DEFINE TOK_IDENTIFIER expr TOK_RPAREN
        {
            printf("[parser] define variavel: '%s'\n", $3);
            insert_symbol(table, $3, TYPE_NUMBER);
            $$ = create_define($3, $4);
        }
    | TOK_LPAREN TOK_DEFINE TOK_LPAREN TOK_IDENTIFIER
        { enter_scope(table); }
      param_list TOK_RPAREN body TOK_RPAREN
        {
            printf("[parser] define funcao: '%s'\n", $4);
            insert_symbol(table, $4, TYPE_FUNCTION);
            exit_scope(table);
            ASTNode *lam = create_lambda($6, $8);
            $$ = create_define($4, lam);
        }
    ;

/* ════════════════════════════════════════════════════════════
   PARÂMETROS
   ════════════════════════════════════════════════════════════ */

param_list
    : /* vazio */
        { $$ = NULL; }
    | param_list TOK_IDENTIFIER
        {
            printf("[parser] parametro: '%s'\n", $2);
            insert_symbol(table, $2, TYPE_NUMBER);
            ASTNode *p = create_identifier($2);
            $$ = append_node($1, p);
        }
    ;

/* ════════════════════════════════════════════════════════════
   CORPO
   ════════════════════════════════════════════════════════════ */

body
    : expr          { $$ = $1; }
    | body expr     { $$ = append_node($1, $2); }
    ;

/* ════════════════════════════════════════════════════════════
   EXPRESSÃO
   ════════════════════════════════════════════════════════════ */

expr
    : atom      { $$ = $1; }
    | list_expr { $$ = $1; }
    ;

number
    : TOK_INTEGER
        { printf("[parser] inteiro: %d\n", $1); $$ = create_number($1); }
    | TOK_DECIMAL
        { 
            printf("[parser] numero decimal: %f\n", $1); 
            $$ = create_float($1);
        }
    ;

negative_number
    : TOK_MINUS TOK_INTEGER %prec TOK_UMINUS
        { printf("[parser] inteiro negativo: -%d\n", $2); $$ = create_number(-$2); }
    | TOK_MINUS TOK_DECIMAL %prec TOK_UMINUS
        { printf("[parser] numero decimal negativo: -%f\n", $2); 
        $$ = create_float(-$2);}
    ;

atom
    : number            { $$ = $1; }
    | negative_number   { $$ = $1; }
    | TOK_STRING
        { printf("[parser] string: %s\n", $1); $$ = create_string($1); }
    | TOK_IDENTIFIER
        {
            printf("[parser] identificador: '%s'\n", $1);
            Symbol *s = search_symbol(table, $1);
            if (!s) {
                yynerrs++;
                yyerror("[Erro Semantico]: Variável não declarada");
            }
            $$ = create_identifier($1);
        }
    | TOK_TRUE    { $$ = create_boolean(1); }
    | TOK_FALSE   { $$ = create_boolean(0); }
    | TOK_PLUS    { $$ = create_identifier("+"); }
    /* TOK_MINUS removido: conflito shift/reduce com negative_number.
       Como átomo isolado, "-" só aparece dentro de listas (call_expr),
       onde é capturado por expr_in_list_item sem ambiguidade.          */
    | TOK_MULT    { $$ = create_identifier("*"); }
    | TOK_DIVIDE  { $$ = create_identifier("/"); }
    | TOK_EQUAL   { $$ = create_identifier("="); }
    | TOK_LEFT_ARROW  { $$ = create_identifier("<"); }
    | TOK_RIGHT_ARROW { $$ = create_identifier(">"); }
    ;

/* ════════════════════════════════════════════════════════════
   FORMAS ESPECIAIS
   ════════════════════════════════════════════════════════════ */

list_expr
    : lambda_expr   { $$ = $1; }
    | if_expr       { $$ = $1; }
    | cond_expr     { $$ = NULL; }
    | let_expr      { $$ = $1; }
    | begin_expr    { $$ = $1; }
    | set_expr      { $$ = $1; }
    | when_expr     { $$ = NULL; }
    | and_or_expr   { $$ = NULL; }
    | call_expr     { $$ = $1; }
    ;

lambda_expr
    : TOK_LPAREN TOK_LAMBDA TOK_LPAREN param_list TOK_RPAREN body TOK_RPAREN
        { $$ = create_lambda($4, $6); }
    ;

if_expr
    : TOK_LPAREN TOK_IF expr expr TOK_RPAREN
        { $$ = create_if($3, $4, NULL); }
    | TOK_LPAREN TOK_IF expr expr expr TOK_RPAREN
        { $$ = create_if($3, $4, $5); }
    ;

cond_expr
    : TOK_LPAREN TOK_COND cond_clause_list TOK_RPAREN
    ;

cond_clause_list
    : cond_clause
    | cond_clause_list cond_clause
    ;

cond_clause
    /* Usa expr_in_list_item + expr_in_list para evitar ambiguidade com
       negative_number: dentro de parênteses, "-" é sempre operador.   */
    : TOK_LPAREN expr_in_list_item expr_in_list TOK_RPAREN
        { printf("[parser] cond clause\n"); }
    | TOK_LPAREN TOK_ELSE expr_in_list TOK_RPAREN
        { printf("[parser] cond else\n"); }
    ;

let_expr
    : TOK_LPAREN TOK_LET { enter_scope(table); }
      TOK_LPAREN binding_list TOK_RPAREN body TOK_RPAREN
        {
            printf("[parser] let\n");
            exit_scope(table);
            $$ = create_let(0, $5, $7);
        }
    | TOK_LPAREN TOK_LETREC { enter_scope(table); }
      TOK_LPAREN binding_list TOK_RPAREN body TOK_RPAREN
        {
            printf("[parser] letrec\n");
            exit_scope(table);
            $$ = create_let(1, $5, $7);
        }
    ;

binding_list
    : /* vazio */           { $$ = NULL; }
    | binding_list binding  { $$ = append_node($1, $2); }
    ;

binding
    : TOK_LPAREN TOK_IDENTIFIER expr TOK_RPAREN
        {
            printf("[parser] binding: '%s'\n", $2);
            insert_symbol(table, $2, TYPE_NUMBER);
            $$ = create_define($2, $3);
        }
    ;

begin_expr
    : TOK_LPAREN TOK_BEGIN expr_in_list TOK_RPAREN
        { $$ = create_begin($3); }
    ;

set_expr
    : TOK_LPAREN TOK_SET TOK_IDENTIFIER expr TOK_RPAREN
        { $$ = create_set($3, $4); }
    ;

when_expr
    : TOK_LPAREN TOK_WHEN expr body TOK_RPAREN
        { printf("[parser] when\n"); }
    ;

and_or_expr
    : TOK_LPAREN TOK_AND expr_in_list TOK_RPAREN
        { printf("[parser] and\n"); }
    | TOK_LPAREN TOK_OR expr_in_list TOK_RPAREN
        { printf("[parser] or\n"); }
    ;

call_expr
    : TOK_LPAREN expr_in_list_item expr_in_list TOK_RPAREN
        { $$ = create_call($2, $3); }
    ;

expr_in_list
    : /* vazio */                   { $$ = NULL; }
    | expr_in_list expr_in_list_item { $$ = append_node($1, $2); }
    ;

expr_in_list_item
    : number        { $$ = $1; }
    | TOK_STRING    { $$ = create_string($1); }
    | TOK_IDENTIFIER
        {
            printf("[parser] identificador: '%s'\n", $1);
            Symbol *s = search_symbol(table, $1);
            if (!s) {
                yynerrs++;
                yyerror("[Erro Semantico]: Variável não declarada");
            }
            $$ = create_identifier($1);
        }
    | TOK_TRUE    { $$ = create_boolean(1); }
    | TOK_FALSE   { $$ = create_boolean(0); }
    | TOK_PLUS    { $$ = create_identifier("+"); }
    | TOK_MINUS   { $$ = create_identifier("-"); }
    /* Nota: TOK_MINUS aqui NÃO conflita com negative_number porque
       expr_in_list_item não inclui a regra negative_number.
       Dentro de (- 3 5), o "-" é consumido como operador (este case)
       e o "3"/"5" são consumidos como number nos itens seguintes.   */
    | TOK_MULT    { $$ = create_identifier("*"); }
    | TOK_DIVIDE  { $$ = create_identifier("/"); }
    | TOK_EQUAL   { $$ = create_identifier("="); }
    | TOK_LEFT_ARROW  { $$ = create_identifier("<"); }
    | TOK_RIGHT_ARROW { $$ = create_identifier(">"); }
    | list_expr   { $$ = $1; }
    | error TOK_RPAREN { yyerrok; $$ = NULL; }
    ;

%%

/* ════════════════════════════════════════════════════════════
   FUNÇÕES AUXILIARES
   ════════════════════════════════════════════════════════════ */

/* CORRIGIDO: yylloc só existe quando %locations está declarado (acima) */
void yyerror(const char *s) {
    extern char *yytext;
    fprintf(stderr,
            "[parser] ERRO %d (linha %d, coluna %d): %s | token: '%s'\n",
            yynerrs,
            yylloc.last_line,
            yylloc.last_column,
            s,
            yytext);
}

int main(void) {
    printf("=== Parser Scheme ===\n");

    table = create_symbol_table();

    int result = yyparse();

    if (result == 0) {
        printf("\n=== AST ===\n");
        if (ast_root)
            print_ast(ast_root, 0);
        else
            printf("[Aviso] Arvore vazia.\n");
        printf("===========\n");
    } else {
        printf("=== Parsing falhou ===\n");
    }

    free(table);
    printf("Erros: %d\n", yynerrs);
    return result;
}
