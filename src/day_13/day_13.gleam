import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 13
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  //   let assert 143 = 
  pt_1(sample)
}

fn pt_1(lines: List(String)) {
  lines
  |> list.sized_chunk(4)
  |> list.map(fn(x) { x |> list.drop(1) })
  |> list.map(fn(x) {
    case x {
      [a, b, res] -> {
        [parse_button(a), parse_button(b), parse_res(res)]
      }
      _ -> []
    }
  })
  |> io.debug
}

fn parse_button(button: String) {
  button
  |> string.split("+")
  |> list.drop(1)
  |> io.debug
  |> list.map(fn(x) { string.split(x, ",") })
  |> list.flatten
  |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
  |> list.filter(fn(x) { x > 0 })
}

fn parse_res(res: String) {
  res
  |> string.split(on: "=")
  |> list.drop(1)
  |> list.map(fn(x) { string.split(x, ",") })
  |> list.flatten
  |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
  |> list.filter(fn(x) { x > 0 })
}

fn pt_2(lines: List(String)) {
  todo
}
