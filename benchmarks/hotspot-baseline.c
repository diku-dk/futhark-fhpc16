#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include "common.h"

#define STR_SIZE	256

// Number of grid's rows
const int rows           = 512;

// Number of grid's columns
const int cols           = 512;

// Converhence-Loop Count
const int num_iterations = 360;


// Maximum power density possible (say 300W for a 10mm x 10mm chip)
const float max_pd = 3.0e6;

// Required precision in degrees
const float precision = 0.001;

const float spec_heat_si = 1.75e6;

const float k_si = 100.0;

// Capacitance fitting factor
const float factor_chip = 0.5;

// Chip parameters
const float t_chip = 0.0005;
const float chip_height = 0.016;
const float chip_width = 0.016;

// Ambient temperature assuming no package at all
const float amb_temp = 80.0;

void fatal(const char *s)
{
	fprintf(stderr, "error: %s\n", s);
	exit(1);
}

void read_input(float *vect, int grid_rows, int grid_cols, const char *file)
{
  	int i, index;
	FILE *fp;
	char str[STR_SIZE];
	float val;

	fp = fopen (file, "r");
	if (!fp)
		fatal ("file could not be opened for reading");

	for (i=0; i < grid_rows * grid_cols; i++) {
		char* dummy = fgets(str, STR_SIZE, fp);
		if (feof(fp))
			fatal("not enough lines in file");
		if ((sscanf(str, "%f", &val) != 1) )
			fatal("invalid file format");
		vect[i] = val;
        //printf("Val[%d] = %f", i, val);
	}

	fclose(fp);	
}

// Single iteration of the transient solver in the grid model.
// advances the solution of the discretized difference equations by
// one time step
void single_iteration( const float* temp 
                     , const float* power
                     , const float cap, const float rx, const float ry 
                     , const float rz, const float step
                     , float* res )
{
    int r, c;
    for(r=0; r<rows; r++) {
        for(c=0; c<cols; c++) {
            float acc;

            if ( (r == 0) && (c == 0) ) { // Corner 1
               acc = (temp[r*cols + c+1] - temp[r*cols + c]) / rx +
                     (temp[(r+1)*cols + c] - temp[r*cols + c]) / ry;
            } else if ( (r == 0) && (c == cols-1) ) { // Corner 2
               acc = (temp[r*cols + c-1] - temp[r*cols + c]) / rx +
                     (temp[(r+1)*cols + c] - temp[r*cols + c]) / ry;
            } else if ( (r == rows-1) && (c == cols-1) ) { // Corner 3
               acc = (temp[r*cols + c-1] - temp[r*cols + c]) / rx +
                     (temp[(r-1)*cols + c] - temp[r*cols + c]) / ry;
            } else if ( (r == rows-1) && (c == 0) ) { // Corner 4
               acc = (temp[r*cols + c+1] - temp[r*cols + c]) / rx +
                     (temp[(r-1)*cols + c] - temp[r*cols + c]) / ry;
            } else if (r == 0) { // Edge 1
               acc = (temp[r*cols + c+1] + temp[r*cols + c-1] - 
                     2.0*temp[r*cols + c]) / rx +
                     (temp[(r+1)*cols + c] - temp[r*cols + c]) / ry;
            } else if (c == cols-1) { // Edge 2
               acc = (temp[r*cols + c-1] - temp[r*cols + c]) / rx +
                     (temp[(r+1)*cols + c] + temp[(r-1)*cols + c] - 
                     2.0*temp[r*cols + c]) / ry;
            } else if (r == rows-1) { // Edge 3
               acc = (temp[r*cols + c+1] + temp[r*cols + c-1] - 
                     2.0*temp[r*cols + c]) / rx +
                     (temp[(r-1)*cols  + c] - temp[r*cols + c]) / ry;
            } else if (c == 0) { // Edge 4
               acc = (temp[r*cols + c+1] - temp[r*cols + c]) / rx +
                     (temp[(r+1)*cols + c] + temp[(r-1)*cols + c] - 
                     2.0*temp[r*cols + c]) / ry;
            } else {
               acc = (temp[r*cols + c+1] + temp[r*cols + c-1] - 
                     2.0 * temp[r*cols + c]) / rx +
                     (temp[(r+1)*cols + c] + temp[(r-1)*cols + c] - 
                     2.0 * temp[r*cols + c]) / ry;
            }
            acc += (amb_temp - temp[r*cols + c]) / rz;
            res[r*cols + c] = temp[r*cols+c] + (step / cap) * ( power[r*cols+c] + acc );
        }
    }
}

// Transient solver driver routine: simply converts the heat transfer
// differential equations to difference equations and solves the
// difference equations by iterating.
//
// Returns a new 'temp' array.
float* compute_tran_temp( const float* ptemp, const float* power ) {
  float* res  = (float*)malloc(rows*cols*sizeof(float));
  float* temp = (float*)malloc(rows*cols*sizeof(float));
  float grid_height = chip_height / rows;
  float grid_width  = chip_width  / cols;
  float cap = factor_chip * spec_heat_si * t_chip * grid_width * grid_height;
  float rx = grid_width / (2.0 * k_si * t_chip * grid_height);
  float ry = grid_height / (2.0 * k_si * t_chip * grid_width);
  float rz = t_chip / (k_si * grid_height * grid_width);
  float max_slope = max_pd / (factor_chip * t_chip * spec_heat_si);
  float step = precision / max_slope;
  int i; float* tmptmp;

  memcpy(temp, ptemp, cols*rows*sizeof(float));

  for(i=0; i<num_iterations; i++) {
    single_iteration(temp, power, cap, rx, ry, rz, step, res);
    tmptmp = temp;
    temp = res;
    res = tmptmp;
  }
  free(res);
  return temp;
}

void bench(int bench, float *temp, float *power) {
  if (bench) {
    start_run();
  }
  float* res = compute_tran_temp(temp, power);

  float max_el = 1000.0;
  for (int i=0; i<rows*cols; i++) {
    float cur_el = res[i];
    if(max_el < cur_el) max_el = cur_el;
  }
  if (bench) {
    end_run();
  }
  free(res);
  printf("Max Element: %f\n", max_el);
}

int main(int argc, char **argv) {
  float* temp  = (float*)malloc(rows*cols*sizeof(float));
  float* power = (float*)malloc(rows*cols*sizeof(float));

  read_input(temp , rows, cols, "temp_512" );
  read_input(power, rows, cols, "power_512");

  parse_args(argc, argv);

  bench(0, temp, power);

  for (int i = 0; i < runs; i++) {
    bench(1, temp, power);
  }

  free(temp);
  free(power);
}

