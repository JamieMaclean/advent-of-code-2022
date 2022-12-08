defmodule Day7Test do
  use ExUnit.Case

  alias Day7
  alias Day7.{Directory, Filesystem, Action}

  test "completes challenge successfully" do
    assert Day7.run("test/day_7/input.txt") == {95437, 24_933_642}
  end

  describe "update_file_system/3" do
    test "add a directory to the base_dir" do
      filesystem =
        %Filesystem{}
        |> Filesystem.update_file_system(%Action{
          action: :add,
          data: %Directory{name: "level_1 dir"}
        })

      assert [%Directory{}] = filesystem.filesystem.contents
    end
  end
end
