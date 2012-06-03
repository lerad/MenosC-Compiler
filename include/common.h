#ifndef  DEFINITIONS_INC
#define  DEFINITIONS_INC

#include <stdio.h>


extern int numErrores;
extern int verbose;
extern int showTDS;
extern int level;
extern FILE* yyin;
extern int yylex();
extern int yyparse();
extern char* yytext;
extern int yylineno;
extern "C" { void yyerror(char *s) ; }
void declareVariable(int n, char *nom, int type, int desp, int size, int ref);
void declareSymbol(char *nom, int category, int type, int desp, int level, int ref);

// TODO: Is there a standard version in the stdlib?
#define TRUE 1
#define FALSE 0

#endif   /* ----- #ifndef DEFINITIONS_INC  ----- */
