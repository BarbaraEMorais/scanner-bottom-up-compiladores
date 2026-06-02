#include "ast.h"
#include <stdio.h>

void print_ast(struct ASTNode *node, int level) {
    if (!node) {
        return;
    }

    for (int i = 0; i < level; i++) {
        printf("  ");
    }

    switch(node->type) {
        case NODE_NUMBER:
            printf("Number: %d\n", node->number);
            break;
        case NODE_IDENTIFIER:
            printf("Identifier: %s\n", node->identifier);
            break;
        case NODE_BINARY_OP:
            printf("Binary Operation: %c\n", node->binary.op);
            print_ast(node->binary.left, level + 1);
            print_ast(node->binary.right, level + 1);
            break;
        case NODE_DEFINE:
            printf("Define: %s\n", node->define_stmt.name);
            print_ast(node->define_stmt.value, level + 1);
            break;
        case NODE_IF:
            printf("If Statement\n");
            print_ast(node->if_stmt.condition, level + 1);
            print_ast(node->if_stmt.then_branch, level + 1);
            if (node->if_stmt.else_branch) {
                print_ast(node->if_stmt.else_branch, level + 1);
            }
            break;
        default:   
            printf("Unknown node type\n");
            break;
    }
}