Mandelbrot set explorer in APL, with Pygame frontend
====================================================

Execute `make run` to build and run the demo with default settings.
The visualisation uses single-precision floating point (due to most
consumer GPUs only supporting this with any real efficiency), which
means that you will fairly quickly encounter artifacts at close zoom
levels.

The following interaction is permitted:

  * Use the arrow keys to move around.
  * Use the `+` and `-` keys to smoothly scroll in and out.
  * Left-click the mouse to zoom to a specific location; right-click to zoom out.
  * Use `w` to increase the iteration bound on the convergence loop; `q` to decrease it.

  You can also run `python mandelbrot-gui.py` followed by a range
of command line options customising the behaviour:

| Option | Meaning |
| --- | --- |
| `--width INT` | The width of the window in pixels. |
| `--height INT` | The height of the window in pixels. |
| `--pick-device` | Interactively query for the OpenCL device to use.  This option is passed by default by `make run`. |
