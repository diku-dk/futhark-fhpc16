-- A Mandelbrot-implementation written by hand.  The sequential loop
-- is outside the map nest.

import "/futlib/math"

default(f32)

type complex = (f32, f32)

let dot(c: complex): f32 =
  let (r, i) = c in
  r * r + i * i

let multComplex(x: complex, y: complex): complex =
  let (a, b) = x in
  let (c, d) = y in
  (a*c - b * d,
   a*d + b * c)

let addComplex(x: complex, y: complex): complex =
  let (a, b) = x in
  let (c, d) = y in
  (a + c,
   b + d)

let mandelbrot(screenX: i32, screenY: i32, depth: i32, view: (f32,f32,f32,f32)): [screenY][screenX]i32 =
  let (xmin, ymin, xmax, ymax) = view
  let sizex = xmax - xmin
  let sizey = ymax - ymin
  let c0s = reshape (screenX*screenY)
                    (map (\  (y: i32): [screenX]complex  ->
                          map  (\  (x: i32): complex  ->
                                 (xmin + (f32(x) * sizex) / f32(screenX),
                                  ymin + (f32(y) * sizey) / f32(screenY))) (
                               iota(screenX))) (iota(screenY)))
  let escapes = replicate (screenY*screenX) 0
  let (_, esc) =
    loop (cs, escapes) = (c0s, escapes) for i < depth do
      unzip(map (\  (c0: complex) (c: complex) (j: i32): (complex, i32)  ->
                      (addComplex(c0, multComplex(c, c)),
                       j + if dot(c) < 4.0 then 1 else 0)) c0s cs escapes)
  in reshape (screenX,screenY) esc

let main(): f32 =
  let depth = 255
  let screenX = 1000
  let screenY = 1000
  let view = (-2.0, -0.75, 0.75, 0.75)
  let escapes = mandelbrot(screenX, screenY, depth, view)
  in reduce (+) (0.0) (reshape (1000*1000)
                            (map (\  (row: []i32): [screenX]f32  ->
                                    map (/f32(depth)) (map f32 row)) escapes))
