#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "common.h"

const int N = 10000000;

float redsignal(const int n, float* x) { 
  int i;
  float acc = 0.0;
  for(i=0; i<n; i++) {
    float tmp;
    float x_el = x[i];
    float xip1 = (i == n-1) ? x[0] : x[i+1];
    tmp = x_el - xip1;
    tmp = tmp / (x_el + 0.01);
    tmp = tmp * 50.0;

    tmp = (tmp < -50.0) ? -50.0 :
            (tmp > 50.0) ? 50.0 : tmp;

    acc += tmp;
  }

  return acc;
}

float* input(int x) { 
  int i;
  float* arr = (float*)malloc(x*sizeof(float));

  float fy = ((float)x) / 10.0;
  for(i=0; i<x; i++) {
    arr[i] = sin( ((float)i)/fy );
  }
  return arr;
}

void bench(int measure) {
  if (measure) {
    start_run();
  }

  float* arr = input(N);
  float  res = redsignal(N, arr);
  printf("Result: %f\n", res);

  if (measure) {
    end_run();
  }

  free(arr);
}

int main(int argc, char **argv) {
  parse_args(argc, argv);

  bench(0);

  for (int i = 0; i < runs; i++) {
    bench(1);
  }
}
