#include<stdio.h>

inline
int easter(int i) {
  int G, C, X, Z, S, E, b, F, N, M, D;
  G = (i % 19) + 1;
  C = i / 100 + 1;
  X = (C*3)/4 - 12;
  Z = (5+8*C)/25 - 5;
  S = (5*i)/4 - (X + 10);
  E = (11*G+20+Z-X) % 30;
  b = ( (E == 24) || ((E==25) && (G >11)) ) ? 1 : 0;
  F = E + b;
  b = (F > 23) ? 1 : 0;
  N = 30*b + (44 - F);
  N = N + 7 - (S+N) % 7;
  b = (N > 31) ? 1 : 0;
  M = 3 + b;
  D = N - 31*b;
  return (10000*i + 100*M + D);
}

int main() {
  int i;
  int max_val = -2147483648;
  for(i=0; i<10000000; i++) {
    int val = easter(i);
    if(max_val < val) { max_val = val; }
  }
  printf("MaxVal is: %d\n", max_val);
}
