defmodule Day1Test do
  use ExUnit.Case

  alias Day1

  test "asserts day 1 test score" do
    assert Day1.run("test/day_1/input.txt") == {24000, 45000}
  end
end
