import gleam/dict

// import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 14
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  //   let sample =
  //     runner.parse_sample(day)
  //     |> list.map(fn(x) { string.trim(x) })

  //   let assert 12 = pt_1(sample, #(11, 7))
  //   pt_1(res, #(101, 103))
  pt_2(res, #(101, 103))
}

// fn pt_1(lines: List(String), size: #(Int, Int)) {
//   let bots =
//     get_bots(lines)
//     |> list.map(fn(x) { get_position_after(x, 100, size) })
//   calculate_safety(bots, size) |> io.debug
// }

fn get_position_after(
  bot: #(Int, #(#(Int, Int), #(Int, Int))),
  seconds: Int,
  size: #(Int, Int),
) {
  let #(_, #(#(px, py), #(vx, vy))) = bot
  let #(x_size, y_size) = size
  let out_x = px + vx * seconds
  let out_y = py + vy * seconds

  let fin_x = out_x |> int.remainder(x_size) |> result.unwrap(0)
  let fin_y = out_y |> int.remainder(y_size) |> result.unwrap(0)

  let x = case fin_x < 0 {
    True -> x_size + fin_x
    False -> fin_x
  }

  let y = case fin_y < 0 {
    True -> y_size + fin_y
    False -> fin_y
  }

  #(x, y)
}

fn get_bots(lines: List(String)) {
  lines
  |> list.index_map(fn(x, i) {
    let bot =
      x
      |> string.split("=")
      |> list.drop(1)
      |> list.map(fn(x) { string.replace(x, " v", "") })
      |> list.map(fn(x) {
        string.split(x, ",")
        |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
      })

    case bot {
      [[a1, a2], [b1, b2]] -> {
        #(i, #(#(a1, a2), #(b1, b2)))
      }
      _ -> #(0, #(#(0, 0), #(0, 0)))
    }
  })
  // |> io.debug
}

// fn calculate_safety(bots: List(#(Int, Int)), size: #(Int, Int)) {
//   let mid_x = size.0 / 2
//   let mid_y = size.1 / 2

//   let init_quadrants =
//     list.range(0, 3)
//     |> list.map(fn(x) { #(x, 0) })
//     |> dict.from_list

//   bots
//   |> list.fold(init_quadrants, fn(acc, bot) {
//     io.debug(bot)
//     let #(x, y) = bot
//     case x == mid_x, y == mid_y {
//       False, False ->
//         case x < mid_x, y < mid_y {
//           True, True -> insert_into(acc, 0, 1)
//           False, True -> insert_into(acc, 1, 1)
//           True, False -> insert_into(acc, 2, 1)
//           False, False -> insert_into(acc, 3, 1)
//         }
//       _, _ -> acc
//     }
//   })
//   |> dict.to_list
//   |> io.debug
//   |> list.fold(1, fn(acc, x) { acc * x.1 })
// }

// fn insert_into(dict: dict.Dict(Int, Int), key: Int, value: Int) {
//   case dict.get(dict, key) {
//     Ok(v) -> dict.insert(dict, key, v + value)
//     Error(_) -> dict.insert(dict, key, value)
//   }
// }

fn pt_2(lines: List(String), size: #(Int, Int)) {
  let bots = get_bots(lines)

  search_spread(bots, size, 8000)
}

fn search_spread(
  bots: List(#(Int, #(#(Int, Int), #(Int, Int)))),
  size: #(Int, Int),
  seconds: Int,
) {
  let spread =
    bots
    |> list.map(fn(x) { get_position_after(x, seconds, size) })
    |> list.unique

  print_map(spread, size)
  io.print(seconds |> int.to_string)
  //   process.sleep(1000)
  search_spread(bots, size, seconds + 1)
}

fn print_map(map: List(#(Int, Int)), size: #(Int, Int)) {
  io.print("\u{001b}[H")
  let bots =
    map
    |> list.map(fn(x) { #(x, True) })
    |> dict.from_list
  //   io.print("\u{001b}[2J")
  let horizontal = list.range(0, size.1)
  let vertical = list.range(0, size.0)

  let res =
    horizontal
    |> list.map(fn(y) {
      let line =
        vertical
        |> list.map(fn(x) {
          case dict.get(bots, #(x, y)) {
            Ok(_) -> "O"
            _ -> "."
          }
        })

      line |> list.fold("", fn(acc, x) { acc <> x })
    })
    |> list.fold("", fn(acc, x) { acc <> "\n" <> x })

  io.print(res)
}
