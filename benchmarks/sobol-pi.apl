dirVecf   ← ReadCSVInt '../data/direction_vectors'
bitsNum   ← 30
dirVec    ← ⌷2 bitsNum ⍴ dirVecf
grayCode ← { ⍵ xor ⍵ srl 1 }

⍝ Sobol sequences using inductive approach
sobolIndI ← {
  dirVec ← ⍵
  n ← ⍺
  bits  ← ⍳bitsNum
  is ← ⌷n ∘.{⍵ testBit (grayCode ⍺)} bits
  is xor.× ⌷⍉dirVec
}

sobolIndR ← {
  arri ← ⍺ sobolIndI ⍵
  arri÷2*bitsNum
}

⍝ Number of iterations
n ← 10000000

⍝ Compute pi
pi ← {
  ⍝ Compute 2 dimensional sobol vector
  s ← (⍳ ⍵) sobolIndR 2 30⍴dirVec
⍝  4×(+/1>((s[;1]*2)+s[;2]*2)*÷2)÷n
  4×(+/1>(+/s*2)*÷2)÷⍵
}

test ← {
  ⍵
  pi n
}

(test bench 30) 0

