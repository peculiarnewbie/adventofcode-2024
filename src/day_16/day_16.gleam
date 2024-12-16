import gleam/dict
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
}

fn pt_1(lines: List(String)) {
  let #(map, size) = generate_map(lines)
  let init_pos = Coord(1, size.1 - 1)
  let init = init_graph(map, init_pos, 1)
  let res =
    init
    |> list.map(fn(x) {
      let #(init_map, pos, dir) = x
      // io.debug(init_map)
      generate_graph(init_map, map, pos, dir)
    })

  case res {
    [first, ..] -> {
      let paths =
        first
        |> io.debug
        |> print_res(size)
        |> traverse_graph([], [], _, init_pos, Coord(size.0 - 1, 1))
      paths
      |> list.map(fn(path) {
        path
        |> list.map(fn(path) {
          let Path(coord, _) = path
          let node =
            first |> dict.get(coord) |> result.unwrap(Node(False, -1, []))
          #(coord, node)
        })
        |> dict.from_list
      })
      |> list.map(fn(path) { print_res(path, size) })

      paths
      |> list.map(fn(path) {
        path
        |> list.fold(0, fn(acc, x) {
          let Path(_, cost) = x
          acc + cost
        })
      })
      |> io.debug
    }
    _ -> panic as "No result"
  }
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

  #(map, #(x_size - 1, y_size - 1))
}

pub type Node {
  Node(leaf: Bool, dir: Int, neighbors: List(Path))
}

pub type Path {
  Path(pos: Coord, cost: Int)
}

pub type Coord {
  Coord(x: Int, y: Int)
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
      |> dict.insert(pos, Node(False, dir, [Path(next_pos, 1)]))
      |> dict.insert(next_pos, Node(False, dir, [Path(coord, cost)]))
      |> dict.insert(coord, Node(True, dir, []))
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
        |> dict.insert(
          pos,
          Node(False, dir, neighbors |> list.map(fn(x) { x.0 })),
        )
        |> dict.insert(next_pos, Node(True, -1, []))

      neighbors
      |> list.fold(new_res, fn(acc, x) {
        let #(Path(coord, _), branch_dir) = x
        acc
        |> dict.insert(coord, Node(True, branch_dir, []))
        |> generate_graph(map, coord, branch_dir)
      })
    }
    Ok("E"), _ ->
      res
      |> dict.insert(pos, Node(False, dir, [Path(next_pos, 1)]))
      |> dict.insert(next_pos, Node(True, 4, []))
    _, _ -> res |> dict.insert(pos, Node(False, dir, []))
  }
}

fn traverse_graph(
  current_path: List(Path),
  paths: List(List(Path)),
  graph: dict.Dict(Coord, Node),
  pos: Coord,
  target: Coord,
) {
  let Node(leaf, dir, neighbours) =
    graph |> dict.get(pos) |> result.unwrap(Node(False, 0, []))
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

fn init_graph(map: dict.Dict(Coord, String), pos: Coord, dir: Int) {
  find_branches(map, dict.new(), pos)
  |> list.map(fn(x) {
    let #(coord, branch_dir) = x
    let neighbour = case branch_dir == dir {
      True -> Path(coord, 1)
      False -> Path(coord, 1001)
    }
    let init_map =
      dict.new()
      |> dict.insert(pos, Node(False, dir, [neighbour]))
      |> dict.insert(coord, Node(True, branch_dir, []))
    #(init_map, coord, branch_dir)
  })
}

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

fn print_res(map: dict.Dict(Coord, Node), size: #(Int, Int)) {
  let horizontal = list.range(0, size.1)
  let vertical = list.range(0, size.0)

  let res =
    horizontal
    |> list.map(fn(y) {
      let line =
        vertical
        |> list.map(fn(x) {
          case dict.get(map, Coord(x, y)) {
            Ok(Node(_, dir, _)) ->
              case dir {
                0 -> "^"
                1 -> ">"
                2 -> "v"
                3 -> "<"
                4 -> "E"
                -1 -> "."
                _ -> "W"
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

fn pt_2(lines: List(String)) {
  todo
}
