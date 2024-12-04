import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 4
  let res = runner.parse_line(day)
  let sample = runner.parse_sample(day)
  let assert 9 = pt_2(sample)
  pt_2(res)
  |> io.debug
}

fn pt_1(lines: List(String)) {
  let grid =
    lines
    |> list.map(string.trim)
    |> list.map(fn(x) { string.to_graphemes(x) })
  // |> io.debug

  traverse_grid(grid, 0, 0)
  |> io.debug
}

fn traverse_grid(grid: List(List(String)), x: Int, score: Int) {
  let line = grid |> list.first() |> result.unwrap([])
  // io.debug(line)

  let forward_score = case line {
    ["X", ..] -> get_score("X", False, grid, x)
    ["S", ..] -> get_score("S", False, grid, x)
    _ -> 0
  }

  let edge_score = case line {
    [_, _, _, "X", ..] -> get_score("X", True, grid, x)
    [_, _, _, "S", ..] -> get_score("S", True, grid, x)
    _ -> 0
  }

  continue_traversal(grid, x, score + forward_score + edge_score)
}

fn pt_2(lines: List(String)) {
  let grid =
    lines
    |> list.map(string.trim)
    |> list.map(fn(x) { string.to_graphemes(x) })
  // |> io.debug

  traverse_grid_2(grid, 0, 0)
  |> io.debug
}

fn traverse_grid_2(grid: List(List(String)), x: Int, score: Int) {
  let line = grid |> list.first() |> result.unwrap([])

  case line {
    [] -> score
    ["M", ..] -> continue_traversal_2(grid, x, score + get_score_2(grid, x))
    ["S", ..] -> continue_traversal_2(grid, x, score + get_score_2(grid, x))
    _ -> continue_traversal_2(grid, x, score)
  }
}

fn continue_traversal(grid: List(List(String)), x: Int, score: Int) {
  let line = grid |> list.first() |> result.unwrap([])

  case line {
    [] -> score
    [_] -> grid |> list.drop(1) |> traverse_grid(0, score)
    _ -> traverse_next_char(grid, x, score)
  }
}

fn continue_traversal_2(grid: List(List(String)), x: Int, score: Int) {
  let line = grid |> list.first() |> result.unwrap([])

  case line {
    [] -> score
    [_] -> grid |> list.drop(1) |> traverse_grid_2(0, score)
    _ -> traverse_next_char_2(grid, x, score)
  }
}

fn traverse_next_char(grid: List(List(String)), x: Int, score: Int) {
  let line = grid |> list.first() |> result.unwrap([])

  grid
  |> list.drop(1)
  |> list.prepend(line |> list.drop(1))
  |> traverse_grid(x + 1, score)
}

fn traverse_next_char_2(grid: List(List(String)), x: Int, score: Int) {
  let line = grid |> list.first() |> result.unwrap([])

  grid
  |> list.drop(1)
  |> list.prepend(line |> list.drop(1))
  |> traverse_grid_2(x + 1, score)
}

fn get_spread(grid: List(List(String)), x_size: Int, y_size: Int, offset: Int) {
  case grid |> list.length() == 1 {
    True -> {
      let #(line, _) =
        grid |> list.first() |> result.unwrap([]) |> list.split(x_size)
      [line]
    }
    False -> {
      let #(cut, _) = grid |> list.split(y_size)
      let length = grid |> list.last() |> result.unwrap([]) |> list.length()

      let first_line =
        cut
        |> list.first()
        |> result.unwrap([])
        |> fn(x) {
          let current_length = x |> list.length()
          let diff = length - current_length
          trim_line(x, offset - diff, x_size)
        }

      cut
      |> list.drop(1)
      |> list.map(trim_line(_, offset, x_size))
      |> list.prepend(first_line)
    }
  }
}

fn trim_line(line: List(String), offset: Int, x_size: Int) {
  let #(_, start) = line |> list.split(offset)
  let #(trimmed, _) = start |> list.split(x_size)
  trimmed
}

fn get_score(
  graphene: String,
  late: Bool,
  grid: List(List(String)),
  offset: Int,
) {
  let spread = get_spread(grid, 4, 4, offset)
  io.debug(late)
  io.debug(spread)
  case graphene, late {
    "X", True -> backward_check(spread, "XMAS")
    "S", True -> backward_check(spread, "SAMX")
    "X", False -> forward_check(spread, "XMAS")
    "S", False -> forward_check(spread, "SAMX")
    _, _ -> 0
  }
  |> io.debug
}

fn get_score_2(grid: List(List(String)), offset: Int) {
  let spread = get_spread(grid, 3, 3, offset)
  let diagonal_forward = get_diagonal_line(spread, 0, 3, "")
  let diagonal_backward = get_backwards_line(spread, 0, 3, "")

  io.debug(spread)
  io.debug(diagonal_forward)
  io.debug(diagonal_backward)

  case
    { diagonal_forward == "SAM" || diagonal_forward == "MAS" }
    && { diagonal_backward == "SAM" || diagonal_backward == "MAS" }
  {
    True -> 1 |> io.debug
    False -> 0
  }
}

fn forward_check(grid: List(List(String)), phrase: String) {
  let right =
    grid
    |> list.first()
    |> result.unwrap([])
    |> check_line(phrase)

  let down =
    grid
    |> list.map(fn(x) { x |> list.first() |> result.unwrap("") })
    |> check_line(phrase)

  let diagonal =
    grid
    |> get_diagonal_line(0, 4, "")
    |> fn(x) {
      case x == phrase {
        True -> 1
        False -> 0
      }
    }

  // io.debug(right + down + diagonal)

  right + down + diagonal
}

fn backward_check(grid: List(List(String)), phrase: String) {
  case get_backwards_line(grid, 0, 4, "") == phrase {
    True -> 1
    False -> 0
  }
}

fn check_line(line: List(String), phrase: String) {
  line
  |> list.reduce(fn(acc, x) { acc <> x })
  |> result.unwrap("")
  |> fn(x) {
    case x == phrase {
      True -> 1
      False -> 0
    }
  }
}

fn get_diagonal_line(
  grid: List(List(String)),
  step: Int,
  size: Int,
  result: String,
) {
  case step == size {
    True -> result
    False -> {
      let line = grid |> list.drop(step) |> list.first() |> result.unwrap([])
      let graphene =
        line |> list.drop(step) |> list.first() |> result.unwrap("")
      get_diagonal_line(grid, step + 1, size, result <> graphene)
    }
  }
}

fn get_backwards_line(
  grid: List(List(String)),
  step: Int,
  size: Int,
  result: String,
) {
  case step == size {
    True -> result
    False -> {
      let line = grid |> list.drop(step) |> list.first() |> result.unwrap([])
      let graphene =
        line |> list.drop(size - step - 1) |> list.first() |> result.unwrap("")
      get_backwards_line(grid, step + 1, size, result <> graphene)
    }
  }
}
// S__S__S
// _A_A_A_
// __MMM__
// SAMXMAS
// __MMM__
// _A_A_A_
// S__S__S

// X
// XMAS
// MM__
// A_A_
// S__S

// ___X
// __M_
// _A__
// S___

// S
// SAMX
// AA__
// M_M_
// X__X

// ___S
// __A_
// _M__
// X___
