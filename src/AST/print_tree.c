#include "ast.h"
#include <stdio.h>

void print_ast(ASTNode *node, int level) {
    if (!node) return;

    // opt: identa arvore
    for (int i = 0; i < level; i++) {
        printf("  ");
    }

    switch(node->type) {
        case NODE_NUMBER:
            printf("Number: %d\n", node->number);
            break;
            
        case NODE_DECIMAL:
            printf("Decimal: %f\n", node->decimal);
            break;
            
        case NODE_IDENTIFIER:
            printf("Identifier: %s\n", node->identifier);
            break;
            
        case NODE_STRING:
            printf("String: \"%s\"\n", node->string_value);
            break;
            
        case NODE_BOOLEAN:
            printf("Boolean: %s\n", node->boolean_value ? "#t" : "#f");
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

        case NODE_SET:
            printf("Set!: %s\n", node->set_stmt.name);
            print_ast(node->set_stmt.value, level + 1);
            break;

        case NODE_IF:
            printf("If Statement\n");
            print_ast(node->if_stmt.condition, level + 1);
            print_ast(node->if_stmt.then_branch, level + 1);
            if (node->if_stmt.else_branch) {
                print_ast(node->if_stmt.else_branch, level + 1);
            }
            break;

        case NODE_BEGIN:
            printf("Begin Block\n");
            ASTNode *b_expr = node->begin_stmt.exprs;
            while (b_expr) {
                print_ast(b_expr, level + 1);
                b_expr = b_expr->next; // Navega pelos comandos irmãos
            }
            break;

        case NODE_CALL:
            printf("Function Call\n");
            for (int i = 0; i < level + 1; i++) printf("  ");
            printf("Operator:\n");
            print_ast(node->call_expr.op, level + 2);
            
            if (node->call_expr.arguments) {
                for (int i = 0; i < level + 1; i++) printf("  ");
                printf("Arguments:\n");
                ASTNode *arg = node->call_expr.arguments;
                while (arg) {
                    print_ast(arg, level + 2);
                    arg = arg->next; // Navega pela lista de argumentos
                }
            }
            break;

        case NODE_LAMBDA:
            printf("Lambda Expression\n");
            for (int i = 0; i < level + 1; i++) printf("  ");
            printf("Parameters:\n");
            ASTNode *param = node->lambda_expr.params;
            while (param) {
                print_ast(param, level + 2);
                param = param->next;
            }
            for (int i = 0; i < level + 1; i++) printf("  ");
            printf("Body:\n");
            ASTNode *l_body = node->lambda_expr.body;
            while (l_body) {
                print_ast(l_body, level + 2);
                l_body = l_body->next;
            }
            break;

        case NODE_LET:
            printf("%s Expression\n", node->let_expr.is_rec ? "Letrec" : "Let");
            for (int i = 0; i < level + 1; i++) printf("  ");
            printf("Bindings:\n");
            ASTNode *bind = node->let_expr.bindings;
            while (bind) {
                print_ast(bind, level + 2);
                bind = bind->next;
            }
            for (int i = 0; i < level + 1; i++) printf("  ");
            printf("Body:\n");
            print_ast(node->let_expr.body, level + 2);
            break;

        default:   
            printf("Unknown node type: %d\n", node->type);
            break;
    }
}