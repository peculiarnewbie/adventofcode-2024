//// this is last year's day 0. Just to test the runner

import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 0
  let res =
    runner.parse_line(day)
    |> list.map(parse_line)
    |> list.map(get_value_from_line)
    |> int.sum

  io.debug(res)
}

fn parse_line(line: String) {
  string.to_graphemes(line) |> list.filter_map(int.parse)
}

fn get_value_from_line(numbers: List(Int)) -> Int {
  //   io.debug(list.length(numbers))
  case list.length(numbers) {
    1 -> list.first(numbers) |> result.unwrap(0) |> from_single_value
    _ ->
      [list.first(numbers), list.last(numbers)]
      |> result.values()
      |> from_two_values
  }
}

fn from_single_value(number: Int) {
  number * 10 + number
}

fn from_two_values(numbers: List(Int)) {
  let assert Ok(first) = list.first(numbers)
  let assert Ok(second) = list.last(numbers)
  first * 10 + second
}
