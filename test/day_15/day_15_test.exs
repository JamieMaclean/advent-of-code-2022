defmodule Day15Test do
  use ExUnit.Case

  alias Day15

  test "completes challenge successfully" do
    assert Day15.run("test/day_15/input.txt") == {0, 0}
  end
end
