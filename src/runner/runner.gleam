import gleam/int
import gleam/string
import gleam/string_tree
import simplifile

pub fn parse_line(day: Int) {
  let input_file =
    int.to_string(day)
    |> string_tree.from_string()
    |> string_tree.prepend("./src/day_")
    |> string_tree.append("/input.txt")
    |> string_tree.to_string()
  let assert Ok(input) = simplifile.read(from: input_file)
  input |> string.split(on: "\n")
}
