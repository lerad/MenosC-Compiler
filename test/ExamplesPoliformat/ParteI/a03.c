// Ejemplo puramente sintactico de funciones y 
//  variables globales y locales
int a;
struct{int b1; int b2;} b;

int A(int x, int y)
{
  int A[10];  

  y += A[x]; a = y + x;
  return a++;
}

int c[27];
struct{int d1; int d2;} d;
int e;

int B(int x, int y)
{
  int a;

  a = (b.b1+d.d1+x)/(b.b2+d.d2+y);
  return ++a;
}

int f[27];
int g;

int C(int x, int x)
{
  return A(B(x,y),B(x,y));
}

int i[27];
int j;
struct{int k1; int k2;} k;

int main()
{
  int x;
  int y;

  read(x);
  read(y);
  if (x < y) print(C(x,y));
  else print(C(y,x));
}
