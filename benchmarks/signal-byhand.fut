
--diff ← {1↓⍵−¯1⌽⍵}
--signal ← {¯50⌈50⌊50×(diff 0,⍵)÷0.01+⍵}
--test ← {
--  ⍵
--  input ← {{1○⍵}¨ (⍳ ⍵) ÷ ⍵ ÷ 10}
--  +/ signal input 10000000
--}
-- (test bench 30) 0

import "/futlib/math"
default (f32)

let diff [n] (x: [n]f32): [n]f32 =
  map(\  (i: i32): f32  ->
        let xip1 = if i == n-1 then x[0] else unsafe x[i+1]
        in  (x[i] - xip1))
     (iota n)

let signal [n] (x: [n]f32): [n]f32 =
  let ds0 = diff(x) in
  let ds1 = map (\  (d: f32, xx: f32): f32  -> d / (xx+0.01f32))
                (zip ds0 x)
  in
  let ds2 = map (*50.0f32) ds1 in
  map(\  (x: f32): f32  ->
            if x < -50.0f32 then -50.0f32
            else if x > 50.0f32 then 50.0f32
                                else x)
     ds2

let input(x: i32): [x]f32 =
  let fx = f32(x) in
  let fy = fx / 10.0f32 in
  map f32.sin (map (/fy) (map f32 (iota x)))

let main(): f32 =
  reduce (+) 0.0f32 (signal(input 10000000))
