export PATH := tools:${PATH}

CFLAGS=-O3 -lm -std=c99
TAIL_CFLAGS=${CFLAGS} -I ${TAIL_ROOT}/include
TAIL_PRELUDE=${TAIL_ROOT}/lib/prelude.apl
RUNS=30 # Note: hardcoded in APL programs.

COMPILERS=tail futhark-c futhark-opencl
BENCHMARKS=signal easter funintegral life blackscholes sobol-pi hotspot mandelbrot1 mandelbrot2

ifndef TAIL_ROOT
$(error TAIL_ROOT is not set)
endif

.PHONY: clean benchmark_hotspot

all: $(BENCHMARKS:%=benchmark_%) plot.png

plot.pdf: $(BENCHMARKS:%=benchmark_%)
	python tools/plot.py $@ $(BENCHMARKS)

benchmark_mandelbrot1: runtimes/mandelbrot1-futhark-c.avgtime runtimes/mandelbrot1-futhark-opencl.avgtime runtimes/mandelbrot1-byhand-futhark-c.avgtime runtimes/mandelbrot1-byhand-futhark-opencl.avgtime

benchmark_mandelbrot2: runtimes/mandelbrot2-futhark-c.avgtime runtimes/mandelbrot2-futhark-opencl.avgtime runtimes/mandelbrot2-byhand-futhark-c.avgtime runtimes/mandelbrot2-byhand-futhark-opencl.avgtime

$(BENCHMARKS:%=benchmark_%): benchmark_%: runtimes/%-tail.avgtime runtimes/%-futhark-c.avgtime runtimes/%-futhark-opencl.avgtime runtimes/%-byhand-futhark-c.avgtime runtimes/%-byhand-futhark-opencl.avgtime

runtimes/%-tail.avgtime: compiled/%-tail
	mkdir -p runtimes
	(cd input && ../compiled/$*-tail) | grep AVGTIMING | awk '{print $$2}' > $@

runtimes/%.avgtime: runtimes/%.runtimes
	mkdir -p runtimes
	awk '{sum += strtonum($$0) / 1000.0} END{print sum/NR}' < $< > $@

# Fallback rules for missing implementations
runtimes/blackscholes-byhand-futhark-c.avgtime:
	echo 0 > $@
runtimes/blackscholes-byhand-futhark-opencl.avgtime:
	echo 0 > $@
runtimes/mandelbrot1-tail.avgtime:
	echo 0 > $@
runtimes/mandelbrot2-tail.avgtime:
	echo 0 > $@

runtimes/%-futhark-c.runtimes: compiled/%-futhark-c
	mkdir -p runtimes
	futinput $* | compiled/$*-futhark-c -r ${RUNS} -t $@ > /dev/null

runtimes/%-futhark-opencl.runtimes: compiled/%-futhark-opencl
	mkdir -p runtimes
	futinput $* | compiled/$*-futhark-opencl -r ${RUNS} -t $@ > /dev/null

compiled/%-tail: benchmarks/%.apl
	mkdir -p compiled
	aplt -unsafe -c -O 2 -oc compiled/$*-tail.c  ${TAIL_PRELUDE} $<
	gcc -o $@ -O3 compiled/$*-tail.c ${TAIL_CFLAGS}

compiled/%-futhark-c: compiled/%.fut
	mkdir -p compiled
	futhark-c $< -o $@

compiled/%-futhark-opencl: compiled/%.fut
	mkdir -p compiled
	futhark-opencl $< -o $@

compiled/%-byhand-futhark-c: benchmarks/%-byhand.fut
	mkdir -p compiled
	futhark-c $< -o $@

compiled/%-byhand-futhark-opencl: benchmarks/%-byhand.fut
	mkdir -p compiled
	futhark-opencl $< -o $@

compiled/%.fut: compiled/%.tail
	mkdir -p compiled
	tail2futhark --float-as-single $< > $@

compiled/%.tail: benchmarks/%.apl
	mkdir -p compiled
	aplt  -p_types -s_tail -c -o $@ ${TAIL_PRELUDE} $<

clean:
	rm -rf runtimes
	rm -rf compiled
	rm -f plot.pdf
