defmodule AODTest do
  use ExUnit.Case
  doctest AOD

  test "greets the world" do
    assert AOD.hello() == :world
  end
end
