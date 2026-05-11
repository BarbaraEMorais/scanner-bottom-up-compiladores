
extern int yylex (void);

int yywrap(){}
int main(int argc, char *argv[])
{
    yylex();
    return 0;
}