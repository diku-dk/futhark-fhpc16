--easter←{                     ⍝ Easter Sunday in year ⍵
--    G←1+19|⍵                 ⍝ year "golden number"
--    C←1+⌊⍵÷100               ⍝ Century: eg 1984 → 20th
--    X← ¯12 + ⌊ C×3÷4         ⍝ yrs in which leap yr omitted
--    Z← ¯5 + ⌊ (5+8×C)÷25     ⍝ synch Easter & moon's orbit
--    S←(⌊(5×⍵)÷4)-X+10        ⍝ find Sunday
--    E←30|(11×G)+20+Z-X       ⍝ Epact
--    F←E+(E=24)∨(E=25)∧G>11   ⍝    (when full moon occurs)
--    N←(30×F>23)+44-F         ⍝ find full moon
--    N←N+7-7|S+N              ⍝ advance to Sunday
--    M←3+N>31                 ⍝ month: March or April
--    D←N-31×N>31              ⍝ day within month
--    10000 100 1+.×⍵ M D      ⍝ yyyymmdd
--}
--run ← {
--  ⍵ 
--  ⌈/easter¨⍳ 10000000
--}
--(run bench 30) 0

fun easter(i: int): int = 
  let g = (i % 19) + 1 in
  let c = i / 100 + 1  in
  let x = (c*3)/4 - 12 in
  let z = (5+8*c)/25 - 5 in
  let s = (5*i)/4 - (x + 10) in
  let e = (11*g+20+z-x) % 30 in
  let b = if (e == 24) || ((e==25) && (g >11)) then 1 else 0 in
  let f = e + b in
  let b = if f > 23 then 1 else 0 in
  let n = 30*b + (44 - f) in
  let n = n + 7 - (s+n) % 7 in
  let b = if n > 31 then 1 else 0 in
  let m = 3 + b in
  let d = n - 31*b in
  10000*i + 100*m + d
  
fun max(x: int) (y: int): int = if x < y then y else x

fun main(): int =
  let dates = map easter (map (+0) (iota(10000000))) in
  reduce max (-2147483648) dates
