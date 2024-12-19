import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 18
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  //   let assert 143 = 
  pt_1(sample, Coord(6, 6), 12)
  //   pt_1(res, Coord(70, 70), 3000)
  pt_2(sample, Coord(6, 6))
  pt_2(res, Coord(70, 70))
}

pub type Coord {
  Coord(x: Int, y: Int)
}

pub type Weighted {
  Weighted(Coord, weight: Int, value: Int)
}

fn pt_1(lines: List(String), size: Coord, limit: Int) {
  lines
  |> generate_map(size, limit)
  |> io.debug
  |> traverse_map(size, [Weighted(Coord(0, 0), 0, 0)])
  |> io.debug
}

fn pt_2(lines: List(String), size: Coord) {
  let init_map = generate_map(lines, size, 0)
  let corrupted = get_corrupted(lines)
  corrupted
  |> list.fold_until(init_map, fn(acc, x) {
    let #(coord, _) = x
    io.debug(coord)
    let new_map = acc |> dict.insert(coord, True)
    let res = traverse_map(new_map, size, [Weighted(Coord(0, 0), 0, 0)])
    case res {
      -1 -> list.Stop(acc)
      _ -> list.Continue(new_map)
    }
  })
  //   |> dict.fold(0, fn(acc, _, val) {
  //     case val {
  //       True -> acc + 1
  //       False -> acc
  //     }
  //   })
  |> io.debug
}

fn get_corrupted(lines: List(String)) {
  lines
  |> list.map(fn(x) {
    let split =
      string.split(x, ",")
      |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
    case split {
      [x, y] -> #(Coord(x, y), True)
      _ -> #(Coord(-1, -1), False)
    }
  })
}

fn generate_map(lines: List(String), size: Coord, limit: Int) {
  let #(split, _) = get_corrupted(lines) |> list.split(limit)
  let mems = split |> dict.from_list

  let Coord(x_size, y_size) = size
  let horizontal = list.range(0, x_size)
  let vertical = list.range(0, y_size)
  vertical
  |> list.fold(dict.new(), fn(acc, y) {
    horizontal
    |> list.fold(acc, fn(acc, x) {
      let corrupted = dict.get(mems, Coord(x, y))
      case corrupted {
        Ok(True) -> dict.insert(acc, Coord(x, y), True)
        _ -> dict.insert(acc, Coord(x, y), False)
      }
    })
  })
}

fn traverse_map(
  map: dict.Dict(Coord, Bool),
  target: Coord,
  queue: List(Weighted),
) {
  let current_node =
    queue
    |> list.first

  case current_node {
    Ok(Weighted(current_coord, _, current_value)) -> {
      //   io.debug(#(current_coord, current_weight, current_value))
      case dict.get(map, current_coord) {
        Ok(True) -> traverse_map(map, target, queue |> list.drop(1))
        _ -> {
          case current_coord == target {
            True -> current_value
            False -> {
              let new_map = map |> dict.insert(current_coord, True)

              let neighbors = find_neighbours(new_map, current_coord)
              let neighbors_weight =
                neighbors
                |> list.map(fn(x) {
                  let #(next_coord, _) = x
                  let added_weight = {
                    let Coord(next_x, next_y) = next_coord
                    let Coord(target_x, target_y) = target
                    target_x - next_x + target_y - next_y
                  }
                  Weighted(
                    next_coord,
                    current_value + added_weight,
                    current_value + 1,
                  )
                })
              let new_queue =
                queue
                |> list.drop(1)
                |> list.append(neighbors_weight)
                |> list.sort(fn(a, b) {
                  let Weighted(_, a_weight, _) = a
                  let Weighted(_, b_weight, _) = b
                  int.compare(a_weight, b_weight)
                })
              traverse_map(new_map, target, new_queue)
            }
          }
        }
      }
    }
    _ -> -1
  }
}

fn find_neighbours(map: dict.Dict(Coord, Bool), pos: Coord) {
  list.range(0, 3)
  |> list.map(fn(dir) {
    let next = get_direction(dir)
    let Coord(x, y) = pos
    let next_pos = Coord(x + next.0, y + next.1)
    case map |> dict.get(next_pos) {
      Ok(False) -> Ok(#(next_pos, dir))
      _ -> Error(Nil)
    }
  })
  |> list.filter(fn(x) { x != Error(Nil) })
  |> list.map(fn(x) { x |> result.unwrap(#(Coord(-1, -1), -1)) })
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
