/*****************************************************************************/
/**  Definiciones de las constantes y estructuras auxiliares usadas en      **/
/**  la librería <<libtds>>, asi como el perfil de las funciones de         **/
/**  manipulación de la  TDS y la TDB.                                      **/
/**                     Jose Miguel Benedi, 2011-2012 <jbenedi@dsic.upv.es> **/
/*****************************************************************************/
/*****************************************************************************/
#ifndef _LIBTDS_H
#define _LIBTDS_H

#ifdef __cplusplus
extern "C" {
#endif


/******************************************* Tipos para la Tabla de Simbolos */
#define T_VACIO       0
#define T_ENTERO      1
#define T_LOGICO      2
#define T_ARRAY       3
#define T_RECORD      4
#define T_ERROR       5
/************************************** Categorias para la Tabla de Simbolos */
#define NULO          0
#define VARIABLE      1
#define FUNCION       2
#define PARAMETRO     3
typedef struct simb /* Estructura para la informacion obtenida de la TDS     */
{
  int   categoria;                /* Categoria del objeto                    */
  int   tipo;                     /* Tipo del objeto                         */
  int   desp;                     /* Desplazamiento relativo en el segmento  */
  int   nivel;                    /* nivel del bloque                        */
  int   ref;                      /* Campo de referencia de usos multiples   */
} SIMB;
typedef struct dim  /* Estructura para la informacion obtenida de la TDArray */
{
  int   telem;                                      /* Tipo de los elementos */
  int   nelem;                                      /* Numero de elementos   */
} DIM;
typedef struct inf  /* Estructura para las funciones                         */
{
  char *nombre;                          /* Nombre de la funcion             */
  int   tipo;                            /* Tipo del rango de la funcion     */
  int   tparam;                          /* Talla del segmento de parametros */
}INF;
typedef struct reg  /* Estructura para los campos de un registro             */
{
  int   tipo;                          /* Tipo del campo                     */
  int   desp;                          /* Desplazamiento relativo en memoria */
}REG;
/************************************* Operaciones para la gestion de la TDS */
void cargaContexto (int n);
/* Crea el contexto necesario asi como las inicializaciones de la TDS y 
   la TDB para un nuevo bloque con nivel de anidamiento "n". Si "n=0" 
   corresponde a los objetos globales; si "n=1" a los objetos locales a las
   funciones;  y si "n>0" a los objetos locales al nuevo bloque.             */
void descargaContexto (int n);
/* Libera en la TDB y la TDS el contexto asociado con el bloque "n".         */
void mostrarTDS (int n);
/* Muestra en pantalla toda la informacion de la TDS asociada con el bloque
   definido por "n".                                                         */
int  insertaSimbolo(char *nom, int clase, int tipo, int desp, int n, int ref);
/* Inserta en la TDS toda la informacion asociada con un simbolo de: nombre 
   "nom", clase "clase", tipo "tipo", desplazamiento relativo en el segmento 
   correspondiente (variables, parametros o instrucciones) "desp", nivel del 
   bloque "n" y referencia a posibles subtablas "ref" (-1 si no referencia a 
   otras subtablas). Si el identificador ya existe en el bloque actual, 
   devuelve el valor "FALSE=0" ("TRUE=1" en caso contrario).                 */
int  insertaInfoArray (int telem, int nelem);
/* Inserta en la Tabla de Arrays la informacion de un array cuyos elementos 
   son de tipo "telem" y el numero de elementos es "nelem". Devuelve su 
   referencia en la Tabla de Arrays.                                         */
int  insertaInfoCampo (int refe, char *nom, int tipo, int desp);
/* Inserta en la Tabla de Registros, referenciada por "refe", la informacion 
   de un determinado campo: nombre de campo "nom", tipo de campo "tipo" y 
   desplazamiento del campo "desp". Si "ref = -1" entonces crea una nueva 
   entrada en la Tabla de Registros para este campo y devuelve su referencia.
   Comprueba ademas que el nombre del campo no este repetido en el registro, 
   devolviendo "-1" en caso de algun error.                                 */
int  insertaInfoDominio (int refe, int tipo);
/* Para un dominio existente referenciado por "refe", inserta en la Tabla 
   de Dominios la informacion del "tipo" del parametro. Si "refe= -1" entonces
   crea una nueva entrada en la tabla de dominios para el tipo de este 
   parametro y devuelve su referencia.  Si la funcion no tiene parametros, 
   debe crearse un dominio vacio con: "refe = -1" y "tipo = T_VACIO".       */
SIMB obtenerSimbolo (char *nom);
/* Obtiene toda la informacion asociada con un objeto de nombre "nom" y la
   devuelve en una estructura de tipo "SIMB". Si el objeto no está declarado,
   en el campo "categoria" devuelve el valor "NULO".                         */
DIM  obtenerInfoArray (int ref);
/* Devuelve toda la informacion asociada con un array referenciado por "ref" 
   en la Tabla de Arrays.                                                    */
INF  obtenerInfoFuncion (int ref);
/* Devuelve la informacion del nombre de la función, el tipo del rango y el 
   numero (talla) del segmento de parametros de una función cuyo dominio 
   esta referenciado por "ref" en la TDS. Si "ref<0" entonces devuelve la 
   informacion de la funcion actual.                                         */
int  comparaDominio (int refx, int refy);
/* Si los dominios referenciados por "refx" y "refy" no coinciden devuelve 
   "FALSE=0" ("TRUE=1" si son iguales).                                      */
REG  obtenerInfoCampo (int ref, char *nom);
/* Obtiene toda la informacion asociada con un campo, de nombre "nom", de un 
   registro referenciado por el indice "ref" en la Tabla de Registros. Si
   no se encuentra devuelve "T_ERROR" en el campo "tipo".                    */

#ifdef __cplusplus
}
#endif


#endif  /* _LIBTDS_H */
/*****************************************************************************/
