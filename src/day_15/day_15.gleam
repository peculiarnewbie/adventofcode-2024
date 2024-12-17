import gleam/dict

// import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 15
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  let assert 10_092 = pt_1(sample)
  // pt_1(res)

  pt_2(sample)
  pt_2(res)
}

fn pt_1(lines: List(String)) {
  let #(map, movement, init_pos, size) = split_input(lines)
  let final_map = move_bot(map, movement, init_pos)
  print_map(final_map, size)
  final_map |> calculate_gps |> io.debug
}

fn move_bot(
  map: dict.Dict(#(Int, Int), String),
  movement: List(Int),
  //   size: #(Int, Int),
  pos: #(Int, Int),
) {
  case movement {
    [] -> map
    _ -> {
      let #(x, y) = pos
      let #(x_move, y_move) =
        movement |> list.first |> result.unwrap(0) |> get_direction
      //   print_map(map, #(10, 10))
      //   io.print("\n")
      //   io.debug(#(pos, x_move, y_move))

      let next_pos = #(x + x_move, y + y_move)
      let next_char = map |> dict.get(next_pos)
      case next_char {
        Ok("#") -> move_bot(map, movement |> list.drop(1), #(x, y))
        Ok(".") -> {
          let new_map =
            map
            |> dict.insert(#(x, y), ".")
            |> dict.insert(#(x + x_move, y + y_move), "@")
          move_bot(new_map, movement |> list.drop(1), next_pos)
        }
        // Ok("O") -> move_bot(map, movement |> list.drop(1), #(x, y))
        Ok("O") -> {
          let #(able, edge) = can_move_box(map, #(x_move, y_move), next_pos)
          //   io.debug(#(able, pos, next_pos, edge))
          case able {
            False -> move_bot(map, movement |> list.drop(1), pos)
            True -> {
              let new_map =
                map
                |> dict.insert(next_pos, "@")
                |> dict.insert(edge, "O")
                |> dict.insert(pos, ".")
              move_bot(new_map, movement |> list.drop(1), next_pos)
            }
          }
        }
        _ -> dict.new()
      }
    }
  }
}

fn can_move_box(
  map: dict.Dict(#(Int, Int), String),
  movement: #(Int, Int),
  pos: #(Int, Int),
) {
  let next_pos = #(pos.0 + movement.0, pos.1 + movement.1)
  case map |> dict.get(next_pos) {
    Ok("#") -> #(False, pos)
    Ok(".") -> #(True, next_pos)
    Ok("O") -> can_move_box(map, movement, next_pos)
    _ -> #(False, pos)
  }
}

fn print_map(map: dict.Dict(#(Int, Int), String), size: #(Int, Int)) {
  io.print("\u{001b}[H")
  let horizontal = list.range(0, size.1)
  let vertical = list.range(0, size.0)

  let res =
    horizontal
    |> list.map(fn(y) {
      let line =
        vertical
        |> list.map(fn(x) {
          case dict.get(map, #(x, y)) {
            Ok(a) -> a
            _ -> "X"
          }
        })

      line |> list.fold("", fn(acc, x) { acc <> x })
    })
    |> list.fold("", fn(acc, x) { acc <> "\n" <> x })
  io.print(res)
  map
}

fn calculate_gps(map: dict.Dict(#(Int, Int), String)) {
  map
  |> dict.to_list
  |> list.fold(0, fn(acc, node) {
    case node.1 {
      "O" -> {
        io.debug(node)
        let #(x, y) = node.0
        acc + x + 100 * y
      }
      _ -> acc
    }
  })
}

fn pt_2(lines: List(String)) {
  let #(map, movement, init_pos, size) = split_input_2(lines)
  print_map(map, size)

  let final_map = move_bot_2(map, movement, init_pos) |> print_map(size)
  final_map
  |> dict.to_list
  |> list.filter(fn(x) { x.1 == "[" })
  |> list.fold(0, fn(acc, x) {
    let #(x, y) = x.0
    acc + x + 100 * y
  })
  |> io.debug
}

fn move_bot_2(
  map: dict.Dict(#(Int, Int), String),
  movement: List(Int),
  pos: #(Int, Int),
) {
  // io.debug(#(pos, movement))
  case movement {
    [] -> map
    _ -> {
      let #(x, y) = pos
      let #(x_move, y_move) =
        movement |> list.first |> result.unwrap(0) |> get_direction
      // print_map(map, #(19, 9))
      // process.sleep(50)
      //   io.debug(#(pos, x_move, y_move))

      let next_pos = #(x + x_move, y + y_move)
      let next_char = map |> dict.get(next_pos)
      case next_char {
        Ok("#") -> move_bot_2(map, movement |> list.drop(1), #(x, y))
        Ok(".") -> {
          let new_map =
            map
            |> dict.insert(#(x, y), ".")
            |> dict.insert(#(x + x_move, y + y_move), "@")
          move_bot_2(new_map, movement |> list.drop(1), next_pos)
        }
        // Ok("O") -> move_bot(map, movement |> list.drop(1), #(x, y))
        Ok("[") -> try_move_box(map, movement, pos)
        Ok("]") -> try_move_box(map, movement, pos)
        _ -> dict.new()
      }
    }
  }
}

fn try_move_box(
  map: dict.Dict(#(Int, Int), String),
  movement: List(Int),
  pos: #(Int, Int),
) {
  let dir = movement |> list.first |> result.unwrap(-1)
  let horizontal = case dir {
    1 -> True
    3 -> True
    _ -> False
  }

  case horizontal {
    True -> try_move_box_horizontal(map, movement, pos)
    False -> try_move_box_vertical(map, movement, pos)
    // try_move_box_vertical(map, movement, pos, right)
  }
}

fn try_move_box_vertical(
  map: dict.Dict(#(Int, Int), String),
  movement: List(Int),
  pos: #(Int, Int),
) {
  // print_map(map, #(13, 6))
  let dir = movement |> list.first |> result.unwrap(-1)
  let #(_, y_move) = dir |> get_direction
  // io.debug("can move vertical")
  let can_move =
    can_move_box_2_vertical(map, dir, pos, "@", []) |> list.all(fn(x) { x })
  // io.debug(#(pos, "can_move_vertical", can_move))
  case can_move {
    True -> {
      let moved =
        dict.new()
        |> dict.insert(pos, ".")
        |> move_box_2_vertical(map, dir, pos, "@")
      move_bot_2(map |> dict.merge(moved), movement |> list.drop(1), #(
        pos.0,
        pos.1 + y_move,
      ))
    }
    False -> move_bot_2(map, movement |> list.drop(1), pos)
  }
}

fn move_box_2_vertical(
  moved: dict.Dict(#(Int, Int), String),
  map: dict.Dict(#(Int, Int), String),
  dir: Int,
  pos: #(Int, Int),
  last_char: String,
) {
  let #(_, y_move) = dir |> get_direction
  let next_pos = #(pos.0, pos.1 + y_move)
  let next_char = map |> dict.get(next_pos) |> result.unwrap("")
  // io.debug(#(pos, dir, last_char, next_char))
  case last_char {
    "@" -> {
      let new_moved = moved |> dict.insert(next_pos, "@")
      case next_char {
        "[" -> {
          let left = new_moved |> move_box_2_vertical(map, dir, next_pos, "[")
          let right_pos = #(pos.0 + 1, next_pos.1)
          let right =
            new_moved
            |> dict.merge(left)
            |> dict.insert(right_pos, ".")
            |> move_box_2_vertical(map, dir, right_pos, "]")
          new_moved |> dict.merge(right)
        }
        "]" -> {
          let left_pos = #(pos.0 - 1, next_pos.1)
          let left =
            new_moved
            |> dict.insert(left_pos, ".")
            |> move_box_2_vertical(map, dir, left_pos, "[")
          let right =
            new_moved
            |> dict.merge(left)
            |> move_box_2_vertical(map, dir, next_pos, "]")
          new_moved |> dict.merge(right)
        }
        _ -> dict.new()
      }
    }
    _ -> {
      let new_moved = moved |> dict.insert(next_pos, last_char)
      case last_char == next_char {
        True -> new_moved |> move_box_2_vertical(map, dir, next_pos, last_char)
        False -> {
          case next_char {
            "[" -> {
              let right_pos = #(pos.0 + 1, next_pos.1)
              let left =
                new_moved |> move_box_2_vertical(map, dir, next_pos, "[")
              let all = new_moved |> dict.merge(left)
              case all |> dict.get(right_pos) {
                Ok(_) -> all |> move_box_2_vertical(map, dir, next_pos, "[")
                _ -> {
                  let right =
                    all
                    |> dict.insert(right_pos, ".")
                    |> move_box_2_vertical(map, dir, right_pos, "]")
                  all |> dict.merge(right)
                }
              }
            }
            "]" -> {
              let left_pos = #(pos.0 - 1, next_pos.1)
              let right =
                new_moved
                |> move_box_2_vertical(map, dir, next_pos, "]")
              let all = new_moved |> dict.merge(right)
              case all |> dict.get(left_pos) {
                Ok(_) -> all |> move_box_2_vertical(map, dir, next_pos, "]")
                _ -> {
                  let left =
                    all
                    |> dict.insert(left_pos, ".")
                    |> move_box_2_vertical(map, dir, left_pos, "[")
                  all |> dict.merge(left)
                }
              }
            }
            "." -> {
              case moved |> dict.get(pos) {
                Ok(_) -> moved |> dict.insert(next_pos, last_char)
                _ ->
                  moved
                  |> dict.insert(pos, ".")
                  |> dict.insert(next_pos, last_char)
              }
            }
            _ -> dict.new()
          }
        }
      }
    }
  }
}

fn can_move_box_2_vertical(
  map: dict.Dict(#(Int, Int), String),
  dir: Int,
  pos: #(Int, Int),
  last_char: String,
  final_list: List(Bool),
) {
  // io.debug(#(pos, dir, last_char))
  let #(x_move, y_move) = dir |> get_direction
  let next_pos = #(pos.0 + x_move, pos.1 + y_move)
  case map |> dict.get(next_pos) {
    Ok("#") -> [False]
    Ok(".") -> final_list |> list.append([True])
    Ok("[") -> {
      case last_char == "[" {
        True -> can_move_box_2_vertical(map, dir, next_pos, "[", final_list)
        False -> {
          let left =
            can_move_box_2_vertical(map, dir, next_pos, "[", final_list)
          let right =
            can_move_box_2_vertical(
              map,
              dir,
              #(pos.0 + 1, next_pos.1),
              "]",
              final_list,
            )
          // io.debug(#("[", pos, "left", left, "right", right, last_char))

          let left_case = left |> list.all(fn(x) { x })
          let right_case = right |> list.all(fn(x) { x })
          case left_case, right_case {
            True, True -> final_list |> list.append(left) |> list.append(right)
            _, _ -> [False]
          }
        }
      }
    }
    Ok("]") -> {
      case last_char == "]" {
        True -> can_move_box_2_vertical(map, dir, next_pos, "]", final_list)
        False -> {
          let left =
            can_move_box_2_vertical(
              map,
              dir,
              #(pos.0 - 1, next_pos.1),
              "[",
              final_list,
            )
          let right =
            can_move_box_2_vertical(map, dir, next_pos, "]", final_list)
          // io.debug(#("]", pos, "left", left, "right", right, last_char))
          let left_case = left |> list.all(fn(x) { x })
          let right_case = right |> list.all(fn(x) { x })
          case left_case, right_case {
            True, True -> final_list |> list.append(left) |> list.append(right)
            _, _ -> [False]
          }
        }
      }
    }
    _ -> [False]
  }
}

fn try_move_box_horizontal(
  map: dict.Dict(#(Int, Int), String),
  movement: List(Int),
  pos: #(Int, Int),
) {
  let dir = movement |> list.first |> result.unwrap(-1)
  let #(x_move, _) = dir |> get_direction
  case can_move_box_2(map, dir, pos) {
    #(True, edge) -> {
      let next_pos = #(pos.0 + x_move, pos.1)
      let x_diff = { edge.0 - pos.0 } |> int.absolute_value
      let range = list.range(1, x_diff)
      let affected = range |> list.map(fn(x) { pos.0 + x * x_move })
      let first_char = map |> dict.get(next_pos) |> result.unwrap("")
      let new_map =
        move_horizontal(map, affected, pos, first_char)
        |> dict.insert(pos, ".")
        |> dict.insert(next_pos, "@")
      // print_map(new_map, #(13, 6))
      move_bot_2(new_map, movement |> list.drop(1), next_pos)
    }
    _ -> move_bot_2(map, movement |> list.drop(1), pos)
  }
}

fn move_horizontal(
  map: dict.Dict(#(Int, Int), String),
  line: List(Int),
  pos: #(Int, Int),
  inserted_last: String,
) {
  case line {
    [] -> map
    _ -> {
      let next_insert = case inserted_last {
        "[" -> "]"
        "]" -> "["
        _ -> "."
      }
      let x_pos = line |> list.first |> result.unwrap(0)
      let next_pos = #(x_pos, pos.1)
      let new_map = map |> dict.insert(#(x_pos, pos.1), next_insert)
      move_horizontal(new_map, line |> list.drop(1), next_pos, next_insert)
    }
  }
}

fn can_move_box_2(
  map: dict.Dict(#(Int, Int), String),
  dir: Int,
  pos: #(Int, Int),
) {
  let #(x_move, y_move) = dir |> get_direction
  let next_pos = #(pos.0 + x_move, pos.1 + y_move)
  case map |> dict.get(next_pos) {
    Ok("#") -> #(False, pos)
    Ok(".") -> #(True, next_pos)
    Ok("[") -> can_move_box_2(map, dir, next_pos)
    Ok("]") -> can_move_box_2(map, dir, next_pos)
    _ -> #(False, pos)
  }
}

fn split_input_2(lines: List(String)) {
  let #(init_map, mov) = lines |> list.split_while(fn(x) { x != "" })
  let movement = mov |> create_movement_list
  let #(map, init_pos, size) = init_map |> expand_map
  #(map, movement, init_pos, size)
}

fn expand_map(init_map: List(String)) {
  let height = init_map |> list.length
  let width =
    init_map
    |> list.first
    |> result.unwrap("")
    |> string.length
    |> int.multiply(2)

  let final_list =
    init_map
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.map(fn(char) {
        case char {
          "#" -> "##"
          "." -> ".."
          "O" -> "[]"
          "@" -> "@."
          _ -> "WW"
        }
        |> string.to_graphemes
      })
      |> list.flatten
      |> list.index_map(fn(char, x) { #(#(x, y), char) })
    })
    |> list.flatten

  let #(init_pos, _) =
    final_list
    |> list.find(fn(x) { x.1 == "@" })
    |> result.unwrap(#(#(0, 0), "x"))

  #(final_list |> dict.from_list, init_pos, #(width - 1, height - 1))
}

fn create_movement_list(lines: List(String)) {
  lines
  |> list.drop(1)
  |> list.fold("", fn(acc, x) { acc <> x })
  |> string.to_graphemes
  |> list.map(fn(x) {
    case x {
      "^" -> 0
      ">" -> 1
      "v" -> 2
      "<" -> 3
      _ -> -1
    }
  })
}

fn split_input(lines: List(String)) {
  let #(init_map, mov) = lines |> list.split_while(fn(x) { x != "" })
  let movement = mov |> create_movement_list

  let height = init_map |> list.length
  let width = init_map |> list.first |> result.unwrap("") |> string.length

  let final_list =
    init_map
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(char, x) { #(#(x, y), char) })
    })
    |> list.flatten

  let #(init_pos, _) =
    final_list
    |> list.find(fn(x) {
      case x.1 {
        "@" -> True
        _ -> False
      }
    })
    |> result.unwrap(#(#(0, 0), "x"))

  let final_map = dict.from_list(final_list)

  #(final_map, movement, init_pos, #(width - 1, height - 1))
}

fn get_direction(dir: Int) {
  case dir {
    0 -> #(0, -1)
    1 -> #(1, 0)
    2 -> #(0, 1)
    3 -> #(-1, 0)
    _ -> #(0, 0)
  }
}
