#include<stdio.h>
#include <math.h>

const float pi = 3.141592653589793;
const float a[5] = {0.31938153, -0.356563782, 1.781477937, -1.821255978, 1.330274429};
static const int K  = sizeof(a)/sizeof(a[0]);

// S - current price
const float s = 60.0;

// X - strike price
const float x = 65.0;

// T - expiry in years
const float t = 1.0;

// r - riskless interest rate
const float r = 0.1;

// v - volatility
const float v = 0.2;

const int n = 1000000;
const int years = 10;


float sign(float x) {
  return (x > 0.0) ? 1.0 : (x < 0.0) ? -1.0 : 0.0;
}

float min(float x, float y) { 
  return (x <= y) ? x : y; 
}

float cnd(float x) {
  float t1, t2, t3, w;
  int i = 0; 
  float l = fabs(x);
  float k = 1.0 / (1.0 + 0.2316419*l);

  float acc = 0.0;
  for(i=0; i<K; i++) {
    acc += a[i]*pow(k,i+1);
  }

  t1 = exp( - (l*l / 2.0) );
  t2= 1.0/sqrt( 2.0 * pi );
  w = 1.0 - t2 * t1 * acc;
  
  t3 = min(0.0, sign(x));
  return t3*(1.0-w) + (1.0-t3)*w;
}

float d1(float w) { 
  float t1, t2, t3;
  t1 = v * sqrt(w);
  t2 = (r + pow(v , 2.0) / 2.0) * w;
  t3 = log(s / x);
  return (t3 + t2) / t1;
}

float d2(float w) { 
  return d1(w) - v*sqrt(w);
}

// Call price
float callPrice(float w) {
  float t1 = x * exp(-r*w) * cnd(d2(w));
  return (s * cnd( d1(w) ) - t1);
}

float price(int w) {
  int i;
  int nn = w*years;
  float avg = 0.0;
  for(i=1; i<=nn; i++) {
    float t = ((float)i) / w;
    avg += callPrice(t);
  }
  return ( avg / nn ); 
}

int main() {
  float res = price(n);
  printf("Price is: %f\n", res);
}

