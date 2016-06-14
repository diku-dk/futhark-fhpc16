⍝ Mandelbrot
⍝ grid-size in left argument (e.g., (1024 768))
⍝ X-range, Y-range in right argument

dim ← ReadCSVInt 'dim.txt'
dim ← 2 ↑ dim
field ← ReadCSVDouble 'field.txt'
field ← 4 ↑ field
N ← ReadCSVInt 'N.txt'
N ← N[1]

mandelbrot ← {
  Y ← ⊃⍺                                 ⍝ e.g., 1024
  X ← ⊃1↓⍺                               ⍝ e.g., 768
  xRng ← 2↑⍵ 
  yRng ← 2↓⍵
  dx ← ((xRng[2])-xRng[1]) ÷ X
  dy ← ((yRng[2])-yRng[1]) ÷ Y
  cxA ← Y X ⍴ (xRng[1]) + dx × ⍳X        ⍝ real plane
  cyA ← ⍉ X Y ⍴ (yRng[1]) + dy × ⍳Y      ⍝ img plane
  mandel1 ← {
    cx ← ⍺
    cy ← ⍵
    f ← {
      arg ← ⍵
      x ← arg[1]                         ⍝ real value
      y ← arg[2]                         ⍝ imaginary value
      count ← arg[3]
      dummy ← arg[4]
      zx ← cx+(x×x)-(y×y)
      zy ← cy+(x×y)+(x×y)
      conv ← 4 > (zx × zx) + zy × zy
      count2 ← count + 1 - conv
      (zx zy count2 dummy)
    }
    res ← (f ⍣ N) (0 0 0 'dummy')                ⍝ perform N iteration of a single mandelbrot point
    res[3]
  }
  res ← cxA mandel1¨ cyA
  res ÷ N
}

red ← {
  (⍵ < 1.0) × 3 × ⍵ × N
}
green ← {
  (⍵ < 1.0) × 5 × ⍵ × N
}
blue ← {
  (⍵ < 1.0) × 7 × ⍵ × N
}

escapes ← -dim mandelbrot field
⎕ ← red ¨ escapes
⎕ ← green ¨ escapes
⎕ ← blue ¨ escapes
0
