fun int bint(bool b) = if b then 1 else 0
fun bool intb(int x) = if x == 0 then False else True

fun [][]bool to_bool_board([][]int board) =
  map(fn []bool ([]int r) => map(intb, r), board)

fun [][]int to_int_board([][]bool board) =
  map(fn []int ([]bool r) => map(bint, r), board)

fun int cell_neighbors(int i, int j, [n][m]bool board) =
  unsafe
  let above = (i - 1) % n in
  let below = (i + 1) % n in
  let right = (j + 1) % m in
  let left = (j - 1) % m in
  bint(board[above,left]) + bint(board[above,j]) + bint(board[above,right]) +
  bint(board[i,left]) + bint(board[i,right]) +
  bint(board[below,left]) + bint(board[below,j]) + bint(board[below,right])

fun [n][m]int all_neighbours([n][m]bool board) =
  map(fn []int (int i) =>
        map(fn int (int j) =>
              cell_neighbors(i,j,board),
            iota(m)),
        iota(n))

fun [n][m]bool iteration([n][m]bool board) =
  let lives = all_neighbours(board) in
  zipWith(fn []bool ([]int lives_r, []bool board_r) =>
            zipWith(fn bool (int neighbors, bool alive) =>
                      if neighbors < 2
                      then False
                      else if neighbors == 3 then True
                      else if alive && neighbors < 4 then True
                      else False,
                    lives_r, board_r),
            lives, board)

fun int main() =
  let (n, m) = (1200, 1200)
  let iterations = 100
  let glider = reshape((3,3), [1,1,1,1,0,0,0,1,0])
  let int_board = map(fn [m]int (int i) =>
                        map(fn int (int j) =>
                              unsafe glider[i%size(0,glider), j%size(1,glider)],
                            iota(m)),
                      iota(n))
  let board = to_bool_board(int_board)
  loop (board) = for i < iterations do
    iteration(board)
  in reduce(+, 0, reshape((n*m), to_int_board(board)))
