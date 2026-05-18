#include "token.h"

#include <stdlib.h>
#include "errors.h"

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