#include <stdio.h>
#include <string.h>
#include "common.h"

/* I could use C99 complex numbers, but that turned out to be quite
   slow, so instead I manually pass around pairs of floats. */
#define COMPLEX_DOT(re, im) (re * re + im * im)
#define COMPLEX_MULT(re_out, im_out, a, b, c, d) (re_out = a*c - b*d, im_out = a*d + b*c)
#define COMPLEX_ADD(re_out, im_out, a, b, c, d) (re_out = a + c, im_out = b + d)

float mandelbrot(int screenX, int screenY, int depth,
                 float xmin, float ymin, float xmax, float ymax) {
  float sizex = xmax - xmin;
  float sizey = ymax - ymin;

  float *res0 = malloc(screenX*screenY*sizeof(float));
  float *ims0 = malloc(screenX*screenY*sizeof(float));
  float *res = malloc(screenX*screenY*sizeof(float));
  float *ims = malloc(screenX*screenY*sizeof(float));
  int *escapes = calloc(screenY*screenX, sizeof(int));

  for (int y = 0; y < screenY; y++) {
    for (int x = 0; x < screenX; x++) {
      res[y*screenX + x] =
        (xmin + (x * sizex) / screenX);
      ims[y*screenX + x] =
        (ymin + (y * sizey) / screenY);
    }
  }

  memcpy(res0, res, screenX*screenY*sizeof(float));
  memcpy(ims0, ims, screenX*screenY*sizeof(float));

  for (int i = 0; i < depth; i++) {
    for (int j = 0; j < screenX*screenY; j++) {
      float re0 = res0[j];
      float im0 = ims0[j];

      float re = res[j];
      float im = ims[j];

      float new_re, new_im;

      COMPLEX_MULT(new_re, new_im, re, im, re, im);
      COMPLEX_ADD(res[j], ims[j], new_re, new_im, re0, im0);

      float dot = COMPLEX_DOT(re, im);
      if (dot < 4) {
        escapes[j]++;
      }
    }
  }

  free(res0);
  free(ims0);
  free(res);
  free(ims);

  /* Sum it up. */
  float sum = 0;
  for (int j = 0; j < screenX*screenY; j++) {
    sum += ((float)escapes[j])/depth;
  }

  free(escapes);

  return sum;
}

void bench(int measure) {
  if (measure) {
    start_run();
  }

  int screenX = 1000;
  int screenY = 1000;
  int depth = 255;
  float xmin = -2.0;
  float ymin = -0.75;
  float xmax = 0.75;
  float ymax = 0.75;

  float sum = mandelbrot(screenX, screenY, depth, xmin, ymin, xmax, ymax);

  if (measure) {
    end_run();
  }

  printf("%f\n", sum);
}

int main(int argc, char** argv) {
  parse_args(argc, argv);

  bench(0);

  for (int i = 0; i < runs; i++) {
    bench(1);
  }
}
