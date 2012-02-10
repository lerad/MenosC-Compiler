%{
#include <stdio.h>
extern int yylineno;

%}

%error-verbose

%token ID_ CTI_
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
%%
program : declarationList;
declarationList : declaration | declarationList declaration;
declaration : variableDeclaration | functionDeclaration;
variableDeclaration : type ID_ SEMICOLON_ | type  ID_ SQUARE_OPEN_ CTI_ SQUARE_CLOSE_  SEMICOLON_; 
type : INT_ | STRUCT CURLY_OPEN_ fieldList CURLY_CLOSE_;
fieldList : variableDeclaration | fieldList variableDeclaration;
functionDeclaration : functionHead block;
functionHead : type ID_ PAR_OPEN_ formalParameters PAR_CLOSE_;
formalParameters : /* eps */ | formalParameterList ;
formalParameterList : type ID_ | type ID_ COMMA formalParameterList ;
block : CURLY_OPEN_ localVariableDeclaration instructionList CURLY_CLOSE_ ; 
localVariableDeclaration : /* eps */ | localVariableDeclaration variableDeclaration;
instructionList : /* eps */  | instructionList instruction ;
instruction : CURLY_OPEN_ localVariableDeclaration instructionList CURLY_CLOSE_ |
                expressionInstruction | ioInstruction | selectionInstruction | iterationInstruction | returnInstruction;
expressionInstruction : SEMICOLON_ | expression SEMICOLON_;
ioInstruction : READ_ PAR_OPEN_ ID_ PAR_CLOSE_ SEMICOLON_ | PRINT_ PAR_OPEN_ expression PAR_CLOSE_ SEMICOLON_;
selectionInstruction : IF PAR_OPEN_ expression PAR_CLOSE_ PAR_CLOSE_ instruction ELSE instruction ;
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
