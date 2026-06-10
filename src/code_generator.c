#include "AST/ast.h"
#include <stdio.h>
#include <string.h>

// Esse módulo navega pela AST e gera código python

char* get_idents(int identation_level){
    char* base = "";
    for(int i = 0; i < identation_level; i++){
        strcat(base, "\t" );
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
            sprintf(value, "%d", node->number);
            strcat(to_write, value );
            break;
        case NODE_IDENTIFIER:
            sprintf(value, "%d", node->number);
            strcat(to_write, value );
            break;
        case  NODE_BINARY_OP:
            strcat(to_write, navigate_node(node->binary.left, 0));
            strcat(to_write, &node->binary.op);
            strcat(to_write, navigate_node(node->binary.right, 0));
            break;
        case NODE_DEFINE:
            strcat(to_write, node->define_stmt.name);
            strcat(to_write, "=");
            strcat(to_write, navigate_node(node->define_stmt.value, 0));
            strcat(to_write, "\n");
            break;
        case NODE_IF:
            strcat(to_write, "if ");
            strcat(to_write, navigate_node(node->if_stmt.condition, 0));
            strcat(to_write, ":\n");

            strcat(to_write, navigate_node(node->if_stmt.then_branch, curr_ident+1));

            strcat(to_write, "else:\n");
            strcat(to_write, navigate_node(node->if_stmt.else_branch, curr_ident+1));
            strcat(to_write, "\n");
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


