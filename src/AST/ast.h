#ifndef AST_H
#define AST_H

typedef enum {
    NODE_NUMBER,
    NODE_IDENTIFIER,
    NODE_BINARY_OP,
    NODE_DEFINE,
    NODE_IF
} ASTNodeType;

typedef struct ASTNode {
    ASTNodeType type;

    union {
        int number;

        char *identifier;

        struct {
            char op;
            struct ASTNode *left;
            struct ASTNode *right;
        } binary;

        struct {
            char *name;
            struct ASTNode *value;
        } define_stmt;

        struct {
            struct ASTNode *condition;
            struct ASTNode *then_branch;
            struct ASTNode *else_branch;
        } if_stmt;
    };

} ASTNode;

ASTNode *create_number(int value);
ASTNode *create_identifier(char *name);
ASTNode *create_binary_operation(
    char op,
    ASTNode *left,
    ASTNode *right);
ASTNode *create_define(
    char *name,
    ASTNode *value);

ASTNode *create_if(
    ASTNode *condition,
    ASTNode *then_branch,
    ASTNode *else_branch);
    
void print_ast(ASTNode *node, int level);

#endif