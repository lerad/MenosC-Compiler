/*****************************************************************************/
/**  Definiciones de las estructuras auxiliares, constantes y variables     **/
/**  globales usadas en la librería <<libgci>>, asi como el perfil de las   **/
/**  funciones de ayuda para la generacion de codigo intermedio.            **/
/**                     Jose Miguel Benedi, 2011-2012 <jbenedi@dsic.upv.es> **/
/*****************************************************************************/
/*****************************************************************************/
#ifndef _LIBGCI_H
#define _LIBGCI_H

/********************************* Instrucciones del Codigo Tres Direcciones */
#define ESUM          0
#define EDIF          1
#define EMULT         2
#define EDIVI         3
#define RESTO         4
#define ESIG          5
#define EASIG         6
#define GOTOS         7
#define EIGUAL        8
#define EDIST         9
#define EMEN         10
#define EMAY         11
#define EMAYEQ       12
#define EMENEQ       13
#define EAV          14
#define EVA          15
#define EREAD        16
#define EWRITE       17
#define FIN          18
#define RET          19
#define CALL         20
#define EPUSH        21
#define EPOP         22
#define PUSHFP       23
#define FPPOP        24
#define FPTOP        25
#define TOPFP        26
#define INCTOP       27
#define DECTOP       28
#define ETOB         29
#define BTOE         30
typedef struct tipo_pos /*********** Estructura para una posición de memoria */
{
  int pos;                            /*     Posicion relativa de memoria    */
  int niv;                            /*     Contexto (nivel) de la variable */
}TIPO_POS;
typedef struct tipo_arg /****** Estructura para los argumentos del codigo 3D */
{              
  int tipo;                  /* Tipo del argumento                           */
  union {
    int      i;              /* Variable para argumento entero               */
    TIPO_POS p;              /* Variable para argumento posicion de memoria  */
    int e;                   /* Variable para argumento direccion de memoria */
  } val;
}TIPO_ARG;
/*************************** Variables globales de uso en todo el compilador */

extern int si;                /* Desplazamiento en el Segmento de Codigo     */
extern int dvar;              /* Desplazamiento en el Segmento de Variables  */

/*************** Funciones para crear los argumentos de las instrucciones 3D */
TIPO_ARG crArgNulo ();
/* Crea un argumento de una instruccion tres direcciones de tipo nulo.       */
TIPO_ARG crArgEntero (int valor);
/* Crea un argumento de una instruccion tres direcciones de tipo entero 
   con la informacion de la constante entera dada en "valor".                */
TIPO_ARG crArgEtiqueta (int valor);
/*  Crea el argumento de una instruccion tres direcciones de tipo etiqueta 
    con la informacion de la direccion dada en "valor".                      */
TIPO_ARG crArgPosicion (int n, int valor);
/*  Crea el argumento de una instruccion tres direcciones de tipo posicion 
    con la informacion del nivel en "n" y del desplazamiento en "valor".     */

/******************************** Funciones para la manipulacion de las LANS */
int creaLans (int d);
/* Crea una lista de argumentos no satisfechos para una instruccion
   incompleta cuya direccion es "d" y devuelve su referencia.                */
int fusionaLans (int x, int y);
/* Fusiona dos listas de argumentos no satisfechos cuyas referencias
   son "x" e "y" y devuelve la referencia de la lista fusionada.             */
void completaLans (int x, TIPO_ARG arg);
/* Completa con el argumento "arg" el campo "res" de todas las instrucciones 
   incompletas de la lista "x".                                              */

void emite (int cop, TIPO_ARG arg1, TIPO_ARG arg2, TIPO_ARG res);
/* Crea una instruccion tres direcciones con el codigo de operacion "cod" y 
   los argumentos "arg1", "arg2" y "res", y la pone en la siguiente posicion 
   libre (indicada por "si") del Segmento de Codigo. A continuacion, 
   incrementa "si".                                                          */
int creaVarTemp ();
/*  Crea una variable temporal entera (de talla "1"), en el segmento de
    variables (indicado por "dvar") del RA actual y devuelve su 
    desplazamiento relativo. A continuacion, incrementa "dvar".              */
void vuelcaCodigo(char *nom);
/* Vuelca el codigo generado, en modo texto, a un fichero cuyo nombre
   es el del fichero de entrada con la extension ".c3d".                     */

#endif  /* _LIBGCI_H */
/*****************************************************************************/
