ifndef TAIL_ROOT
$(error TAIL_ROOT is not set)
endif

TAIL_PRELUDE=${TAIL_ROOT}/lib/prelude.apl

.PHONY: clean all run

all: life.py

run: all
	python life-gui.py --pick-device

life.py: life.fut
	futhark-pyopencl --library life.fut

life.fut: life.tail
	tail2futhark life.tail > life.fut

life.tail: life.apl
	aplt  -p_types -p_tail -c -o $@ ${TAIL_PRELUDE} $<

clean:
	rm -f life.py life.fut life.tail *.pyc
