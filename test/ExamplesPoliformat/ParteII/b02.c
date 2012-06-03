// Ejemplo (absurdo) de 5 errores semanticos
int A(int x, int y)
{ int A[0];                       // talla inapropiada  
  int x;                          // identificador repetido
  y += A[x]; y = y + x;
  return y++;
}

int C(int x, int y)
{                                  // Num.Param distinto, prametro
  return A(A(x,x,y),A(x,(y==3)));  // no entero y dominios diferentes
}

int main()
{
  int x;  int y;

  read(x);
  read(z);                         // objeto no declarado
  if (x < y) print(C(x,y));
  else print(C(y,x));
}
