// Ejemplo expresiones de asignación con registros: 1,2,3,6,15
struct {
  int a;
  int b;
  int c;
} r;

int suma(int x, int y, int z) 
{ 
  return x+y+z;
}

int main() 
{ 
  print(r.a=1); print(r.b=2); print(r.c=3);
  print(r.c=r.a+r.b+r.c);
  print(r.c+=suma(r.a,r.b,r.c));
}
