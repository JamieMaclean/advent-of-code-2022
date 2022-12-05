defmodule Mix.Tasks.Day1 do
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    File.read!("lib/mix/tasks/day_1/input.txt")
    |> String.split("\n\n")
    |> Enum.map(&String.split(&1, "\n"))
    |> Enum.map(&convert_to_ints/1)
    |> Enum.map(&Enum.sum/1)
    |> take_max()
    |> Enum.sum()
    |> IO.puts()
  end

  defp convert_to_ints(array) do
    Enum.reject(array, fn string -> string == "" end)
    |> Enum.map(&String.to_integer/1)
  end

  defp take_max(array, answer \\ [])

  defp take_max(_array, [_, _, _] = answer), do: answer

  defp take_max(array, answer) do
    max = Enum.max(array)
    array = Enum.reject(array, fn a -> a == max end)
    take_max(array, [max | answer])
  end
end
