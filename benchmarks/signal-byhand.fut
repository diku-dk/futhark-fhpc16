
--diff ← {1↓⍵−¯1⌽⍵}
--signal ← {¯50⌈50⌊50×(diff 0,⍵)÷0.01+⍵}
--test ← {
--  ⍵
--  input ← {{1○⍵}¨ (⍳ ⍵) ÷ ⍵ ÷ 10}
--  +/ signal input 10000000
--}
-- (test bench 30) 0

fun [f32,n] diff ([f32,n] x) =  -- probably the BUG is here in "rotate"
  map(fn f32 (int i) =>
        let xip1 = if i == n-1 then x[0] else unsafe x[i+1] 
        in  (x[i] - xip1)
     , iota(n))

fun [f32,n] signal([f32,n] x) = 
  let ds0 = diff(x) in
  let ds1 = map ( fn f32 (f32 d, f32 xx) => d / (xx+0.01f32)
                , zip(ds0, x) ) 
  in
  let ds2 = map ( *50.0f32, ds1 ) in
  map(fn f32 (f32 x) =>
            if x < -50.0f32 then -50.0f32
            else if x > 50.0f32 then 50.0f32
                                else x
     , ds2)

fun [f32,x] input(int x) = 
  let fx = f32(x) in
  let fy = fx / 10.0f32 in
  map(sin32, map(/fy, map(f32, iota(x)) ) )

fun f32 main() = 
  reduce(+, 0.0f32, signal( input(10000000) ) )
   