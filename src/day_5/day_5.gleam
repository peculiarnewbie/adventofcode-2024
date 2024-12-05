import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub type Dict(key, value)

pub fn main() {
  let day = 5
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  let assert 143 = pt_1(sample)
  let assert 4569 = pt_1(res)

  let assert 123 = pt_2(sample)
  let assert 6456 = pt_2(res) |> io.debug
}

fn pt_1(lines: List(String)) {
  let #(updates, rules) = split_input(lines, [])
  let rules_list = rules |> build_rules

  updates
  |> list.map(fn(x) {
    x
    |> string.split(on: ",")
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
  })
  |> list.map(fn(x) { get_line_value(x, rules_list) })
  |> list.reduce(fn(acc, x) { acc + x })
  |> result.unwrap(0)
}

fn split_input(lines: List(String), rules: List(String)) {
  let first = lines |> list.first() |> result.unwrap("")
  case first {
    "--" -> #(lines |> list.drop(1), rules)
    _ -> split_input(lines |> list.drop(1), rules |> list.append([first]))
  }
}

fn build_rules(lines: List(String)) {
  lines
  |> list.map(fn(x) { string.split(x, on: "|") })
  |> list.map(fn(line) {
    case line {
      [a, b] -> #(
        int.parse(a) |> result.unwrap(0),
        int.parse(b) |> result.unwrap(0),
      )
      _ -> #(0, 0)
    }
  })
  |> dict_from_tuple_list(dict.new())
}

fn dict_from_tuple_list(
  lines: List(#(Int, Int)),
  map: dict.Dict(Int, List(Int)),
) {
  case lines {
    [] -> map
    _ -> {
      let #(key, value) = lines |> list.first() |> result.unwrap(#(0, 0))
      case dict.has_key(map, key) {
        True -> {
          let mapped_value = dict.get(map, key) |> result.unwrap([])
          let new_list = mapped_value |> list.append([value])
          dict_from_tuple_list(
            lines |> list.drop(1),
            map |> dict.insert(key, new_list),
          )
        }
        False ->
          dict_from_tuple_list(
            lines |> list.drop(1),
            map |> dict.insert(key, [value]),
          )
      }
    }
  }
}

fn get_line_value(line: List(Int), rules: dict.Dict(Int, List(Int))) {
  let length = line |> list.length()
  let val = line |> list.drop(length / 2) |> list.first() |> result.unwrap(0)

  case check_line(list.reverse(line), rules) {
    True -> val
    False -> 0
  }
}

//reverse line on first input
fn check_line(line: List(Int), rules: dict.Dict(Int, List(Int))) {
  case line {
    [] -> True
    _ -> {
      let first = line |> list.first() |> result.unwrap(0)
      let char_check =
        line
        |> list.all(fn(x) {
          dict.get(rules, first)
          |> result.unwrap([])
          |> list.contains(x)
          |> fn(x) { !x }
        })

      case char_check {
        True -> check_line(line |> list.drop(1), rules)
        False -> False
      }
    }
  }
}

fn sort_line(
  line: List(Int),
  rules: dict.Dict(Int, List(Int)),
  sorted: List(Int),
) {
  case line {
    [] -> {
      let length = sorted |> list.length()
      sorted |> list.drop(length / 2) |> list.first() |> result.unwrap(0)
    }
    _ -> {
      let first = line |> list.first() |> result.unwrap(0)
      let char_check =
        line
        |> list.all(fn(x) {
          dict.get(rules, first)
          |> result.unwrap([])
          |> list.contains(x)
          |> fn(x) { !x }
        })

      case char_check {
        True ->
          sort_line(line |> list.drop(1), rules, sorted |> list.append([first]))
        False ->
          sort_line(line |> list.drop(1) |> list.append([first]), rules, sorted)
      }
    }
  }
}

fn pt_2(lines: List(String)) {
  let #(updates, rules) = split_input(lines, [])
  let rules_list = rules |> build_rules

  updates
  |> list.map(fn(x) {
    x
    |> string.split(on: ",")
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
  })
  |> list.filter(fn(x) { !check_line(list.reverse(x), rules_list) })
  |> list.map(fn(x) { sort_line(x, rules_list, []) })
  |> list.reduce(fn(acc, x) { acc + x })
  |> result.unwrap(0)
}
