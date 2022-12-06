defmodule Day1 do
  def run(file) do
    part_1 =
      parse_file(file)
      |> max_held_by_elves(1)

    part_2 =
      parse_file(file)
      |> max_held_by_elves(3)

    {part_1, part_2}
  end

  def parse_file(file) do
    File.read!(file)
    |> String.split("\n\n", trim: true)
  end

  def max_held_by_elves(elves, number_of_elves) do
    Enum.map(elves, fn snacks ->
      String.split(snacks, "\n", trim: true)
      |> convert_to_ints()
      |> Enum.sum()
    end)
    |> take_max(number_of_elves)
    |> Enum.sum()
    |> IO.inspect(label: "Max calories held by #{number_of_elves} elves:")
  end

  defp convert_to_ints(array) do
    Enum.reject(array, fn string -> string == "" end)
    |> Enum.map(&String.to_integer/1)
  end

  defp take_max(array, number_of_elves, answer \\ [])

  defp take_max(_array, number_of_elves, answer) when length(answer) == number_of_elves,
    do: answer

  defp take_max(array, number_of_elves, answer) do
    max = Enum.max(array)
    array = Enum.reject(array, fn a -> a == max end)
    take_max(array, number_of_elves, [max | answer])
  end
end
