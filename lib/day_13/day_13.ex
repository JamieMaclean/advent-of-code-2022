defmodule Day13 do
  def run(file) do
    pairs = get_pairs(file)

    compared = Enum.map(pairs, fn [first, second] -> 
      case compare(first, second) do
        nil -> true
        bool -> bool
      end
    end)

    {sum, _} = for bool <- compared, reduce: {0, 0} do
      {sum, index} -> if bool do
          {sum + index + 1, index + 1}
      else
          {sum, index + 1}
      end
    end

    IO.inspect(sum, label: "Part 1")

    part_2 = for [first, second] <- pairs, reduce: [] do
      list -> [first | [second | list]]
    end
    |> Enum.concat([[[6]]])
    |> Enum.concat([[[2]]])
    |> Enum.sort(&compare/2)

    first = Enum.find_index(part_2, fn val -> val == [[2]] end) + 1
    second = Enum.find_index(part_2, fn val -> val == [[6]] end) + 1
    part_2 = first * second

    IO.inspect(part_2, label: "Part 2")

    {sum, first * second}
  end

  def get_pairs(filename) do
    File.read!(filename)
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn pair -> 
      String.split(pair, "\n", trim: true)
      |> Enum.map(fn list -> 
        String.graphemes(list)
        |> parse_list()
      end)
    end)
  end

  defp parse_list(["[" | rest]) do
    {list, _} = parse_list(rest, [])
    list
  end

  defp parse_list(["," | rest], list) do
    parse_list(rest, list)
  end

  defp parse_list(["]" | rest], list) do
    {Enum.reverse(list), rest}
  end

  defp parse_list(["[" | rest], list) do
    {inner_list, rest} = parse_list(rest, [])

    parse_list(rest, [inner_list | list])
  end

  defp parse_list([<<digit_1>> | [<<digit_2>> | rest]], list) when digit_1 in ?0..?9 and digit_2 in ?0..?9 do
    parse_list(rest, [String.to_integer(<<digit_1, digit_2>>) | list])
  end

  defp parse_list([<<digit>> = letter | rest], list) when digit in ?0..?9 do
    parse_list(rest, [String.to_integer(letter) | list])
  end

  defp compare([], [_ | _]), do: true
  defp compare([_ | _], []), do: false
  defp compare([], []), do: nil

  defp compare([first | first_rest], [second | second_rest]) do
    cond do
      is_number(first) and is_number(second) and first < second -> true
      first == second -> compare(first_rest, second_rest)
      is_list(first) and is_list(second) ->
        case compare(first, second) do
          true -> true
          false -> false
          nil -> compare(first_rest, second_rest)
        end
      is_list(first) and is_number(second) -> 
        case compare(first, [second]) do
          true -> true
          false -> false
          nil -> compare(first_rest, second_rest)
        end
      is_number(first) and is_list(second) -> 
        case compare([first], second) do
          true -> true
          false -> false
          nil -> compare(first_rest, second_rest)
        end
      true -> false
    end
  end
end
