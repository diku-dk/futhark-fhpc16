#!/usr/bin/env python

import mandelbrot
import numpy
import pygame
import argparse
import pyopencl as cl
import sys
import time

parser = argparse.ArgumentParser(description='Mandelbrot')
parser.add_argument('--width', metavar='INT', type=int, default=1200,
                    help='Width of the window')
parser.add_argument('--height', metavar='INT', type=int, default=800,
                    help='Height of the window')

args = parser.parse_args()

width = args.width
height = args.height
size=(width,height)
sizearr = numpy.array(size, dtype=numpy.int32)
minx=-2.0
miny=-0.75
maxx=0.75
maxy=0.75
limit=255
frame = numpy.zeros((width,height,3), dtype=numpy.byte)

pygame.init()
pygame.display.set_caption('Mandelbrot APL demo')
screen = pygame.display.set_mode(size)
surface = pygame.Surface(size)
font = pygame.font.Font(None, 36)
pygame.key.set_repeat(1, 1)

l = mandelbrot.mandelbrot()

def showText(what, where):
    text = font.render(what, 1, (255, 255, 255))
    screen.blit(text, where)

def render():
    fieldarr = numpy.array([miny, maxy, minx, maxx], dtype=numpy.float32)
    limitarr = numpy.array([limit], dtype=numpy.int)
    start = time.time()
    reds, greens, blues = l.main(sizearr, fieldarr, limitarr)
    frame[:,:,0] = reds.get()
    frame[:,:,1] = greens.get()
    frame[:,:,2] = blues.get()
    end = time.time()

    pygame.surfarray.blit_array(surface, frame)
    screen.blit(surface, (0, 0))

    infomessage = "Region: (%f,%f) to (%f,%f)    Rendering limit: %d" % (minx, miny, maxx, maxy, limit)
    showText(infomessage, (10,10))
    speedmessage = "APL call took %.2fms (including copy-back)" % ((end-start)*1000,)
    showText(speedmessage, (10, 40))

    pygame.display.flip()

def moveLeft():
    global minx, maxx
    x_dist = abs(maxx-minx)
    minx -= x_dist * 0.01
    maxx -= x_dist * 0.01

def moveRight():
    global minx, maxx
    x_dist = abs(maxx-minx)
    minx += x_dist * 0.01
    maxx += x_dist * 0.01

def moveUp():
    global miny, maxy
    y_dist = abs(maxy-miny)
    miny -= y_dist * 0.01
    maxy -= y_dist * 0.01

def moveDown():
    global miny, maxy
    y_dist = abs(maxy-miny)
    miny += y_dist * 0.01
    maxy += y_dist * 0.01

def zoomIn():
    global minx, maxx, miny, maxy
    x_dist = abs(maxx-minx)
    y_dist = abs(maxy-miny)
    minx += x_dist * 0.01
    maxx -= x_dist * 0.01
    miny += y_dist * 0.01
    maxy -= y_dist * 0.01

def zoomOut():
    global minx, maxx, miny, maxy
    x_dist = abs(maxx-minx)
    y_dist = abs(maxy-miny)
    minx -= x_dist * 0.01
    maxx += x_dist * 0.01
    miny -= y_dist * 0.01
    maxy += y_dist * 0.01

def zoomTo(pos, factor):
    global minx, maxx, miny, maxy
    pos_x, pos_y = pos
    rel_x = float(pos_x) / float(width)
    rel_y = float(pos_y) / float(height)
    x_span = maxx - minx
    y_span = maxy - miny
    x = minx + x_span * rel_x
    y = miny + y_span * rel_y

    minx = x - factor * x_span
    maxx = x + factor * x_span
    miny = y - factor * y_span
    maxy = y + factor * y_span

while True:
    render()
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            sys.exit()
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_RIGHT:
                moveRight()
            if event.key == pygame.K_LEFT:
                moveLeft()
            if event.key == pygame.K_UP:
                moveUp()
            if event.key == pygame.K_DOWN:
                moveDown()
            if event.unicode == 'q':
                limit -= 1
            if event.unicode == 'w':
                limit += 1
            if event.unicode == '+':
                zoomIn()
            if event.unicode == '-':
                zoomOut()
        elif event.type == pygame.MOUSEBUTTONDOWN:
            if pygame.mouse.get_pressed()[0]:
                zoomTo(pygame.mouse.get_pos(), 0.25)
            if pygame.mouse.get_pressed()[2]:
                zoomTo(pygame.mouse.get_pos(), 1.25)
