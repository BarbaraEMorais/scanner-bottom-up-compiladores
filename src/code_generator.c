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

FILE** definitions_file_ptr;

int num_aux_created = 0;

char* navigate_node(ASTNode* node, int identation_level, FILE** fptr){
    char idents[BUF_SIZE];
    get_idents(idents,  identation_level);
    int temp_ident_store = 0;

    ASTNode* node_navigator = NULL;

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
            fprintf(*fptr, "%sif ", idents);
            navigate_node(node->if_stmt.condition, 0, fptr);
            fprintf(*fptr, ":\n%s", idents);

            navigate_node(node->if_stmt.then_branch, identation_level+1, fptr);

            fprintf(*fptr, "\n");

            if (node->if_stmt.else_branch != NULL){
                fprintf(*fptr, "%selse:", idents);
                fprintf(*fptr, "\n");
                navigate_node(node->if_stmt.else_branch, identation_level+1, fptr);
                fprintf(*fptr, "\n");    
            }

            break;

        case NODE_BOOLEAN:
                if (node->boolean_value){
                    fprintf(*fptr, "True");
                } else {
                    fprintf(*fptr, "False");
                }
            break;
        case NODE_STRING:
                fprintf(*fptr, "%s", node->string_value);
                break;

        case NODE_SET:
                fprintf(*fptr, "%s%s = ", idents, node->set_stmt.name);
                navigate_node(node->set_stmt.value, 0, fptr);
                fprintf(*fptr, "\n");

                break;
        
        case NODE_BEGIN:
                node_navigator = node->begin_stmt.exprs;

                while (node_navigator != NULL) {
                    navigate_node(node_navigator, identation_level+1, fptr);
                    fprintf(*fptr, "\n");
                    node_navigator = node_navigator->next;
                }

                node_navigator = NULL;

                break;

        case NODE_CALL:
                fprintf(*fptr, "%s", idents);

                navigate_node(node->call_expr.op, 0, fptr);
                
                fprintf(*fptr, "(");

                node_navigator = node->call_expr.arguments;

                while (node_navigator != NULL) {
                    if (node_navigator != node->call_expr.arguments){
                        fprintf(*fptr, ", ");
                    }

                    navigate_node(node_navigator, 0, fptr);
                    
                    node_navigator = node_navigator->next;
                }

                fprintf(*fptr, ")");
                break;

        case NODE_LAMBDA:
                fprintf(*definitions_file_ptr, "%sdef lambda%d( ", idents, num_aux_created);

                node_navigator = node->lambda_expr.params;

                while (node_navigator != NULL) {
                    if (node_navigator != node->lambda_expr.params){
                        fprintf(*definitions_file_ptr, ", ");
                    }

                    navigate_node(node_navigator, 0, definitions_file_ptr);
                    
                    node_navigator = node_navigator->next;
                }

                fprintf(*definitions_file_ptr, " ):\n");

                node_navigator = node->lambda_expr.body;

                while (node_navigator->next != NULL){
                    navigate_node(node_navigator, identation_level+1, definitions_file_ptr);
                    fprintf(*definitions_file_ptr, "\n");

                    node_navigator = node_navigator->next;
                }

                fprintf(*definitions_file_ptr, "return ");

                navigate_node(node_navigator, 0, definitions_file_ptr);
                fprintf(*definitions_file_ptr,"\n\n");

                fprintf(*fptr, "lambda%d (", num_aux_created);

                node_navigator = node->lambda_expr.params;

                while (node_navigator != NULL) {
                    if (node_navigator != node->lambda_expr.params){
                        fprintf(*fptr, ", ");
                    }

                    navigate_node(node_navigator, 0, fptr);
                    
                    node_navigator = node_navigator->next;
                }

                fprintf(*fptr, ")");

                num_aux_created++;
                break;

        default:
            fprintf(stderr, "AST ERROR: node type %d is not a  defined type", node->type);
            return NULL;
    }

}

void generate(ASTNode* root, char* file_name){
    FILE* fptr = fopen(file_name, "a");

    FILE* aux_files = fopen("aux.py", "a");
    definitions_file_ptr = &aux_files;

    fprintf(fptr, "import aux\n");
    navigate_node(root, 0, &fptr);
    
    fprintf(fptr, "\n");

    fclose(fptr);
    fclose(aux_files);
    
}


