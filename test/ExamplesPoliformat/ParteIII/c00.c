// Ejemplo de variables locales en bloques: (n*10), 
//   para un n > 0, y termina con el numero de intentos 
int i;            
int a[10];

int lee ( )
{ int x;
  i++;
  read(x);
  return x;
}

int main()
{ int n; 

  i=0; n=lee();
  for(;n > 0;) {
    int i;
    a[0]=n; 
    for (i=1; i < 10; i++) a[i]=a[i-1]+n;
    print(a[9]);
    n=lee();
  }
  print (i-1);
}
