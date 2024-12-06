import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 6
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  // let assert 41 = pt_1(sample)
  // pt_1(res) |> io.debug
  let assert 6 = pt_2(sample)
  pt_2(res) |> io.debug
}

fn pt_1(lines: List(String)) {
  let direction =
    dict.new()
    |> dict.insert(0, #(0, 1))
    |> dict.insert(1, #(1, 0))
    |> dict.insert(2, #(0, -1))
    |> dict.insert(3, #(-1, 0))

  let map = lines |> build_map()
  let start_coord = get_start_coord(map)
  let clean_map = map |> dict.insert(start_coord, ".")

  traverse_map(clean_map, start_coord, 0, direction)
  // |> print_map()
  |> dict.fold(0, fn(acc, _, val) {
    case val {
      "X" -> acc + 1
      _ -> acc
    }
  })
}

fn pt_2(lines: List(String)) {
  let direction =
    dict.new()
    |> dict.insert(0, #(0, 1))
    |> dict.insert(1, #(1, 0))
    |> dict.insert(2, #(0, -1))
    |> dict.insert(3, #(-1, 0))

  let map = lines |> build_map()
  let start_coord = get_start_coord(map)
  let clean_map =
    map
    |> dict.insert(start_coord, ".")
    |> traverse_map(start_coord, 0, direction)
    |> print_map()

  let #(new_map, added_obstructions) =
    traverse_obstruction(clean_map, start_coord, 0, direction, 0, True)
  print_map(new_map)
  added_obstructions
}

fn build_map(lines: List(String)) {
  // let x_size = lines |> list.first() |> result.unwrap("") |> string.length()
  // let y_size = lines |> list.length()
  lines
  |> list.reverse()
  |> list.index_map(fn(x, i) { iterate_line(x, i, dict.new(), 0) })
  |> list.fold(dict.new(), fn(acc, x) { dict.merge(acc, x) })
}

fn iterate_line(
  line: String,
  y_pos: Int,
  res: dict.Dict(#(Int, Int), String),
  x_pos: Int,
) {
  // io.debug(#(line, x_pos, y_pos, res, x_pos))
  case line {
    "" -> res
    _ -> {
      let char = line |> string.first() |> result.unwrap("")
      let new_dict = dict.insert(res, #(x_pos, y_pos), char)
      iterate_line(line |> string.drop_start(1), y_pos, new_dict, x_pos + 1)
    }
  }
}

fn get_start_coord(map: dict.Dict(#(Int, Int), String)) -> #(Int, Int) {
  map
  |> dict.filter(fn(_, value) { value == "^" })
  |> dict.keys()
  |> list.first()
  |> result.unwrap(#(0, 0))
}

fn traverse_map(
  map: dict.Dict(#(Int, Int), String),
  coord: #(Int, Int),
  current_direction: Int,
  directions: dict.Dict(Int, #(Int, Int)),
) {
  // print_map(map)
  // io.debug("-------------------")
  let #(x_dir, y_dir) =
    directions |> dict.get(current_direction) |> result.unwrap(#(0, 0))
  let next_coord = #(coord.0 + x_dir, coord.1 + y_dir)
  let next_char = map |> dict.get(next_coord)
  // io.debug(#(coord, current_direction, directions, next_char))
  case next_char {
    Ok(".") ->
      traverse_map(
        dict.insert(map, coord, "X"),
        next_coord,
        current_direction,
        directions,
      )
    Ok("X") ->
      traverse_map(
        dict.insert(map, coord, "X"),
        next_coord,
        current_direction,
        directions,
      )
    Ok("#") -> {
      let next_direction = { current_direction + 1 } % 4
      traverse_map(map, coord, next_direction, directions)
    }
    Ok(_) -> dict.insert(map, coord, "X")
    Error(_) -> dict.insert(map, coord, "X")
  }
}

fn traverse_obstruction(
  map: dict.Dict(#(Int, Int), String),
  coord: #(Int, Int),
  current_direction: Int,
  directions: dict.Dict(Int, #(Int, Int)),
  prev_obstructions: Int,
  first_turn_flag: Bool,
) {
  // print_map(map)
  // io.debug("-------------------")
  let #(x_dir, y_dir) =
    directions |> dict.get(current_direction) |> result.unwrap(#(0, 0))
  let next_coord = #(coord.0 + x_dir, coord.1 + y_dir)
  let next_char = map |> dict.get(next_coord)
  let current_char = map |> dict.get(coord)

  let can_obstruct = case current_char {
    Ok("X") -> {
      case first_turn_flag {
        True -> False
        False -> check_right(map, coord, current_direction, directions)
      }
    }
    _ -> False
  }

  let obstructions = case can_obstruct {
    True -> prev_obstructions + 1
    False -> prev_obstructions
  }

  // io.debug(#(coord, current_direction, directions, next_char))
  case next_char {
    Ok(".") ->
      traverse_obstruction(
        dict.insert(map, coord, "X"),
        next_coord,
        current_direction,
        directions,
        obstructions,
        first_turn_flag,
      )
    Ok("X") ->
      traverse_obstruction(
        dict.insert(map, coord, "X"),
        next_coord,
        current_direction,
        directions,
        obstructions,
        first_turn_flag,
      )
    Ok("#") -> {
      let next_direction = { current_direction + 1 } % 4
      traverse_obstruction(
        map,
        coord,
        next_direction,
        directions,
        obstructions,
        False,
      )
    }
    _ -> #(dict.insert(map, coord, "X"), obstructions)
  }
}

fn check_right(
  prev_map: dict.Dict(#(Int, Int), String),
  coord: #(Int, Int),
  current_direction: Int,
  directions: dict.Dict(Int, #(Int, Int)),
) {
  // io.debug(#("check_right", coord, current_direction))
  // print_map(prev_map)
  // io.debug("----------------------")

  let direction =
    dict.get(directions, current_direction) |> result.unwrap(#(0, 0))
  let next_coord = #(coord.0 + direction.0, coord.1 + direction.1)
  let next_char = prev_map |> dict.get(next_coord)
  let map = dict.insert(prev_map, next_coord, "O")
  let right_direction = { current_direction + 1 } % 4
  let #(x_dir, y_dir) =
    directions
    |> dict.get(right_direction)
    |> result.unwrap(#(0, 0))
  // io.debug(#(x_dir, y_dir))
  let right_coord = #(coord.0 + x_dir, coord.1 + y_dir)
  let right_char = map |> dict.get(right_coord)

  case next_char {
    Ok("#") -> False
    Ok(_) -> {
      case right_char {
        Ok("X") ->
          check_continous(map, right_coord, right_direction, directions)
        _ -> False
      }
    }
    Error(_) -> False
  }
}

fn check_continous(
  map: dict.Dict(#(Int, Int), String),
  coord: #(Int, Int),
  current_direction: Int,
  directions: dict.Dict(Int, #(Int, Int)),
) {
  io.debug(#("check_continous", coord, current_direction))
  print_map(map)
  io.debug("----------------------")
  let #(x_dir, y_dir) =
    directions |> dict.get(current_direction) |> result.unwrap(#(0, 0))
  let next_coord = #(coord.0 + x_dir, coord.1 + y_dir)
  let next_char = map |> dict.get(next_coord)
  case next_char {
    Ok("#") -> {
      io.debug("yooooooooooooooooooooooooooooooooooo")
      True
    }
    Error(_) -> False
    Ok(_) ->
      check_continous(
        dict.insert(map, coord, "-"),
        next_coord,
        current_direction,
        directions,
      )
  }
}

// fn

// fn pt_2(lines: List(String)) {
//   todo
// }

// ---------------------- DEBUG ----------------------

fn print_map(map: dict.Dict(#(Int, Int), String)) {
  let size = map |> get_dimenstions(#(0, 0))
  let y_list = list.range(0, size.1 - 1)
  let x_list = list.range(0, size.0 - 1)

  y_list
  |> list.reverse()
  |> list.map(fn(y) {
    x_list
    |> list.map(fn(x) {
      let key = #(x, y)
      case dict.get(map, key) {
        Ok(a) -> a
        Error(_) -> ""
      }
    })
    |> list.fold("", fn(acc, x) { acc <> x })
  })
  |> list.map(fn(x) { io.debug(x) })
  map
}

fn get_dimenstions(map: dict.Dict(#(Int, Int), String), size: #(Int, Int)) {
  case map |> dict.is_empty() {
    True -> #(size.0 + 1, size.1 + 1)
    False -> {
      let key = map |> dict.keys() |> list.first() |> result.unwrap(#(0, 0))
      let #(x, y) = key
      let #(x_size, y_size) = size
      case x > x_size, y > y_size {
        True, True -> get_dimenstions(dict.drop(map, [key]), #(x, y))
        True, False -> get_dimenstions(dict.drop(map, [key]), #(x, y_size))
        False, True -> get_dimenstions(dict.drop(map, [key]), #(x_size, y))
        False, False ->
          get_dimenstions(dict.drop(map, [key]), #(x_size, y_size))
      }
    }
  }
}
