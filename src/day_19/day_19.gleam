import gleam/dict
import gleam/io
import gleam/list
import gleam/string
import runner/runner

pub fn main() {
  let day = 19
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  //   let assert 143 = 
  pt_1(sample)
  //   pt_1(res)
  //   pt_2(sample)
  pt_2(res)
}

fn pt_1(lines: List(String)) {
  let #(towels, patterns, max) = generate_towels(lines) |> io.debug
  patterns
  |> list.index_map(fn(x, i) {
    io.debug(i)
    let #(res, _) = create_pattern(x, 1, towels, max, dict.new())
    res |> io.debug
  })
  |> list.filter(fn(x) { x })
  |> list.length
  |> io.debug
}

fn pt_2(lines: List(String)) {
  let #(towels, patterns, max) = generate_towels(lines) |> io.debug
  patterns
  |> list.index_map(fn(x, i) {
    io.debug(i)
    let #(res, _) = count_pattern(x, 1, towels, max, dict.new(), 0)
    res |> io.debug
  })
  |> list.fold(0, fn(acc, x) { acc + x })
  |> io.debug
}

fn generate_towels(lines: List(String)) {
  case lines {
    [towels, _, ..patterns] -> {
      let #(max, towels) =
        string.split(towels, ", ")
        |> list.map_fold(0, fn(acc, x) {
          let length = string.length(x)
          case length > acc {
            True -> #(length, #(x, True))
            False -> #(acc, #(x, True))
          }
        })

      #(towels |> dict.from_list, patterns, max)
    }
    _ -> #(dict.new(), [], -1)
  }
}

fn create_pattern(
  pattern: String,
  pointer: Int,
  towels: dict.Dict(String, Bool),
  max_length: Int,
  cache: dict.Dict(String, Bool),
) {
  case pattern |> string.length == 0 {
    True -> #(True, cache)
    False -> {
      case cache |> dict.get(pattern) {
        Ok(True) -> #(False, cache)
        _ -> {
          case pointer > max_length, pointer > pattern |> string.length {
            False, False -> {
              let start = pattern |> string.slice(0, pointer)
              io.debug(#(pattern, start, pointer, max_length))
              let #(start_res, new_cache) = case towels |> dict.get(start) {
                Ok(True) -> {
                  //   io.debug(#("found", start))
                  create_pattern(
                    pattern |> string.drop_start(pointer),
                    1,
                    towels,
                    max_length,
                    cache,
                  )
                }
                _ -> #(False, cache)
              }

              case start_res {
                True -> #(True, cache)
                _ -> {
                  create_pattern(
                    pattern,
                    pointer + 1,
                    towels,
                    max_length,
                    new_cache,
                  )
                }
              }
            }
            _, _ -> #(False, cache |> dict.insert(pattern, True))
          }
        }
      }
    }
  }
}

fn count_pattern(
  pattern: String,
  pointer: Int,
  towels: dict.Dict(String, Bool),
  max_length: Int,
  cache: dict.Dict(String, Int),
  res: Int,
) -> #(Int, dict.Dict(String, Int)) {
  io.debug(#(pattern, pointer, max_length, res))
  case pattern |> string.length == 0 {
    True -> #(res + 1, cache)
    False -> {
      case cache |> dict.get(pattern) {
        Ok(0) -> #(res, cache) |> io.debug
        _ -> {
          case pointer > max_length, pointer > pattern |> string.length {
            False, False -> {
              let start = pattern |> string.slice(0, pointer)
              let end = pattern |> string.drop_start(pointer)
              let #(start_res, cache_res) = case towels |> dict.get(start) {
                Ok(True) -> {
                  io.debug(#("found", start))
                  case cache |> dict.get(end) {
                    Ok(a) -> #(res + a, cache)
                    _ ->
                      count_pattern(
                        pattern |> string.drop_start(pointer),
                        1,
                        towels,
                        max_length,
                        cache,
                        res,
                      )
                  }
                }
                _ -> #(res, cache)
              }

              let new_cache = case start_res > res {
                True ->
                  cache_res
                  |> dict.insert(
                    pattern |> string.drop_start(pointer),
                    start_res - res,
                  )
                _ -> cache_res
              }

              count_pattern(
                pattern,
                pointer + 1,
                towels,
                max_length,
                new_cache,
                start_res,
              )
            }
            _, _ -> {
              case cache |> dict.get(pattern) {
                Ok(_) -> #(res, cache)
                _ -> #(res, cache |> dict.insert(pattern, 0))
              }
            }
          }
        }
      }
    }
  }
}
