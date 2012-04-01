#include <stdlib.h>
#include <libtds.h>
#include <string.h> 
#include "include/common.h"
void declareVariable(int n, char *nom, int type, int desp, int size, int ref) {
    int result = insertaSimbolo(nom, VARIABLE, type, desp,n, ref); 
    if(result == 0) {
        yyerror("Multiple declaration of the same identifier");
    }
    printf("Variable Declaration: %s Class: %i, Type: %i Desp: %i Level: %i Ref: %i\n",  nom, VARIABLE, type, desp, n, ref); 
}
