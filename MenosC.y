%{

#include "include/common.h"
#include "include/DebugMsg.h"
#include "include/libgci.h"
#include <stdio.h>
#include <stdlib.h>
#include <libtds.h>
#include <string.h>
#include <iostream>
#include <vector>

int verbose = FALSE;
int showTDS = FALSE;
int numErrores = 0;
int level = 0;
int globalDesp = 0; // Desplacement of global variables
const int INTEGER_SIZE = 1;

extern int si;
extern int dvar;

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
        int desp;
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
    struct {
        TIPO_ARG pos;
        int tipo; //TODO : Use type
    } expression;
    struct {
        int siStackIncrement;
        int oldDvar;
    } block;
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
%type <localVariableDeclaration> localVariableDeclaration;
%type <expression> expression;
%type <expression> equalityExpression;
%type <expression> relationalExpression;
%type <expression> additiveExpression;
%type <expression> multiplicativeExpression;
%type <expression> unaryExpression;
%type <expression> suffixExpression;
	%%
	program :           
                        {
                            level = 0; 
                            cargaContexto(level); 
                            DebugEnterLevel(); 
                            // Call main:
                            emite(CALL, crArgNulo(), crArgNulo(), crArgEtiqueta(0));
                            emite(FIN, crArgNulo(), crArgNulo(), crArgNulo());
                        }  
                declarationList 
                        {
                            DebugStream("Show TDS after end of the program. Level: " << level);
                            mostrarTDS(level); 

                            DebugStream("Let us see the TDS after the program:" );                            
                            mostrarTDS(level);
                            SIMB main = obtenerSimbolo("main");
                            if(main.categoria != FUNCION) {
                               yyerror("Function main does not exist!\n"); 
                            }
                            int siOld = si;
                            si = 0;
                            emite(CALL, crArgNulo(), crArgNulo(), crArgEtiqueta(main.desp));
                            si = siOld;
                            descargaContexto(level); 
                            DebugEndLevel(); 
                        } ;
	declarationList : declaration | declarationList declaration;
	declaration : variableDeclaration 
                        {
                            declareVariable(level, $1.name, $1.type, globalDesp,  $1.size, $1.ref); 
                            globalDesp += $1.size;
                        }
                | functionDeclaration 
                        {
                            // TODO: Do we need DESP here? Functions don't need 'place' in this sense. 
                            // But where do we save the address of the function? Or is this only important later in the assembler phase?
                            insertaSimbolo($1.name, FUNCION, $1.returnType, $1.desp, level, $1.parameterRef);  
                            DebugStream("Show TDS after declaration of '" << $1.name << "' in level " << level);
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
						    DebugStream("Variable Declaration: " << $2 );
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
                            $$.desp = $1.desp;
                            $$.returnType = $1.returnType; 
                            $$.returnTypeRef = $1.returnTypeRef;
                            $$.name = $1.name; 
                            $$.parameterRef = $1.parameterRef; 
                            DebugStream("Show TDS before returning from the declaration of "<< $1.name << " in level " << level);
                            mostrarTDS(level); 

                            emite(RET, crArgNulo(), crArgNulo(), crArgNulo());

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
                            $$.desp = si;
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
                           *       how can we retrieve the parameters to check them if they fit to the call (statical type checking)
                           *       I think for this we have to use the function insertaInfoDominio but there is no way to check if for example
                           *       the structs fit, as only the data that it is a struct is saved.
                           *       Btw. how do you translate dominio to english? I would think about domain, but I don't see the connection to function calls?
                           * ANSWER: Yes, we have to use this (insertaInfoDominio)
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
	block : CURLY_OPEN_ localVariableDeclaration 
                        { 
                            // We add a dummy increment here, which we later overwrite
                            $<block>$.oldDvar = dvar;
                            $<block>$.siStackIncrement = si;
                            DebugStream("Save si = " << si << " for level " << level);
                            DebugStream("Save dvar = " << dvar << " for level " << level);
                            emite(INCTOP, crArgNulo(), crArgNulo(), crArgEntero(0)); 
                            dvar = $2.desp + 1;

                        }
                        instructionList 
                        { 
                            // Overwrite the increment at the begin of the block
                            int oldsi = si;
                            si = $<block>3.siStackIncrement;
                            DebugStream("Load si = " << $<block>3.siStackIncrement << " for level " << level);
                            DebugStream("Load dvar = " << $<block>3.oldDvar << " for level " << level);
                            emite(INCTOP, crArgNulo(), crArgNulo(), crArgEntero(dvar));
                            si = oldsi;

                            // Remove the place for local variables
                            emite(DECTOP, crArgNulo(), crArgNulo(), crArgEntero(dvar));
                            dvar = $<block>3.oldDvar;
                            
                            // TODO:
                            // We have to get the return address from the stack and jump to this place
                        }
                        CURLY_CLOSE_ ;  ; 
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
                            // TODO: We have to save place on the stack too!
                            mostrarTDS(level); 
                            descargaContexto(level); 
                            DebugEndLevel(); level--; 
                        } 
            | expressionInstruction | ioInstruction | selectionInstruction | iterationInstruction | returnInstruction;
	expressionInstruction : SEMICOLON_ | expression SEMICOLON_;
	ioInstruction : READ_ PAR_OPEN_ ID_ PAR_CLOSE_ SEMICOLON_ 
            | PRINT_ PAR_OPEN_ expression PAR_CLOSE_ SEMICOLON_ 
                        {
                            emite(EWRITE, crArgNulo(), crArgNulo(), $3.pos);
                        };
	selectionInstruction : IF PAR_OPEN_ expression PAR_CLOSE_  instruction ELSE instruction ;
	iterationInstruction : FOR PAR_OPEN_ optionalExpression SEMICOLON_ expression SEMICOLON_ optionalExpression PAR_CLOSE_  instruction;
	optionalExpression : /* eps */ | expression;
	returnInstruction : RETURN expression SEMICOLON_ ;
	expression : equalityExpression 
                        {
                            $$.pos = $1.pos;
                        }
            | ID_ asignationOperator expression 
                        {
                            SIMB id = obtenerSimbolo($1);
                            if(id.categoria == NULO) {
                                printf("The variable %s is not declared.", $1);
                                yyerror("Variable declaration failed");
                            }
                            else {
                                emite(EASIG, $3.pos, crArgNulo(), crArgPosicion(level, id.desp)); 
                                $$.pos = crArgPosicion(level, id.desp);
                            }
                        }
            | ID_ SQUARE_OPEN_ expression SQUARE_CLOSE_ asignationOperator expression 
                        {
                            $$.pos = crArgPosicion(level,0); // TODO: implement
                        }

            | ID_ POINT_ ID_ asignationOperator expression 
                        {
                            $$.pos = crArgPosicion(level,0); // TODO: implement
                        };
	equalityExpression : relationalExpression 
                        {
                            $$.pos = $1.pos;
                        }
                | equalityExpression equalityOperator relationalExpression ;
	relationalExpression : additiveExpression 
                        {
                            $$.pos = $1.pos;
                        }
                | relationalExpression relationalOperator additiveExpression ;
	additiveExpression : multiplicativeExpression 
                        {
                            $$.pos = $1.pos;
                        }
                | additiveExpression additiveOperator multiplicativeExpression;
	multiplicativeExpression : unaryExpression 
                        {
                            $$.pos = $1.pos;
                        }

                | multiplicativeExpression multiplicativeOperator unaryExpression;
	unaryExpression : suffixExpression 
                        {
                            $$.pos = $1.pos;
                        }
                | unaryOperator unaryExpression 
                        {
                            $$.pos = crArgPosicion(level,0); // TODO: implement
                        }
                | incrementOperator ID_
                        {
                            $$.pos = crArgPosicion(level,0); // TODO: implement
                        };
	suffixExpression :
                /* Array access */
                 ID_ SQUARE_OPEN_ expression SQUARE_CLOSE_ 
                        {
                            $$.pos = crArgPosicion(level,0); // TODO: implement
                        }
                /* Record access */
                | ID_ POINT_ ID_ 
                        {
                            $$.pos = crArgPosicion(level,0); // TODO: implement
                        }
                /* Increment/Decrement */
                | ID_ incrementOperator 
                        {
                            $$.pos = crArgPosicion(level,0); // TODO: implement
                        }
                /* Function call */
                | ID_ PAR_OPEN_ actualParameters PAR_CLOSE_ 
                        {
                            $$.pos = crArgPosicion(level, 0); // TODO: implement
                        }
                | PAR_OPEN_ expression PAR_CLOSE_ 
                        {
                            $$.pos = $2.pos;
                        }
                | ID_ 
                        {
                            $$.pos = crArgPosicion(level, 0); // TODO: Implement
                        }
                | CTI_ {
                    
                    $$.pos = crArgPosicion(level, creaVarTemp()) ;
                    emite(EASIG, crArgEntero($1), crArgNulo(), $$.pos);
                };
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
