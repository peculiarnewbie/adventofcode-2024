import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

// 934154
// too low

// 1216392
// too high

pub fn main() {
  let day = 20
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  //   let assert 143 = 
  pt_1(sample)
  //   pt_1(res)
  //   pt_2(sample, 49)
  pt_2(res, 99)
}

pub type Coord {
  Coord(x: Int, y: Int)
}

pub type Path {
  Path(coord: Coord, score: Int, path: List(Coord))
}

pub type Info {
  Start
  End
}

fn pt_1(lines: List(String)) {
  let #(map, info, size) = generate_map(lines)
  let start_coord = info |> dict.get(Start) |> result.unwrap(Coord(0, 0))
  let end_coord = info |> dict.get(End) |> result.unwrap(Coord(0, 0))

  traverse_normal([Path(start_coord, 0, [])], map, end_coord)
  |> result.unwrap([])
  |> print_path(map, size)
  |> find_cheats(map)
  |> list.fold(0, fn(acc, skip) {
    case skip > 99 {
      True -> acc + 1
      False -> acc
    }
  })
  |> io.debug
}

fn pt_2(lines: List(String), lower_limit: Int) {
  let #(map, info, _) = generate_map(lines)
  let start_coord = info |> dict.get(Start) |> result.unwrap(Coord(0, 0))
  let end_coord = info |> dict.get(End) |> result.unwrap(Coord(0, 0))

  traverse_normal([Path(start_coord, 0, [])], map, end_coord)
  |> result.unwrap([])
  |> find_hyper_cheats(map, lower_limit)
  |> dict.fold(0, fn(acc, _, value) { acc + value })
  //   |> list.fold(0, fn(acc, skip) {
  //     io.debug(skip)
  //     case skip > 99 {
  //       True -> acc + 1
  //       False -> acc
  //     }
  //   })
  //   |> list.fold(dict.new(), fn(acc, skip) {
  //     case acc |> dict.get(skip) {
  //       Ok(val) -> acc |> dict.insert(skip, val + 1)
  //       _ -> acc |> dict.insert(skip, 1)
  //     }
  //   })
  |> io.debug
}

fn generate_map(lines: List(String)) {
  let y_size = lines |> list.length
  let x_size = lines |> list.first |> result.unwrap("") |> string.length
  lines
  |> list.index_fold([], fn(acc, line, y) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(char, x) { #(Coord(x, y), char) })
    |> list.append(acc, _)
  })
  |> list.fold(#(dict.new(), dict.new()), fn(acc, node) {
    let #(coords, info) = acc
    let #(Coord(x, y), char) = node
    let new_info = case char {
      "S" -> info |> dict.insert(Start, Coord(x, y))
      "E" -> info |> dict.insert(End, Coord(x, y))
      _ -> info
    }
    #(coords |> dict.insert(Coord(x, y), char), new_info)
  })
  |> fn(x) {
    let #(coords, info) = x
    #(coords, info, Coord(x_size, y_size))
  }
}

fn traverse_normal(
  prio_queue: List(Path),
  map: dict.Dict(Coord, String),
  end: Coord,
) -> Result(List(Coord), Nil) {
  use current_node <- check_queue(prio_queue)
  let Path(current_coord, score, path) = current_node

  use _ <- check_end(current_coord, end, path)
  let new_map = map |> dict.delete(current_coord)

  find_neighbours(new_map, current_coord, 1)
  |> list.map(fn(neighbour) {
    let #(next_coord, _) = neighbour
    Path(next_coord, score + 1, path |> list.append([current_coord]))
  })
  |> list.append(prio_queue, _)
  |> list.drop(1)
  |> list.sort(fn(a, b) {
    let Path(_, a_score, _) = a
    let Path(_, b_score, _) = b
    int.compare(a_score, b_score)
  })
  |> traverse_normal(new_map, end)
}

fn find_cheats(path: List(Coord), map: dict.Dict(Coord, String)) {
  let path_map =
    path |> list.index_map(fn(coord, i) { #(coord, i) }) |> dict.from_list

  traverse_cheats(path, map, path_map, [])
}

fn traverse_cheats(
  path: List(Coord),
  map: dict.Dict(Coord, String),
  path_map: dict.Dict(Coord, Int),
  res: List(Int),
) {
  case path |> list.first {
    Ok(current_coord) -> {
      let index = path_map |> dict.get(current_coord) |> result.unwrap(0)
      let new_map = map |> dict.delete(current_coord)
      find_neighbour_skips(new_map, current_coord)
      |> list.fold(res, fn(acc, neighbour) {
        let skip_index = path_map |> dict.get(neighbour.0) |> result.unwrap(0)
        acc |> list.append([skip_index - index - 2])
      })
      |> traverse_cheats(path |> list.drop(1), new_map, path_map, _)
    }
    _ -> res
  }
}

fn find_hyper_cheats(
  path: List(Coord),
  map: dict.Dict(Coord, String),
  lower_limit: Int,
) {
  let path_map =
    path
    |> list.index_map(fn(coord, i) { #(coord, i) })
    // |> io.debug
    |> dict.from_list

  let spread = create_spread(20)

  traverse_hyper_cheats(path, map, path_map, dict.new(), lower_limit, spread)
}

fn traverse_hyper_cheats(
  path: List(Coord),
  map: dict.Dict(Coord, String),
  path_map: dict.Dict(Coord, Int),
  res: dict.Dict(Int, Int),
  lower_limit: Int,
  spread: List(#(Coord, Int)),
) {
  //   io.debug(path |> list.first |> result.unwrap(Coord(0, 0)))
  case path |> list.first {
    Ok(current_coord) -> {
      let index = path_map |> dict.get(current_coord) |> result.unwrap(0)
      let new_map = map |> dict.delete(current_coord)
      find_hyper_skips(new_map, current_coord, spread)
      //   |> io.debug
      |> list.fold(res, fn(acc, jump) {
        let skip_index = path_map |> dict.get(jump.0) |> result.unwrap(0)
        let efficiency = skip_index - index - jump.1
        case efficiency > lower_limit {
          True ->
            case acc |> dict.get(efficiency) {
              Ok(val) -> acc |> dict.insert(efficiency, val + 1)
              _ -> acc |> dict.insert(efficiency, 1)
            }
          False -> acc
        }
      })
      |> traverse_hyper_cheats(
        path |> list.drop(1),
        new_map,
        path_map,
        _,
        lower_limit,
        spread,
      )
    }
    _ -> res
  }
}

fn find_hyper_skips(
  map: dict.Dict(Coord, String),
  pos: Coord,
  spread: List(#(Coord, Int)),
) {
  //   find_spread(pos, spread)
  //   |> io.debug
  let Coord(x_pos, y_pos) = pos
  spread
  |> list.filter_map(fn(jump) {
    let Coord(x, y) = jump.0
    let new_pos = Coord(x_pos + x, y_pos + y)
    case map |> dict.get(new_pos) {
      Ok(".") | Ok("E") -> Ok(#(new_pos, jump.1))
      _ -> Error(Nil)
    }
  })
}

pub type Skip {
  Skip(coord: Coord, time: Int)
}

fn find_spread(pos: Coord, spread: List(#(Coord, Int))) {
  let Coord(x_pos, y_pos) = pos
  spread
  |> list.fold([], fn(acc, jump) {
    let #(Coord(x, y), time) = jump
    acc |> list.append([Skip(Coord(x_pos + x, y_pos + y), time)])
  })
}

fn create_spread(spread: Int) {
  list.range(0, spread)
  |> list.fold(dict.new(), fn(acc, prev_x) {
    list.range(0, prev_x)
    |> list.map(fn(y) {
      let x = prev_x - y
      let time = x + y
      [Coord(x, y), Coord(x, -y), Coord(-x, y), Coord(-x, -y)]
      //   |> io.debug
      |> list.map(fn(jump) { Skip(jump, time) })
    })
    |> list.flatten
    |> list.fold(acc, fn(final, skip) {
      case final |> dict.get(skip.coord) |> result.unwrap(10_000) > skip.time {
        True -> final |> dict.insert(skip.coord, skip.time)
        _ -> final
      }
    })
  })
  |> dict.to_list
}

fn check_queue(
  prio_queue: List(Path),
  function: fn(Path) -> Result(List(Coord), Nil),
) {
  case prio_queue {
    [current_node, ..] -> function(current_node)
    _ -> Error(Nil)
  }
}

fn check_end(
  coord: Coord,
  end: Coord,
  path: List(Coord),
  function: fn(Coord) -> Result(List(Coord), Nil),
) {
  case coord == end {
    True -> Ok(path |> list.append([end]))
    False -> function(coord)
  }
}

fn find_neighbours(map: dict.Dict(Coord, String), pos: Coord, range: Int) {
  list.range(0, 3)
  |> list.map(fn(dir) {
    let next = get_direction(dir)
    let Coord(x, y) = pos
    let next_pos = Coord(x + next.0 * range, y + next.1 * range)
    case map |> dict.get(next_pos) {
      Ok(".") | Ok("E") -> Ok(#(next_pos, dir))
      _ -> Error(Nil)
    }
  })
  |> list.filter(fn(x) { x != Error(Nil) })
  |> list.map(fn(x) { x |> result.unwrap(#(Coord(-1, -1), -1)) })
}

fn find_neighbour_skips(map: dict.Dict(Coord, String), pos: Coord) {
  list.range(0, 3)
  |> list.map(fn(dir) {
    let next = get_direction(dir)
    let Coord(x, y) = pos
    let next_pos = Coord(x + next.0, y + next.1)
    let skip = Coord(x + next.0 * 2, y + next.1 * 2)
    case map |> dict.get(next_pos) {
      Ok("#") -> {
        case map |> dict.get(skip) {
          Ok(".") | Ok("E") -> Ok(#(skip, dir))
          _ -> Error(Nil)
        }
      }
      _ -> Error(Nil)
    }
  })
  |> list.filter(fn(x) { x != Error(Nil) })
  |> list.map(fn(x) { x |> result.unwrap(#(Coord(-1, -1), -1)) })
}

fn print_path(path: List(Coord), map: dict.Dict(Coord, String), size: Coord) {
  let path_map =
    path
    |> list.map(fn(coord) { #(coord, True) })
    |> dict.from_list

  let horizontal = list.range(0, size.x)
  let vertical = list.range(0, size.y)

  vertical
  |> list.map(fn(y) {
    horizontal
    |> list.map(fn(x) {
      case path_map |> dict.get(Coord(x, y)) {
        Ok(True) -> "0"
        _ ->
          case map |> dict.get(Coord(x, y)) {
            Ok(val) -> val
            _ -> "X"
          }
      }
    })
    |> list.fold("", fn(acc, char) { acc <> char })
  })
  |> list.fold("", fn(acc, line) { acc <> "\n" <> line })
  |> io.print
  path
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
