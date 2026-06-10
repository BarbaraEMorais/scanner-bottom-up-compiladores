#include <stdio.h>
#include "../AST/ast.h"

void test_number() {
    ASTNode *node = create_number(42);
    print_ast(node, 0);
}

void test_identifier() {
    ASTNode *node = create_identifier("x");
    print_ast(node, 0);
}

void test_binary_operation() {
    ASTNode *n1 = create_number(2);
    ASTNode *n2 = create_number(3);
    ASTNode *node = create_binary_operation('+', n1, n2);
    print_ast(node, 0);
}

void test_define() {
    ASTNode *value = create_number(10);
    ASTNode *node = create_define("x", value);
    print_ast(node, 0);
}   

void test_if() {
    ASTNode *condition = create_binary_operation('>', create_identifier("x"), create_number(0));
    ASTNode *then_branch = create_identifier("positive");
    ASTNode *else_branch = create_identifier("non-positive/else");
    ASTNode *node = create_if(condition, then_branch, else_branch);
    print_ast(node, 0);
}

int main() {
    printf("Testing number node:\n");
    test_number();

    printf("\nTesting identifier node:\n");
    test_identifier();

    printf("\nTesting binary operation node:\n");
    test_binary_operation();

    printf("\nTesting define node:\n");
    test_define();

    printf("\nTesting if statement node:\n");
    test_if();

    return 0;
}