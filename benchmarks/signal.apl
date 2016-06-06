diff ← {1↓⍵−¯1⌽⍵}
signal ← {¯50⌈50⌊50×(diff 0,⍵)÷0.01+⍵}

test ← {
  ⍵
  input ← {{1○⍵}¨ (⍳ ⍵) ÷ ⍵ ÷ 10}
  +/ signal input 10000000
}

(test bench 30) 0
