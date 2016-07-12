-- A Mandelbrot-implementation written by hand.  The sequential loop
-- inside the map nest.

default(f32)

type complex = (f32, f32)

fun f32 dot(complex c) =
  let (r, i) = c in
  r * r + i * i

fun complex multComplex(complex x, complex y) =
  let (a, b) = x in
  let (c, d) = y in
  (a*c - b * d,
   a*d + b * c)

fun complex addComplex(complex x, complex y) =
  let (a, b) = x in
  let (c, d) = y in
  (a + c,
   b + d)

fun int divergence(int depth, complex c0) =
  loop ((c, j) = (c0, 0)) = for i < depth do
    (addComplex(c0, multComplex(c, c)),
     j + if dot(c) < 4.0 then 1 else 0) in
  j

fun [screenY][screenX]int mandelbrot(int screenX, int screenY, int depth, (f32,f32,f32,f32) view) =
  let (xmin, ymin, xmax, ymax) = view in
  let sizex = xmax - xmin in
  let sizey = ymax - ymin in
  map(fn [screenX]int (int y) =>
        map (fn int (int x) =>
               let c0 = (xmin + (f32(x) * sizex) / f32(screenX),
                         ymin + (f32(y) * sizey) / f32(screenY)) in
               divergence(depth, c0)
            , iota(screenX)),
        iota(screenY))

fun f32 main() =
  let depth = 255
  let screenX = 1000
  let screenY = 1000
  let view = (-2.0, -0.75, 0.75, 0.75)
  let escapes = mandelbrot(screenX, screenY, depth, view)
  in reduce(+, 0.0, reshape((1000*1000),
                            map(fn [screenX]f32 ([]int row) =>
                                  map(/f32(depth), map(f32, row)),
                                escapes)))
