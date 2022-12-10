defmodule Day6Test do
  use ExUnit.Case

  alias Day6

  test "completes challenge successfully" do
    assert Day6.run("test/day_06/input.txt") == {11, 26}
  end
end
