import gleam/io
import runner/runner

pub fn main() {
  let day = 0
  let res = runner.parse_line(day)

  io.debug(res)
}
