// Ejemplo simple de variables locales a bloques.
int main() 
{
  int a;  int b;
  a = 0;  b = 0;
  {
    int b;
    b = 1;
    {
      int a;
      a = 2;
      print(a); print(b);
    }
    {
      int b;
      b = 3;
      print(a); print(b);
    }
    print(a); print(b);
    }
    print(a); print(b);
 }
