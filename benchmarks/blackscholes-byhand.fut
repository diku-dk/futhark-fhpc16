
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

fun f32 pi() = 3.141592653589793f32

fun f32 sign(f32 x) = if x > 0.0f32 then 1.0f32 else if x < 0.0f32 then -1.0f32 else 0.0f32
fun f32 min(f32 x, f32 y) = if (x <= y) then x else y

fun f32 cnd(f32 x) = 
  let a = [0.31938153f32, -0.356563782f32, 1.781477937f32, -1.821255978f32, 1.330274429f32] in
  let l = abs(x) in
  let k = 1.0f32 / (1.0f32 + 0.2316419f32*l) in
  let w = map( fn f32 ((int,f32) ai) => let (i,a_el) = ai in a_el * (k**f32(i+1)) 
             , zip(iota(5),a))
  let r1= reduce(+, 0.0f32, w) in
  let t1= exp32( - (l*l / 2.0f32) ) in
  let t2= 1.0f32/sqrt32( 2.0f32 * pi() ) in
  let w = 1.0f32 - t2 * t1 * r1 in
  
  let t3 = min(0.0f32, sign(x)) in
  t3*(1.0f32-w) + (1.0f32-t3)*w

-- S - current price
fun f32 s() = 60.0f32

-- X - strike price
fun f32 x() = 65.0f32

-- T - expiry in years
fun f32 t() = 1.0f32

-- r - riskless interest rate
fun f32 r() = 0.1f32

-- v - volatility
fun f32 v() = 0.2f32


-- d1 ← { ((⍟S÷X)+(r+(v*2)÷2)×⍵)÷(v×⍵*0.5) }
fun f32 d1(f32 w) = 
  let t1 = v() * sqrt32(w) in
  let t2 = (r() + (v() ** 2.0f32) / 2.0f32) * w in
  let t3 = log32(s() / x()) in
  (t3 + t2) / t1

-- d2 ← { (d1 ⍵) -v×⍵*0.5 }
fun f32 d2(f32 w) = d1(w) - v() * sqrt32(w)




-- n ← 1000000
fun int n() = 1000000
-- years ← 10
fun int years() = 10


-- Call price
-- callPrice ← { (S×CND(d1 ⍵))-(X×*-r×⍵)×CND(d2 ⍵) }
fun f32 callPrice(f32 w) =
  let t1 = x() * exp32(-r()*w) * cnd(d2(w)) in
  s() * cnd( d1(w) ) - t1

-- avg ← { (+/⍵) ÷ ⊃⍴ ⍵ }
fun f32 avg([f32,n] x) = 
  reduce(+, 0.0f32, x) / f32(n)


-- price ← { avg callPrice ¨ (⍳ ⍵ × years) ÷ ⍵ }
fun f32 price(int w) =
  let nn = map( fn f32 (int i) => f32(i) / f32(w)
              , map(+1, iota(w*years())) ) 
  in 
  avg( map(callPrice, nn) )


-- test ← {
--  ⍵ 
--  price n
-- }
-- (test bench 30) 0

fun f32 main() = price( n() )
