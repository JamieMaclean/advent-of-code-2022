defmodule Day2Test do
  use ExUnit.Case

  alias Day2

  test "asserts day 3 test score" do
    assert Day2.run("test/day_2/input.txt") == {15, 12}
  end
end
