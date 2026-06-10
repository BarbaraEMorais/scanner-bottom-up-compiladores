#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "ast.h"

ASTNode *create_number(int value);
ASTNode *create_decimal(double value);
ASTNode *create_identifier(char *name);
ASTNode *create_boolean(int value);
ASTNode *create_string(char *text);
ASTNode *create_set(char *name, ASTNode *value);
ASTNode *create_begin(ASTNode *exprs);
ASTNode *create_call(ASTNode *operator, ASTNode *arguments);
ASTNode *create_lambda(ASTNode *params, ASTNode *body);
ASTNode *create_let(int is_rec, ASTNode *bindings, ASTNode *body);
ASTNode *append_node(ASTNode *list, ASTNode *new_node);


ASTNode *create_number(int value) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) 
        return NULL;

    node->type = NODE_NUMBER;
    node->next = NULL;
    node->number = value;

    return node;
}

ASTNode *create_decimal(double value) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) 
        return NULL;

    node->type = NODE_FLOAT;
    node->next = NULL;
    node->float_value = value;

    return node;
}

ASTNode *create_identifier(char *name) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) 
        return NULL;

    node->type = NODE_IDENTIFIER;
    node->next = NULL;
    node->identifier = strdup(name);

    return node;
}

ASTNode *create_string(char *value) {
    
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) 
        return NULL;

    node->type = NODE_STRING;
    node->next = NULL;
    node->string_value = strdup(value);

    return node;
}

ASTNode *create_boolean(int value) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) 
        return NULL;

    node->type = NODE_BOOLEAN;
    node->next = NULL;
    node->boolean_value = value;

    return node;
}

ASTNode *create_binary_operation(char op, ASTNode *left, ASTNode *right) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) 
        return NULL;

    node->type = NODE_BINARY_OP;
    node->next = NULL;
    node->binary.op = op;
    node->binary.left = left;
    node->binary.right = right;

    return node;
}

ASTNode *create_define(char *name, ASTNode *value) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) 
        return NULL;

    node->type = NODE_DEFINE;
    node->next = NULL;
    node->define_stmt.name = strdup(name);
    node->define_stmt.value = value;

    return node;
}

ASTNode *create_if(ASTNode *condition, ASTNode *then_branch, ASTNode *else_branch) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) 
        return NULL;

    node->type = NODE_IF;
    node->next = NULL;
    node->if_stmt.condition = condition;
    node->if_stmt.then_branch = then_branch;
    node->if_stmt.else_branch = else_branch;

    return node;
}

ASTNode *create_set(char *name, ASTNode *value) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) 
        return NULL;

    node->type = NODE_SET;
    node->next = NULL;
    node->set_stmt.name = strdup(name);
    node->set_stmt.value = value;

    return node;
}

ASTNode *create_begin(ASTNode *exprs) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) 
        return NULL;

    node->type = NODE_BEGIN;
    node->next = NULL;
    node->begin_stmt.exprs = exprs;

    return node;
}

ASTNode *create_call(ASTNode *op, ASTNode *arguments) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) 
        return NULL;

    node->type = NODE_CALL;
    node->next = NULL;
    node->call_expr.op = op;
    node->call_expr.arguments = arguments;

    return node;
}

ASTNode *create_lambda(ASTNode *params, ASTNode *body) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) 
        return NULL;

    node->type = NODE_LAMBDA;
    node->next = NULL;
    node->lambda_expr.params = params;
    node->lambda_expr.body = body;

    return node;
}

ASTNode *create_let(int is_rec, ASTNode *bindings, ASTNode *body) {

    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) 
        return NULL;

    node->type = NODE_LET;
    node->next = NULL;
    node->let_expr.is_rec = is_rec;
    node->let_expr.bindings = bindings;
    node->let_expr.body = body;

    return node;
}

ASTNode *append_node(ASTNode *head, ASTNode *new_node) {
    if (!head)
        return new_node;
    if (!new_node)
        return head;

    ASTNode *current = head;
    while (current->next != NULL) {
        current = current->next;
    }
    current->next = new_node;  

    return head;
}