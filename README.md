Empirical evaluation code and demos for our FHPC'16 paper
=========================================================

Benchmarks are in `benchmarks`, demos in `demos`.

To run these programs you must have [the Futhark
compiler](https://github.com/HIPERFIT/futhark) (`futhark-opencl` must
be in your `$PATH`), [the `apltail`
compiler](https://github.com/melsman/apltail/) and a working OpenCL
setup.  You will need a *nix-like system.  OpenCL execution will by
default use the first detected platform and device.

The benchmark system is built using `make` (sorry).  Ideally, you just
run `make` and it will build and run all benchmarks.  The result will
be a speedup graph in a file called `plot.pdf`, and a runtime table in
a file `graph.tex`.  There will also be a directory called `runtimes/`
that contains files with runtime measurements (in miliseconds).

Of course, many things can go wrong.  You may need to modify the
`Makefile` to fix include paths and the like to fit your system.

Problems
--

If you are on a 64-bit system, then you are adviced to compile
`apltail` with MLton, not MLKit.
