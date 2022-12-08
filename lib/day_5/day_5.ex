defmodule Day5 do
  def run(file) do
    [stacks, instructions] = parse_input(file)

    part_1 =
      make_move(stacks, instructions, 9000)
      |> Enum.map(fn {<<first::binary-size(1), _::binary>>, _} -> first end)
      |> List.to_string()
      |> IO.inspect(label: "Top of each stack:")

    part_2 =
      make_move(stacks, instructions, 9001)
      |> Enum.map(fn {<<first::binary-size(1), _::binary>>, _} -> first end)
      |> List.to_string()
      |> IO.inspect(label: "With crane 9001:")

    {part_1, part_2}
  end

  def parse_input(filename) do
    [stacks, instructions] =
      filename
      |> File.read!()
      |> String.split("\n\n", trim: true)

    stacks =
      String.split(stacks, "\n", trim: true)
      |> Enum.map(fn row ->
        parse_row(row)
      end)
      |> Enum.reject(&is_nil/1)
      |> invert_stacks()
      |> Enum.reverse()
      |> Enum.map(fn stack -> List.to_string(stack) end)
      |> Enum.with_index()

    instructions =
      instructions
      |> String.split("\n", trim: true)
      |> Enum.map(fn instructoion ->
        [_, quantity, _, stack_1, _, stack_2] = String.split(instructoion, " ", trim: true)
        [String.to_integer(quantity), String.to_integer(stack_1), String.to_integer(stack_2)]
      end)

    [stacks, instructions]
  end

  def make_move(stacks, [], _crane_type) do
    stacks
  end

  def make_move(stacks, [[quantity, from, to] | other_moves], crane_type) do
    {<<moved::binary-size(quantity), remaining_from::binary>>, _} =
      Enum.find(stacks, fn {_, index} -> index == from - 1 end)

    {to_stack, _} = Enum.find(stacks, fn {_, index} -> index == to - 1 end)

    updated_to_stack =
      if crane_type == 9000 do
        String.reverse(moved) <> to_stack
      else
        moved <> to_stack
      end

    Enum.map(stacks, fn
      {_, index} when index == from - 1 -> {remaining_from, index}
      {_, index} when index == to - 1 -> {updated_to_stack, index}
      stack -> stack
    end)
    |> make_move(other_moves, crane_type)
  end

  def parse_row(row) do
    if String.contains?(row, "[") do
      parse_row(row, [])
    else
      nil
    end
  end

  def parse_row("", parsed_row) do
    parsed_row
  end

  def parse_row(<<32, 32, 32, 32, rest::binary>>, parsed_row) do
    parse_row(rest, ["" | parsed_row])
  end

  def parse_row(<<32, 91, letter::binary-size(1), 93, rest::binary>>, parsed_row) do
    parse_row(rest, [letter | parsed_row])
  end

  def parse_row(<<91, letter::binary-size(1), 93, rest::binary>>, parsed_row) do
    parse_row(rest, [letter | parsed_row])
  end

  def invert_stacks(stacks) do
    Enum.zip(stacks)
    |> Enum.map(&Tuple.to_list/1)
  end
end
