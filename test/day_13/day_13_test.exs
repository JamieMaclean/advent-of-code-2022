defmodule Day13Test do
  use ExUnit.Case

  alias Day13

  test "completes challenge successfully" do
    assert Day13.run("test/day_13/input.txt") == {13, 140}
  end
end
