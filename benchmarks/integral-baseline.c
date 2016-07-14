#include <stdio.h>
#include "common.h"

inline
float f(float x) { return 2.0 / (x + 2.0); }

void bench() {
  start_run();

  int x  = 10000000;
  int i;

  float acc = 0.0;
  for(i=0; i<x; i++) {
    float dom = 10.0 * ((float)i) / x;
    acc += f(dom) / x;
  }
  end_run();

  printf("Result: %f\n", acc);
}

int main(int argc, char **argv) {
  parse_args(argc, argv);

  for (int i = 0; i < runs; i++) {
    bench();
  }
}
