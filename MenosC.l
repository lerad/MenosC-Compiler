%{ 
#include "MenosC.tab.h"
#include "include/common.h"
#include <string.h>
#include <stdlib.h>

int createCnumber();
int truncCreal();

char* createId();

const int MAX_LENGTH = 14; // maximum length of id in characters
%}

/* %option c++ */

DIGIT      [0-9]
REAL 	   {DIGIT}+.{DIGIT}+
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


{REAL}  {yylval.integer = truncCreal(); return CTI_;}
{DIGIT}+ { yylval.integer =createCnumber(); return CTI_; }
{LETTER}({LETTER}|{DIGIT})* {  yylval.id = createId(); return ID_; }
"//"[^\n]* 


. { printf("ERROR"); exit(1); }

%%


/*returns new allocated char* copied from yytext */
char *createId()
{

	if(yyleng >MAX_LENGTH)
		yyleng = MAX_LENGTH;
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
  if ((yyin = fopen(argv[1], "r")) == NULL)
    fprintf(stderr, "Invalid file \%s", argv[1]);
 return  yyparse();  
//return 0;
}


