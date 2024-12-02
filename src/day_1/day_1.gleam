import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 1
  let res = runner.parse_line(day)

  let split =
    res
    |> list.map(split_line)

  pt_1(split)
  pt_2(split)
}

// ------------------- pt 1 ---------------------
fn pt_1(split: List(List(Int))) {
  let first_list = get_first_list(split)
  let second_list = get_second_list(split)

  let new_list =
    list.map2(first_list, second_list, fn(x, y) {
      case x > y {
        True -> x - y
        False -> y - x
      }
    })

  io.debug(new_list |> list.fold(0, fn(x, y) { x + y }))
}

fn split_line(line: String) {
  line
  |> string.split(on: "   ")
  |> list.map(string.trim)
  |> list.map(int.parse)
  |> result.values()
}

fn get_first_list(input_list: List(List(Int))) {
  input_list
  |> list.map(fn(x) { list.first(x) |> result.unwrap(0) })
  |> list.sort(by: int.compare)
}

fn get_second_list(input_list: List(List(Int))) {
  input_list
  |> list.map(fn(x) { list.last(x) |> result.unwrap(0) })
  |> list.sort(by: int.compare)
}

// ------------------- pt 2 ---------------------
fn pt_2(split: List(List(Int))) {
  let first_list = get_first_list(split)
  let second_dict =
    get_second_list(split)
    |> create_dict(dict.new())

  io.debug(second_dict)

  first_list
  |> list.fold(0, fn(x, y) {
    io.debug(y)
    io.debug(dict.get(second_dict, y) |> result.unwrap(0))
    x + y * { dict.get(second_dict, y) |> result.unwrap(0) }
  })
  |> io.debug
}

fn create_dict(input_list: List(Int), new_dict: dict.Dict(Int, Int)) {
  case input_list {
    [first, ..rest] ->
      case dict.has_key(new_dict, first) {
        True ->
          create_dict(
            rest,
            dict.insert(
              new_dict,
              first,
              { dict.get(new_dict, first) |> result.unwrap(0) } + 1,
            ),
          )
        False -> create_dict(rest, dict.insert(new_dict, first, 1))
      }
    [] -> new_dict
  }
}
