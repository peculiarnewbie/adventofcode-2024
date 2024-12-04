import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 3
  let res = runner.parse_line_no_split(day)
  // let res = runner.parse_sample_no_split(day)

  // io.debug(res)
  // pt_1(res)
  pt_2(res)
}

fn pt_1(memory: String) {
  memory
  |> string.split(on: "mul(")
  |> list.map(fn(x) {
    x |> string.split(on: ")") |> list.first() |> result.unwrap("")
  })
  |> list.map(fn(x) {
    x
    |> string.split(on: ",")
    |> list.map(fn(x) {
      int.parse(x)
      |> result.unwrap(0)
    })
  })
  |> list.map(fn(x) {
    case x {
      [a, b] -> a * b
      _ -> 0
    }
  })
  |> list.reduce(fn(acc, x) { acc + x })
  |> io.debug
}

fn pt_2(memory: String) {
  memory
  |> string.split(on: "do()")
  |> list.map(fn(x) {
    string.split(x, on: "don't()")
    |> list.first()
    |> result.unwrap("")
  })
  |> list.map(fn(x) { pt_1(x) |> result.unwrap(0) })
  |> list.reduce(fn(acc, x) { acc + x })
  |> io.debug
}

fn iterate(memory: List(List(Int)), index: Int, count: Int) {
  case index == count {
    True -> io.debug(memory)
    False -> iterate(memory, index + 1, count)
  }
}
