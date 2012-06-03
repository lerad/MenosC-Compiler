// Calculo de los numeros primos menores que un numero < 150
int a[150];

int divisor (int d, int n)
{
  if (n < d) return 0;
  else {
    for (; n >= d;) n-=d ;
    if (n == 0) return 1;
    else return 0;
    }
}

int max; 

int main()
{ int n; int m; int ok;

  read(max);
  for (ok=0; ok == 0;)
    if (max > 1) 
      if (max < 150)  ok=1;
      else read(max); 
    else read(max);
 
  for (n=2; n <= max; n++) a[n]=1;

  for (n=4; n <= max; n++) { 
    if (divisor(2,n) == 1) a[n]=0; 
    else {
      for (m=3; (m*m) <= n;) 
	if (divisor(m,n) == 1) {
	  a[n]=0; m=n;
	  }
	else m=m+2;
    }
  }

  for (n=2; n <= max; n++)
    if (a[n] == 1) print(n);
    else ;  
}
