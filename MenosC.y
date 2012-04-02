%{

#include "include/common.h"
#include "include/DebugMsg.h"
#include <stdio.h>
#include <libtds.h>
#include <string.h>
#include<iostream>


int level = 0;
const int INTEGER_SIZE = 4;


%}
%union {
    char *id;
    int integer;
    struct {
        int type; // STRUCT or INTEGER
        int ref; // n.ref if it is a struct
        int size; 
    } type;
    struct {
        int type;
        char *name;
        int size; // In case of arrays this is not equal to type.size
        int ref;
    } variableDeclaration;
    struct {
        int returnType; // STRUCT or INTEGER
        int returnTypeRef;
        int parameterRef; 
        char *name;
    } functionDeclaration, functionHead;
    struct {
        int desp;
        int parameterRef; // "Dominio"
    } formalParameters, formalParameterList;
    struct {
        int fieldsRef;
        int desp;
    } fieldList;
    struct {
        int desp;
    } declarationList;
    struct {
        int desp;
    } localVariableDeclaration;
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

%type <type> type;
%type <variableDeclaration> variableDeclaration;
%type <functionDeclaration> functionDeclaration;
%type <functionHead> functionHead;
%type <formalParameters> formalParameters;
%type <formalParameterList> formalParameterList;
%type <fieldList> fieldList;
// %type <declarationList> declarationList;
%type <localVariableDeclaration> localVariableDeclaration;


	%%
	program :           
                        {
                            level = 0; 
                            cargaContexto(level); 
                            DebugEnterLevel(); 
                        }  
                declarationList 
                        {
                            printf("Show TDS after end of the program. Level: %i", level);
                            mostrarTDS(level); 
                            descargaContexto(level); 
                            DebugEndLevel(); 
                        } ;
	declarationList : declaration | declarationList declaration;
	declaration : variableDeclaration 
                        {
                            declareVariable(level, $1.name, $1.type, 0,  $1.size, $1.ref); /* TODO: desp */ 
                        }
                | functionDeclaration 
                        {
                            // TODO: Do we need DESP here? Functions don't need 'place' in this sense. But we must somewhere save the address of the function?  
                            insertaSimbolo($1.name, FUNCION, $1.returnType, 0, level, $1.parameterRef);  
                            printf("Show TDS after declaration of '%s' in level %i", $1.name, level);
                            mostrarTDS(level);
                        };
	variableDeclaration : type ID_ SEMICOLON_ 
				        {
                            $$.type = $1.type; 
                            $$.name = $2; 
                            $$.size = $1.size; 
                            $$.ref = $1.ref;
                        } 
			    |  type  ID_  SQUARE_OPEN_ CTI_ SQUARE_CLOSE_  SEMICOLON_  
				        { 
                            $$.type = T_ARRAY; 
				            $$.name = $2; 
				            $$.size = $1.size * $4; 
				            $$.ref = insertaInfoArray($1.type, $4); 
				            printf("Debug: Variable Declaration: %s\n", $2);
                        } ; 
	type : INT_ 
                        {
                            $$.type = T_ENTERO; 
                            $$.ref = -1; 
                            $$.size = INTEGER_SIZE; 
                        } 
          | STRUCT CURLY_OPEN_ fieldList CURLY_CLOSE_ 
                        {
                            $$.type = T_RECORD; 
                            $$.ref = $3.fieldsRef; 
                            $$.size = $3.desp; 
                        } ; 
	fieldList : variableDeclaration  
                        {  
                            // When this is a struct: Is there any problem, that the ref to the struct's fields is missing?
                            $$.fieldsRef = insertaInfoCampo(-1, $1.name, $1.type, 0); 
                            $$.desp = $1.size;
                        };
            | fieldList variableDeclaration
                        {
                            int result = insertaInfoCampo($1.fieldsRef, $2.name, $2.type, $1.desp);
                            if(result == -1) { yyerror("Multiple uses of the same identifier"); }
                            $$.desp = $1.desp + $2.size;
                            $$.fieldsRef = result; /* Is this identical to $1.fieldsRef?*/
                        };
	functionDeclaration : functionHead block  
                        {
                            $$.returnType = $1.returnType; 
                            $$.returnTypeRef = $1.returnTypeRef;
                            $$.name = $1.name; 
                            $$.parameterRef = $1.parameterRef; 
                            printf("Show TDS before returning from the declaration of %s in level %i\n", $1.name, level);
                            mostrarTDS(level); 
                            descargaContexto(level); 
                            DebugEndLevel();  
                            level--;
                        } ;
	functionHead : type ID_ 
                        {   
                            level++; 
                            cargaContexto(level); 
                            DebugEnterLevel(); 
                        } 
                    PAR_OPEN_  formalParameters PAR_CLOSE_  
                        {
                            $$.returnType = $1.type;
                            $$.returnTypeRef = $1.ref;
                            $$.parameterRef = $5.parameterRef; /* $5, because the action counts too! */
                            $$.name = $2;
                        };
	formalParameters : /* eps */ 
                        { 
                            $$.desp = 0; 
                            $$.parameterRef = insertaInfoDominio(-1, T_VACIO);
                        }
                    | formalParameterList 
                        {   
                            $$.desp = $1.desp; 
                            $$.parameterRef = $1.parameterRef;
                        };
	formalParameterList : type ID_ 
                        { 
                          /*
                           * TODO: Actually we are here saving the parameter as parameter into the symbol table
                           *       but: This is lost when we leave the scope of the function. So if we later call the function
                           *       how can we retrieve the parameters to check them if the fit the call
                           *       I think for this we have to use the function insertaInfoDominio but there is no way to check if for example
                           *       structs fit. 
                           *       Btw. how do you translate dominio to english? I would think about domain, but I don't see the connection to function calls?
                           */
                          insertaSimbolo($2, PARAMETRO , $1.type, 0, level, $1.ref); 
                          $$.parameterRef = insertaInfoDominio(-1, $1.type);
                          $$.desp = $1.size;  
                        }
                    | type ID_ COMMA formalParameterList 
                        {
                          insertaSimbolo($2, PARAMETRO, $1.type, $4.desp, level, $1.ref);
                          $$.parameterRef = insertaInfoDominio($4.parameterRef, $1.type);
                          $$.desp = $4.desp + $1.size;
                        };
	block : CURLY_OPEN_ localVariableDeclaration instructionList CURLY_CLOSE_ ; 
	localVariableDeclaration : /* eps */ 
                        {
                            $$.desp = 0;
                        }
            | localVariableDeclaration variableDeclaration
                        {
                            declareVariable(level, $2.name, $2.type, $1.desp,  $2.size, $2.ref); 
                            $$.desp = $1.desp + $2.size;
                        };
	instructionList : /* eps */  | instructionList instruction ;
	instruction : 
                        {
                            level++; 
                            cargaContexto(level); 
                            DebugEnterLevel(); 
                        } 
            CURLY_OPEN_ localVariableDeclaration instructionList CURLY_CLOSE_ 
                        {
                            mostrarTDS(level); 
                            descargaContexto(level); 
                            DebugEndLevel(); level--; 
                        } 
            | expressionInstruction | ioInstruction | selectionInstruction | iterationInstruction | returnInstruction;
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

void yyerror(char *s) 
{
  //printf("Line %d: %s\n", yylineno, s);
  std::cerr << "Line " << yylineno << ": " << s << std::endl;
}
