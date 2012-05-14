// Ejemplo sencillo


int main ()
{
  int x;
  int y;
  x = 2;
  y = 3;
  if (y == 3) {
    x = 4;
    x = x + 2;
  }
  else {
    x = 3;
    x = x * 4;
  }

  print(x);
}

