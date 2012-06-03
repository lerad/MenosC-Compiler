%{ 
#include "include/common.h"
#include "include/libgci.h"
#include <string.h>
#include <stdlib.h>
#include "MenosC.tab.h"

int createCnumber();
int truncCreal();

char* createId();

const int MAX_LENGTH = 14; // maximum length of id in characters
%}

/* %option c++ */

DIGIT      [0-9]
REAL 	   {DIGIT}+.{DIGIT}+
WHITESPACE [ \t]
LETTER      [a-zA-Z_]

%%

"int"   {  return INT_; }
"read"  { return READ_; }
"print" { return PRINT_; }
"if"    { return IF; }
"else"  { return ELSE; }
"return" { return RETURN; }
"for"   { return FOR; }
"struct" {return STRUCT; }
{WHITESPACE}+ 
"\n" {yylineno++;}
"}"  { return CURLY_CLOSE_; }
"{"  { return CURLY_OPEN_; }
"]"  { return SQUARE_CLOSE_; }
"["  { return SQUARE_OPEN_; }
")"  { return PAR_CLOSE_; }
"("  { return PAR_OPEN_; }
";"  { return SEMICOLON_; }
"+"  { return PLUS; }
"*"  { return MULT; }
"-"  { return MINUS; }
"/"  { return DIV; }
"="  { return ASIGN; }
"==" { return EQUAL; }
"!=" { return NOT_EQUAL; }
">=" { return GREATER_EQUAL; }
"<=" { return LESS_EQUAL; }
"<"  { return LESS; }
">"  { return GREATER; }
"++" { return INC; }
"--" { return DEC; }
"+=" { return ADD_ASIGN; }
"-=" { return MINUS_ASIGN; }
"."  { return POINT_; }
","  { return COMMA; }


{REAL}  {yylval.integer = truncCreal(); printf("Warning: Conversion from real to int in line %i\n", yylineno);  return CTI_;}
{DIGIT}+ { yylval.integer =createCnumber(); return CTI_; }
{LETTER}({LETTER}|{DIGIT})* {  yylval.id = createId(); return ID_; }
"//"[^\n]* 


. { 
  char buffer[200];
  sprintf(buffer, "Unknown character '%s'\n", yytext, yylineno);
  yyerror(buffer);
}

%%


/*returns new allocated char* copied from yytext */
char *createId()
{

	if(yyleng >MAX_LENGTH) {
        printf("Warning: Identifier '%s' at line %i will be reduced to %i letters\n", yytext, yylineno, MAX_LENGTH); 
		yyleng = MAX_LENGTH;
    }
	char *buffer = (char*)malloc(yyleng + 1); 
	strncpy(buffer, yytext, yyleng);
    buffer[yyleng] = '\0';
	return buffer;
}

int truncCreal()
{
  return (int)atof(yytext);
}

int createCnumber()
{
  return atoi(yytext); 
}
  
/*MAIN*/
int main(int argc, char **argv) {
  char *fileName;
  int i, n = 0;
  for(i = 0; i<argc; ++i) {
    if(strcmp(argv[i], "-v") == 0) { verbose = TRUE; n++; }
    else if(strcmp(argv[i], "-t") == 0) { showTDS = TRUE; n++; }
  }
  --argc; 
  n++;
  
  if (argc == n) {
    if((yyin = fopen (argv[argc], "r")) == NULL) 
        fprintf(stderr, "Invalid file %s\n", argv[argc]);
    else {
        if (verbose == TRUE) fprintf(stdout, "$3d.- ", yylineno);
        fileName = argv[argc];
        yyparse();
        if (numErrores == 0) vuelcaCodigo(fileName);
        else fprintf(stdout, "\nNumber of errors: %d\n", numErrores); 
     }
   }
   else fprintf(stderr, "Usage: cmc [-v] [-t] file\n");

  //return 0;
}


