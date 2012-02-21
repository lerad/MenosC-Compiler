%{
#include <stdio.h>
#include <libtds.h>
extern int yylineno;

int level = 0;


%}

%union {
    char *id;
    int integer;
    float real;
    struct {
        int tipo; // STRUCT or INTEGER
        int ref; // n.ref if it is a struct
        int size; 
    } tipo;
}

%error-verbose

%token <id> ID_ 
%token <integer> CTI_
%token INT_ 
%token PRINT_ READ_
%token ASIG_ MAS_ POR_
%token SEMICOLON_
%token PAR_OPEN_ PAR_CLOSE_
%token SQUARE_OPEN_ SQUARE_CLOSE_
%token CURLY_OPEN_ CURLY_CLOSE_
%token ASIGN ADD_ASIGN MINUS_ASIGN
%token EQUAL NOT_EQUAL GREATER LESS GREATER_EQUAL LESS_EQUAL
%token PLUS MINUS
%token MULT DIV
%token FOR
%token INC DEC
%token IF ELSE
%token RETURN STRUCT
%token POINT_
%token COMMA

%type <tipo> type;

%%
program : {level = 0; cargaContexto(level); printf("Debug: Enter level %i\n", level); }  declarationList {descargaContexto(level); printf("Debug: End of level %i\n", level);} ;
declarationList : declaration | declarationList declaration;
declaration : variableDeclaration | functionDeclaration;
variableDeclaration : type ID_ SEMICOLON_ { printf("Variable Declaration: %s \n",  $2); } | type  ID_ SQUARE_OPEN_ CTI_ SQUARE_CLOSE_  SEMICOLON_ {printf("Debug: Variable Declaration\n");}; 
type : INT_ {$$.tipo = T_ENTERO; $$.ref = -1; $$.size = 4; /* TODO: define size as constant */}   | STRUCT CURLY_OPEN_ fieldList CURLY_CLOSE_ {$$.tipo = T_RECORD; $$.ref = -1; /* TODO: Use result of fieldList */ $$.size = -1; /* TODO: Use result of fieldlist */} ; // type integer; struct n.ref talla
fieldList : variableDeclaration  | fieldList variableDeclaration;
functionDeclaration : functionHead block {descargaContexto(level); printf("Debug: End of level %i\n", level);  level--;} ;
functionHead : type ID_ { level++; cargaContexto(level); printf("Debug: Enter level %i\n", level); } PAR_OPEN_  formalParameters PAR_CLOSE_ ; 
formalParameters : /* eps */ | formalParameterList ;
formalParameterList : type ID_ | type ID_ COMMA formalParameterList ;
block : CURLY_OPEN_ localVariableDeclaration instructionList CURLY_CLOSE_ ; 
localVariableDeclaration : /* eps */ | localVariableDeclaration variableDeclaration;
instructionList : /* eps */  | instructionList instruction ;
instruction : {level++; cargaContexto(level); printf("Debug: Enter level %i\n", level); } CURLY_OPEN_ localVariableDeclaration instructionList CURLY_CLOSE_ {descargaContexto(level); printf("Debug: End of level %i\n", level); level--; } |
                expressionInstruction | ioInstruction | selectionInstruction | iterationInstruction | returnInstruction;
expressionInstruction : SEMICOLON_ | expression SEMICOLON_;
ioInstruction : READ_ PAR_OPEN_ ID_ PAR_CLOSE_ SEMICOLON_ | PRINT_ PAR_OPEN_ expression PAR_CLOSE_ SEMICOLON_;
selectionInstruction : IF PAR_OPEN_ expression PAR_CLOSE_  instruction ELSE instruction ;
iterationInstruction : FOR PAR_OPEN_ optionalExpression SEMICOLON_ expression SEMICOLON_ optionalExpression PAR_CLOSE_  instruction;
optionalExpression : /* eps */ | expression;
returnInstruction : RETURN expression SEMICOLON_ ;
expression : equalityExpression | ID_ asignationOperator expression | ID_ SQUARE_OPEN_ expression SQUARE_CLOSE_ asignationOperator expression | 
             ID_ POINT_ ID_ asignationOperator expression;
equalityExpression : relationalExpression | equalityExpression equalityOperator relationalExpression ;
relationalExpression : additiveExpression | relationalExpression relationalOperator additiveExpression ;
additiveExpression : multiplicativeExpression | additiveExpression additiveOperator multiplicativeExpression;
multiplicativeExpression : unaryExpression | multiplicativeExpression multiplicativeOperator unaryExpression;
unaryExpression : suffixExpression | unaryOperator unaryExpression | incrementOperator ID_;
suffixExpression : ID_ SQUARE_OPEN_ expression SQUARE_CLOSE_ | ID_ POINT_ ID_ | ID_ incrementOperator | 
    ID_ PAR_OPEN_ actualParameters PAR_CLOSE_ | PAR_OPEN_ expression PAR_CLOSE_ | ID_ | CTI_;
actualParameters : /* eps */ | actualParameterList
actualParameterList : expression | expression COMMA actualParameterList 
asignationOperator : ASIGN | ADD_ASIGN | MINUS_ASIGN ;
equalityOperator : EQUAL | NOT_EQUAL;
relationalOperator : GREATER | LESS | GREATER_EQUAL | LESS_EQUAL ;
additiveOperator : PLUS | MINUS;
multiplicativeOperator : MULT | DIV;
incrementOperator : INC | DEC;
unaryOperator : PLUS | MINUS;





%%

yyerror(char *s) 
{
  printf("Line %d: %s\n", yylineno, s);
}
