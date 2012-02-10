%{ 
#include <stdio.h>
#include "MenosC.tab.h"
%}

DIGIT      [0-9]
WHITESPACE [ \t\n]
LETRA      [a-zA-Z_]

%%

// Test commit

"int"   {  return INT_; }
"read"  { return READ_; }
"print" { return PRINT_; }
"if"    { return IF; }
"else"  { return ELSE; }
"return" { return RETURN; }
"for"   { return FOR; }
"struct" {return STRUCT; }
{WHITESPACE}+ 
"}"  { return LLAVCER_; }
"{"  { return LLAVABR_; }
"]"  { return CORCER_; }
"["  { return CORABR_; }
")"  { return PARCER_; }
"("  { return PARABR_; }
";"  { return PUNTOYCOMA_; }
"+"  { return PLUS; }
"*"  { return MULT; }
"-"  { return MENOS; }
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
"-=" { return MENOS_ASIGN; }
"."  { return POINT_; }
","  { return COMMA; }

{DIGIT}+ { return CTE_; }
{LETRA}({LETRA}|{DIGIT})* { return ID_; }
"//"[^\n]* 


. { printf("ERROR"); exit(1); }

%%

int main(int argc, char **argv) {
  if ((yyin = fopen(argv[1], "r")) == NULL)
    fprintf(stderr, "Fichero no valido \%s", argv[1]);
  yyparse();  
return 0;
}


