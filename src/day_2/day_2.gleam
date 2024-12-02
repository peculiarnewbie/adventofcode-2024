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
  // let res = runner.parse_sample(day)

  pt_1(res)
  pt_2(res)
}

fn pt_1(list: List(String)) {
  list
  |> list.map(parse_line)
  |> list.map(fn(x) {
    let increase = increase_decrease(x)
    check_line(x, increase)
  })
  |> list.count(fn(x) { x })
  |> io.debug
}

fn pt_2(list: List(String)) {
  list
  |> list.map(parse_line)
  |> list.map(fn(x) {
    let increase = increase_decrease(x)
    check_dampened(x, increase, False, [])
  })
  |> list.count(fn(x) { x })
  |> io.debug
}

fn parse_line(line: String) {
  line
  |> string.trim()
  |> string.split(" ")
  |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
}

fn check_line(line: List(Int), increase: Bool) -> Bool {
  case line {
    [] -> True
    [_] -> True
    [first, second, ..] -> {
      case first < second == increase {
        False -> False
        True -> {
          let abs = int.absolute_value(first - second)
          case abs > 0 && abs < 4 {
            False -> False
            True -> check_line(list.drop(line, 1), increase)
          }
        }
      }
    }
  }
}

fn check_dampened(
  line: List(Int),
  increase: Bool,
  dampened: Bool,
  dropped: List(Int),
) -> Bool {
  case line {
    [] -> True
    [_] -> True
    [first, second, ..rest] -> {
      case first < second == increase {
        False -> second_chance(dampened, line, dropped, check_dampened)
        True -> {
          let abs = int.absolute_value(first - second)
          case abs > 0 && abs < 4 {
            False -> second_chance(dampened, line, dropped, check_dampened)
            True ->
              check_dampened(
                [second, ..rest],
                increase,
                dampened,
                list.append(dropped, [first]),
              )
          }
        }
      }
    }
  }
}

fn second_chance(
  dampened: Bool,
  line: List(Int),
  dropped: List(Int),
  function: fn(List(Int), Bool, Bool, List(Int)) -> Bool,
) -> Bool {
  case dampened {
    True -> False
    False -> {
      case line {
        [] -> True
        [_] -> True
        [first, second, ..rest] -> {
          let line1 = [dropped, [first], rest] |> list.flatten()
          let line2 = [dropped, [second], rest] |> list.flatten()

          let reports = case dropped {
            [_] -> [line1, line2]
            _ -> [line1, line2, line]
          }

          list.any(reports, fn(report) {
            function(report, increase_decrease(report), True, [])
          })
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
