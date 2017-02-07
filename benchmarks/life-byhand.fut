import "futlib/numeric"

fun bint(b: bool): i32 = if b then 1 else 0
fun intb(x: i32): bool = if x == 0 then false else true

fun to_bool_board(board: [][]i32): [][]bool =
  map (\  (r: []i32): []bool  -> map intb r) board

fun to_int_board(board: [][]bool): [][]i32 =
  map (\  (r: []bool): []i32  -> map bint r) board

fun cell_neighbors(i: i32, j: i32, board: [n][m]bool): i32 =
  unsafe
  let above = (i - 1) % n in
  let below = (i + 1) % n in
  let right = (j + 1) % m in
  let left = (j - 1) % m in
  bint(board[above,left]) + bint(board[above,j]) + bint(board[above,right]) +
  bint(board[i,left]) + bint(board[i,right]) +
  bint(board[below,left]) + bint(board[below,j]) + bint(board[below,right])

fun all_neighbours(board: [n][m]bool): [n][m]i32 =
  map (\  (i: i32): []i32  ->
        map (\  (j: i32): i32  ->
              cell_neighbors(i,j,board)) (
            iota(m))) (
        iota(n))

fun iteration(board: [n][m]bool): [n][m]bool =
  let lives = all_neighbours(board) in
  zipWith (\  (lives_r: []i32) (board_r: []bool): []bool  ->
            zipWith (\  (neighbors: i32) (alive: bool): bool  ->
                      if neighbors < 2
                      then false
                      else if neighbors == 3 then true
                      else if alive && neighbors < 4 then true
                      else false) (
                    lives_r) (board_r)) lives board

fun main(): i32 =
  let (n, m) = (1200, 1200)
  let iterations = 100
  let glider = reshape (4,4) ([0,0,0,0, 1,1,1,0, 1,0,0,0, 0,1,0,0])
  let int_board = map (\  (i: i32): [m]i32  ->
                        map (\  (j: i32): i32  ->
                              unsafe glider[(shape glider)[0], j%((shape glider)[1])]) (
                            iota(m))) (
                      iota(n))
  let board = to_bool_board(int_board)
  loop (board) = for i < iterations do
    iteration(board)
  in reduce (+) 0 (reshape (n*m) (to_int_board(board)))
