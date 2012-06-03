#include <stdlib.h>
#include <libtds.h>
#include <string.h> 
#include "include/common.h"
#include "include/DebugMsg.h"
void declareVariable(int n, char *nom, int type, int desp, int size, int ref) {
    int result = insertaSimbolo(nom, VARIABLE, type, desp,n, ref); 
    if(result == 0) {
        yyerror("Multiple declaration of the same identifier");
    }
    DebugStream("Variable Declaration: " << nom << " Class: " << VARIABLE << ", Type: " << type << " Desp: " << desp << " Level: "<< n <<" Ref:" << ref); 
}

void declareSymbol(char *nom, int category, int type, int desp, int level, int ref) 
{
    int result = insertaSimbolo(nom, category, type, desp, level, ref);
    if(result == 0) {
        char buffer[200];
        sprintf(buffer, "Multiple declaration of %s at line %i", nom, yylineno);
        yyerror(buffer);
    }
}
