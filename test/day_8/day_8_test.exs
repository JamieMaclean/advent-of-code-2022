defmodule Day8Test do
  use ExUnit.Case

  alias Day8
  alias Day8.Tree

  test "completes challenge successfully" do
    assert Day8.run("test/day_8/input.txt") ==
             {21, %Tree{size: 5, viewing_distance: 8, visible: true}}
  end
end
