// calcula el m.c.d. de dos numeros naturales > 0
int max(int x, int y)
{
  if (x < y) return y;
  else return x;
}

int min(int x, int y)
{
  if (x < y) return x;
  else return y;
}

int mcd(int x, int y)
{
  if (x == y) return x;
  else return mcd(min(x,y-x),max(x,y-x));
}

int main()
{
  int x;
  int y;

  read(x);
  read(y);
  if (x < y) print(mcd(x,y));
  else print(mcd(y,x));
}
