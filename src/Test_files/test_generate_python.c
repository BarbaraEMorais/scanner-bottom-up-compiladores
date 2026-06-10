#include "../AST/ast.h"
#include "../code_generator.h"
#include "stdio.h"


void test_number() {
    ASTNode *node = create_number(42);
    printf("%s\n\n", navigate_node(node, 0));
}

void test_identifier() {
    ASTNode *node = create_identifier("x");
    printf("%s\n\n", navigate_node(node, 0));
}

void test_binary_operation() {
    ASTNode *n1 = create_number(2);
    ASTNode *n2 = create_number(3);
    ASTNode *node = create_binary_operation('+', n1, n2);
    printf("%s\n\n", navigate_node(node, 0));
}

void test_define() {
    ASTNode *value = create_number(10);
    ASTNode *node = create_define("x", value);
    printf("%s\n\n", navigate_node(node, 0));
}   

void test_if() {
    ASTNode *condition = create_binary_operation('>', create_identifier("x"), create_number(0));
    ASTNode *then_branch = create_identifier("positive");
    ASTNode *else_branch = create_identifier("non-positive/else");
    ASTNode *node = create_if(condition, then_branch, else_branch);
    printf("%s\n\n", navigate_node(node, 0));
}

int main(){
    test_number();

    test_identifier();

    test_if();

    test_define();

    test_binary_operation();
}

