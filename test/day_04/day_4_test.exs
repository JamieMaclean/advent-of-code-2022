defmodule Day4Test do
  use ExUnit.Case

  alias Day4

  test "asserts day 3 test score" do
    assert Day4.run("test/day_04/input.txt") == {2, 4}
  end
end
