import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 10
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  let assert 36 = pt(sample, 1)
  pt(res, 1) |> io.debug

  let assert 81 = pt(sample, 2)
  pt(res, 2) |> io.debug
}

fn pt(lines: List(String), pt: Int) {
  let map = build_map(lines)

  map
  |> dict.fold(0, fn(acc, key, val) {
    case val {
      0 -> {
        let head_list =
          get_trailhead_score(
            map,
            key,
            current_step: 0,
            heads: dict.new(),
            pt: pt,
          )
        // io.debug(#(key, head_list))
        acc + list.length(head_list)
      }
      _ -> acc
    }
  })
}

fn build_map(lines: List(String)) {
  lines
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(grapheme, x) {
      grapheme
      |> int.parse
      |> result.unwrap(0)
      |> fn(z) { #(#(x, y), z) }
    })
  })
  |> list.flatten
  |> dict.from_list
}

fn get_trailhead_score(
  map: dict.Dict(#(Int, Int), Int),
  pos: #(Int, Int),
  current_step current_step: Int,
  heads heads: dict.Dict(#(Int, Int), Bool),
  pt pt: Int,
) {
  case current_step {
    -1 -> []
    9 -> [pos]
    a -> {
      //   io.debug(#(pos, current_step, score))
      let up = #(pos.0, pos.1 - 1)
      let up_step = dict.get(map, up) |> result.unwrap(-1)
      let right = #(pos.0 + 1, pos.1)
      let right_step = dict.get(map, right) |> result.unwrap(-1)
      let down = #(pos.0, pos.1 + 1)
      let down_step = dict.get(map, down) |> result.unwrap(-1)
      let left = #(pos.0 - 1, pos.1)
      let left_step = dict.get(map, left) |> result.unwrap(-1)

      let up_list = case up_step == { a + 1 } {
        True -> get_trailhead_score(map, up, up_step, heads, pt)
        False -> []
      }
      let right_list = case right_step == { a + 1 } {
        True -> get_trailhead_score(map, right, right_step, heads, pt)
        False -> []
      }
      let down_list = case down_step == { a + 1 } {
        True -> get_trailhead_score(map, down, down_step, heads, pt)
        False -> []
      }
      let left_list = case left_step == { a + 1 } {
        True -> get_trailhead_score(map, left, left_step, heads, pt)
        False -> []
      }

      let res =
        up_list
        |> list.append(right_list)
        |> list.append(down_list)
        |> list.append(left_list)

      case pt {
        1 -> res |> list.unique
        _ -> res
      }
      //   |> list.unique
    }
  }
}
