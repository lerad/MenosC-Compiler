// Programa con 6 errores semanticos
int  a;
int  b[20];
struct{int c1; int c2;} c;

int main()
{
  b = c.c1;                     // Asignacion no valida
  c = b[2];                     // Asignacion no valida

  for (a=0; a=20; a++) b[a]=0;  // Expresion no es de tipo logico

  c[a] = 1 ;                    // La variable no es un array
  a = b.c1;                     // La variable no es un registro
  a = (a == 2);                 // La expresion no es entera
}

