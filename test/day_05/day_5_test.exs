defmodule Day5Test do
  use ExUnit.Case

  alias Day5

  test "asserts day 3 test score" do
    assert Day5.run("test/day_05/input.txt") == {"CMZ", "MCD"}
  end
end
