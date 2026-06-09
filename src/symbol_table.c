#include "symbol_table.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

SymbolTable* create_symbol_table() {

    SymbolTable *table = (SymbolTable *)malloc(sizeof(SymbolTable));

    if (table == NULL) {
        fprintf(stderr, "Error: Could not allocate memory for SymbolTable.\n");
        exit(1);
    }
    table->head = NULL;
    table->actual_scope = 0; 
    return table;
}

void enter_scope(SymbolTable *table) {
    table->actual_scope++;
}

Symbol* search_symbol(SymbolTable *table, char *name) {

    if (table == NULL)
        return NULL;

    Symbol *current = table->head;

    while (current) {
        if (current && strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

void insert_symbol(SymbolTable *table, char *name, SymbolType type) {

    // nao funciona com shadowing

    // if (search_symbol(table, name)) {
    //     printf("Error: Symbol '%s' already exists in the current scope.\n", name);
    //     return;
    // }
    // printf("[DEBUG] Entrou no insert para: %s\n", name);

    Symbol *existing = search_symbol(table, name);

    // printf("[DEBUG] Passou pelo search_symbol\n");

    if (existing != NULL) {
        //printf("[DEBUG] O ponteiro nao e nulo, tentando ler o escopo...\n");
        if (existing->scope == table->actual_scope) {
            printf("Error: Symbol '%s' already exists in the current scope.\n", name);
            return;
        }
    }
    //printf("[DEBUG] Passou da checagem de escopo com sucesso!\n");
    Symbol *new_symbol = (Symbol *)malloc(sizeof(Symbol));

    if (new_symbol == NULL) { printf("Erro no malloc\n"); return; }

    new_symbol->name = strdup(name);
    new_symbol->type = type;
    new_symbol->scope = table->actual_scope;

    //printf("[DEBUG] Vai atualizar os ponteiros da head\n");
    new_symbol->next = table->head;
    table->head = new_symbol;
    //printf("[DEBUG] Símbolo %s inserido com sucesso!\n", name);
}

void exit_scope(SymbolTable *table) {
    if (table == NULL)
        return;

    while(table->head != NULL && table->head->scope == table->actual_scope) {
        Symbol *cleaner = table->head;
        table->head = table->head->next;
        free(cleaner->name);
        free(cleaner);
    }
    table->actual_scope--;
}

const char* tipo_para_texto(SymbolType type) {
    switch(type) {
        case TYPE_NUMBER:  return "NUMBER";
        case TYPE_BOOLEAN: return "BOOLEAN";
        case TYPE_STRING:  return "STRING";
        default:           return "UNKNOWN";
    }
}