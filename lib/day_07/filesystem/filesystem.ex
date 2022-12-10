defmodule Day7.Filesystem do
  alias __MODULE__
  alias Day7.{Action, Archive, Directory}

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
    case Directory.size(dir) do
      small when small < 100_000 -> part_1_directory_reducer(dirs, size + small)
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
    case Directory.size(dir) do
      big when big > size -> all_big_dirs(dirs, size, [dir | big_dirs])
      _ -> all_big_dirs(dirs, size, big_dirs)
    end
  end
end
