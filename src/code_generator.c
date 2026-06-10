#include "AST/ast.h"
#include <stdio.h>
#include <string.h>

// Esse módulo navega pela AST e gera código python

char* joinstr(char* base, char* to_add){
    char ret[sizeof(base) + sizeof(to_add) + 1];

    strcat(ret, base);
    strcat(ret, base);
}

char* get_idents(int identation_level){
    char* base = "";
    for(int i = 0; i < identation_level; i++){
        joinstr(base, "\t" );
    }

    return  base;
}

char* navigate_node(ASTNode* node, int identation_level){
    int curr_ident = identation_level;
    char* to_write = get_idents(curr_ident);
    char* value = "";
    int temp_ident_store = 0;
    switch (node->type) {
        case NODE_NUMBER:
            sscanf(value, "%d", &node->number);
            joinstr(to_write, value );
            break;
        case NODE_IDENTIFIER:
            sscanf(value, "%s", node->identifier);
            joinstr(to_write, value );
            break;
        case  NODE_BINARY_OP:
            joinstr(to_write, navigate_node(node->binary.left, 0));
            joinstr(to_write, &node->binary.op);
            joinstr(to_write, navigate_node(node->binary.right, 0));
            break;
        case NODE_DEFINE:
            joinstr(to_write, node->define_stmt.name);
            joinstr(to_write, "=");
            joinstr(to_write, navigate_node(node->define_stmt.value, 0));
            joinstr(to_write, "\n");
            break;
        case NODE_IF:
            joinstr(to_write, "if ");
            joinstr(to_write, navigate_node(node->if_stmt.condition, 0));
            joinstr(to_write, ":\n");

            joinstr(to_write, navigate_node(node->if_stmt.then_branch, curr_ident+1));

            joinstr(to_write, "else:\n");
            joinstr(to_write, navigate_node(node->if_stmt.else_branch, curr_ident+1));
            joinstr(to_write, "\n");
            break;
        default:
            fprintf(stderr, "AST ERROR: node type %d is not a  defined type", node->type);
            return NULL;
    }


    return to_write;
}

void generate(ASTNode* root){
    FILE* fptr = fopen("out.py", "w");

    fprintf(fptr,
             "%s",
            navigate_node(root, 0)
        );
    
}


