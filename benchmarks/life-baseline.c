#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "common.h"

int count_neighbours(int n, int m, int8_t *board, int i, int j) {
  int above = i == 0 ? n-1 : i-1;
  int below = (i+1) % n;
  int left = j == 0 ? m-1 : (j-1);
  int right = (j+1) % m;
  return
    board[above*m + left] + board[above*m + j] + board[above*m + right] +
    board[i*m + left] + board[i*m + right] +
    board[below*m + left] + board[below*m + j] + board[below*m + right];
}

void iteration(int n, int m, int8_t *restrict board, int8_t *restrict out_board) {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      int alive = board[i*m + j];
      int neighbours = count_neighbours(n, m, board, i, j);
      if (neighbours < 2) {
        out_board[i*m + j] = 0;
      } else if (neighbours == 3) {
        out_board[i*m + j] = 1;
      } else if (alive && neighbours < 4) {
        out_board[i*m + j] = 1;
      } else {
        out_board[i*m + j] = 0;
      }
    }
  }
}

void life(int measure) {
  if (measure) {
    start_run();
  }

  int n = 1200, m = 1200;
  int iterations = 100;

  int8_t glider[] = { 0,0,0,0, 1,1,1,0, 1,0,0,0, 0,1,0,0 };

  int8_t *board = malloc(n*m*sizeof(int8_t));
  int8_t *tmp_board = malloc(n*m*sizeof(int8_t));

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      board[i*m + j] = glider[i%4*4 + j%4];
    }
  }

  for (int i = 0; i < iterations; i++) {
    iteration(n, m, board, tmp_board);

    /* Swap the pointers. */
    int8_t *tmp = board;
    board = tmp_board;
    tmp_board = tmp;
  }

  int sum = 0;
  for (int i = 0; i < n * m; i++) {
    sum += board[i];
  }

  if (measure) {
    end_run();
  }

  printf("Live cells: %d\n", sum);
}

int main(int argc, char **argv) {
  parse_args(argc, argv);

  life(0);

  for (int i = 0; i < runs; i++) {
    life(1);
  }
}
