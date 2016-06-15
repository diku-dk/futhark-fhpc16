⍝ Conway's Game of Life in APL without the use of nested arrays
⍝ Martin Elsman, 2014-11-10

⍝ Function computing the next generation of a board of life
life ← {
  rowsum ← {
    (¯1⌽⍵) + ⍵ + 1⌽⍵
  }
  neighbor ← {
    (rowsum ¯1⊖⍵) + (rowsum ⍵) + rowsum 1⊖⍵
  }
  n ← neighbor ⍵
  (n=3) ∨ (n=4) ∧ ⍵
}

nlife ← {
  (life ⍣ ⍺) ⍵
}

⍝ We don't intend to actually run this APL code, and the file names
⍝ are not used by tail2futhark.  The order of the reads is important,
⍝ however.

steps ← ReadCSVInt 'steps.txt'
steps ← steps[1]
dim ← ReadCSVInt 'dim.txt'
dim ← 2 ↑ dim
data ← ReadCSVInt 'data.txt'
data ← data > 0

board ← dim ⍴ data

⎕ ← dim ⍴ steps nlife board

1
