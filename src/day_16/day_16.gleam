import gleam/dict
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 16
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  //   let assert 143 =
  pt_1(sample)
  //   pt_1(res)
}

fn pt_1(lines: List(String)) {
  let #(map, size) = generate_map(lines)
  let init_pos = Coord(1, size.1 - 1)

  //   map
  //   |> generate_graph_priority(dict.new(), _, [PathDir(init_pos, 0, 1)])
  //   |> io.debug
  //   |> print_res(size)

  map
  |> traverse_map([NewPath(init_pos, 0, 1, 1)], _, Coord(size.0 - 1, 1))
  |> io.debug
}

fn generate_map(lines: List(String)) {
  let map =
    lines
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(char, x) { #(Coord(x, y), char) })
    })
    |> list.flatten
    |> dict.from_list

  let y_size = lines |> list.length
  let x_size = lines |> list.first |> result.unwrap("") |> string.length

  #(map, #(x_size, y_size))
}

pub type NewPath {
  NewPath(coord: Coord, score: Int, prev_dir: Int, dir: Int)
}

fn traverse_map(
  prio_queue: List(NewPath),
  map: dict.Dict(Coord, String),
  end: Coord,
) {
  use current_node <- check_queue(prio_queue)
  let NewPath(current_coord, score, _, dir) = current_node

  use _ <- check_end(current_coord, end, score)
  let new_map = map |> dict.delete(current_coord)

  find_neighbours(new_map, current_coord, 1)
  |> list.map(fn(neighbour) {
    let Path(next_coord, next_dir) = neighbour
    let cost = case dir == next_dir {
      True -> 1
      False -> 1001
    }
    NewPath(next_coord, score + cost, dir, next_dir)
  })
  |> list.append(prio_queue, _)
  |> list.drop(1)
  |> list.sort(fn(a, b) {
    let NewPath(_, a_score, _, _) = a
    let NewPath(_, b_score, _, _) = b
    int.compare(a_score, b_score)
  })
  |> traverse_map(new_map, end)
}

fn check_queue(
  prio_queue: List(NewPath),
  function: fn(NewPath) -> Result(Int, Nil),
) {
  case prio_queue {
    [current_node, ..] -> function(current_node)
    _ -> Error(Nil)
  }
}

fn check_end(
  coord: Coord,
  end: Coord,
  score: Int,
  function: fn(Coord) -> Result(Int, Nil),
) {
  case coord == end {
    True -> Ok(score)
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
      Ok(".") | Ok("E") -> Ok(Path(next_pos, dir))
      _ -> Error(Nil)
    }
  })
  |> list.filter(fn(x) { x != Error(Nil) })
  |> list.map(fn(x) { x |> result.unwrap(Path(Coord(-1, -1), -1)) })
}

pub type Node {
  Node(node_type: NodeType, neighbors: List(Path))
}

pub type PrioNode {
  Prio(node_type: NodeType, neighbors: List(PathDir), total_cost: Int)
}

pub type Path {
  Path(pos: Coord, cost: Int)
}

pub type PathDir {
  PathDir(pos: Coord, cost: Int, dir: Int)
}

pub type Coord {
  Coord(x: Int, y: Int)
}

pub type NodeType {
  Start
  Normal
  Leaf
  End
  Dead
}

fn generate_graph_priority(
  res: dict.Dict(Coord, PrioNode),
  map: dict.Dict(Coord, String),
  queue: List(PathDir),
) {
  print_res(res, #(140, 140))
  case queue {
    [] -> res
    [current_node, ..rest] -> {
      let PathDir(pos, cost, dir) = current_node
      let char = map |> dict.get(pos) |> result.unwrap("")
      case char {
        "E" -> res |> dict.insert(pos, Prio(End, [], cost))
        _ -> {
          let neighbors =
            find_branches_prio(map, res, pos)
            |> list.map(fn(x) {
              let #(branch_coord, branch_dir) = x
              case dir == branch_dir {
                True -> PathDir(branch_coord, cost + 1, branch_dir)
                False -> PathDir(branch_coord, cost + 1001, branch_dir)
              }
            })

          let new_queue =
            rest
            |> list.append(neighbors)
            |> list.sort(fn(a, b) {
              let PathDir(_, a_cost, _) = a
              let PathDir(_, b_cost, _) = b
              int.compare(a_cost, b_cost)
            })

          let this_node = case neighbors {
            [] -> Prio(Dead, neighbors, cost)
            _ -> Prio(Normal, neighbors, cost)
          }

          res
          |> dict.insert(pos, this_node)
          |> generate_graph_priority(map, new_queue)
        }
      }
    }
  }
}

fn find_branches_prio(
  map: dict.Dict(Coord, String),
  res: dict.Dict(Coord, PrioNode),
  pos: Coord,
) {
  let node = map |> dict.get(pos)
  case node {
    Ok(_) -> {
      list.range(0, 3)
      |> list.map(fn(dir) {
        let next = get_direction(dir)
        let Coord(x, y) = pos
        let next_pos = Coord(x + next.0, y + next.1)
        case map |> dict.get(next_pos), res |> dict.get(next_pos) {
          _, Ok(_) -> Error(Nil)
          Ok("."), _ | Ok("E"), _ -> Ok(#(next_pos, dir))
          _, _ -> Error(Nil)
        }
      })
      |> list.filter(fn(x) { x != Error(Nil) })
      |> list.map(fn(x) { x |> result.unwrap(#(pos, 0)) })
    }
    _ -> []
  }
}

fn generate_graph(
  res: dict.Dict(Coord, Node),
  map: dict.Dict(Coord, String),
  pos: Coord,
  dir: Int,
) {
  let #(x_move, y_move) = dir |> get_direction
  let next_pos = Coord(pos.x + x_move, pos.y + y_move)
  let next_branches = find_branches(map, res, next_pos)
  let next_char = map |> dict.get(next_pos)
  case next_char, next_branches {
    Ok("."), [branch1] -> {
      let #(coord, branch_dir) = branch1
      let cost = case branch_dir == dir {
        True -> 1
        False -> 1001
      }
      res
      |> dict.insert(pos, Node(Normal, [Path(next_pos, 1)]))
      |> dict.insert(next_pos, Node(Normal, [Path(coord, cost)]))
      |> dict.insert(coord, Node(Leaf, []))
      |> generate_graph(map, coord, branch_dir)
    }
    Ok("."), _ -> {
      let neighbors =
        next_branches
        |> list.map(fn(x) {
          let #(coord, branch_dir) = x
          case dir == branch_dir {
            True -> #(Path(coord, 2), branch_dir)
            False -> #(Path(coord, 1002), branch_dir)
          }
        })
      let new_res =
        res
        |> dict.insert(pos, Node(Normal, neighbors |> list.map(fn(x) { x.0 })))
        |> dict.insert(next_pos, Node(Leaf, []))

      neighbors
      |> list.fold(new_res, fn(acc, x) {
        let #(Path(coord, _), branch_dir) = x
        acc
        |> dict.insert(coord, Node(Leaf, []))
        |> generate_graph(map, coord, branch_dir)
      })
    }
    Ok("E"), _ ->
      res
      |> dict.insert(pos, Node(Normal, [Path(next_pos, 1)]))
      |> dict.insert(next_pos, Node(End, []))
    _, _ -> res |> dict.insert(pos, Node(Leaf, []))
  }
}

fn traverse_graph(
  current_path: List(Path),
  paths: List(List(Path)),
  graph: dict.Dict(Coord, Node),
  pos: Coord,
  target: Coord,
) {
  let Node(_, neighbours) =
    graph |> dict.get(pos) |> result.unwrap(Node(Leaf, []))
  case neighbours {
    [] -> paths |> list.append([])
    [path] -> {
      let Path(coord, _) = path
      case coord == target {
        True -> [[path, ..current_path], ..paths]
        False ->
          traverse_graph(
            current_path |> list.append([path]),
            paths,
            graph,
            coord,
            target,
          )
      }
    }
    _ -> {
      neighbours
      |> list.map(fn(x) {
        let Path(coord, _) = x
        traverse_graph(
          current_path |> list.append([x]),
          paths,
          graph,
          coord,
          target,
        )
      })
      |> list.fold(paths, fn(acc, x) { acc |> list.append(x) })
    }
  }
}

// fn init_graph(map: dict.Dict(Coord, String), pos: Coord, dir: Int) {
//   find_branches(map, dict.new(), pos)
//   |> list.map(fn(x) {
//     let #(coord, branch_dir) = x
//     let cost = case branch_dir == dir {
//       True -> 1
//       False -> 1001
//     }
//     let init_map =
//       dict.new()
//       |> dict.insert(pos, Node(Start, [Path(coord, cost)]))
//       |> dict.insert(coord, Node(Leaf, [Path(pos, cost)]))
//     #(init_map, coord, branch_dir)
//   })
// }

fn find_branches(
  map: dict.Dict(Coord, String),
  res: dict.Dict(Coord, Node),
  pos: Coord,
) {
  let node = map |> dict.get(pos)
  case node {
    Ok(_) -> {
      list.range(0, 3)
      |> list.map(fn(dir) {
        let next = get_direction(dir)
        let Coord(x, y) = pos
        let next_pos = Coord(x + next.0, y + next.1)
        case map |> dict.get(next_pos), res |> dict.get(next_pos) {
          _, Ok(_) -> Error(Nil)
          Ok("."), _ | Ok("E"), _ -> Ok(#(next_pos, dir))
          _, _ -> Error(Nil)
        }
      })
      |> list.filter(fn(x) { x != Error(Nil) })
      |> list.map(fn(x) { x |> result.unwrap(#(pos, 0)) })
    }
    _ -> []
  }
}

fn print_res(map: dict.Dict(Coord, PrioNode), size: #(Int, Int)) {
  //   io.print("\u{001b}[H")
  process.sleep(10)
  let horizontal = list.range(0, size.1)
  let vertical = list.range(0, size.0)

  let res =
    horizontal
    |> list.map(fn(y) {
      let line =
        vertical
        |> list.map(fn(x) {
          case dict.get(map, Coord(x, y)) {
            Ok(Prio(node_type, _, _)) ->
              case node_type {
                Start -> "S"
                End -> "E"
                Normal -> "O"
                Leaf -> "W"
                Dead -> "X"
              }
            _ -> "#"
          }
        })

      line |> list.fold("", fn(acc, x) { acc <> x })
    })
    |> list.fold("", fn(acc, x) { acc <> "\n" <> x })

  io.print(res)
  map
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
// fn pt_2(lines: List(String)) {
//   todo
// }
// fn pt_1_old(lines: List(String)) {
//   let #(map, size) = generate_map(lines)
//   let init_pos = Coord(1, size.1 - 1)
//   let init = init_graph(map, init_pos, 1)
//   let res =
//     init
//     |> list.map(fn(x) {
//       let #(init_map, pos, dir) = x
//       // io.debug(init_map)
//       generate_graph(init_map, map, pos, dir)
//     })

//   case res {
//     [first, ..] -> {
//       let paths =
//         first
//         |> io.debug
//         |> print_res(size)
//         |> traverse_graph([], [], _, init_pos, Coord(size.0 - 1, 1))
//       paths
//       |> list.map(fn(path) {
//         path
//         |> list.map(fn(path) {
//           let Path(coord, _) = path
//           let node =
//             first |> dict.get(coord) |> result.unwrap(Node(False, -1, []))
//           #(coord, node)
//         })
//         |> dict.from_list
//       })
//       |> list.map(fn(path) { print_res(path, size) })

//       paths
//       |> list.map(fn(path) {
//         path
//         |> list.fold(0, fn(acc, x) {
//           let Path(_, cost) = x
//           acc + cost
//         })
//       })
//       |> io.debug
//     }
//     _ -> panic as "No result"
//   }
// }
