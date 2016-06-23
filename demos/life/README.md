Game of Life in APL, with Pygame frontend
=========================================

Execute `make run` to build and run the demo with default settings.
By default, the game world will be populated randomly.  The simulation
runs in a busy loop as quickly as possible.  Each pixel corresponds to
one cell.  Some interaction is permitted:

  * Press `p` to pause the simulation.  Press `p` again to resume.
  * When paused, press `space` to run `--steps` steps of the simulation (see below).
  * Left-click anywhere to insert random cells.
  * Right-click anywhere to insert a copy of the original `--pattern` option (see below).

  You can also run `python life-gui.py` followed by a range
of command line options customising the behaviour:

| Option | Meaning |
| --- | --- |
| `--width INT` | Set the width of the world in cells. |
| `--height INT` | Set the height of the world in cells. |
| `--scale INT` | The number of pixels in height and width that each cell should take up. |
| `--steps INT` | The number of simulation steps to run between each frame.  Essentially, this is a crude speed setting. |
| `--paused` | Start the simulation paused |
| `--pattern FILE` | Initialise the world with the pattern described in FILE, which must be in [Life RLE](http://www.conwaylife.com/wiki/Run_Length_Encoded) format.  The pattern will be inserted in the upper-left part of the world. |
| `--pick-device` | Interactively query for the OpenCL device to use.  This option is passed by default by `make run`. |
