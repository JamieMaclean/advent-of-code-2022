defmodule Day11Test do
  use ExUnit.Case

  alias Day11

  test "completes challenge successfully" do
    assert Day11.run("test/day_11/input.txt") == {0, 0}
  end
end
