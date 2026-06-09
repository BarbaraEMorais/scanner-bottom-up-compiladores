#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

typedef enum {
    TYPE_NUMBER,
    TYPE_FLOAT,
    TYPE_STRING,
    TYPE_BOOLEAN,
    TYPE_FUNCTION,
    TYPE_UNKNOWN
} SymbolType;

typedef struct Symbol {
    char *name;
    SymbolType type;
    int scope; // 0 for global, 1 for local
    struct Symbol *next;
} Symbol;

typedef struct SymbolTable {
    Symbol *head;
    int actual_scope; 
} SymbolTable;

SymbolTable* create_symbol_table();
void insert_symbol(SymbolTable *table, char *name, SymbolType type);
Symbol* search_symbol(SymbolTable *table, char *name);
void enter_scope(SymbolTable *table);
void exit_scope(SymbolTable *table);
const char* tipo_para_texto(SymbolType type); 

#endif