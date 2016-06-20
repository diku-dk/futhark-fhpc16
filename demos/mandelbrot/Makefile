ifndef TAIL_ROOT
$(error TAIL_ROOT is not set)
endif

TAIL_PRELUDE=${TAIL_ROOT}/lib/prelude.apl

.PHONY: clean all run

all: mandelbrot.py

run: all
	python mandelbrot-gui.py --pick-device

mandelbrot.py: mandelbrot.fut
	futhark-pyopencl --library mandelbrot.fut

mandelbrot.fut: mandelbrot.tail
	tail2futhark --float-as-single mandelbrot.tail > mandelbrot.fut

mandelbrot.tail: mandelbrot.apl
	aplt  -p_types -s_tail -c -o $@ ${TAIL_PRELUDE} $<

clean:
	rm -f mandelbrot.py mandelbrot.fut mandelbrot.tail *.pyc
