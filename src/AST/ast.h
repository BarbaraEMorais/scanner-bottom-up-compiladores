#ifndef AST_H
#define AST_H

typedef enum {
    NODE_NUMBER,
    NODE_DECIMAL,
    NODE_IDENTIFIER,
    NODE_BINARY_OP,
    NODE_DEFINE,
    NODE_IF,
    NODE_BOOLEAN,      
    NODE_STRING,       
    NODE_LAMBDA,       
    NODE_LET,         
    NODE_BEGIN,        
    NODE_SET,          
    NODE_CALL,         
    NODE_PROGRAM
} ASTNodeType;

typedef struct ASTNode {
    ASTNodeType type;
    struct ASTNode *next; 

    union {
        int number;
        double decimal;
        char *identifier;
        char *string_value;
        int boolean_value;

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

        struct {
            char *name;
            struct ASTNode *value;
        } set_stmt;

        struct {
            struct ASTNode *params; 
            struct ASTNode *body;   
        } lambda_expr;

        struct {
            int is_rec;              
            struct ASTNode *bindings; 
            struct ASTNode *body;    
        } let_expr;

        struct {
            struct ASTNode *exprs;   
        } begin_stmt;

        struct {
            struct ASTNode *operator;  
            struct ASTNode *arguments; 
        } call_expr;
    };

} ASTNode;

void print_ast(ASTNode *node, int level);

ASTNode *create_number(int value);
ASTNode *create_decimal(double value);
ASTNode *create_identifier(char *name);
ASTNode *create_boolean(int value);
ASTNode *create_string(char *value);
ASTNode *create_set(char *name, ASTNode *value);
ASTNode *create_begin(ASTNode *exprs);
ASTNode *create_call(ASTNode *operator, ASTNode *arguments);
ASTNode *create_lambda(ASTNode *params, ASTNode *body);
ASTNode *create_let(int is_rec, ASTNode *bindings, ASTNode *body);
ASTNode *append_node(ASTNode *head, ASTNode *new_node);

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

#endif