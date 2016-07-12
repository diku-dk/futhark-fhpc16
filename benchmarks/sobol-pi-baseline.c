#include <stdio.h>
#include <math.h>
#include "common.h"

#define N 1000000
#define M 2
#define NUM_BITS 30

int dirvcts[M][NUM_BITS] =
{
    {
        536870912, 268435456, 134217728, 67108864, 33554432, 16777216, 8388608, 4194304, 2097152, 1048576, 524288, 262144, 131072, 65536, 32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1
    },
    {
        536870912, 805306368, 671088640, 1006632960, 570425344, 855638016, 713031680, 1069547520, 538968064, 808452096, 673710080, 1010565120, 572653568, 858980352, 715816960, 1073725440, 536879104, 805318656, 671098880, 1006648320, 570434048, 855651072, 713042560, 1069563840, 538976288, 808464432, 673720360, 1010580540, 572662306, 858993459
    }
};

inline int grayCode(int x) { return (x >> 1) ^ x; }


//Sobol Generator

int testBit(int n, int ind) {
    int t = (1 << ind);
    return ( (n & t) == t );
}

// INDEPENDENT FORMULA: 
// m==2
void sobolIndR( int n, int* sob ) {
  int i, j;
  int g = grayCode(n);

  for(i=0; i<M; i++) {
    int tmp = 0;
    for(j=0; j<NUM_BITS; j++) {
        int t = (1 << j);
        int dv = (t == (g & t)) ? dirvcts[i][j] : 0;
        tmp = tmp ^ dv;
    }
    sob[i] = tmp;
  }
}

void bench(int measure) {
  if (measure) {
    start_run();
  }

  float pi_result;
  int i;
  int sob[2];
  float divisor = pow( 2.0 , NUM_BITS );

  int inside = 0;

  for(i=0; i<N; i++) {
    sobolIndR( i, sob );
    float x = sob[0] / divisor;
    float y = sob[1] / divisor;
    float d = sqrt(x*x + y*y);
    if(d <= 1.0) { inside++; }
  }

  pi_result = (4.0*inside) / N;

  if (measure) {
    end_run();
  }

  printf("Result: %f\n", pi_result);
}

int main(int argc, char **argv) {
  parse_args(argc, argv);

  bench(0);

  for (int i = 0; i < runs; i++) {
    bench(1);
  }
}
