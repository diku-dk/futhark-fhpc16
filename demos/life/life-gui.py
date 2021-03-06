#!/usr/bin/env python

import life
import numpy
import pygame
import argparse
import pyopencl as cl
import sys

# Modified from https://github.com/wordaligned/game-of-life/blob/master/conways-game-of-life.py
def run_length_decode(rle):
    ''' Expand the series of run-length encoded characters.
    '''
    run = ''
    for c in rle:
        if c in '0123456789':
            run += c
        else:
            run = int(run or 1)          # if the run isn't explicitly coded, it has length 1
            v = c if c in 'bo$' else 'b' # treat unexpected cells as dead ('b')
            for _ in range(run):
                yield v
            run = ''

def expand_rle(rle_file_name):
    ''' Expand a run-length encoded pattern.
    Returns the pattern cells. http://www.conwaylife.com/wiki/RLE
    '''
    lines = open(rle_file_name).read().splitlines()
    if lines[0].startswith('#N '):
        name = lines[0][3:]
    else:
        name = rle
    lines = [L for L in lines if not L.startswith('#')]
    header = lines[0]
    xv, yv = header.split(',')[:2]
    x = int(xv.partition('=')[2])
    y = int(yv.partition('=')[2])
    pattern = [[0 for i in range(x)] for j in range(y)]
    body = ''.join(lines[1:])
    body = body[:body.index('!')].lower() # '!' terminates the body
    i, j = 0, 0
    for c in run_length_decode(body):
        if c == '$':
            i, j = i+1, 0
        else:
            if c == 'o':
                pattern[i][j] = 1
            j += 1
    return pattern

parser = argparse.ArgumentParser(description='The Game of Life!')
parser.add_argument('--width', metavar='INT', type=int, default=800,
                    help='Width of the world')
parser.add_argument('--height', metavar='INT', type=int, default=600,
                    help='Height of the world')
parser.add_argument('--steps', metavar='INT', type=int, default=3,
                    help='Number of simulation steps to perform per frame')
parser.add_argument('--scale', metavar='INT', type=int, default=1,
                    help='Number of pixels per cell')
parser.add_argument('--paused', help='Start the simulation paused', action='store_true')
parser.add_argument('--pattern', metavar='FILE', default=None,
                    help='File containing an RLE-encoded pattern')
parser.add_argument('--pick-device', action='store_true',
                    help='Ask at startup for the OpenCL device to use')

args = parser.parse_args()
paused = args.paused
width = args.width
height = args.height
steps=args.steps
scale=args.scale
size=(width,height)
framesize=(width*scale, height*scale)
stepsarr = numpy.array([steps], dtype=numpy.int32)
sizearr = numpy.array(size, dtype=numpy.int32)
frame = numpy.zeros((width*scale,height*scale,3), dtype=numpy.byte)
world = numpy.zeros(size, dtype=numpy.int32)

if args.pattern:
    pattern_cells = numpy.array(expand_rle(args.pattern), dtype=numpy.int32).copy()

    world[:pattern_cells.shape[0], :pattern_cells.shape[1]] = pattern_cells
else:
    pattern_cells = numpy.empty((0,0), dtype=numpy.int32)
    world[:,:] = numpy.random.choice([0, 1], size=size)

l = life.life(interactive=args.pick_device)

screen = pygame.display.set_mode(framesize)
surface = pygame.Surface(framesize)

def render(paused, world):
    if not paused:
        world = l.main(stepsarr, sizearr, world.reshape(width*height)).get().astype(numpy.int32)
    world_expanded = numpy.repeat(numpy.repeat(world, scale, axis=0), scale, axis=1)

    frame[:,:,:] = 255
    frame[world_expanded==1,:] = 0

    pygame.surfarray.blit_array(surface, frame)
    screen.blit(surface, (0, 0))
    pygame.display.flip()
    return world

steps = -1
while True:
    if steps == 0:
        paused = True
    if steps > 0:
        steps -= 1
    world = render(paused, world)
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            sys.exit()
        elif event.type == pygame.KEYDOWN:
            if event.unicode == 'p':
                paused = not paused
                steps = -1
            if event.unicode == ' ':
                if paused:
                    paused = False
                    steps = 1
                else:
                    paused = True
        elif pygame.mouse.get_pressed()[0]:
            try:
                (x,y) = pygame.mouse.get_pos()
                i = int(x / scale)
                j = int(y / scale)
                n = 5
                world[i:i+n,j:j+n] = numpy.random.choice([0,1], size=(n,n)).astype(numpy.int32)
            except AttributeError:
                pass
        elif pygame.mouse.get_pressed()[2]:
            try:
                (x,y) = pygame.mouse.get_pos()
                i = int(x / scale)
                j = int(y / scale)
                n, m = pattern_cells.shape
                world[i:i+n,j:j+m] = pattern_cells
            except AttributeError:
                pass


