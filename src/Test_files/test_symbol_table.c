#include <stdio.h>
#include <stdlib.h>
#include "../symbol_table.h" 

void testar_busca(SymbolTable *tabela, char *nome) {
   
    Symbol *s = search_symbol(tabela, nome); 
    if (s != NULL) {
        printf("  Busca por '%s': Achado! Tipo: %s, Escopo: %d\n", s->name, tipo_para_texto(s->type), s->scope);
    } else {
        printf("  Busca por '%s': NAO ENCONTRADO (Erro de contexto!)\n", nome);
    }
}

void print_tabela(SymbolTable *tabela) {
    printf("\n--- ESTADO ATUAL DA TABELA (Escopo Atual: %d) ---\n", tabela->actual_scope);
    
    Symbol *atual = tabela->head;
    if (atual == NULL) {
        printf("  [Tabela Vazia]\n");
    }

    while (atual != NULL) {
        printf("  [ Nome: %s | Tipo: %d | Escopo: %d ] ->\n", atual->name, atual->type, atual->scope);
        atual = atual->next; 
    }
    printf("  [ NULL ]\n------------------------------------------------\n\n");
}

int main() {
    
    
    printf("1. Inicializando a tabela de símbolos...\n");
    SymbolTable *tabela = create_symbol_table();
    print_tabela(tabela);

    printf("2. Inserindo variáveis globais (Escopo 0)...\n");
    insert_symbol(tabela, "x", TYPE_NUMBER);
    insert_symbol(tabela, "glorp", TYPE_BOOLEAN);
    print_tabela(tabela);

    printf("3. Testando buscas no escopo global:\n");
    testar_busca(tabela, "x");      
    testar_busca(tabela, "glorp");  
    testar_busca(tabela, "y");      

    printf("\n4. Entrando em um bloco (Mudando para Escopo 1)...\n");
    enter_scope(tabela); 
    
    insert_symbol(tabela, "x", TYPE_BOOLEAN); 
    insert_symbol(tabela, "y", TYPE_STRING); 
    print_tabela(tabela);

    printf("5. Testando buscas dentro do Escopo 1:\n");
    testar_busca(tabela, "x");      
    testar_busca(tabela, "y");      
    testar_busca(tabela, "glorp");  

    printf("\n6. Saindo do bloco (Voltando para Escopo 0)...\n");
    exit_scope(tabela);
    print_tabela(tabela);

    printf("7. Testando buscas de volta ao Escopo 0:\n");
    testar_busca(tabela, "x");      
    testar_busca(tabela, "y");      

    exit_scope(tabela); 
    free(tabela);
    
    printf("\nTestes concluídos com sucesso!\n");
    return 0;
}