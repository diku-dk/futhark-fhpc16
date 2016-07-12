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

glider ← 4 4⍴0 0 0 0   1 1 1 0    1 0 0 0    0 1 0 0

board ← ⍉ ¯300 ↑ ⍉ ¯300 ↑ glider
square ← { x ← (5 ⊖ ⍵), 3 ⌽ ⍉ ⍵ ⋄ x ⍪ 4 ⊖ x }

board ← square board
board ← ⌷square board


life2 ← {
  ⍵
  +/+/ (life ⍣ 100) board
}

r ← (life2 bench 30) 0
r

⍝ ⎕ ← a
⍝ ⎕ ← 'Stable: '
⍝ s ← ∧/,a=b
⍝ s
