defmodule Day12Test do
  use ExUnit.Case

  alias Day12

  test "completes challenge successfully" do
    assert Day12.run("test/day_12/input.txt") == {32, 0}
  end
end
