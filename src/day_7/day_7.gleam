import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 7
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  let assert 3749 = pt_1(sample)
  // pt_1(res)

  let assert 11_387 = pt_2(sample)
  pt_2(res)
}

fn pt_1(lines: List(String)) {
  lines
  |> generate_res_tuple()
  |> list.map(fn(x) {
    let #(result, children) = x
    let pass = traverse(result, children, 0)
    #(result, pass)
  })
  |> list.fold(0, fn(acc, x) {
    case x {
      #(result, True) -> acc + result
      _ -> acc
    }
  })
  |> io.debug
}

fn pt_2(lines: List(String)) {
  lines
  |> generate_res_tuple()
  // |> io.debug
  |> list.map(fn(x) {
    let #(result, children) = x
    let pass = traverse_with_combine(result, children)
    #(result, pass)
  })
  |> list.fold(0, fn(acc, x) {
    case x {
      #(result, True) -> acc + result
      _ -> acc
    }
  })
  |> io.debug
}

fn generate_res_tuple(lines: List(String)) {
  lines
  |> list.map(fn(x) {
    let split = x |> string.split(on: ":")
    case split {
      [a, b, ..] -> {
        let result = a |> int.parse() |> result.unwrap(0)
        let children =
          b
          |> string.split(on: " ")
          |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
        #(result, children)
      }
      _ -> #(0, [])
    }
  })
}

fn traverse(result: Int, children: List(Int), acc: Int) {
  case children {
    [] ->
      case acc == result {
        True -> {
          // io.debug(#(result, children, acc))
          True
        }
        False -> False
      }
    _ -> {
      let child = children |> list.first() |> result.unwrap(0)
      case traverse(result, children |> list.drop(1), acc + child) {
        True -> True
        False -> traverse(result, children |> list.drop(1), acc * child)
      }
    }
  }
}

fn traverse_with_combine(result: Int, children: List(Int)) {
  //   io.debug(#(result, children))
  case children {
    [] -> False
    [a] -> {
      case a == result {
        True -> True
        False -> False
      }
    }
    [a, b, ..] -> {
      let combined =
        { int.to_string(a) <> int.to_string(b) }
        |> int.parse()
        |> result.unwrap(0)
      case
        traverse_with_combine(
          result,
          children |> list.drop(2) |> list.prepend(combined),
        )
      {
        True -> True
        False ->
          case
            traverse_with_combine(
              result,
              children |> list.drop(2) |> list.prepend(a + b),
            )
          {
            True -> True
            False ->
              traverse_with_combine(
                result,
                children |> list.drop(2) |> list.prepend(a * b),
              )
          }
      }
    }
  }
}
