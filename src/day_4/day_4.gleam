import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 4
  // let res = runner.parse_line(day)
  let sample = runner.parse_sample(day)
  let assert 18 = pt_1(sample)
  // io.debug(res)
}

fn pt_1(lines: List(String)) {
  let grid =
    lines
    |> list.map(string.trim)
    |> list.map(fn(x) { string.to_graphemes(x) })
  // |> io.debug

  let length = grid |> list.last() |> result.unwrap([]) |> list.length()

  traverse_grid(grid, 0, length, 0)
}

fn traverse_grid(grid: List(List(String)), x: Int, length: Int, score: Int) {
  let line = grid |> list.first() |> result.unwrap([])
  // io.debug(line)

  case line {
    [] -> score
    ["X", ..] ->
      grid
      |> get_spread(4, 4, x, length)
      |> get_score("X", False, _)
      |> int.add(score)
      |> continue_traversal(grid, x, length, _)

    ["S", ..] ->
      grid
      |> get_spread(4, 4, x, length)
      |> get_score("S", False, _)
      |> int.add(score)
      |> continue_traversal(grid, x, length, _)

    [_, _, _, "X", ..] ->
      grid
      |> get_spread(4, 4, x, length)
      |> get_score("X", True, _)
      |> int.add(score)
      |> continue_traversal(grid, x, length, _)

    [_, _, _, "S", ..] ->
      grid
      |> get_spread(4, 4, x, length)
      |> get_score("S", True, _)
      |> int.add(score)
      |> continue_traversal(grid, x, length, _)

    _ -> continue_traversal(grid, length, x, score)
  }
}

fn continue_traversal(grid: List(List(String)), x: Int, length: Int, score: Int) {
  let line = grid |> list.first() |> result.unwrap([])

  case line {
    [] -> score
    [_] -> grid |> list.drop(1) |> traverse_grid(0, length, score)
    _ -> traverse_next_char(grid, x, length, score)
  }
}

fn traverse_next_char(grid: List(List(String)), x: Int, length: Int, score: Int) {
  let line = grid |> list.first() |> result.unwrap([])

  grid
  |> list.drop(1)
  |> list.prepend(line |> list.drop(1))
  |> traverse_grid(x + 1, length, score)
}

fn get_spread(
  grid: List(List(String)),
  x_size: Int,
  y_size: Int,
  offset: Int,
  length: Int,
) {
  let #(cut, _) = grid |> list.split(y_size)

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

fn trim_line(line: List(String), offset: Int, x_size: Int) {
  let #(_, start) = line |> list.split(offset)
  let #(trimmed, _) = start |> list.split(x_size)
  trimmed
}

fn get_score(graphene: String, late: Bool, spread: List(List(String))) {
  io.debug(graphene)
  io.debug(late)
  io.debug(spread)
  case graphene, late {
    "X", True -> backward_check(spread, "XMAS")
    "S", True -> backward_check(spread, "SAMX")
    "X", False -> forward_check(spread, "XMAS")
    "S", False -> forward_check(spread, "SAMX")
    _, _ -> 0
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

  io.debug(right + down + diagonal)
}

fn backward_check(grid: List(List(String)), phrase: String) {
  case get_backwards_line(grid, 0, 4, "") == phrase {
    True -> 1
    False -> 0
  }
  |> io.debug
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

// S
// SAMX
// AA__
// M_M_
// X__X

// ___S
// __A_
// _M__
// X___

// X
// XMAS
// MM__
// A_A_
// S__S

// ___X
// __M_
// _A__
// S___
