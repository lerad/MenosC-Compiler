// Ejemplo absurdo: sintacticamente correcto, pero...
// como veremos, semanticamente incorrecto
struct{
  int c1;
  int c2[27];
  struct { int c31; int c32;} c;
} a;

struct{int a; int b;} F (struct{int a; int b;} a, int b) {

  if (a[b]=b) return (a[b] == 0);
  else;
}
