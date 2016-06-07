#!/usr/bin/env python

import life
import numpy
import pygame
import argparse
import pyopencl as cl
import sys

parser = argparse.ArgumentParser(description='The Game of Life!')
parser.add_argument('--width', metavar='INT', type=int, default=800,
                    help='Width of the world')
parser.add_argument('--height', metavar='INT', type=int, default=600,
                    help='Height of the world')
parser.add_argument('--steps', metavar='INT', type=int, default=3,
                    help='Number of simulation steps to perform per frame')

args = parser.parse_args()

steps=args.steps
size=(args.width,args.height)
sizearr = numpy.array(size, dtype=numpy.int32)
world = numpy.random.choice([0, 1], size=(args.width*args.height)).astype(numpy.int32)
frame = numpy.zeros((args.width,args.height,3), dtype=numpy.byte)

screen = pygame.display.set_mode(size)
surface = pygame.Surface(size)

l = life.life()

def render(world):
    world = l.main(sizearr, world).get().reshape(args.width*args.height).astype(numpy.int32)

    frame[:,:,:] = 255
    frame[world.reshape((args.width,args.height))==1,:] = 0

    pygame.surfarray.blit_array(surface, frame)
    screen.blit(surface, (0, 0))
    pygame.display.flip()
    return world

while True:
    world = render(world)
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            sys.exit()
