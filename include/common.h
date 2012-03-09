#ifndef  DEFINITIONS_INC
#define  DEFINITIONS_INC

#include <stdio.h>




extern FILE* yyin;
extern int yylex();
extern int yyparse();
extern char* yytext;
extern int yylineno;
extern "C" { void yyerror(char *s) ; }
void declareVariable(int n, char *nom, int type, int desp, int size, int ref);



#endif   /* ----- #ifndef DEFINITIONS_INC  ----- */
