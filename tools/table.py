#!/usr/bin/env python

import sys
import os

variants = ['tail', 'futhark-c', 'futhark-opencl', 'byhand-futhark-c', 'byhand-futhark-opencl']
programs = {'funintegral'
            : {'name': 'Integral',
               'size': '$N = 10,000,000$'},
            'signal'
            : {'name': 'Signal',
               'size': '$N = 50,000,000$'},
            'life'
            : {'name': 'Game of Life',
               'size': r'''$1200 \times 1200, N = 100$'''},
            'easter'
            : {'name': 'Easter',
               'size': '$N = 10,000,000$'},
            'blackscholes'
            : {'name': 'Black-Scholes',
               'size': '$N = 10,000,000$'},
            'sobol-pi'
            : {r'name': 'Sobol MC-$\pi$',
               'size': '$N = 10,000,000$'},
            'hotspot'
            : {r'name': 'HotSpot',
               'size': r'''$512 \times 512, N = 360$'''},
            'mandelbrot1'
            : { 'name': 'Mandelbrot1',
                'size': r'''$1000 \times 1000, N = 255$'''},
            'mandelbrot2'
            : { 'name': 'Mandelbrot2',
                'size': r'''$1000 \times 1000, N = 255$'''}
            }
order = ['funintegral', 'signal', 'life', 'easter', 'blackscholes', 'sobol-pi', 'hotspot', 'mandelbrot1', 'mandelbrot2']

runtimes = {}
for program in programs:
    runtimes[program] = {}
    for variant in variants:
        with open(os.path.join('runtimes', program + '-' + variant + ".avgtime")) as f:
            runtime = float(f.read())
            runtimes[program][variant] = '-' if runtime == 0 else '%.2f' % runtime

print(r'''
\begin{tabular}{llrrrrr}
& & & \multicolumn{2}{c}{\textbf{TAIL Futhark}} & \multicolumn{2}{c}{\textbf{Hand-written Futhark}} \\
\textbf{Benchmark} & \textbf{Problem size} & \textbf{TAIL C} & \textbf{Sequential} & \textbf{Parallel} & \textbf{Sequential} & \textbf{Parallel} \\''')

for program in order:

    print(programs[program]['name'] + ' & ' +
          programs[program]['size'] + ' & ' +
          ' & '.join(runtimes[program].values()) + r''' \\''')

print(r'''\end{tabular}''')
