defmodule Day7 do
  defmodule Directory do
    defstruct [:name, contents: []]
  end

  defmodule Action do
    defstruct [:action, :data]
  end

  defmodule Archive do
    defstruct [:name, :size]
  end

  defmodule Filesystem do
    defstruct filesystem: %Directory{name: "~"}, current_directory: ["~"]

    def update_file_system(
          %Filesystem{filesystem: base_dir, current_directory: cd},
          %Action{} = action
        ) do
      base_dir = update_directory(base_dir, cd, action)
      %Filesystem{filesystem: base_dir, current_directory: cd}
    end

    def update_directories([], _cd, _action, updated_dirs) do
      updated_dirs
    end

    def update_directories([%Archive{} = archive | remaining_dirs], cd, action, updated_dirs) do
      update_directories(remaining_dirs, cd, action, [archive | updated_dirs])
    end

    def update_directories([%Directory{} = dir | remaining_dirs], cd, action, updated_dirs) do
      dir = update_directory(dir, cd, action)
      update_directories(remaining_dirs, cd, action, [dir | updated_dirs])
    end

    def update_directory(%Directory{} = dir, %Action{action: :add, data: new_item}) do
      if Filesystem.exists?(dir, new_item) do
        dir
      else
        struct(dir, %{contents: [new_item | dir.contents]})
      end
    end

    def update_directory(
          %Directory{name: name} = dir,
          [dir_name | []],
          %Action{} = action
        ) do
      if name == dir_name do
        update_directory(dir, action)
      else
        dir
      end
    end

    def update_directory(
          %Directory{contents: children, name: name} = dir,
          [dir_name | remaining_dirs],
          %Action{} = action
        ) do
      if name == dir_name do
        struct(dir, %{contents: update_directories(children, remaining_dirs, action, [])})
      else
        dir
      end
    end

    def get_current_directory(%Directory{name: name, contents: children}, [
          next_dir | remaining_dirs
        ])
        when name == next_dir do
      get_current_directory(children, remaining_dirs)
    end

    def get_current_directory(_, _), do: nil

    def exists?(%Directory{} = cd, %Directory{name: name}) do
      Enum.any?(cd.contents, fn
        %Directory{name: ^name} -> true
        _ -> false
      end)
    end

    def exists?(%Directory{} = cd, %Archive{name: name}) do
      Enum.any?(cd.contents, fn
        %Archive{name: ^name} -> true
        _ -> false
      end)
    end

    def move_to_root(%Filesystem{} = filesystem) do
      struct(filesystem, current_directory: ["~"])
    end

    def move_to_dir(%Filesystem{current_directory: cd} = filesystem, dir) do
      struct(filesystem, current_directory: cd ++ [dir])
    end

    def move_up_dir(%Filesystem{current_directory: []} = fs), do: fs

    def move_up_dir(%Filesystem{current_directory: cd} = filesystem) do
      cd =
        Enum.reverse(cd)
        |> tl()
        |> Enum.reverse()

      struct(filesystem, current_directory: cd)
    end

    def part_1_directory_reducer(%Filesystem{filesystem: dirs}) do
      part_1_directory_reducer(dirs, 0)
    end

    def part_1_directory_reducer([], size) do
      size
    end

    def part_1_directory_reducer([%Archive{} | rest], size) do
      part_1_directory_reducer(rest, size)
    end

    def part_1_directory_reducer([%Directory{} = dir | rest], size) do
      size = part_1_directory_reducer(dir, size)
      part_1_directory_reducer(rest, size)
    end

    def part_1_directory_reducer(%Directory{contents: dirs} = dir, size) do
      case total_size(dir) do
        small when small < 100000 -> part_1_directory_reducer(dirs, size + small)
        _ -> part_1_directory_reducer(dirs, size)
      end
    end

    def all_big_dirs(%Filesystem{filesystem: dirs}, size) do
      all_big_dirs(dirs, size, [])
    end

    def all_big_dirs([], _size, dirs) do
      dirs
    end

    def all_big_dirs([%Archive{} | rest], size, dirs) do
      all_big_dirs(rest, size, dirs)
    end

    def all_big_dirs([%Directory{} = dir | rest], size, big_dirs) do
      big_dirs = all_big_dirs(dir, size, big_dirs)
      all_big_dirs(rest, size, big_dirs)
    end

    def all_big_dirs(%Directory{contents: dirs} = dir, size, big_dirs) do
      case total_size(dir) do
        big when big > size -> all_big_dirs(dirs, size, [dir | big_dirs])
        _ -> all_big_dirs(dirs, size, big_dirs)
      end
    end

    def total_size(%Directory{contents: directories}) do
      total_size(directories, 0)
    end

    def total_size([], size) do
      size
    end

    def total_size([%Directory{contents: []} | rest], size) do
      total_size(rest, size)
    end

    def total_size([%Directory{contents: contents} | rest], size) do
      size = total_size(contents, size)
      total_size(rest, size)
    end

    def total_size([%Archive{size: archive_size} | rest], size) do
      size = size + archive_size
      total_size(rest, size)
    end
  end

  def run(file) do
    part_1 =
      list_commands(file)
      |> execute_command(%Filesystem{})
      |> Filesystem.part_1_directory_reducer()
      |> IO.inspect(label: "Size of all directories smaller than 100000:")

    part_2_filesystem =
      list_commands(file)
      |> execute_command(%Filesystem{})

    total = 70000000
    required = 30000000

    size = Filesystem.total_size(part_2_filesystem.filesystem)
    free = total - size

    to_be_deleted = required - free

      part_2 = Filesystem.all_big_dirs(part_2_filesystem, to_be_deleted)
      |> Enum.map(&Filesystem.total_size/1)
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
