
--CND ← {
--    X ← ⍵
--    a ← 0.31938153 ¯0.356563782 1.781477937 ¯1.821255978 1.330274429
--
--    l ← |X
--    k ← ÷1+0.2316419×l
--    w ← 1 - (÷((2×(○1))*0.5)) × (*-(l×l)÷2) × (a +.× (k*⍳5))
--
--    ((|0⌊×X)×(1-w))+(1-|0⌊×X)×w
--}

import "/futlib/math"

let pi(): f32 = 3.141592653589793f32

let sign(x: f32): f32 = if x > 0.0f32 then 1.0f32 else if x < 0.0f32 then -1.0f32 else 0.0f32
let min(x: f32, y: f32): f32 = if (x <= y) then x else y

let cnd(x: f32): f32 =
  let a = [0.31938153f32, -0.356563782f32, 1.781477937f32, -1.821255978f32, 1.330274429f32] in
  let l = f32.abs(x) in
  let k = 1.0f32 / (1.0f32 + 0.2316419f32*l) in
  let w = map (\  (ai: (i32,f32)): f32  -> let (i,a_el) = ai in a_el * (k**f32(i+1))
             ) (zip  (iota(5)) a)
  let r1= reduce (+) (0.0f32) w in
  let t1= f32.exp( - (l*l / 2.0f32) ) in
  let t2= 1.0f32/f32.sqrt( 2.0f32 * pi() ) in
  let w = 1.0f32 - t2 * t1 * r1 in

  let t3 = min(0.0f32, sign(x)) in
  t3*(1.0f32-w) + (1.0f32-t3)*w

-- S - current price
let s(): f32 = 60.0f32

-- X - strike price
let x(): f32 = 65.0f32

-- T - expiry in years
let t(): f32 = 1.0f32

-- r - riskless interest rate
let r(): f32 = 0.1f32

-- v - volatility
let v(): f32 = 0.2f32


-- d1 ← { ((⍟S÷X)+(r+(v*2)÷2)×⍵)÷(v×⍵*0.5) }
let d1(w: f32): f32 =
  let t1 = v() * f32.sqrt(w) in
  let t2 = (r() + (v() ** 2.0f32) / 2.0f32) * w in
  let t3 = f32.log(s() / x()) in
  (t3 + t2) / t1

-- d2 ← { (d1 ⍵) -v×⍵*0.5 }
let d2(w: f32): f32 = d1(w) - v() * f32.sqrt(w)




-- n ← 1000000
let n(): i32 = 1000000
-- years ← 10
let years(): i32 = 10


-- Call price
-- callPrice ← { (S×CND(d1 ⍵))-(X×*-r×⍵)×CND(d2 ⍵) }
let callPrice(w: f32): f32 =
  let t1 = x() * f32.exp(-r()*w) * cnd(d2(w)) in
  s() * cnd( d1(w) ) - t1

-- avg ← { (+/⍵) ÷ ⊃⍴ ⍵ }
let avg [n] (x: [n]f32): f32 =
  reduce (+) (0.0f32) x / f32(n)


-- price ← { avg callPrice ¨ (⍳ ⍵ × years) ÷ ⍵ }
let price(w: i32): f32 =
  let nn = map (\  (i: i32): f32  -> f32(i) / f32(w)
              ) (map (+1) (iota(w*years())) )
  in
  avg( map callPrice nn )


-- test ← {
--  ⍵
--  price n
-- }
-- (test bench 30) 0

let main(): f32 = price( n() )
