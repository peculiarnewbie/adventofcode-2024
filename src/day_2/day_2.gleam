import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

// import gleam/result
import runner/runner

pub fn main() {
  let day = 2
  let res = runner.parse_line(day)

  // let #(_sample, sample2) = list.split(res, 999)

  res
  |> list.map(parse_line)
  |> list.map(fn(x) {
    let increase = increase_decrease(x)
    check_line(x, increase)
  })
  |> list.count(fn(x) { x })
  |> io.debug
  // io.debug(sample)
  // io.debug(res)
}

fn parse_line(line: String) {
  line
  |> string.trim()
  |> string.split(" ")
  |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
}

fn check_line(line: List(Int), increase: Bool) -> Bool {
  let #(val, _) = list.split(line, 2)
  // io.debug(#(line, val, increase))
  case list.length(val) {
    1 -> True
    _ -> {
      let assert Ok(first) = list.first(val)
      let assert Ok(second) = list.last(val)

      case increase {
        True -> {
          case second - first < 1 || second - first > 3 {
            True -> False
            False -> check_line(list.drop(line, 1), increase)
          }
        }
        False -> {
          // io.debug(#(first, second, "decrease"))
          case first - second < 1 || first - second > 3 {
            True -> False
            False -> check_line(list.drop(line, 1), increase)
          }
        }
      }
    }
  }
}

fn increase_decrease(line: List(Int)) -> Bool {
  let #(val, _) = list.split(line, 2)
  let assert Ok(first) = list.first(val)
  let assert Ok(second) = list.last(val)
  first < second
}
