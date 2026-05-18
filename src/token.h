// Define os tokens básicos da linguagem scheme
// string, identificadores e números podem em teoria ser definidos aqui
// Ou podemos usar a recursão da linguagem no bison.

#include <stdlib.h>
#include "errors.h"

typedef struct token Token;

typedef enum token_type{ 
    // Delimitadores
    L_PAREN,
    R_PAREN,
    BACKSLASH,
    STRING_DELIMITER,
    LITERAL_DELIMITER,
    COMMA,
    SEMICOLON,
    MULTILINE_COMMENT_START,
    MULTILINE_COMMENT_END,

    // Palavras Reservadas
    DEFINE,
    DEFINE_VALUES,
    DEFINE_RECORD_TYPE,
    BEGIN_scheme,
    LAMBDA,
    COND,
    CASE,
    IF,
    ELSE,
    AND,
    OR,
    WHEN,
    UNLESS,
    LET,
    LETREC,
    LET_VALUES,
    LET_SYNTAX,
    LETREC_SYNTAX,
    DO,
    DELAY,
    DELAY_FORCE,
    PARAMETRIZE,
    GUARD,
    CASE_LAMBDA,
    EXPORT,
    RENAME,
    COND_EXPAND,
    IMPORT,
    INCLUDE_LIBRARY_DECLARATIONS,
    ONLY,
    EXCEPT,
    PREFIX,
    NOT,
    LOOP,
    EQ,
    CONS,
    SET,

    // Symbols
    MULT,
    PLUS,
    MINUS,
    ASSIGN,
    TRUE,
    FALSE,
    VERTICAL_LINE,
    EQUAL_SIGN,
    LEFT_ARROW,
    RIGHT_ARROW,
    COLON,
    PERCENT,
    DOLLAR,
    AMPERSAND,
    INTERROGATION,
    UNDERLINE,
    POINT,
    DIGIT,
    LETTER,

    // Prefixes
    CHARACTER_CONSTANT,
    VECTOR_CONSTANT_START,
    BYTE_VECTOR_CONSTANTE_START,
    DIRECTIVE_START,
    BASE_2_INDICATOR,
    BASE_8_INDICATOR,
    BASE_16_INDICATOR,
    BASE_10_INDICATOR,
    E_INDICATOR,
    I_INDICATOR,
} TokenType;

// O struct token em si, contém o tipo e o conteúdo do token, se existir.
struct token
{
    TokenType type;
    char* value;
    Token* previous;
    Token* next;
};

Token* create_token(TokenType type, char* content){
    Token* base = (Token*) malloc(sizeof(Token));
    if (base == NULL){
        print_error(MALLOC_ERROR, content);
        return NULL;
    }
    base->type = type;
    base->value = content;
    base->previous = NULL;
}

Token* move_to_end(Token* base){
    Token* curr=base;
    while (curr->next != NULL)
    {
        curr = curr->next;
    }
    
    return curr;
}

Token append_new_token(Token* base, TokenType new_token_type, char* new_token_content){
    Token* last = move_to_end(base);
    
    last->next = create_token(new_token_type, new_token_content);
    last->next->previous = base;
}

Token append_token(Token* base, Token* to_append){
    base->next = to_append;
    to_append->previous = base;
}

void free_tokens(Token* base){
    Token* curr = base;

    while (curr != NULL)
    {
        Token* to_delete = base;
        curr = base->next;
        free(to_delete);
    }
    
}