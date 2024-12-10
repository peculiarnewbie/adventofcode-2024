import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 9
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  //   let assert 1928 = pt_1(sample)
  //   pt_1(res)

  pt_2(sample)
}

fn pt_1(lines: List(String)) {
  let line = lines |> list.first() |> result.unwrap("") |> string.trim()
  let values =
    line
    |> string.to_graphemes
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })

  values
  |> list.index_map(fn(x, i) {
    case i % 2 {
      0 -> list.repeat(i / 2, x)
      _ -> list.repeat(-1, x)
    }
  })
  |> list.flatten
  //   |> io.debug
  |> list.index_map(fn(x, i) { #(i, x) })
  //   |> io.debug
  |> dict.from_list
  |> fn(x) { condense(x, 0, dict.size(x) - 1) }
  //   |> io.debug
  |> dict.fold(0, fn(acc, key, val) {
    case val {
      -1 -> acc
      _ -> acc + key * val
    }
  })
  |> io.debug
}

fn condense(map: dict.Dict(Int, Int), index: Int, edge: Int) {
  case index > edge {
    True -> map
    False -> {
      let current_val = map |> dict.get(index) |> result.unwrap(0)
      let flip_val = map |> dict.get(edge) |> result.unwrap(0)
      case current_val, flip_val {
        _, -1 -> condense(map, index, edge - 1)
        -1, a ->
          condense(
            map |> dict.insert(index, a) |> dict.insert(edge, -1),
            index + 1,
            edge - 1,
          )
        _, _ -> condense(map, index + 1, edge)
      }
    }
  }
}

fn condense_list(line: List(Int), index: Int) {
  let #(first, second) = line |> list.split(index)
  case second {
    [] -> line
    _ -> {
      //   io.debug(index)
      case list.first(second) {
        Ok(-1) -> {
          {
            case list.last(second) {
              Ok(-1) -> {
                let #(new_line, _) = line |> list.split(list.length(line) - 1)
                condense_list(new_line, index)
              }
              _ -> {
                let #(new_second, last) =
                  second |> list.drop(1) |> list.split(list.length(second) - 2)
                condense_list(
                  first |> list.append(last) |> list.append(new_second),
                  index + 1,
                )
              }
            }
          }
        }
        Ok(_) -> condense_list(line, index + 1)
        Error(_) -> condense_list(line, index + 1)
      }
    }
  }
  //   io.debug(#(line, first, second))
}

pub type Element {
  Info(size: Int, val: Int)
}

fn pt_2(lines: List(String)) {
  let line = lines |> list.first() |> result.unwrap("") |> string.trim()
  let values =
    line
    |> string.to_graphemes
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })

  values
  |> list.index_map(fn(x, i) {
    case i % 2 {
      0 -> Info(x, i / 2)
      _ -> Info(x, -1)
    }
  })
  |> io.debug
}
