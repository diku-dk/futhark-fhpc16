#include<stdio.h>

float f(float x) { return 2.0 / (x + 2.0); }

int main() {
  int x  = 10000000; 
  float fX = (float)x;
  int i;
  
  float acc = 0.0;
  for(i=0; i<x; i++) {
    float dom = 10.0 * ((float)i) / x;
    acc += f(dom) / x;
  }

  printf("Result: %f\n", acc);
}
