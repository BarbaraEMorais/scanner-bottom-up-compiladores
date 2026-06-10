#include "../AST/ast.h"
#include "../code_generator.h"
#include "stdio.h"


void test_number() {
    ASTNode *node = create_number(42);
    generate(node, "number.py");
}

void test_identifier() {
    ASTNode *node = create_identifier("x");
    generate(node, "id.py");
}

void test_binary_operation() {
    ASTNode *n1 = create_number(2);
    ASTNode *n2 = create_number(3);
    ASTNode *node = create_binary_operation('+', n1, n2);
    generate(node, "bin.py");
}

void test_define() {
    ASTNode *value = create_number(10);
    ASTNode *node = create_define("x", value);
    generate(node, "def.py");
}   

void test_if() {
    ASTNode *condition = create_binary_operation('>', create_identifier("x"), create_number(0));
    ASTNode *then_branch = create_identifier("positive");
    ASTNode *else_branch = create_identifier("non-positive/else");
    ASTNode *node = create_if(condition, then_branch, else_branch);
    generate(node, "if.py");
}

void test_all(){

    ASTNode *cond = create_binary_operation('<', 
                                                                                create_binary_operation('+',
                                                                                    create_identifier("a"),
                                                                                    create_number(3)), create_number(5));
    
    ASTNode *then = create_identifier("OK");
    ASTNode *else_branch_left = create_define("a", create_number(4));
    ASTNode *else_branch_right = create_define("b", create_number(3));

                                                            

    ASTNode* else_branch = create_if(create_binary_operation('>', create_identifier("a"), create_number(6)), else_branch_left, else_branch_right);

    ASTNode* root = create_if(cond, then,else_branch);


    generate(root, "all.py");
}

int main(){
    test_number();

    test_identifier();

    test_if();

    test_define();

    test_binary_operation();

    test_all();
}

