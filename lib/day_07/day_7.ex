defmodule Day7 do
  alias Day7.{Action, Archive, Directory, Filesystem}

  def run(file) do
    part_1 =
      list_commands(file)
      |> execute_command(%Filesystem{})
      |> Filesystem.part_1_directory_reducer()
      |> IO.inspect(label: "Size of all directories smaller than 100000:")

    part_2_filesystem =
      list_commands(file)
      |> execute_command(%Filesystem{})

    total = 70_000_000
    required = 30_000_000

    total_used = Directory.size(part_2_filesystem.filesystem)
    free = total - total_used

    to_be_deleted = required - free

    part_2 =
      Filesystem.all_big_dirs(part_2_filesystem, to_be_deleted)
      |> Enum.map(&Directory.size/1)
      |> Enum.min()
      |> IO.inspect(label: "Smallest directory to free up space:")

    {part_1, part_2}
  end

  def list_commands(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
  end

  defp execute_command(["$ ls" | remaining_commands], filesystem) do
    execute_command(remaining_commands, filesystem)
  end

  defp execute_command(["$ cd /" | remaining_commands], filesystem) do
    execute_command(remaining_commands, Filesystem.move_to_root(filesystem))
  end

  defp execute_command(["$ cd .." | remaining_commands], filesystem) do
    execute_command(remaining_commands, Filesystem.move_up_dir(filesystem))
  end

  defp execute_command(["$ cd " <> dir | remaining_commands], filesystem) do
    execute_command(remaining_commands, Filesystem.move_to_dir(filesystem, dir))
  end

  defp execute_command(["dir " <> dir_name | remaining_commands], filesystem) do
    action = %Action{action: :add, data: %Directory{name: dir_name}}
    filesystem = Filesystem.update_file_system(filesystem, action)

    execute_command(remaining_commands, filesystem)
  end

  defp execute_command([file | remaining_commands], filesystem) do
    [size, filename] = String.split(file, " ", trim: true)
    action = %Action{action: :add, data: %Archive{name: filename, size: String.to_integer(size)}}
    filesystem = Filesystem.update_file_system(filesystem, action)

    execute_command(remaining_commands, filesystem)
  end

  defp execute_command([], filesystem) do
    filesystem
  end
end
