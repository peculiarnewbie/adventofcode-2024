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

  let assert 1928 = pt_1(sample)
  pt_1(res)

  let assert 2858 = pt_2(sample)
  pt_2(res)
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
  |> list.filter(fn(x) {
    case x {
      Info(a, _) -> a != 0
    }
  })
  |> fn(x) {
    condense_2(x, list.length(x) - 1, 1_000_000_000_000_000_000_000_000_000_000)
  }
  |> list.flat_map(fn(x) {
    let Info(size, val) = x
    list.repeat(val, size)
  })
  //   |> io.debug
  |> list.index_fold(0, fn(acc, x, i) {
    case x {
      -1 -> acc
      _ -> acc + x * i
    }
  })
  |> io.debug
}

fn condense_2(
  line: List(Element),
  edge: Int,
  last_checked: Int,
) -> List(Element) {
  let #(rest, back) = line |> list.split(edge)
  //   io.debug(#(edge, last_checked, rest, back))
  let edge_info = back |> list.first
  case rest, edge_info {
    [], _ -> line
    _, Ok(Info(_, -1)) ->
      condense_2(rest |> list.append(back), edge - 1, last_checked)
    _, Ok(Info(size, val)) -> {
      case val >= last_checked {
        True -> condense_2(rest |> list.append(back), edge - 1, last_checked)
        False -> {
          let #(left, right) = when_fits_splits(rest, size)
          case right {
            [] ->
              condense_2(
                left
                  |> list.append(back),
                edge - 1,
                val,
              )
            _ -> {
              //   io.debug(#("swap", Info(size, val), left, right))
              let Info(s, v) = right |> list.first |> result.unwrap(Info(0, 0))
              let add_list = case size == v {
                True -> [Info(size, val)]
                False -> [Info(size, val), Info(s - size, v)]
              }
              condense_2(
                left
                  |> list.append(add_list)
                  |> list.append(right |> list.drop(1))
                  |> list.append(
                    back |> list.drop(1) |> list.prepend(Info(size, -1)),
                  ),
                edge,
                val,
              )
            }
          }
        }
      }
    }
    _, _ -> line
  }
}

fn when_fits_splits(line: List(Element), size: Int) {
  line
  |> list.split_while(fn(x) {
    case x {
      Info(a, -1) -> size > a
      Info(_, _) -> True
    }
  })
}
// fn condense_list(line: List(Int), index: Int) {
//   let #(first, second) = line |> list.split(index)
//   case second {
//     [] -> line
//     _ -> {
//       //   io.debug(index)
//       case list.first(second) {
//         Ok(-1) -> {
//           {
//             case list.last(second) {
//               Ok(-1) -> {
//                 let #(new_line, _) = line |> list.split(list.length(line) - 1)
//                 condense_list(new_line, index)
//               }
//               _ -> {
//                 let #(new_second, last) =
//                   second |> list.drop(1) |> list.split(list.length(second) - 2)
//                 condense_list(
//                   first |> list.append(last) |> list.append(new_second),
//                   index + 1,
//                 )
//               }
//             }
//           }
//         }
//         Ok(_) -> condense_list(line, index + 1)
//         Error(_) -> condense_list(line, index + 1)
//       }
//     }
//   }
//   //   io.debug(#(line, first, second))
// }
