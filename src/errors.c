#include <stdio.h>
#include <stdlib.h>
#include "errors.h"

Error* get_tail(Error* base){
    Error* tail = base;
    while (tail->next != NULL) {
        tail = tail-> next;
    }

    return tail;
}

Error* add_error(Error* base, ErrorType type, char* message, int line_num, int column_num, char* token_char){
    Error* new_err = (Error*) malloc(sizeof(Error));

    new_err->message = message;
    new_err->err_type = type;
    new_err->column_num = column_num;
    new_err->line_num = line_num;
    new_err->next = NULL;
    new_err->token_char = token_char;

    if (base == NULL) base = new_err;
    else{
        Error* tail = get_tail(base);
        tail->next = new_err;
    }

    return  new_err;
}

void print_errs(Error* base) {
    Error* curr = base;
    while(curr != NULL){
        fprintf(
            stderr,
            "ERROR (Line %d, Column %d): %s; Token: %s\n\n", 
            curr->line_num, 
            curr->column_num, 
            curr->message,
            curr->token_char
        );
    }
}