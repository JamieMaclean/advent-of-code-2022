defmodule Day6 do
  def run(file) do
    part_1 =
      get_signal(file)
      |> get_marker(4, 4)
      |> IO.inspect(label: "Total Rucksack Priority:")

    part_2 =
      get_signal(file)
      |> get_marker(14, 14)
      |> IO.inspect(label: "Total Rucksack Priority:")

    {part_1, part_2}
  end

  def get_marker(string, marker_size, count) do
    <<head, marker::binary-size(marker_size-1), rest::binary>> = string

    String.graphemes(<<head>> <> marker)
    |> Enum.uniq()
    |> length()
    |> case do
      ^marker_size -> count
      _ -> get_marker(marker <> rest, marker_size, count + 1)
    end
  end

  def get_signal(filename) do
    [signal] = File.read!(filename)
    |> String.split("\n", trim: true)

    signal
  end
end
