defmodule Day7.Directory do
  defstruct [:name, contents: []]

  alias __MODULE__
  alias Day7.Archive

  def size(%Directory{contents: directories}) do
    size(directories, 0)
  end

  def size([], size) do
    size
  end

  def size([%Directory{contents: []} | rest], size) do
    size(rest, size)
  end

  def size([%Directory{contents: contents} | rest], size) do
    size = size(contents, size)
    size(rest, size)
  end

  def size([%Archive{size: archive_size} | rest], size) do
    size = size + archive_size
    size(rest, size)
  end
end
