import gleam/dict

// import gleam/int
import gleam/io
import gleam/list

// import gleam/order
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 12
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  let assert 1930 = pt_1(sample)
  pt_1(res)

  pt_2(sample)
  pt_2(res)
}

fn pt_1(lines: List(String)) {
  generate_map(lines)
  |> generate_areas
  |> get_total_values
  |> io.debug
  // let r = create_area(map, #(0, 0), dict.new()) |> io.debug
  // let r2 = create_area(map, #(0, 1), r) |> io.debug
}

fn generate_map(lines: List(String)) {
  lines
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(char, x) { #(#(x, y), char) })
  })
  |> list.flatten
  |> dict.from_list
}

fn generate_areas(map: dict.Dict(#(Int, Int), String)) {
  map
  |> dict.to_list
  |> list.index_fold(dict.new(), fn(acc, node, index) {
    let #(coord, _) = node
    case acc |> dict.get(coord) {
      Error(_) -> {
        let area = create_area(map, coord, acc, index)
        acc |> dict.merge(area)
      }
      Ok(_) -> acc
    }
  })
}

fn get_total_values(map: dict.Dict(#(Int, Int), #(Int, Int))) {
  map
  |> dict.fold(dict.new(), fn(acc, _, value) {
    let #(code, fence_count) = value
    case acc |> dict.get(code) {
      Ok(#(area, per)) ->
        acc
        |> dict.insert(code, #(area + 1, per + fence_count))
      Error(_) -> acc |> dict.insert(code, #(1, fence_count))
    }
  })
  |> dict.fold(0, fn(acc, _, data) {
    let #(area, perimeter) = data
    acc + area * perimeter
  })
}

fn create_area(
  map: dict.Dict(#(Int, Int), String),
  node: #(Int, Int),
  final_map: dict.Dict(#(Int, Int), #(Int, Int)),
  code: Int,
) {
  let #(x, y) = node
  let root_grapheme = map |> dict.get(node) |> result.unwrap("")
  case final_map |> dict.get(node) {
    Ok(_) -> final_map
    Error(_) -> {
      let neighbour_list =
        [#(x, y - 1), #(x + 1, y), #(x, y + 1), #(x - 1, y)]
        |> list.map(fn(pos) {
          let grapheme = map |> dict.get(pos) |> result.unwrap("")
          #(pos, grapheme)
        })
      let fence_count =
        neighbour_list
        |> list.fold(0, fn(acc, neighbor_node) {
          case neighbor_node.1 == root_grapheme {
            True -> acc
            False -> acc + 1
          }
        })
      let new_acc = final_map |> dict.insert(node, #(code, fence_count))
      list.fold(neighbour_list, new_acc, fn(acc, node) {
        let #(pos, grapheme) = node
        case grapheme == root_grapheme {
          False -> acc
          True -> acc |> dict.merge(create_area(map, pos, acc, code))
        }
      })
    }
  }
}

fn pt_2(lines: List(String)) {
  let areas =
    generate_map(lines)
    |> generate_areas

  let area_dict =
    areas
    |> dict.fold(dict.new(), fn(acc, _, data) {
      let #(code, _) = data
      case acc |> dict.get(code) {
        Ok(count) -> acc |> dict.insert(code, count + 1)
        Error(_) -> acc |> dict.insert(code, 1)
      }
    })

  generate_border(areas)
  |> list.map(fn(x) {
    let clean_border =
      invalidate_border(x)
      |> dict.to_list
    #(x.0, clean_border)
  })
  |> list.map(fn(area) {
    let #(code, area) = area
    let perimeter = area |> list.filter(fn(x) { x.1 }) |> list.length
    let size = area_dict |> dict.get(code) |> result.unwrap(0)
    size * perimeter
  })
  |> list.fold(0, fn(acc, x) { acc + x })
  |> io.debug
  // |> pretty_print_map
}

fn generate_border(map: dict.Dict(#(Int, Int), #(Int, Int))) {
  map
  |> dict.to_list
  |> list.map(fn(node) {
    let #(#(x, y), #(code, _)) = node
    [#(#(x, y - 1), 0), #(#(x + 1, y), 1), #(#(x, y + 1), 2), #(#(x - 1, y), 3)]
    |> list.map(fn(neighbour) {
      let #(pos, dir) = neighbour
      // let #(x, y) = pos
      let #(grapheme, _) = map |> dict.get(pos) |> result.unwrap(#(-1, -1))
      let data = {
        grapheme != code
      }
      #(code, #(#(x, y), dir), data)
    })
    |> list.filter(fn(x) { x.2 })
  })
  |> list.flatten
  |> list.group(fn(x) {
    let #(code, _, _) = x
    code
  })
  |> dict.to_list
  |> list.map(fn(x) {
    let #(code, line) = x
    let new_line =
      line
      |> list.map(fn(node) {
        let #(_, coord, data) = node
        #(coord, data)
      })
    #(code, new_line)
  })
}

fn invalidate_border(border: #(Int, List(#(#(#(Int, Int), Int), Bool)))) {
  let #(_, line) = border
  let map = line |> dict.from_list
  line
  |> list.fold(map, fn(acc, node) {
    let #(#(coord, dir), _) = node
    let data = acc |> dict.get(#(coord, dir)) |> result.unwrap(False)
    case data {
      False -> acc
      True -> {
        let same_side = get_same_side(coord, dir, acc)
        let new_dict =
          same_side
          |> list.fold(dict.new(), fn(in_acc, in_node) {
            let #(coord, dir) = in_node
            in_acc |> dict.insert(#(coord, dir), False)
          })
        acc |> dict.merge(new_dict)
      }
    }
  })
}

fn get_same_side(
  coord: #(Int, Int),
  dir: Int,
  border: dict.Dict(#(#(Int, Int), Int), Bool),
) {
  // 
  let horizontal = case dir {
    0 -> True
    1 -> False
    2 -> True
    _ -> False
  }

  let #(x, y) = coord

  case horizontal {
    True -> {
      let left = traverse_border(#(x - 1, y), dir, #(-1, 0), border, [])
      let right = traverse_border(#(x + 1, y), dir, #(1, 0), border, [])
      left |> list.append(right)
    }
    False -> {
      let top = traverse_border(#(x, y - 1), dir, #(0, -1), border, [])
      let bottom = traverse_border(#(x, y + 1), dir, #(0, 1), border, [])
      top |> list.append(bottom)
    }
  }
}

fn traverse_border(
  coord: #(Int, Int),
  dir: Int,
  traverse_dir: #(Int, Int),
  border: dict.Dict(#(#(Int, Int), Int), Bool),
  res: List(#(#(Int, Int), Int)),
) {
  let node = border |> dict.get(#(coord, dir))
  case node {
    Ok(data) -> {
      case data {
        True -> {
          let #(x, y) = coord
          let #(x2, y2) = traverse_dir
          let new_coord = #(x + x2, y + y2)
          traverse_border(
            new_coord,
            dir,
            traverse_dir,
            border,
            res |> list.append([#(#(x, y), dir)]),
          )
        }
        False -> res
      }
    }
    Error(_) -> res
  }
}
// fn pretty_print_map(map: dict.Dict(#(Int, Int), #(Int, Int))) {
//   map
//   |> dict.to_list
//   |> list.sort(fn(a, b) {
//     case int.compare(a.1.0, b.1.0) {
//       order.Eq ->
//         case int.compare(a.0.1, b.0.1) {
//           order.Eq ->
//             case a.0.0 > b.0.0 {
//               True -> order.Gt
//               False -> order.Lt
//             }

//           ord -> ord
//         }
//       ord -> ord
//     }
//   })
//   |> list.map(fn(x) {
//     io.debug(x)
//     x
//   })
// }

// fn pretty_print_border(border: dict.Dict(#(Int, #(Int, Int), Int), Bool)) {
//   border
//   |> dict.to_list
//   // |> list.sort(fn(a, b) {
//   //   case int.compare
//   // })
// }
