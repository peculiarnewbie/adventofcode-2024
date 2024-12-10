import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 8
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  let assert 14 = pt_1(sample)
  pt_1(res) |> io.debug

  let assert 34 = pt_2(sample)
  pt_2(res) |> io.debug
}

fn pt_1(lines: List(String)) {
  let map = create_map(lines)

  let x_size = lines |> list.first |> result.unwrap("") |> string.length
  let y_size = lines |> list.length
  let dimension = #(x_size - 1, y_size - 1)

  get_total_value(map, dimension, get_anti_node)
}

fn create_map(lines: List(String)) {
  lines
  |> list.index_map(fn(line, y) {
    let dict_part = dict.new()
    line
    |> string.to_graphemes
    |> list.index_map(fn(char, x) {
      case char {
        "." -> dict_part
        _ -> {
          case dict.get(dict_part, char) {
            Ok([rest]) -> dict.insert(dict_part, char, [rest, #(x + 1, y)])
            _ -> dict.insert(dict_part, char, [#(x, y)])
          }
        }
      }
    })
    |> list.reduce(fn(acc, x) { dict.merge(acc, x) })
    |> result.unwrap(dict.new())
  })
  |> list.reduce(fn(acc, x) {
    dict.combine(acc, x, fn(a, b) { list.append(a, b) })
  })
  |> result.unwrap(dict.new())
  //   |> io.debug
}

fn get_total_value(
  map: dict.Dict(String, List(#(Int, Int))),
  dimension: #(Int, Int),
  function: fn(#(Int, Int), #(Int, Int), #(Int, Int)) -> List(#(Int, Int)),
) {
  map
  |> dict.keys
  |> list.map(fn(key) {
    map
    |> dict.get(key)
    |> result.unwrap([])
    |> list.combination_pairs
    |> list.map(fn(pair) {
      let #(coord1, coord2) = pair
      let antinode1 = function(coord1, coord2, dimension)
      let antinode2 = function(coord2, coord1, dimension)
      list.append(antinode1, antinode2)
    })
  })
  |> list.flatten
  |> list.flatten
  |> list.unique
  |> list.length
  //   |> fn(x) { x - 1 }
  //   |> io.debug
}

fn get_anti_node(
  coord1: #(Int, Int),
  coord2: #(Int, Int),
  dimension: #(Int, Int),
) {
  let diff = #(coord1.0 - coord2.0, coord1.1 - coord2.1)
  let final_coord = #(coord2.0 - diff.0, coord2.1 - diff.1)
  case
    final_coord.0 > dimension.0
    || final_coord.0 < 0
    || final_coord.1 > dimension.1
    || final_coord.1 < 0
  {
    True -> []
    False -> [final_coord]
  }
}

fn pt_2(lines: List(String)) {
  let map = create_map(lines)

  let x_size = lines |> list.first |> result.unwrap("") |> string.length
  let y_size = lines |> list.length
  let dimension = #(x_size - 1, y_size - 1)

  get_total_value(map, dimension, get_anti_node_line)
}

fn get_anti_node_line(
  coord1: #(Int, Int),
  coord2: #(Int, Int),
  dimension: #(Int, Int),
) {
  let diff = #(coord1.0 - coord2.0, coord1.1 - coord2.1)
  get_line(coord2, diff, dimension, [])
}

fn get_line(
  current_coord: #(Int, Int),
  diff: #(Int, Int),
  dimension: #(Int, Int),
  line: List(#(Int, Int)),
) {
  let new_coord = #(current_coord.0 + diff.0, current_coord.1 + diff.1)
  case
    new_coord.0 > dimension.0
    || new_coord.0 < 0
    || new_coord.1 > dimension.1
    || new_coord.1 < 0
  {
    True -> line
    False ->
      get_line(new_coord, diff, dimension, list.append(line, [new_coord]))
  }
}
