// Ejemplo (absurdo) con 10 errores semanticos
// el programa no tiene "main"
struct{
  int c1[27];                             // campo no entero
  struct { int c21; int c22;} c2;         // campo no entero
  int c3;
} a;

struct{int a; int b;}  F                  // rango no entero
  (struct{int a; int a;} c, int b)        // parametro no entero y
{		                          // campo repetido
  if (a[b]=b)                        // identificador no array y
                                     // expresión de tipo no lógico
    return (a.c4 == 0);              // Campo no declarado y 
                                     // retorno no entero
  else;
}
