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

// fn pt_1(lines: List(String)) {
//   let direction =
//     dict.new()
//     |> dict.insert(0, #(0, 1))
//     |> dict.insert(1, #(1, 0))
//     |> dict.insert(2, #(0, -1))
//     |> dict.insert(3, #(-1, 0))

//   let map = lines |> build_map()
//   let start_coord = get_start_coord(map)
//   let clean_map = map |> dict.insert(start_coord, ".")

//   traverse_map(clean_map, start_coord, 0, direction, 0)
//   // |> print_map()
//   |> dict.fold(0, fn(acc, _, val) {
//     case val {
//       "X" -> acc + 1
//       _ -> acc
//     }
//   })
// }

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
  // |> traverse_map(start_coord, 0, direction, 0)
  // |> fn(x) {
  //   let #(map, index) = x
  //   print_map(map)
  //   io.debug(index)
  //   map
  // }

  let #(new_map, added_obstructions) =
    traverse_obstruction(
      clean_map,
      start_coord,
      0,
      direction,
      0,
      dict.new() |> dict.insert(start_coord, True),
      start_coord,
      clean_map,
      0,
    )
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
  index: Int,
) {
  // print_map(map)
  // io.debug("-------------------")
  let #(x_dir, y_dir) =
    directions |> dict.get(current_direction) |> result.unwrap(#(0, 0))
  let next_coord = #(coord.0 + x_dir, coord.1 + y_dir)
  let next_char = map |> dict.get(next_coord)
  let current_char = map |> dict.get(coord)
  // io.debug(#(coord, current_direction, directions, next_char))
  case next_char {
    Ok(".") ->
      traverse_map(
        dict.insert(map, coord, plus_or_not(current_char)),
        next_coord,
        current_direction,
        directions,
        index + 1,
      )
    Ok("X") ->
      traverse_map(
        dict.insert(map, coord, plus_or_not(current_char)),
        next_coord,
        current_direction,
        directions,
        index + 1,
      )
    // Ok("+") -> traverse_map(map, next_coord, current_direction, directions)
    Ok("#") -> {
      let next_direction = { current_direction + 1 } % 4
      traverse_map(
        dict.insert(map, coord, "+"),
        coord,
        next_direction,
        directions,
        index + 1,
      )
    }
    Ok(_) -> #(dict.insert(map, coord, "X"), index)
    Error(_) -> #(dict.insert(map, coord, "X"), index)
  }
}

fn plus_or_not(current: Result(String, Nil)) {
  case current {
    Ok("+") -> "+"
    _ -> "X"
  }
}

fn traverse_obstruction(
  map: dict.Dict(#(Int, Int), String),
  coord: #(Int, Int),
  current_direction: Int,
  directions: dict.Dict(Int, #(Int, Int)),
  prev_obstructions: Int,
  filled_coords: dict.Dict(#(Int, Int), Bool),
  start_coord: #(Int, Int),
  initial_map: dict.Dict(#(Int, Int), String),
  index: Int,
) {
  // print_map(map)
  // io.debug("-------------------")
  // io.debug(#(index, prev_obstructions))
  let #(x_dir, y_dir) =
    directions |> dict.get(current_direction) |> result.unwrap(#(0, 0))
  let next_coord = #(coord.0 + x_dir, coord.1 + y_dir)
  let next_char = map |> dict.get(next_coord)
  let current_char = map |> dict.get(coord)

  let can_obstruct = case next_char {
    Ok("#") -> False
    Error(_) -> False
    _ -> {
      case dict.get(filled_coords, next_coord) {
        Ok(True) -> False
        _ ->
          check_continous(
            dict.insert(initial_map, next_coord, "O"),
            start_coord,
            0,
            directions,
          )
      }
    }
  }

  let obstructions = case can_obstruct {
    True -> prev_obstructions + 1
    False -> prev_obstructions
  }

  let new_filled_coords = case can_obstruct {
    True -> dict.insert(filled_coords, next_coord, True)
    False -> filled_coords
  }

  // io.debug(#(coord, current_direction, directions, next_char))
  case next_char {
    Ok("#") -> {
      let next_direction = { current_direction + 1 } % 4
      traverse_obstruction(
        dict.insert(map, coord, "+"),
        coord,
        next_direction,
        directions,
        obstructions,
        new_filled_coords,
        start_coord,
        initial_map,
        index + 1,
      )
    }
    Ok(".") ->
      traverse_obstruction(
        dict.insert(map, coord, plus_or_not(current_char)),
        next_coord,
        current_direction,
        directions,
        obstructions,
        new_filled_coords,
        start_coord,
        initial_map,
        index + 1,
      )
    Ok("X") ->
      traverse_obstruction(
        dict.insert(map, coord, plus_or_not(current_char)),
        next_coord,
        current_direction,
        directions,
        obstructions,
        new_filled_coords,
        start_coord,
        initial_map,
        index + 1,
      )
    Ok("+") ->
      traverse_obstruction(
        map,
        next_coord,
        current_direction,
        directions,
        obstructions,
        new_filled_coords,
        start_coord,
        initial_map,
        index + 1,
      )

    _ -> #(dict.insert(map, coord, "X"), obstructions)
  }
}

// fn dir_char(dir: Int, char: String) {
//   case dir {
//     0 -> "|"
//     1 -> "-"
//     2 -> "|"
//     3 -> "-"
//     _ -> ""
//   }
// }

fn check_right(
  map: dict.Dict(#(Int, Int), String),
  coord: #(Int, Int),
  current_direction: Int,
  directions: dict.Dict(Int, #(Int, Int)),
) {
  // io.debug(#("check_right", coord, current_direction))
  // print_map(dict.insert(map, coord, int.to_string(current_direction)))
  // io.debug("----------------------")

  let right_direction = { current_direction + 1 } % 4
  // let #(x_dir, y_dir) =
  //   directions
  //   |> dict.get(right_direction)
  //   |> result.unwrap(#(0, 0))
  // io.debug(#(x_dir, y_dir))
  // let right_coord = #(coord.0 + x_dir, coord.1 + y_dir)
  // let right_char = map |> dict.get(right_coord)

  check_continous(map, coord, right_direction, directions)
}

fn check_continous(
  map: dict.Dict(#(Int, Int), String),
  coord: #(Int, Int),
  current_direction: Int,
  directions: dict.Dict(Int, #(Int, Int)),
) {
  let current_char = map |> dict.get(coord)
  let #(x_dir, y_dir) =
    directions |> dict.get(current_direction) |> result.unwrap(#(0, 0))
  let next_coord = #(coord.0 + x_dir, coord.1 + y_dir)
  let next_char = map |> dict.get(next_coord)
  case next_char {
    Ok("#") ->
      check_right(
        dict.insert(map, coord, "+"),
        coord,
        current_direction,
        directions,
      )
    Ok("O") ->
      check_right(
        dict.insert(map, coord, "+"),
        coord,
        current_direction,
        directions,
      )
    Ok("+") -> {
      case dict.get(map, #(next_coord.0 + x_dir, next_coord.1 + y_dir)) {
        Ok("#") -> {
          // print_map(dict.insert(map, coord, int.to_string(current_direction)))
          // io.debug("--------------------Found")
          True
        }
        Ok(_) ->
          check_continous(
            dict.insert(map, coord, plus_or_not(current_char)),
            next_coord,
            current_direction,
            directions,
          )
        Error(_) -> False
      }
    }
    Error(_) -> False
    Ok(_) ->
      check_continous(
        dict.insert(map, coord, plus_or_not(current_char)),
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
