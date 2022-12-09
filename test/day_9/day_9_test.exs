defmodule Day9Test do
  use ExUnit.Case

  alias Day9

  test "completes challenge successfully" do
    assert Day9.run("test/day_9/input.txt") == {88, 36}
  end
end
