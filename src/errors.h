// O propósito desse módulo é criar uma interface para retornar erros para o usuário

typedef enum error_type {
    MALLOC_ERROR,
    TYPE_ERROR,
    GENERIC_ERROR
} ErrorType;


// Lista de possíveis erros

void print_error(ErrorType error, char* additional_message);