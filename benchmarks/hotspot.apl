⍝ Ported to APL from the ELI version available at http://fastarray.appspot.com/

num_iterations ← 360 ⍝ number of iteration

hotspot ← {
  temp ← ⍺
  power ← ⍵
  t_chip ← 0.0005
  width ← 0.016
  height ← width
  amb_temp ← 80.0
  FACTOR_CHIP←0.5
  K_SI← 100
  SPEC_HEAT_SI ← 1750000
  PRECISION ← 0.001
  MAX_PD ← 3000000

  ⍝ Additional scalar values (compute on CPU)
  row ← ⊃1↑⍴temp
  col ← ⊃¯1↑⍴temp
  gh ← height ÷ row
  gw ← width ÷ col
  Cap ← FACTOR_CHIP × SPEC_HEAT_SI × t_chip × gw × gh
  Rx ← gw ÷ (2.0 × K_SI × t_chip × gh)
  Ry ← gh ÷ (2.0 × K_SI × t_chip × gw)
  Rz ← t_chip ÷ (K_SI × gh × gw)
  max_slope ← MAX_PD ÷ (FACTOR_CHIP × t_chip × SPEC_HEAT_SI)
  step ← PRECISION ÷ max_slope

  k ← 0
  c1 ← (row⍴1),((row, col-2)⍴2), row⍴1
  c2 ← ⍉(col⍴1), ((col, (row-2))⍴2), col ⍴ 1

  iter ← {
    temp ← ⍵
    m1 ← (⍉1↓⍉temp),row 1⍴0
    m2 ← (row 1⍴0),⍉¯1↓⍉temp
    x ← (m1 + m2) - c1 × temp

    n1 ← ⍉(⍉1↓temp),col⍴0
    n2 ← ⍉(col⍴0),⍉¯1↓temp
    y ← (n1 + n2) - c2 × temp

    delta ← (step ÷ Cap) × (power + (y ÷ Ry) + (x ÷ Rx) + (amb_temp - temp) ÷ Rz)
    temp + delta
  }

  (iter ⍣ num_iterations) temp
}

⍝ data files
tempf  ← ReadCSVDouble 'temp_512'
powerf ← ReadCSVDouble 'power_512'
temp   ← ⌷512 512 ⍴ tempf
power  ← ⌷512 512 ⍴ powerf


⍝ We take the maximal element, to get  a scalar result, not really

test ← { 
  ⍵
  ⌈/⌈/temp hotspot power
}

(test bench 30) 0
