Empirical evaluation code and demos for our FHPC'16 paper
=========================================================

Benchmarks are in `benchmarks`, demos in `demos`.

To run these programs you must have:

1. [the Futhark compiler](https://github.com/HIPERFIT/futhark)
    `futhark-opencl` must be in your `$PATH`,

2. [the `apltail` compiler](https://github.com/melsman/apltail/)

3. [the Tail-to-Futhark compiler]
   https://github.com/henrikurms/tail2futhark
   `tail2futhark` must be in you `$PATH`
   For example, after cloning the repository you can install it by
   $ stack setup
   $ stack install

4. a working OpenCL setup.

You will need a *nix-like system.  OpenCL execution will by
default use the first detected platform and device.  You can edit the
`Makefile` to select a different platform and device.

The benchmark system is built using `make` (sorry).  Ideally, you just
run `make` and it will build and run all benchmarks.  The result will
be a speedup graph in a file called `plot.pdf`, and a runtime table in
a file `table.tex`.  There will also be a directory called `runtimes/`
that contains files with runtime measurements (in miliseconds).

Of course, many things can go wrong.  You may need to modify the
`Makefile` to fix include paths and the like to fit your system.

Problems
--

If you are on a 64-bit system, then you are adviced to compile
`apltail` with MLton, not MLKit.

You must set the `TAIL_ROOT` environment variable to point at a local
clone of the [apltail repository](https://github.com/melsman/apltail).
This is so `aplt` can find the TAIL prelude.
