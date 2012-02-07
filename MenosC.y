%{
#include <stdio.h>
extern int yylineno;
//TEST TOMASKO COMMIT
%}

%error-verbose

%token ID_ CTE_
%token INT_ 
%token PRINT_ READ_
%token ASIG_ MAS_ POR_
%token PUNTOYCOMA_
%token PARABR_ PARCER_
%token CORABR_ CORCER_
%token LLAVABR_ LLAVCER_
%token ASIGN ADD_ASIGN MENOS_ASIGN
%token EQUAL NOT_EQUAL GREATER LESS GREATER_EQUAL LESS_EQUAL
%token PLUS MENOS
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
variableDeclaration : type ID_ PUNTOYCOMA_ | type  ID_ CORABR_ CTE_ CORCER_  PUNTOYCOMA_; 
type : INT_ | STRUCT LLAVABR_ fieldList LLAVCER_;
fieldList : variableDeclaration | fieldList variableDeclaration;
functionDeclaration : functionHead block;
functionHead : type ID_ PARABR_ formalParameters PARCER_;
formalParameters : /* eps */ | formalParameterList ;
formalParameterList : type ID_ | type ID_ COMMA formalParameterList ;
block : LLAVABR_ localVariableDeclaration instructionList LLAVCER_ ; 
localVariableDeclaration : /* eps */ | localVariableDeclaration variableDeclaration;
instructionList : /* eps */  | instructionList instruction ;
instruction : LLAVABR_ localVariableDeclaration instructionList LLAVCER_ |
                expressionInstruction | ioInstruction | selectionInstruction | iterationInstruction | returnInstruction;
expressionInstruction : PUNTOYCOMA_ | expression PUNTOYCOMA_;
ioInstruction : READ_ PARABR_ ID_ PARCER_ PUNTOYCOMA_ | PRINT_ PARABR_ expression PARCER_ PUNTOYCOMA_;
selectionInstruction : IF PARABR_ expression PARCER_ PARCER_ instruction ELSE instruction ;
iterationInstruction : FOR PARABR_ optionalExpression PUNTOYCOMA_ expression PUNTOYCOMA_ optionalExpression PARCER_  instruction;
optionalExpression : /* eps */ | expression;
returnInstruction : RETURN expression PUNTOYCOMA_ ;
expression : equalityExpression | ID_ asignationOperator expression | ID_ CORABR_ expression CORCER_ asignationOperator expression | 
             ID_ POINT_ ID_ asignationOperator expression;
equalityExpression : relationalExpression | equalityExpression equalityOperator relationalExpression ;
relationalExpression : additiveExpression | relationalExpression relationalOperator additiveExpression ;
additiveExpression : multiplicativeExpression | additiveExpression additiveOperator multiplicativeExpression;
multiplicativeExpression : unaryExpression | multiplicativeExpression multiplicativeOperator unaryExpression;
unaryExpression : suffixExpression | unaryOperator unaryExpression | incrementOperator ID_;
suffixExpression : ID_ CORABR_ expression CORCER_ | ID_ POINT_ ID_ | ID_ incrementOperator | 
    ID_ PARABR_ actualParameters PARCER_ | PARABR_ expression PARCER_ | ID_ | CTE_;
actualParameters : /* eps */ | actualParameterList
actualParameterList : expression | expression COMMA actualParameterList 
asignationOperator : ASIGN | ADD_ASIGN | MENOS_ASIGN ;
equalityOperator : EQUAL | NOT_EQUAL;
relationalOperator : GREATER | LESS | GREATER_EQUAL | LESS_EQUAL ;
additiveOperator : PLUS | MENOS;
multiplicativeOperator : MULT | DIV;
incrementOperator : INC | DEC;
unaryOperator : PLUS | MENOS;





%%

yyerror(char *s) 
{
  printf("Linea %d: %s\n", yylineno, s);
}
