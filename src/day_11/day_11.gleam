import gleam/dict
import gleam/int
import gleam/io
import gleam/list

// import gleam/order
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 11
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  //   let assert 55_312 = pt_1(sample)
  let iteration = 75
  // list.range(1, iteration)
  // |> list.map(fn(x) { pt_1(res, x) })
  // |> list.map(fn(x) { pt_1(sample, x) })
  // pt_1(res, iteration)

  pt_2(sample, iteration)
  pt_2(res, iteration)
}

fn split_line(lines: List(String)) {
  lines
  |> list.first
  |> result.unwrap("")
  |> string.split(on: " ")
  |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
}

fn blink(line: List(Int)) {
  line
  |> list.map(fn(x) {
    let digits = int.digits(x, 10) |> result.unwrap([])
    let length = list.length(digits)
    case length % 2 {
      0 -> {
        let #(left, right) = list.split(digits, length / 2)
        [
          int.undigits(left, 10) |> result.unwrap(0),
          int.undigits(right, 10) |> result.unwrap(0),
        ]
      }
      _ -> {
        case x {
          0 -> [1]
          _ -> [x * 2024]
        }
      }
    }
  })
  |> list.flatten
}

// fn pt_1(lines: List(String), iteration: Int) {
//   split_line(lines)
//   //   |> io.debug
//   |> repeat(0, iteration, _, blink)
//   // |> io.debug
//   |> list.length
//   |> io.debug
// }

fn repeat(
  count: Int,
  limit: Int,
  res: List(Int),
  function: fn(List(Int)) -> List(Int),
) {
  case count == limit {
    True -> res
    False -> repeat(count + 1, limit, function(res), function)
  }
}

fn find_limit(val: Int, it: Int) {
  //   io.debug(#(val, it))
  let digits = val |> int.digits(10) |> result.unwrap([])
  case list.length(digits) % 2 {
    0 -> #(digits, it)
    _ -> find_limit(val * 2024, it + 1)
  }
}

// fn blink2(line: List(Int)) {
//   let temp =
//     line
//     |> list.map(fn(x) {
//       let digits = int.digits(x, 10) |> result.unwrap([])
//       let length = list.length(digits)
//       case length % 2 {
//         0 -> {
//           let #(left, right) = list.split(digits, length / 2)
//           [
//             int.undigits(left, 10) |> result.unwrap(0),
//             int.undigits(right, 10) |> result.unwrap(0),
//           ]
//         }
//         _ -> {
//           case x {
//             0 -> [-1]
//             _ -> [x * 2024]
//           }
//         }
//       }
//     })
//     |> list.flatten

//   let cache = temp |> list.filter(fn(x) { x == -1 }) |> list.length

//   #(list.filter(temp, fn(x) { x != -1 }), cache)
// }

// fn generate_cache(res: dict.Dict(#(Int, Int), Cache), limit: Int) {
//   case limit {
//     10 -> res
//     8 ->
//       res
//       |> dict.insert(#(8, 0), Node(1, []))
//       |> dict.insert(#(8, 1), Node(1, []))
//       |> dict.insert(#(8, 2), Node(1, []))
//       |> dict.insert(#(8, 3), Node(2, []))
//       |> dict.insert(#(8, 4), Node(4, [32, 77, 26, 8]))
//     _ -> {
//       let cache = cache_num(limit, 0, limit, res)
//       generate_cache(res |> dict.merge(cache), limit + 1)
//     }
//   }
// }

pub type Cache {
  Node(it: Int, branch_to: List(Int))
}

// fn cache_num(num: Int, it: Int, val: Int, cache: dict.Dict(#(Int, Int), Cache)) {
//   //   io.debug(#(num, it, val))
//   let digits = val |> int.digits(10) |> result.unwrap([])
//   case digits |> list.length {
//     4 -> {
//       cache
//       |> dict.insert(#(num, it), Node(1, []))
//       |> dict.insert(#(num, it + 1), Node(2, []))
//       |> dict.insert(#(num, it + 2), Node(4, digits))
//     }
//     8 -> {
//       cache
//       |> dict.insert(#(num, it), Node(1, []))
//       |> dict.insert(#(num, it + 1), Node(2, []))
//       |> dict.insert(#(num, it + 2), Node(4, []))
//       |> dict.insert(#(num, it + 3), Node(8, digits))
//     }
//     _ ->
//       case num {
//         0 -> cache |> dict.insert(#(num, it + 1), Node(1, [1]))
//         _ ->
//           cache_num(
//             num,
//             it + 1,
//             val * 2024,
//             dict.insert(cache, #(num, it), Node(1, [])),
//           )
//       }
//   }
// }

fn generate_cache(num: Int, it: Int, val: Int) {
  let digits = val |> int.digits(10) |> result.unwrap([])
  let length = digits |> list.length
  case length % 2, num {
    0, 8 -> Node(it, digits)
    0, _ -> Node(it, digits)
    _, _ -> generate_cache(num, it + 2, val * 2024)
  }
}

fn pt_2(lines: List(String), iteration: Int) {
  let split_cache =
    list.range(1, 9)
    |> list.map(fn(num) { #(num, generate_cache(num, 1, num)) })
    |> list.append([#(0, Node(1, [1]))])
    |> dict.from_list
  // |> io.debug

  let #(_final_cache, vals) =
    split_line(lines)
    |> list.map(fn(x) { #(x, 0) })
    |> repeat2(0, iteration, _, blink_cache2)
    // |> io.debug
    |> list.map_fold(dict.new(), fn(acc, x) {
      case x.1 {
        0 -> #(acc, 1)
        _ -> {
          let #(val, new_map) = get_value(x.0, x.1, 0, acc, split_cache)
          #(acc |> dict.merge(new_map), val)
        }
      }
    })

  // final_cache 
  // |> io.debug

  vals |> list.fold(0, fn(acc, x) { acc + x }) |> io.debug
  //   list.range(1, 9)
  //   |> list.map(fn(x) {
  //     let #(digits, it) = find_limit(x, 0)
  //     #(x, digits |> int.undigits(10) |> result.unwrap(0), it)
  //   })
}

// fn pretty_print(cache: dict.Dict(#(Int, Int), Int)) {
//   cache
//   |> dict.to_list
//   |> list.sort(fn(a, b) {
//     case a.0.0 > b.0.0 {
//       True -> order.Gt
//       False ->
//         case a.0.0 == b.0.0 {
//           True ->
//             case a.0.1 > b.0.1 {
//               True -> order.Gt
//               False -> order.Lt
//             }
//           False -> order.Lt
//         }
//     }
//   })
//   |> list.map(fn(x) { io.debug(x) })
// }

fn get_value(
  num: Int,
  target: Int,
  it: Int,
  cache: dict.Dict(#(Int, Int), Int),
  split_cache: dict.Dict(Int, Cache),
) -> #(Int, dict.Dict(#(Int, Int), Int)) {
  // io.debug(#("start", num, target, it, cache))
  let target_hit = cache |> dict.get(#(num, target))
  case target_hit {
    Ok(val) -> {
      // io.debug(#(num, target, val))
      #(val, cache)
    }
    Error(_) -> {
      let hit = cache |> dict.get(#(num, it))
      case hit {
        Ok(_) -> {
          // io.debug("hit")
          get_value(num, target, it + 1, cache, split_cache)
        }
        Error(_) -> {
          let branches = get_branch(num, it, split_cache)
          let #(total, map) =
            branches
            |> list.map_fold(0, fn(memo, branch) {
              let #(val, new_map) =
                find_value(branch.0, branch.1, cache, split_cache)
              let new_memo = memo + val
              #(new_memo, new_map |> dict.insert(branch, val))
            })
          let new_dict =
            map
            |> list.fold(dict.new(), fn(acc, map) { acc |> dict.merge(map) })
            |> dict.insert(#(num, it), total)
          // let added = find_value(num, it, cache, split_cache)
          // let value = added |> dict.fold(0, fn(acc, _, value) { acc + value })
          // io.debug(#("split", num, target, added, value))
          // let new_dict =
          //   cache |> dict.insert(#(num, it), value) |> dict.merge(added)
          // io.debug(#("adding", num, target, cache, added))
          get_value(num, target, it, new_dict, split_cache)
        }
      }
    }
  }
}

fn get_branch(num: Int, target: Int, split_cache: dict.Dict(Int, Cache)) {
  let hit = split_cache |> dict.get(num)
  case hit {
    Ok(Node(it_diff, branch_to)) -> {
      case target < it_diff {
        True -> {
          [#(num, target)]
        }
        False -> {
          case num {
            8 -> {
              let new_target = target - it_diff
              [
                #(3, new_target),
                #(2, new_target),
                #(7, new_target),
                #(7, new_target),
                #(2, new_target),
                #(6, new_target),
                #(8, new_target + 1),
              ]
              // [#(3, 0), #(2, 0), #(7, 0), #(7, 0), #(2, 0), #(6, 0), #(8, 1)]
            }
            _ ->
              branch_to
              |> list.map(fn(x) { #(x, target - it_diff) })
          }
          // node_list |> dict.from_list |> dict.insert(#(num, target), value)
        }
      }
    }
    _ -> []
  }
}

fn find_value(
  num: Int,
  target: Int,
  cache: dict.Dict(#(Int, Int), Int),
  split_cache: dict.Dict(Int, Cache),
) {
  let hit = split_cache |> dict.get(num)
  case hit {
    Ok(Node(it_diff, _)) -> {
      case target < it_diff {
        True -> {
          #(repeat(0, target, [num], blink) |> list.length, dict.new())
        }
        False -> {
          get_value(num, target, target - 1, cache, split_cache)
        }
        // node_list |> dict.from_list |> dict.insert(#(num, target), value)
      }
    }
    _ -> #(0, dict.new())
  }
}

fn blink_cache2(line: List(#(Int, Int))) {
  line
  |> list.map(fn(x) {
    let #(num, it) = x
    case num >= 0 && num <= 9 {
      True -> [#(num, it + 1)]
      False -> {
        let digits = num |> int.digits(10) |> result.unwrap([])
        let length = list.length(digits)
        case length % 2 {
          0 -> {
            let #(left, right) = list.split(digits, length / 2)
            [
              #(int.undigits(left, 10) |> result.unwrap(0), 0),
              #(int.undigits(right, 10) |> result.unwrap(0), 0),
            ]
          }
          _ -> [#(num * 2024, 0)]
        }
      }
    }
  })
  //   |> io.debug
  |> list.flatten
}

fn repeat2(
  count: Int,
  limit: Int,
  res: List(#(Int, Int)),
  function: fn(List(#(Int, Int))) -> List(#(Int, Int)),
) {
  // io.debug(#(count, list.length(res)))
  case count == limit {
    True -> res
    False -> {
      let new_res = function(res)
      repeat2(count + 1, limit, new_res, function)
    }
  }
}
