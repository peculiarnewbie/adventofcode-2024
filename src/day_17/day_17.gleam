import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import runner/runner

pub fn main() {
  let day = 17
  let res =
    runner.parse_line(day)
    |> list.map(fn(x) { string.trim(x) })
  let sample =
    runner.parse_sample(day)
    |> list.map(fn(x) { string.trim(x) })

  //   let assert 143 = 
  pt_1(sample)
  //   pt_1(res)
  pt_1(res)
}

pub type Registers {
  Registers(a: Int, b: Int, c: Int)
}

fn pt_1(lines: List(String)) {
  let #(registers, operations) =
    generate_program(lines)
    |> result.unwrap(#(Registers(-1, -1, -1), [-1]))
    |> io.debug

  //   let #(final_registers, output) =
  run_operation(operations, registers, [], operations) |> io.debug
  generate_pt_2_ops(operations)
}

fn generate_pt_2_ops(ops: List(Int)) {
  let new_ops = [0, 1, 2, 3, 4, 1, 5]
  //   let #(relevant, _) = ops |> list.split(length - 2) |> io.debug
  //   reverse_operations(ops |> list.reverse, new_ops, Registers(0, 3, 0))
  reverse_operations(ops |> list.reverse, new_ops, Registers(0, 3, 0))
  |> io.debug
}

fn reverse_operations(input: List(Int), ops: List(Int), registers: Registers) {
  case input {
    [current, ..] -> {
      io.debug(#(ops, registers))
      let new_registers =
        ops
        |> list.fold(registers, fn(acc, op) { new_ops(op, current, acc) })
      reverse_operations(input |> list.drop(1), ops, new_registers)
    }
    _ -> registers
  }
}

fn new_ops(op: Int, input: Int, registers: Registers) {
  io.debug(#(op, input, registers))
  let Registers(a, b, c) = registers
  case op {
    0 -> {
      // 5, 5
      let rem = b |> int.remainder(8) |> result.unwrap(0)
      let addition = case rem > input {
        True -> 16 - rem - input
        False -> input - rem
      }
      io.debug(#(rem, addition))
      Registers(a, b + addition, c)
    }
    1 -> {
      // 1, 7
      let res = b |> int.bitwise_exclusive_or(7)
      Registers(a, res, c)
    }
    2 -> {
      // 4, 4
      let res = b |> int.bitwise_exclusive_or(c)
      Registers(a, res, c)
    }
    3 -> {
      // 0, 3
      let res = a * 8 + input
      let final = case res % 8, a < 8 {
        _, True -> res
        0, _ -> res
        _, _ -> res + b
      }
      Registers(final, b, c)
    }
    4 -> {
      // 7, 5
      //   let multiplier = 2 |> int.power(b |> int.to_float) |> result.unwrap(0.0)
      //   let res = c |> int.to_float |> float.multiply(multiplier) |> float.round
      Registers(a, b, c)
    }
    5 -> {
      // 2, 4
      let rem = a |> int.remainder(8) |> result.unwrap(0)
      let addition = case rem > b {
        True -> 16 - rem - b
        False -> b - rem
      }
      io.debug(#(rem, addition))
      Registers(a, b - rem, c)
    }
    _ -> Registers(a, b, c)
  }
}

fn run_operation(
  ops: List(Int),
  registers: Registers,
  out: List(Int),
  full_ops: List(Int),
) {
  io.debug(#(ops, registers, out))
  let Registers(a, b, c) = registers
  case ops {
    [0, combo, ..] -> {
      let divider =
        2
        |> int.power(get_combo_value(combo, registers) |> int.to_float)
        |> result.unwrap(0.0)
        |> float.round
      let res = {
        a / divider
      }
      run_operation(ops |> list.drop(2), Registers(res, b, c), out, full_ops)
    }
    [1, combo, ..] -> {
      let res = b |> int.bitwise_exclusive_or(combo)
      run_operation(ops |> list.drop(2), Registers(a, res, c), out, full_ops)
    }
    [2, combo, ..] -> {
      let res =
        get_combo_value(combo, registers)
        |> int.remainder(8)
        |> result.unwrap(0)
      run_operation(ops |> list.drop(2), Registers(a, res, c), out, full_ops)
    }
    [3, combo, ..] -> {
      case a {
        0 -> run_operation(ops |> list.drop(2), registers, out, full_ops)
        _ -> {
          run_operation(
            full_ops |> list.drop(combo),
            Registers(a, b, c),
            out,
            full_ops,
          )
        }
      }
    }
    [4, _, ..] -> {
      let res = b |> int.bitwise_exclusive_or(c)
      run_operation(ops |> list.drop(2), Registers(a, res, c), out, full_ops)
    }
    [5, combo, ..] -> {
      let res =
        get_combo_value(combo, registers)
        |> int.remainder(8)
        |> result.unwrap(0)
      run_operation(
        ops |> list.drop(2),
        Registers(a, b, c),
        out |> list.append([res]),
        full_ops,
      )
    }
    [6, combo, ..] -> {
      let divider =
        2
        |> int.power(get_combo_value(combo, registers) |> int.to_float)
        |> result.unwrap(0.0)
        |> float.round
      let res = {
        a / divider
      }
      run_operation(ops |> list.drop(2), Registers(a, res, c), out, full_ops)
    }
    [7, combo, ..] -> {
      let divider =
        2
        |> int.power(get_combo_value(combo, registers) |> int.to_float)
        |> result.unwrap(0.0)
        |> float.round
      let res = {
        a / divider
      }
      run_operation(ops |> list.drop(2), Registers(a, b, res), out, full_ops)
    }
    _ -> #(registers, out)
  }
}

fn get_combo_value(combo: Int, registers: Registers) {
  let Registers(a, b, c) = registers
  case combo {
    0 -> 0
    1 -> 1
    2 -> 2
    3 -> 3
    4 -> a
    5 -> b
    6 -> c
    _ -> -1
  }
}

fn generate_program(lines: List(String)) {
  case lines {
    [a, b, c, _, program, ..] -> {
      let values =
        [a, b, c]
        |> list.map(fn(x) {
          let split = x |> string.split(": ")
          case split {
            [_, val] -> int.parse(val) |> result.unwrap(0)
            _ -> -1
          }
        })
      let registers = case values {
        [q, w, e] -> Registers(q, w, e)
        _ -> Registers(-1, -1, -1)
      }
      let operations =
        program
        |> string.split("Program: ")
        |> list.last
        |> result.unwrap("")
        |> string.split(",")
        |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })

      Ok(#(registers, operations))
    }
    _ -> Error(Nil)
  }
}
