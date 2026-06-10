#include "AST/ast.h"
#include <linux/limits.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Esse módulo navega pela AST e gera código python

char* get_idents(char* base, int identation_level){
    for(int i = 0; i < identation_level; i++){
        base = strcat(base, "\t" );
    }

    return  base;
}

#define BUF_SIZE 9999

char* navigate_node(ASTNode* node, int identation_level, FILE** fptr){
    int curr_ident = identation_level;
    char idents[BUF_SIZE];
    get_idents(idents,  curr_ident);
    int temp_ident_store = 0;
    switch (node->type) {
        case NODE_NUMBER:
            fprintf(*fptr, "%s%d", idents, node->number);
            break;
        case NODE_IDENTIFIER:
            fprintf(*fptr,  "%s%s",idents,  node->identifier);
            break;
        case  NODE_BINARY_OP:
            navigate_node(node->binary.left, 0, fptr);
            fprintf(*fptr, "%s", &node->binary.op);
            navigate_node(node->binary.right, 0, fptr);
            break;
        case NODE_DEFINE:
            fprintf(*fptr, "%s%s = ", idents, node->define_stmt.name);
            navigate_node(node->define_stmt.value, 0, fptr);
            fprintf(*fptr, "%s\n", idents);
            break;
        case NODE_IF:
            fprintf(*fptr, "%sif", idents);
            navigate_node(node->if_stmt.condition, 0, fptr);
            fprintf(*fptr, ":\n");

            navigate_node(node->if_stmt.then_branch, curr_ident+1, fptr);

            fprintf(*fptr, "%selse:\n", idents);
            navigate_node(node->if_stmt.else_branch, curr_ident+1, fptr);
            fprintf(*fptr, "\n");
            break;
        default:
            fprintf(stderr, "AST ERROR: node type %d is not a  defined type", node->type);
            return NULL;
    }

    printf("%s", idents);
}

void generate(ASTNode* root, char* file_name){
    FILE* fptr = fopen(file_name, "a");

    navigate_node(root, 0, &fptr);
    
    fclose(fptr);
    
}


