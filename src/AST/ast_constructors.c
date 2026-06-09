#include <stdlib.h>
#include <string.h>
#include "ast.h"

ASTNode *create_number(int value) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));

    node->type = NODE_NUMBER;
    node->number = value;

    return node;
}

ASTNode *create_identifier(char *name) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));

    node->type = NODE_IDENTIFIER;
    node->identifier = strdup(name);

    return node;
}

ASTNode *create_binary_operation(char op, ASTNode *left, ASTNode *right) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));

    node->type = NODE_BINARY_OP;
    node->binary.op = op;
    node->binary.left = left;
    node->binary.right = right;

    return node;
}

ASTNode *create_define(char *name, ASTNode *value) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));

    node->type = NODE_DEFINE;
    node->define_stmt.name = strdup(name);
    node->define_stmt.value = value;

    return node;
}

ASTNode *create_if(ASTNode *condition, ASTNode *then_branch, ASTNode *else_branch) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));

    node->type = NODE_IF;
    node->if_stmt.condition = condition;
    node->if_stmt.then_branch = then_branch;
    node->if_stmt.else_branch = else_branch;

    return node;
}