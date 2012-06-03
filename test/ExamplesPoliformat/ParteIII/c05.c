// Debe escribir dos veces (3*n)^2 para n = 9..0
int a[10];

int cuadrado(int x)
{
  return x*x;
} 

int doble(int x)
{
  return x+x;
}

int triple(int x)
{
  return x+doble(x);
}

int main()
{ int i;

  for (i=9; i >= 0; i--) {
    a[i]=cuadrado(triple(i));
    print(cuadrado(triple(i)));
    print(a[i]);
  }
}
