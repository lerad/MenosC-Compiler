%{
#include <stdio.h>
extern int yylineno;
%}

%error-verbose

%token ID_ CTE_
%token INT_ BOOL_
%token TRUE_ FALSE_
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
%token INC DEC
%token IF ELSE
%token RETURN STRUCT
%token POINT
%%
programa : 
/*
programa : secuenciaDeclaraciones bloque;
secuenciaDeclaraciones : declaracion | secuenciaDeclaraciones declaracion;
declaracion : declaracionVariable;
declaracionVariable : tipoSimple ID_ PUNTOYCOMA_ | 
                      tipoSimple ID_ CORABR_  CTE_ CORCER_  PUNTOYCOMA_ ;
tipoSimple : INT_ | BOOL_;
bloque : LLAVABR_ listaInstrucciones LLAVCER_;
listaInstrucciones : | listaInstrucciones instruccion;
instruccion : instruccionExpression | instruccionEntradaSalida;
instruccionExpression : PUNTOYCOMA_ | expresion PUNTOYCOMA_; 
instruccionEntradaSalida : READ_ PARABR_ ID_ PARCER_ PUNTOYCOMA_ | 
                           PRINT_ PARABR_ expresion PARCER_ PUNTOYCOMA_;
expresion : ID_ operadorAsignacion expresion | ID_ CORABR_ expresion CORCER_ operadorAsignacion expresion |
            expresionAditiva;
expresionAditiva : expresionMultiplicativa | expresionAditiva operadorAditivo expresionMultiplicativa;
expresionMultiplicativa : expresionUnaria | expresionMultiplicativa operadorMultiplicativo expresionUnaria;
expresionUnaria : expresionSufija;
expresionSufija : ID_ CORABR_ expresion CORCER_ | PARABR_ expresion PARCER_ | 
                ID_  | CTE_ | TRUE_ | FALSE_;
operadorAsignacion : ASIG_;
operadorAditivo : MAS_;
operadorMultiplicativo : POR_;
*/

%%

yyerror(char *s) 
{
  printf("Linea %d: %s\n", yylineno, s);
}
