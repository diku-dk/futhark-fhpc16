
f ← { 2 ÷ ⍵ + 2 }           ⍝ Function \x. 2 / (x+2)
X ← 10000000                ⍝ Valuation points per unit

test ← { ⍵ 
         domain ← 10 × (⍳X) ÷ X      ⍝ Integrate from 0 to 10
         integral ← +/ (f¨domain)÷X  ⍝ Compute integral
       }

(test bench 10) 0



