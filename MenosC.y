%{

#include "include/common.h"
#include "include/DebugMsg.h"
#include "include/libgci.h"
#include <stdio.h>
#include <stdlib.h>
#include <libtds.h>
#include <string.h>
#include <iostream>
#include <list>
#include <vector>

int verbose = FALSE;
int showTDS = FALSE;
int numErrores = 0;
int level = 0;
int globalDesp = 0; // Desplacement of global variables

int globalVariableReservationRef = 0; // Refers to the instructions which reserves the space for global variables
int mainCallRef = 0; // Refers to the instruction which calls the main function

const int INTEGER_SIZE = 1;

extern int si; // Position of the next instruction
extern int dvar; // Position of the next temporary variable


// Contains the update-refs for the memory reservation (INCTOP)  at each level
std::vector<std::list<int> > localPlaceUpdateList;


/*
 * Returns the posicion which belongs to the given ID
 * Calls yyerror if it not defined. (Returns (0,0) than so parsing continues)
 * If is a parameter, it adjust the position, so that it now fits into the parameter position of the memory
 */
TIPO_ARG getSymbolPosition(char *name) {
    SIMB id = obtenerSimbolo(name);
    if(id.categoria == NULO) {
        char buffer[200];
        sprintf(buffer, "The variable %s is not declared.", name);
        yyerror(buffer);
        return crArgPosicion(0,0);
    }

    if(id.categoria == PARAMETRO) {
        INF fn = obtenerInfoFuncion(-1);
        id.desp -= 2; // Return address and saved frame pointer
        id.desp -= fn.tparam; // Starting space for the parameters

    }
    return crArgPosicion(id.nivel, id.desp);
}

// Makes the same as getSymbolPosition, but returns the SIMB struct
SIMB getSymbol(char *name) {
    SIMB id = obtenerSimbolo(name);
    if(id.categoria == NULO) {
        printf("The variable %s is not declared.", name);
        yyerror("The variable is not declared.");
    }

    if(id.categoria == PARAMETRO) {
        INF fn = obtenerInfoFuncion(-1);
        id.desp -= 2; // Return address and saved frame pointer
        id.desp -= fn.tparam; // Starting space for the parameters
    }
    return id;
}
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
    } functionHead;
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
        int type; 
        int size;
    } expression;
    struct {
        int oldDvar;
    } block; // TODO: Rename as currently this is not used for the block-element. (Although it has a close connection)
    struct {
        int label;
        int ref;
    } forHelper;
    struct {
        int ref;
    } actualParameters, actualParameterList;
    int incrementOperator;
    int multiplicativeOperator;
    int additiveOperator;
    int asignationOperator;
    int hasRef;
    int relationalOperator;
    int equalityOperator;
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
%type <expression> optionalExpression;
%type <incrementOperator> incrementOperator;
%type <multiplicativeOperator> multiplicativeOperator;
%type <additiveOperator> additiveOperator;
%type <asignationOperator> asignationOperator;
%type <relationalOperator> relationalOperator;
%type <equalityOperator> equalityOperator;
%type <actualParameters> actualParameters;
%type <actualParameterList> actualParameterList;

	%%
	program :           
                        {
                            level = 0; 
                            cargaContexto(level); 
                            DebugEnterLevel(); 
                            // Reserve space for global variables
                            globalVariableReservationRef = creaLans(si);
                            emite(INCTOP, crArgNulo(), crArgNulo(), crArgEntero(0));
                            // Call main:
                            mainCallRef = creaLans(si);
                            emite(CALL, crArgNulo(), crArgNulo(), crArgEtiqueta(0));
                            emite(FIN, crArgNulo(), crArgNulo(), crArgNulo());
                        }  
                declarationList 
                        {
                            DebugStream("Show TDS after end of the program. Level: " << level);
                            #ifdef DEBUG
                            mostrarTDS(level); 
                            #endif 

                            DebugStream("Let us see the TDS after the program:" );                            
                            #ifdef DEBUG
                            mostrarTDS(level);
                            #endif
                            SIMB main = obtenerSimbolo("main");
                            if(main.categoria != FUNCION) {
                               yyerror("Function main does not exist!\n"); 
                            }
                            completaLans(mainCallRef, crArgEtiqueta(main.desp));
                            completaLans(globalVariableReservationRef, crArgEntero(globalDesp));
                            descargaContexto(level); 
                            DebugEndLevel(); 
                        } ;
	declarationList : declaration | declarationList declaration;
	declaration : variableDeclaration 
                        {
                            declareVariable(level, $1.name, $1.type, globalDesp,  $1.size, $1.ref); 
                            globalDesp += $1.size;
                        }
                | functionDeclaration ;
	variableDeclaration : type ID_ SEMICOLON_ 
				        {
                            $$.type = $1.type; 
                            $$.name = $2; 
                            $$.size = $1.size; 
                            $$.ref = $1.ref;
                        } 
			    |  type  ID_  SQUARE_OPEN_ CTI_ SQUARE_CLOSE_  SEMICOLON_  
				        { 
                            if($4 == 0) {
                                char buffer[200];
                                sprintf(buffer, "Array %s is declared with a length of 0", $2);
                                yyerror(buffer);
                            }
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
	functionDeclaration : functionHead 
                        {
                            // We have to insert the function already here into the table of symbols.
                            // Otherwise we couldn't use it inside the block and recursion wouldn't work.
                            declareSymbol($1.name, FUNCION, $1.returnType, $1.desp, level, $1.parameterRef);  
                            
                        }        
                    block  
                        {
                            DebugStream("Show TDS before returning from the declaration of "<< $1.name << " in level " << level);
                            #ifdef DEBUG
                            mostrarTDS(level); 
                            #endif

                            localPlaceUpdateList.pop_back();
                            descargaContexto(level); 
                            DebugEndLevel();  
                            level--;

                            emite(RET, crArgNulo(), crArgNulo(), crArgNulo());
                        } ;
	functionHead : type ID_ 
                        {   
                            level++; 
                            cargaContexto(level); 
                            localPlaceUpdateList.push_back( std::list<int>() );
                            DebugEnterLevel(); 
                        } 
                    PAR_OPEN_  formalParameters PAR_CLOSE_  
                        {
                            if($1.type != T_ENTERO) {
                                char buffer[200];
                                sprintf(buffer, "Return type of %s is not an integer", $2);
                                yyerror(buffer);
                            }
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
                          /* First reduction that happens. It is the reduction of the last parameter which is at the 
                           * deepest position of the stack. 
                           * It gets the desplacement of 0. 
                           * (-2 -parameterSize) would be nicer, but we don't know the parameterSize yet.
                           * So later, when we access an ID we check if it is a parameter and if this is the case we deduct -2 - parameterSize from it.
                           */
                          if($1.type != T_ENTERO) {
                                char buffer[200];
                                sprintf(buffer, "Parameter %s is not an integer", $2);
                                yyerror(buffer);
                          }

                          declareSymbol($2, PARAMETRO , $1.type, 0, level, $1.ref); 
                          $$.desp =  $1.size;
                          $$.parameterRef = insertaInfoDominio(-1, $1.type);
                        }
                    | type ID_ COMMA formalParameterList 
                        {
                          if($1.type != T_ENTERO) {
                                char buffer[200];
                                sprintf(buffer, "Parameter %s is not an integer", $2);
                                yyerror(buffer);
                          }
                          declareSymbol($2, PARAMETRO, $1.type, $4.desp, level, $1.ref);
                          $$.desp = $4.desp + $1.size;
                          $$.parameterRef = insertaInfoDominio($4.parameterRef, $1.type);
                        };
	block : CURLY_OPEN_ 
                        {
                            $<block>$.oldDvar = dvar;
                            dvar = 0;
                        }
                        localVariableDeclaration 
                        { 
                            emite(PUSHFP, crArgNulo(), crArgNulo(), crArgNulo());
                            emite(FPTOP, crArgNulo(), crArgNulo(), crArgNulo());
                            
                            DebugStream("Save dvar = " << dvar << " for level " << level);
                            int ref = creaLans(si);
                            localPlaceUpdateList.back().push_back(ref);
                            emite(INCTOP, crArgNulo(), crArgNulo(), crArgEntero(0)); 

                        }
                        instructionList 
                        { 
                            int spaceReservedThisLevel = dvar;

                            // Remove the place for local variables
                            emite(DECTOP, crArgNulo(), crArgNulo(), crArgEntero(spaceReservedThisLevel));
                            emite(FPPOP, crArgNulo(), crArgNulo(), crArgNulo());
                            dvar = $<block>2.oldDvar;

                            /* Update all localPlaceUpdateList entries of this level */
                            const std::list<int> &currList = localPlaceUpdateList.back();
                            std::list<int>::const_iterator it;
                            
                            for(it = currList.begin(); it != currList.end(); it++) {
                                 completaLans(*it, crArgEntero(spaceReservedThisLevel));
                            }

                        }
                        CURLY_CLOSE_ ;  ; 
	localVariableDeclaration : /* eps */ 
                        {
                            /*
                             * We have to start at dvar and not at 0. This is because if we have the localVariableDeclaration inside 
                             * of an instruction we have to continue at the previous value of dvar.
                             */
                            $$.desp = dvar;
                        }
            | localVariableDeclaration variableDeclaration
                        {
                            declareVariable(level, $2.name, $2.type, $1.desp,  $2.size, $2.ref); 
                            $$.desp = $1.desp + $2.size;
                            dvar  += $2.size;
                        };
	instructionList : /* eps */  | instructionList instruction ;
	instruction : 
                    CURLY_OPEN_
                        {
                            $<block>$.oldDvar = dvar;
                            level++; 
                            cargaContexto(level); 
                            localPlaceUpdateList.push_back( std::list<int>() );
                            DebugEnterLevel(); 
                            int ref = creaLans(si);
                            emite(INCTOP, crArgNulo(), crArgNulo(), crArgEntero(0));
                            localPlaceUpdateList.back().push_back(ref);
                        } 
                    localVariableDeclaration instructionList CURLY_CLOSE_ 
                        {
                            int spaceReservedThisLevel = dvar - $<block>2.oldDvar;
                            dvar = $<block>2.oldDvar;
                            emite(DECTOP, crArgNulo(), crArgNulo(), crArgEntero(spaceReservedThisLevel));

                            /* Update all localPlaceUpdateList entries of this level */
                            const std::list<int> &currList = localPlaceUpdateList.back();
                            std::list<int>::const_iterator it;
                            
                            for(it = currList.begin(); it != currList.end(); it++) {
                                 completaLans(*it, crArgEntero(spaceReservedThisLevel));
                            }

                            descargaContexto(level); 
                            DebugEndLevel(); level--; 
                            localPlaceUpdateList.pop_back();
                        } 
            | expressionInstruction | ioInstruction | selectionInstruction | iterationInstruction | returnInstruction;
	expressionInstruction : SEMICOLON_ | expression SEMICOLON_;
	ioInstruction : READ_ PAR_OPEN_ ID_ PAR_CLOSE_ SEMICOLON_ 
                        {
                            TIPO_ARG posId = getSymbolPosition($3); 
                            emite(EREAD, crArgNulo(), crArgNulo(), posId); 
                        }
            | PRINT_ PAR_OPEN_ expression PAR_CLOSE_ SEMICOLON_ 
                        {
                            emite(EWRITE, crArgNulo(), crArgNulo(), $3.pos);
                        };
	selectionInstruction : IF PAR_OPEN_ expression PAR_CLOSE_  
                        { 
                            int ref = creaLans(si);
                            $<hasRef>$ = ref;
                            emite(EIGUAL, $3.pos, crArgEntero(0), crArgEtiqueta(0));
                        } 
                        instruction 
                        {
                            int ref = creaLans(si);
                            $<hasRef>$ = ref;
                            emite(GOTOS,  crArgNulo(), crArgNulo(), crArgEtiqueta(0));
                            completaLans($<hasRef>5, crArgEtiqueta(si));
                        }
                        ELSE instruction
                        {
                            completaLans($<hasRef>7, crArgEtiqueta(si));
                        } ;


                        
	iterationInstruction : FOR PAR_OPEN_ optionalExpression SEMICOLON_ 
                        {
                            // Start:
                            $<forHelper>$.label = si;
                        }
                        expression 
                        {
                            $<forHelper>$.ref = creaLans(si);
                            emite(EIGUAL, $6.pos, crArgEntero(0), crArgEtiqueta(0)); // Check if loop condition false, then jump to final
                        }
                        SEMICOLON_ 
                        {
                            $<forHelper>$.ref = creaLans(si);
                            // Goto body
                            emite(GOTOS, crArgNulo(), crArgNulo(), crArgEtiqueta(0)); 
                            // OptExpression:
                            $<forHelper>$.label = si;
                        }
                        optionalExpression PAR_CLOSE_  
                        {   // Goto start
                            emite(GOTOS, crArgNulo(), crArgNulo(), crArgEtiqueta($<forHelper>5.label));
                            // body:
                            completaLans($<forHelper>9.ref, crArgEtiqueta(si));
                        }
                        instruction 
                        {
                            // goto optExpression
                            emite(GOTOS, crArgNulo(), crArgNulo(), crArgEtiqueta($<forHelper>9.label));
                            // Final:
                            completaLans($<forHelper>7.ref, crArgEtiqueta(si));
                        };
	optionalExpression : /* eps */
                        {
                            $$.type = T_VACIO;
                        } | expression;
	returnInstruction : RETURN expression SEMICOLON_ 
                        {
                             /*
                              * Position of the return value:
                              * Stackpointer -1 - 2 (Ret + Old FP) - parameterSize
                              * The -1 is because the stackpointer points to the next element. So SP - 1 is the last element on the stack.
                              */
                             INF fn = obtenerInfoFuncion(-1); // Current function
                             TIPO_ARG posReturn = crArgPosicion(level, -fn.tparam - 3);
                             DebugStream("Posreturn: " << fn.tparam - 1 );
                             emite(EASIG, $2.pos, crArgNulo(), posReturn);
                             // We return from the complete function.
                             // This means we have to remove the place from each level:
                             for(int i=0; i<localPlaceUpdateList.size(); i++) {
                                int ref = creaLans(si);
                                emite(DECTOP, crArgNulo(), crArgNulo(), crArgEntero(0));
                                localPlaceUpdateList[i].push_back(ref);
                             }

                             emite(FPPOP, crArgNulo(), crArgNulo(), crArgNulo());
                             
                             emite(RET, crArgNulo(), crArgNulo(), crArgNulo());
                        };
	expression : equalityExpression 
                        {
                            $$.pos = $1.pos;
                            $$.size = $1.size;
                        }
            | ID_ asignationOperator expression 
                        {
                            TIPO_ARG posId = getSymbolPosition($1);
                            switch($2) {
                                case ASIGN:
                                    emite(EASIG, $3.pos, crArgNulo(), posId);
                                    break;
                                case ADD_ASIGN:
                                    emite(ESUM, posId, $3.pos, posId);
                                    break;
                                case MINUS_ASIGN:
                                    emite(EDIF, posId, $3.pos, posId);
                                    break;
                            }
                            $$.pos = posId;
                            $$.type = T_ENTERO;
                            $$.size = 1; 
                        }
            | ID_ SQUARE_OPEN_ expression SQUARE_CLOSE_ asignationOperator expression 
                        {
                            TIPO_ARG posArray = getSymbolPosition($1);
                            TIPO_ARG varTemp = crArgPosicion(level, creaVarTemp());
                            switch($5) 
                            {
                                case ASIGN:
                                    emite(EVA, posArray, $3.pos, $6.pos); 
                                    emite(EASIG, $6.pos, crArgNulo(), varTemp);
                                    break;
                                case ADD_ASIGN:
                                    emite(EAV, posArray, $3.pos, varTemp);
                                    emite(ESUM, varTemp, $6.pos, varTemp);
                                    emite(EVA, posArray, $3.pos, varTemp); 
                                    break;
                                case MINUS_ASIGN:
                                    emite(EAV, posArray, $3.pos, varTemp);
                                    emite(EDIF, varTemp, $6.pos, varTemp);
                                    emite(EVA, posArray, $3.pos, varTemp); 
                                    break;
                            }
                            $$.pos = varTemp;
                            $$.type = T_ENTERO;
                            $$.size = 1;
                            
                        }

            | ID_ POINT_ ID_ asignationOperator expression 
                        {
                            SIMB simStruct = getSymbol($1);
                            REG campo = obtenerInfoCampo(simStruct.ref, $3);
                            int despTotal = simStruct.desp + campo.desp;
                            TIPO_ARG posField = crArgPosicion(simStruct.nivel,despTotal); 
                            $$.pos = posField;
                            $$.type = campo.tipo;
                            $$.size = 1; // Fields don't have sizes in the TDS
                            switch($4) {
                                case ASIGN:
                                    emite(EASIG, $5.pos, crArgNulo(), posField);
                                    break;
                                case ADD_ASIGN:
                                    emite(ESUM, posField, $5.pos, posField);
                                    break;
                                case MINUS_ASIGN:
                                    emite(EDIF, posField, $5.pos, posField);
                                    break;
                            }
                        };
	equalityExpression : relationalExpression 
                        {
                            $$.pos = $1.pos;
                            $$.type = $1.type;
                            $$.size = $1.size;
                        }
                | equalityExpression equalityOperator relationalExpression 

                        {
                            $$.pos = crArgPosicion(level, creaVarTemp());
                            int ref1 = creaLans(si);
                            emite($2, $1.pos, $3.pos, crArgEtiqueta(0)); // Conditional jump depending on the relation
                            emite(EASIG, crArgEntero(0), crArgNulo(), $$.pos); // Assign 0, because the relation does not hold
                            int ref2 = creaLans(si);
                            emite(GOTOS, crArgNulo(), crArgNulo(), crArgEtiqueta(0)); // Jump to the end
                            completaLans(ref1, crArgEtiqueta(si)); // Jump here if the relation holds
                            emite(EASIG, crArgEntero(1), crArgNulo(), $$.pos); 
                            completaLans(ref2, crArgEtiqueta(si)); 
                            $$.type = T_LOGICO; 
                            $$.size = 1;
                        };
	relationalExpression : additiveExpression 
                        {
                            /*$$.pos = crArgPosicion(level, creaVarTemp());
                            $$.type = T_LOGICO;
                            emite(ETOB, $$.pos, crArgNulo(), $$.pos);*/
                            $$.pos = $1.pos;
                            $$.type = $1.type;
                            $$.size = $1.size;
                            
                        }
                | relationalExpression relationalOperator additiveExpression 
                        {
                            $$.pos = crArgPosicion(level, creaVarTemp());
                            int ref1 = creaLans(si);
                            emite($2, $1.pos, $3.pos, crArgEtiqueta(0)); // Conditional jump depending on the relation
                            emite(EASIG, crArgEntero(0), crArgNulo(), $$.pos); // Assign 0, because the relation does not hold
                            int ref2 = creaLans(si);
                            emite(GOTOS, crArgNulo(), crArgNulo(), crArgEtiqueta(0)); // Jump to the end
                            completaLans(ref1, crArgEtiqueta(si)); // Jump here if the relation holds
                            emite(EASIG, crArgEntero(1), crArgNulo(), $$.pos); 
                            completaLans(ref2, crArgEtiqueta(si)); 
                            $$.type = T_LOGICO; 
                            $$.size = 1;
                        };
	additiveExpression : multiplicativeExpression 
                        {
                            $$.pos = $1.pos;
                            $$.type = $1.type;
                            $$.size = $1.size;
                        }
                | additiveExpression additiveOperator multiplicativeExpression 
                        {
                            $$.pos = crArgPosicion(level, creaVarTemp());
                            $$.type = T_ENTERO;
                            $$.size = 1;
                            emite($2, $1.pos, $3.pos, $$.pos);
                        };
	multiplicativeExpression : unaryExpression 
                        {
                            $$.pos = $1.pos;
                            $$.type = $1.type;
                            $$.size = $1.size;
                        }

                | multiplicativeExpression multiplicativeOperator unaryExpression 
                        {
                            $$.pos = crArgPosicion(level, creaVarTemp());
                            $$.type = T_ENTERO;
                            $$.size = 1;
                            emite($2, $1.pos, $3.pos, $$.pos);
                        };
	unaryExpression : suffixExpression 
                        {
                            $$.type = $1.type;
                            $$.pos = $1.pos;
                            $$.size = $1.size;
                        }
                | unaryOperator unaryExpression 
                        {   
                            TIPO_ARG res = crArgPosicion(level, creaVarTemp());
                            emite(ESIG, $2.pos, crArgNulo(), res);
                            $$.pos = res;
                            $$.type = $2.type;
                            $$.size = $2.size;
                        }
                | incrementOperator ID_
                        {
                            SIMB s = getSymbol($2);
                            TIPO_ARG res = crArgPosicion(s.nivel, s.desp);
                            $$.type = T_ENTERO;
                            $$.size = 1;
                            $$.pos = crArgPosicion(level, creaVarTemp());
                            emite($1, res, crArgEntero(1), res);
                            emite(EASIG, res, crArgNulo(), $$.pos);
                        };
	suffixExpression :
                /* Array access */
                 ID_ SQUARE_OPEN_ expression SQUARE_CLOSE_ 
                        {
                            TIPO_ARG posArray = getSymbolPosition($1);
                            $$.pos = crArgPosicion(level,creaVarTemp()); 
                            $$.type = T_ENTERO;
                            $$.size = 1;
                            emite(EAV, posArray, $3.pos, $$.pos);
                        }
                /* Record access */
                | ID_ POINT_ ID_ 
                        {
                            SIMB simStruct = getSymbol($1);
                            REG campo = obtenerInfoCampo(simStruct.ref, $3);
                            if(campo.tipo == T_ERROR) {
                                char buffer[200];
                                sprintf(buffer, "The struct %s does not contain a field named %s", $1, $3);
                                yyerror(buffer);
                            }
                            int despTotal = simStruct.desp + campo.desp;
                            $$.type = campo.tipo;
                            $$.size = 1; // Fields don't have sizes in the TDS. So assume it is an integer
                            $$.pos = crArgPosicion(simStruct.nivel,despTotal); 
                        }
                /* Increment/Decrement */
                | ID_ incrementOperator 
                        {
                            TIPO_ARG posId = getSymbolPosition($1);
                            $$.type = T_ENTERO;
                            $$.pos = crArgPosicion(level, creaVarTemp()); 
                            $$.size = 1;
                            emite(EASIG, posId, crArgNulo(), $$.pos);
                            emite($2, posId, crArgEntero(1), posId);
                        }
                /* Function call */
                | ID_ PAR_OPEN_ 
                        {
                            emite(EPUSH,crArgNulo(), crArgNulo(), crArgEntero(0)); // Reserve space for the return value
    
                        }
                            actualParameters PAR_CLOSE_ 
                        {
                            SIMB s = obtenerSimbolo($1);
                            INF fun = obtenerInfoFuncion(s.ref);
                            if(s.categoria == NULO) {
                                char buffer[200];
                                sprintf(buffer, "The function %s is not declared", $1);
                                yyerror(buffer);
                            }
                            else if(comparaDominio(s.ref, $4.ref) == FALSE) {
                                char buffer[200];
                                sprintf(buffer, "Invalid parameters at call of function %s", $1);
                                yyerror(buffer);

                            }
                            emite(CALL, crArgNulo(), crArgNulo(), crArgEtiqueta(s.desp));
                            emite(DECTOP, crArgNulo(), crArgNulo(), crArgEntero(fun.tparam));
                            $$.pos = crArgPosicion(level, creaVarTemp()); 
                            $$.type = s.tipo;
                            emite(EPOP, crArgNulo(), crArgNulo(), $$.pos);
                            $$.size = 1; // Assume it is an integer. Although the grammar accepts structs too
                        }
                | PAR_OPEN_ expression PAR_CLOSE_ 
                        {
                            $$.pos = $2.pos;
                            $$.type = $2.type;
                            $$.size = $2.size;
                        }
                | ID_ 
                        {
                            SIMB s = getSymbol($1);
                            $$.pos = crArgPosicion(s.nivel, s.desp); 
                            $$.type = s.tipo;
                            DIM arrayInfo;
                            switch(s.tipo) {
                                case T_ENTERO: 
                                case T_LOGICO:
                                    $$.size = 1; break;
                                case T_RECORD:
                                    $$.size = 1; break; // This is most likely wrong. But SIMB does not save the size and there is no possibility to iterate through the fields
                                case T_ARRAY:
                                    arrayInfo = obtenerInfoArray(s.ref);
                                    $$.size = arrayInfo.nelem; break;
                            }
                        }
                | CTI_ {
                    $$.type = T_ENTERO;
                    /* This is not a position, but we can use an integer everywhere where
                     * we would use this temporary variable. So we can save one temporary variable.
                     * This makes the code cleaner.
                     */
                    $$.pos = crArgEntero($1);
                    $$.size = 1;

                };
	actualParameters : /* eps */ {$$.ref = insertaInfoDominio(-1, T_VACIO);} | actualParameterList {$$.ref = $1.ref;}
                    /*
                     * According to the C calling convention:
                     * fn(1,2,3)
                     * EPUSH 3
                     * EPUSH 2
                     * EPUSH 1
                     */
	actualParameterList : expression 
                                {
                                    emite(EPUSH, crArgNulo(), crArgNulo(), $1.pos);
                                    $$.ref = insertaInfoDominio(-1, $1.type);
                                }
                        | expression COMMA actualParameterList  
                                {
                                    emite(EPUSH, crArgNulo(), crArgNulo(), $1.pos);
                                    $$.ref = insertaInfoDominio($3.ref, $1.type);
                                };
	asignationOperator : ASIGN 
                                {
                                    $$ = ASIGN;
                                } 
                        | ADD_ASIGN 
                                {
                                    $$ = ADD_ASIGN;
                                }
                        | MINUS_ASIGN 
                                {
                                    $$ = MINUS_ASIGN;
                                };
    equalityOperator : EQUAL 
                        {
                            $$ = EIGUAL;
                        }
                        | NOT_EQUAL 
                        {
                            $$ = EDIST;
                        };
    relationalOperator : GREATER 
                        {
                            $$ = EMAY;
                        }
                        | LESS 
                        {
                            $$ = EMEN;
                        }
                        | GREATER_EQUAL 
                        {
                            $$ = EMAYEQ;
                        }
                        | LESS_EQUAL 
                        {
                            $$ = EMENEQ;
                        }
                        ;
    additiveOperator : PLUS     
                        {
                            $$ = ESUM;
                        }
                | MINUS 
                        {
                            $$ = EDIF;
                        };
    multiplicativeOperator : MULT 
                        {
                            $$ = EMULT;
                        }
                | DIV
                        {
                            $$ = EDIVI;
                        };
    incrementOperator : 
                  INC {
                    $$ = ESUM;
                }
                | DEC {
                    $$ = EDIF;
                };
        unaryOperator : PLUS | MINUS;





%%

void yyerror(char *s) 
{
  //printf("Line %d: %s\n", yylineno, s);
  std::cerr << "Error: Line " << yylineno << ": " << s << std::endl;
}
