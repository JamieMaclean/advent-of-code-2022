defmodule Day14Test do
  use ExUnit.Case

  alias Day14

  test "completes challenge successfully" do
    assert Day14.run("test/day_14/input.txt") == {24, 93}
  end
end
