
--f ← { 2 ÷ ⍵ + 2 }           ⍝ Function \x. 2 / (x+2)
--X ← 10000000                ⍝ Valuation points per unit
--test ← { ⍵ 
--         domain ← 10 × (⍳X) ÷ X      ⍝ Integrate from 0 to 10
--         integral ← +/ (f¨domain)÷X  ⍝ Compute integral
--       }
--(test bench 10) 0

fun f32 f(f32 x) = 2.0f32 / (x + 2.0f32)

fun f32 main() =
  let X  = 10000000 in 
  let fX = f32(X) in
  let domain   = map( *10.0f32, map( /fX, map(f32,iota(X)) ) ) in
  let integral = reduce( +, 0.0f32, map(/fX, map(f,domain)) )  in
  integral 

