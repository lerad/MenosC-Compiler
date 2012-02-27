%{ 
#include <stdio.h>
#include "MenosC.tab.h"
#include <string.h>
#include <stdlib.h>
%}

DIGIT      [0-9]
WHITESPACE [ \t\n]
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

{DIGIT}+ { yylval.integer = atoi(yytext); return CTI_; }
{LETTER}({LETTER}|{DIGIT})* { char *buffer = malloc(30); strcpy(buffer, yytext); yylval.id = buffer; return ID_; }
"//"[^\n]* 


. { printf("ERROR"); exit(1); }

%%

int main(int argc, char **argv) {
  if ((yyin = fopen(argv[1], "r")) == NULL)
    fprintf(stderr, "Invalid file \%s", argv[1]);
  yyparse();  
return 0;
}


