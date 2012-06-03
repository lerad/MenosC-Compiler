// Ejemplo (absurdo) sintactico-semantico con variables globales y 
// locales. Comprobad el resultado con la funcion "mostraTDS"
int a;
struct{int b1; int b2;} b;
int c[27];

int A(int x, int y)
{
  int c[27];  
  struct{int b1; int b2;} b;
  int a;
  {  int a;  }
  {  int b;  }

  return y-x;
}

int d[27];
int e;

int main()
{
  int z[27];
  struct{int y1; int y2;} y;
  int x;
  {  int x;  }
  {  int y;  
     read(x);
     read(y);
     if (x < y) print(A(x,y));
     else print(A(y,x));
   }
}
