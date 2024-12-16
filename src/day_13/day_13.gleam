// import gleam/dict
// import gleam/float
import gleam/int
import gleam/io
import gleam/list

// import gleam/order
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 13
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  // let assert 480 = 
  pt_1(sample)
  pt_1(res)
  // pt_2(sample)
  pt_2(res)
}

fn pt_1(lines: List(String)) {
  lines
  |> parse_lines(1)
  // |> list.map(fn(x) { find_value_2(x) })
  |> list.map(fn(x) { find_with_margin(x) })
  // |> io.debug
  |> list.fold(0, fn(acc, x) { acc + x })
  |> io.debug
}

fn parse_lines(lines: List(String), pt: Int) {
  lines
  |> list.sized_chunk(4)
  |> list.map(fn(x) { x |> list.drop(1) })
  |> list.map(fn(x) {
    case x {
      [a, b, res] -> {
        let parsed_res = case pt {
          1 -> parse_line(res, "=")
          _ -> pt2_parse_res(res)
        }
        #(parse_line(a, "+"), parse_line(b, "+"), parsed_res)
      }
      _ -> #(#(0, 0), #(0, 0), #(0, 0))
    }
  })
}

fn parse_line(button: String, grapheme: String) {
  let val =
    button
    |> string.split(grapheme)
    |> list.drop(1)
    |> list.map(fn(x) { string.split(x, ",") })
    |> list.flatten
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
    |> list.filter(fn(x) { x > 0 })

  case val {
    [a, b] -> #(a, b)
    _ -> #(0, 0)
  }
}

fn pt2_parse_res(button: String) {
  let val =
    button
    |> string.split("=")
    |> list.drop(1)
    |> list.map(fn(x) { string.split(x, ",") })
    |> list.flatten
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
    |> list.filter(fn(x) { x > 0 })

  let base = 10_000_000_000_000

  case val {
    [a, b] -> #(base + a, base + b)
    _ -> #(0, 0)
  }
}

fn pt_2(lines: List(String)) {
  lines
  |> parse_lines(2)
  |> list.map(fn(x) { find_with_margin(x) })
  // |> list.filter(fn(x) { x != #(0, 0) })
  // |> list.map(fn(x) {
  //   x
  // })
  |> list.fold(0, fn(acc, x) { acc + x })
  |> io.debug
  // let #(#(ax, ay), #(bx, by), #(x_res, y_res)) = line
  // let ax_max = x_res / ax
  // let ay_max = y_res / ay
}

fn find_with_margin(line: #(#(Int, Int), #(Int, Int), #(Int, Int))) {
  let #(#(x1, y1), #(x2, y2), #(x_res, y_res)) = line

  let top = y_res * x2 - x_res * y2
  let bottom = x_res * y1 - y_res * x1

  case top == bottom {
    True -> {
      // io.debug(#("heyyyyy", top, bottom))
      0
    }
    False -> 0
  }

  let b_top = x_res * bottom
  let b_bot = top * x1 + x2 * bottom
  let b_remainder = b_top |> int.remainder(b_bot)

  let a_top = x_res * top
  let a_bot = top * x1 + bottom * x2
  let a_remainder = a_top |> int.remainder(a_bot)

  // io.debug(#("remainder", a_remainder, b_remainder))

  case a_remainder, b_remainder {
    Ok(0), Ok(0) -> {
      let b = b_top / b_bot
      let a = a_top / a_bot
      let a_check = b * top / bottom
      case a == a_check {
        True -> {
          a * 3 + b
        }
        False -> 0
      }
    }
    _, _ -> 0
  }
  // let margin =
  //   int.to_float(top)
  //   |> float.divide(int.to_float(bottom))
  //   |> fn(x) {
  //     case x {
  //       Ok(x) -> x
  //       Error(a) -> {
  //         io.debug(#("reeeeeeeeeee", a))
  //         0.0
  //       }
  //     }
  //   }
  // // |> result.unwrap(0.0)
  // let hmm =
  //   top * x1
  //   |> int.remainder(bottom)
  // io.debug(#("inttttt", top * x1, bottom, hmm))

  // let b_divider =
  //   x1
  //   |> int.to_float
  //   |> float.multiply(margin)
  //   |> float.add(x2 |> int.to_float)

  // let b_res =
  //   x_res
  //   |> int.to_float
  //   |> float.divide(b_divider)
  //   |> result.unwrap(0.0)

  // let a_divider =
  //   x2
  //   |> int.to_float
  //   |> float.divide(margin)
  //   |> result.unwrap(0.0)
  //   |> float.add(x1 |> int.to_float)

  // let a_res =
  //   x_res |> int.to_float |> float.divide(a_divider) |> result.unwrap(0.0)

  // let a_mod = a_res |> float.modulo(1.0) |> result.unwrap(-0.1)
  // let b_mod = b_res |> float.modulo(1.0) |> result.unwrap(-0.1)

  // case a_mod == 0.0, b_mod == 0.0 {
  //   True, True -> {
  //     let a = a_res |> float.round
  //     let b = b_res |> float.round
  //     io.debug(#(margin, a, b))
  //     a * 3 + b
  //   }
  //   _, _ -> 0
  // }
}

fn find_traverse(
  line: #(#(Int, Int), #(Int, Int), #(Int, Int)),
  multiplier: Int,
  last_multiplier: Int,
) {
  case multiplier == last_multiplier, multiplier < 0 {
    True, _ -> #(0, 0)
    _, True -> #(0, 0)
    _, _ -> {
      let #(#(ax, ay), #(bx, by), #(x_res, y_res)) = line

      let diff = ay * multiplier
      let temp_b = y_res - diff
      let multiplier_b = temp_b / by

      let diff_2 = bx * multiplier_b
      let temp_a = x_res - diff_2
      let final_a = temp_a / ax

      // io.debug(#(multiplier, multiplier_b, final_a))

      let multiplied_x = ax * final_a
      let multiplied_y = ay * final_a

      let mod_x = { x_res - multiplied_x } % bx
      let mod_y = { y_res - multiplied_y } % by

      case mod_x, mod_y {
        0, 0 -> {
          let final_b = { x_res - multiplied_x } / bx
          let check = { y_res - multiplied_y } / by
          // io.debug(#("final", final_a, final_b, check))
          case final_b == check {
            False -> #(0, 0)
            True ->
              case final_a < 0, final_b < 0 {
                True, _ -> #(0, 0)
                _, True -> #(0, 0)
                _, _ -> #(final_a, final_b)
              }
          }
        }
        _, _ -> find_traverse(line, final_a, multiplier)
      }
    }
  }
}
/// fn find_value(line: #(#(Int, Int), #(Int, Int), #(Int, Int))) {
// fn find_value_2(line: #(#(Int, Int), #(Int, Int), #(Int, Int))) {
//   let #(#(x1, y1), #(x2, y2), #(x_res, y_res)) = line
//   let x1_max = x_res / x1
//   let y1_max = y_res / y1

//   let #(a_max, new_line) = case x1_max > y1_max {
//     True -> #(y1_max, #(#(y1, x1), #(y2, x2), #(y_res, x_res)))
//     False -> #(x1_max, line)
//   }

//   // io.debug(#("start from", line, x1_max, y1_max))

//   let a_res = find_traverse(new_line, a_max, a_max + 1)
//   let x2_max = x_res / x2
//   let y2_max = y_res / y2
//   let #(b_max, final_line) = case x2_max > y2_max {
//     True -> #(y2_max, #(#(y2, x2), #(y1, x1), #(y_res, x_res)))
//     False -> #(x2_max, #(#(x2, y2), #(x1, y1), #(x_res, y_res)))
//   }
//   let b_res = find_traverse(final_line, b_max, b_max + 1)

//   let a_val = a_res.0 * 3 + a_res.1
//   let b_val = b_res.1 * 3 + b_res.0

//   // io.debug(#(a_res, b_res))
//   case a_val == b_val {
//     True -> 0
//     False -> {
//       io.debug(#("diff", a_val, b_val))
//       0
//     }
//   }

//   case a_val == 0 {
//     True -> b_val
//     False ->
//       case b_val == 0 {
//         True -> a_val
//         False ->
//           case a_val > b_val {
//             True -> b_val
//             False -> a_val
//           }
//       }
//   }
//   // case final_res.0 > 100, final_res.1 > 100 {
//   //   True, _ -> #(0, 0)
//   //   _, True -> #(0, 0)
//   //   _, _ -> final_res
//   // }
// }
// fn get_min(line: #(#(Int, Int), #(Int, Int), #(Int, Int)), from_max: Int) {
//   let #(#(ax, _), #(bx, _), #(x_res, _)) = line
//   let diff = bx * from_max
//   let temp_b = x_res - diff
//   temp_b / ax
// }
// fn find_value_2(line: #(#(Int, Int), #(Int, Int), #(Int, Int))) {
//   let #(#(x1, y1), #(x2, y2), #(x_res, y_res)) = line
//   let x1_max = x_res / x1
//   let y1_max = y_res / y1
//   let x2_max = x_res / x2
//   let y2_max = y_res / y2
//   let data_1 = #(x1_max, y1_max, x1_max > y1_max)
//   let data_2 = #(x2_max, y2_max, x2_max > y2_max)

//   let #(min_2, max_1) = get_min(#(x1, y1), #(x2, y2), #(x_res, y_res), data_1)
//   let #(min_1, max_2) = get_min(#(x2, y2), #(x1, y1), #(x_res, y_res), data_2)

//   // let max_1 = case data_2.2 {
//   //   True -> y2_max
//   //   False -> x2_max
//   // }
//   // let max_2 = case data_1.2 {
//   //   True -> y1_max
//   //   False -> x1_max
//   // }

//   io.debug(#(min_1, max_1))
//   io.debug(#(min_2, max_2))
//   // let min_max_1 = get_min(line, data_1, data_2) let min_max_2 = get_min(line, data_2, data_1)
//   // io.debug(#(x1, x_res, y1, y_res))
//   // io.debug(#(x1_max, y1_max))
//   // press_buttons(line, max_1, 0)
// }

// fn get_min(
//   check_from: #(Int, Int),
//   check_to: #(Int, Int),
//   res: #(Int, Int),
//   data: #(Int, Int, Bool),
// ) {
//   let #(
//     init,
//     other_button,
//     target_res,
//     max_iter,
//     init_2,
//     other_button_2,
//     target_res_2,
//   ) = case data.2 {
//     True -> #(
//       check_from.0,
//       check_to.0,
//       res.0,
//       data.1,
//       check_to.1,
//       check_from.1,
//       res.1,
//     )
//     False -> #(
//       check_from.1,
//       check_to.1,
//       res.1,
//       data.0,
//       check_to.0,
//       check_from.0,
//       res.0,
//     )
//   }
//   io.debug(#(init, other_button, target_res, max_iter))
//   let diff = init * max_iter
//   let min_target = target_res - diff
//   let min = min_target / other_button

//   io.debug(#(init_2, other_button_2, target_res_2, min))
//   let diff_2 = init_2 * min
//   let min_target_2 = target_res_2 - diff_2
//   let max = min_target_2 / other_button_2

//   #(min, max)
// }

// fn press_buttons(
//   line: #(#(Int, Int), #(Int, Int), #(Int, Int)),
//   max_iter: Int,
//   iter: Int,
// ) {
//   // io.debug(#(line, iter))
//   case iter % 1_000_000_000 == 0 {
//     True -> iter |> io.debug()
//     False -> 0
//   }
//   case iter > max_iter {
//     True -> #(0, 0)
//     False -> {
//       let #(#(x1, y1), #(x2, y2), #(x_res, y_res)) = line
//       case x_res % x1 == 0 {
//         False ->
//           press_buttons(
//             #(#(x1, y1), #(x2, y2), #(x_res - x1, y_res - y1)),
//             max_iter,
//             iter + 1,
//           )
//         True -> {
//           case y_res % y2 == 0 {
//             False ->
//               press_buttons(
//                 #(#(x1, y1), #(x2, y2), #(x_res - x1, y_res - y1)),
//                 max_iter,
//                 iter + 1,
//               )
//             True -> {
//               let x_val = x_res / x1
//               let y_val = y_res / y2
//               case x_val == y_val {
//                 False ->
//                   press_buttons(
//                     #(#(x1, y1), #(x2, y2), #(x_res - x1, y_res - y1)),
//                     max_iter,
//                     iter + 1,
//                   )
//                 True -> #(iter, x_val)
//               }
//             }
//           }
//         }
//       }
//     }
//   }
// }

//   let #(#(x1, y1), #(x2, y2), #(x_res, y_res)) = line
//   let x_max = x_res / x1
//   let y_max = y_res / y1
//   let a_max = case x_max > y_max {
//     True -> x_max
//     False -> y_max
//   }
//   list.range(0, a_max)
//   |> list.fold([], fn(acc, iter) {
//     let #(x_temp, y_temp) = #(x_res - iter * x1, y_res - iter * y1)
//     case x_temp % x2 == 0 {
//       False -> acc
//       True ->
//         case y_temp % y2 == 0 {
//           False -> acc
//           True -> {
//             let x_val = x_temp / x2
//             let y_val = y_temp / y2
//             case x_val == y_val {
//               False -> acc
//               True -> {
//                 acc |> list.append([#(iter, y_val)])
//               }
//             }
//           }
//         }
//     }
//   })
//
