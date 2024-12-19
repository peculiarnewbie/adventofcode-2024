import gleam/int
import gleam/io

pub fn main() {
  io.println("Hello from adventofcode_2024!")
  io.debug([1, 2, 3, 4] |> int.undigits(10))
}
