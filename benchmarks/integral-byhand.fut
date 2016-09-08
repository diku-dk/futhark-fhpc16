
--f ← { 2 ÷ ⍵ + 2 }           ⍝ Function \x. 2 / (x+2)
--X ← 10000000                ⍝ Valuation points per unit
--test ← { ⍵ 
--         domain ← 10 × (⍳X) ÷ X      ⍝ Integrate from 0 to 10
--         integral ← +/ (f¨domain)÷X  ⍝ Compute integral
--       }
--(test bench 10) 0

fun f(x: f32): f32 = 2.0f32 / (x + 2.0f32)

fun main(): f32 =
  let x  = 10000000 in 
  let fX = f32(x) in
  let domain   = map (*10.0f32) (map (/fX) (map f32 (iota(x)) ) ) in
  let integral = reduce (+) (0.0f32) (map (/fX) (map f domain) )  in
  integral 

