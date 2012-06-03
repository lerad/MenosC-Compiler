// Calcula el factorial de un múmero < 20
int factorial(int n)
{
  if (n <= 1) return 1;
  else return n * factorial(n-1);
}

int main()
{ int x;

  read(x);
  if (x > 0) 
    if (x < 20) print(factorial(x)); 
    else ;
  else ;
}
