%{
    #include <stdio.h>

    #define YYPARSE_PARAM scanner
    #define YYLEX_PARAM   scanner
    
    #if YYBISON
    union YYSTYPE;
    struct YYLTYPE;
    extern int yylex(union YYSTYPE *, void *);
    void yyerror(struct YYLTYPE* loc, char* s);
    #endif
%}

%locations
%define api.pure full
%define parse.error detailed

%union
{
  int           ival;   /* integer value  */
  double        dval;   /* float value    */
  char*         sval;   /* string value   */
  char          cval;   /* char value     */
  unsigned int  uval;   /* unsigned value */
  /* custom field */
}

%token TOK_LPAREN "("     

    
%token 
    TOK_RPAREN          
    TOK_COMMA           
    TOK_SEMICOLON       
    TOK_COLON           
    TOK_BACKSLASH       
    TOK_STRING_DELIM
    TOK_LITERAL_DELIM
    TOK_MULTILINE_COMMENT_START
    TOK_MULTILINE_COMMENT_END


    TOK_DEFINE
    TOK_DEFINE_VALUES
    TOK_DEFINE_RECORD_TYPE
    TOK_BEGIN
    TOK_LAMBDA
    TOK_COND
    TOK_CASE
    TOK_IF
    TOK_ELSE
    TOK_AND
    TOK_OR
    TOK_WHEN
    TOK_UNLESS
    TOK_LET
    TOK_LETREC
    TOK_LET_VALUES
    TOK_LETREC_SYNTAX
    TOK_DO
    TOK_DELAY
    TOK_DELAY_FORCE
    TOK_GUARD
    TOK_CASE_LAMBDA
    TOK_EXPORT
    TOK_RENAME
    TOK_COND_EXPAND
    TOK_IMPORT
    TOK_INCLUDE_LIBRARY_DECLARATIONS
    TOK_ONLY
    TOK_EXCEPT
    TOK_PREFIX
    TOK_NOT
    TOK_LOOP
    TOK_EQ
    TOK_CONS
    TOK_SET

    TOK_MULT
    TOK_MINUS
    TOK_ASSIGN
    TOK_TRUE
    TOK_FALSE
    TOK_VERTICAL_LINE
    TOK_EQUAL   
    TOK_LEFT_ARROW

    TOK_NUMBER
    TOK_CHARACTER_STRING

    TOK_UNINDENTIFIED_TOKEN
;

%token <int> TOK_INTEGER "integer"

%% 

integer: {printf("%d", yylval);}

lparen :TOK_LPAREN {}

%%

void yyerror(struct YYLTYPE* loc, char* s){
 fprintf(stderr, "Error at line %d, column %d: %s \n", loc->first_line, loc->first_column, s);
}
