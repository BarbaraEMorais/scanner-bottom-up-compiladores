// O propósito desse módulo é criar uma interface para retornar erros para o usuário

typedef enum error_type {
    MALLOC_ERROR,
    TYPE_ERROR,
    LEXICAL_ERROR,
    PARSE_ERROR,
    GENERIC_ERROR
} ErrorType;

typedef struct error{
    char* message;
    ErrorType err_type;
    int line_num;
    int column_num;
    char* token_char;

    struct error* next;
} Error;

Error* add_error(Error* base, ErrorType type, char* message, int line_num, int column_num, char* token_char);
void print_errs(Error* base) ;
