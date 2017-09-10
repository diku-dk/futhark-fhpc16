import "/futlib/math"

default(f32)

let dirvcts(): [2][30]i32 =
    [
	    [
		536870912, 268435456, 134217728, 67108864, 33554432, 16777216, 8388608, 4194304, 2097152, 1048576, 524288, 262144, 131072, 65536, 32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1
	    ],
	    [
		536870912, 805306368, 671088640, 1006632960, 570425344, 855638016, 713031680, 1069547520, 538968064, 808452096, 673710080, 1010565120, 572653568, 858980352, 715816960, 1073725440, 536879104, 805318656, 671098880, 1006648320, 570434048, 855651072, 713042560, 1069563840, 538976288, 808464432, 673720360, 1010580540, 572662306, 858993459
	    ]
    ]


let grayCode(x: i32): i32 = (x >> 1) ^ x

----------------------------------------
--- Sobol Generator
----------------------------------------
let testBit(n: i32, ind: i32): bool =
    let t = (1 << ind) in (n & t) == t

-----------------------------------------------------------------
---- INDEPENDENT FORMULA:
----    filter is redundantly computed inside map.
----    Currently Futhark hoists it outside, but this will
----    not allow fusing the filter with reduce => redomap,
-----------------------------------------------------------------
let xorInds [num_bits] (n: i32) (dir_vs: [num_bits]i32): i32 =
    let reldv_vals = map (\  (dv: i32, i: i32): i32  ->
                            if testBit(grayCode(n),i)
                            then dv else 0
                         ) (zip  (dir_vs) (iota(num_bits)) ) in
    reduce (^) 0 (reldv_vals )

let sobolIndI [m] [num_bits] (dir_vs:  [m][num_bits]i32, n: i32 ): [m]i32 =
    map (xorInds(n)) (dir_vs )

let sobolIndR [m] [num_bits] (dir_vs:  [m][num_bits]i32) (n: i32 ): [m]f32 =
    let divisor = 2.0 ** f32(num_bits) in
    let arri    = sobolIndI( dir_vs, n )     in
        map (\  (x: i32): f32  -> f32(x) / divisor) arri

let main(): f32 =
    let n = 1000000 in
    let rand_nums = map (sobolIndR(dirvcts())) (iota(n)) in
    let dists     = map  (\  (xy: [2]f32): f32  ->
                            let (x,y) = (xy[0],xy[1]) in f32.sqrt(x*x + y*y)
                         ) (rand_nums)
    in
    let bs        = map (\  (d: f32): i32  -> if d <= 1.0f32 then 1 else 0
                        ) dists
    in
    let inside    = reduce (+) 0 bs in
    4.0f32*f32(inside)/f32(n)
