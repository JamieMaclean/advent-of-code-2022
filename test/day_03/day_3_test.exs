defmodule Day3Test do
  use ExUnit.Case

  alias Day3

  test "asserts day 3 test score" do
    assert Day3.run("test/day_03/input.txt") == {157, 70}
  end
end
