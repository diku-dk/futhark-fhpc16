-- A Mandelbrot-implementation written by hand.  The sequential loop
-- inside the map nest.

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

let divergence(depth: i32, c0: complex): i32 =
  let (_,j) =
    loop (c, j) = (c0, 0) for i < depth do
      (addComplex(c0, multComplex(c, c)),
       j + if dot(c) < 4.0 then 1 else 0) in
  in j

let mandelbrot(screenX: i32, screenY: i32, depth: i32, view: (f32,f32,f32,f32)): [screenY][screenX]i32 =
  let (xmin, ymin, xmax, ymax) = view in
  let sizex = xmax - xmin in
  let sizey = ymax - ymin in
  map (\  (y: i32): [screenX]i32  ->
        map  (\  (x: i32): i32  ->
               let c0 = (xmin + (f32(x) * sizex) / f32(screenX),
                         ymin + (f32(y) * sizey) / f32(screenY)) in
               divergence(depth, c0)
            ) (iota(screenX))) (
        iota(screenY))

let main(): f32 =
  let depth = 255
  let screenX = 1000
  let screenY = 1000
  let view = (-2.0, -0.75, 0.75, 0.75)
  let escapes = mandelbrot(screenX, screenY, depth, view)
  in reduce (+) (0.0) (reshape(1000*1000)
                            (map (\  (row: []i32): [screenX]f32  ->
                                  map (/f32(depth)) (map f32 row)) escapes))
