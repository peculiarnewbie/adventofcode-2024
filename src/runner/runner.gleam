import gleam/int
import gleam/result
import gleam/string
import gleam/string_tree
import simplifile

pub fn parse_line(day: Int) {
  get_file(day, False)
  |> simplifile.read
  |> result.unwrap("")
  |> string.split(on: "\n")
}

pub fn parse_sample(day: Int) {
  get_file(day, True)
  |> simplifile.read
  |> result.unwrap("")
  |> string.split(on: "\n")
}

pub fn parse_line_no_split(day: Int) {
  get_file(day, False)
  |> simplifile.read
  |> result.unwrap("")
}

pub fn parse_sample_no_split(day: Int) {
  get_file(day, True)
  |> simplifile.read
  |> result.unwrap("")
}

fn get_file(day: Int, sample: Bool) {
  let filename = case sample {
    True -> "/sample.txt"
    False -> "/input.txt"
  }
  int.to_string(day)
  |> string_tree.from_string()
  |> string_tree.prepend("./src/day_")
  |> string_tree.append(filename)
  |> string_tree.to_string()
}
