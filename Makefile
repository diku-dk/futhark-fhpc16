export PATH := tools:${PATH}

CFLAGS=-O3 -lm -std=c99
TAIL_CFLAGS=${CFLAGS} -I ${TAIL_ROOT}/include
TAIL_PRELUDE=${TAIL_ROOT}/lib/prelude.apl
RUNS=30 # Note: hardcoded in APL programs.

BENCHMARKS=signal easter integral life blackscholes sobol-pi hotspot mandelbrot1 mandelbrot2

# OpenCL configuration.  Leave blank for default.
OPENCL_PLATFORM=
OPENCL_DEVICE=

ifndef TAIL_ROOT
$(error TAIL_ROOT is not set)
endif

.PHONY: clean benchmark_hotspot

all: $(BENCHMARKS:%=benchmark_%) plot.pdf table.tex

plot.pdf: $(BENCHMARKS:%=benchmark_%)
	python tools/plot.py $@ $(BENCHMARKS)

table.tex: $(BENCHMARKS:%=benchmark_%)
	python tools/table.py > $@

$(BENCHMARKS:%=benchmark_%): benchmark_%: runtimes/%-tail.avgtime runtimes/%-futhark-c.avgtime runtimes/%-futhark-opencl.avgtime runtimes/%-futhark-pyopencl.avgtime runtimes/%-byhand-futhark-c.avgtime runtimes/%-byhand-futhark-opencl.avgtime runtimes/%-byhand-futhark-pyopencl.avgtime runtimes/%-baseline.avgtime

runtimes/%-tail.avgtime: compiled/%-tail
	mkdir -p runtimes
	(cd input && ../compiled/$*-tail) | grep AVGTIMING | gawk '{print $$2}' > $@

runtimes/%.avgtime: runtimes/%.runtimes
	mkdir -p runtimes
	gawk '{sum += strtonum($$0) / 1000.0} END{print sum/NR}' < $< > $@

# Fallback rules for missing implementations
runtimes/mandelbrot1-tail.avgtime:
	echo 0 > $@
runtimes/mandelbrot2-tail.avgtime:
	echo 0 > $@

runtimes/%-futhark-c.runtimes: compiled/%-futhark-c
	mkdir -p runtimes
	futinput $* | compiled/$*-futhark-c -r ${RUNS} -t $@ > /dev/null

runtimes/%-futhark-opencl.runtimes: compiled/%-futhark-opencl
	mkdir -p runtimes
	futinput $* | compiled/$*-futhark-opencl -p "${OPENCL_PLATFORM}" -d "${OPENCL_DEVICE}" -r ${RUNS} -t $@ > /dev/null

runtimes/%-futhark-pyopencl.runtimes: compiled/%-futhark-pyopencl
	mkdir -p runtimes
	futinput $* | compiled/$*-futhark-pyopencl -p "${OPENCL_PLATFORM}" -d "${OPENCL_DEVICE}" -r ${RUNS} -t $@ > /dev/null

runtimes/%-baseline.runtimes: compiled/%-baseline
	mkdir -p runtimes
	(cd input && ../compiled/$*-baseline -r ${RUNS} -t ../$@) > /dev/null

compiled/%-baseline: benchmarks/%-baseline.c
	mkdir -p compiled
	gcc -o $@ -O3 -lm -Wall -Wextra -std=c99 $<

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

compiled/%-futhark-pyopencl: compiled/%.fut
	mkdir -p compiled
	futhark-pyopencl $< -o $@

compiled/%-byhand-futhark-c: benchmarks/%-byhand.fut
	mkdir -p compiled
	futhark-c $< -o $@

compiled/%-byhand-futhark-opencl: benchmarks/%-byhand.fut
	mkdir -p compiled
	futhark-opencl $< -o $@

compiled/%-byhand-futhark-pyopencl: benchmarks/%-byhand.fut
	mkdir -p compiled
	futhark-pyopencl $< -o $@

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
	rm -f table.tex
