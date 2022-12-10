defmodule Day10 do
  def run(file) do
    state = %{
      instructions: get_instructions(file),
      cycle: 0,
      value: 1,
      blocked: {0, 0},
      samples: [],
      sprites: [],
      sample_at: [20, 60, 100, 140, 180, 220]
    }

    %{samples: part_1, sprites: part_2} = tick(state)

    Enum.chunk_every(part_2, 40)
    |> Enum.reverse()
    |> Enum.each(fn a ->
      Enum.reverse(a)
      |> IO.puts()
    end)

    {Enum.sum(part_1), part_2}
  end

  def get_instructions(filename) do
    moves =
      File.read!(filename)
      |> String.split("\n", trim: true)

    for line <- moves do
      case line do
        "noop" -> {"noop", nil}
        <<"addx", 32, number::binary>> -> {"addx", String.to_integer(number)}
      end
    end
  end

  defp tick(
         %{
           value: value,
           instructions: instructions,
           blocked: {blocked_for, then_add}
         } = state
       ) do
    case {blocked_for, instructions} do
      {1, _} ->
        new_state = %{take_sample(state) | blocked: {0, 0}, value: value + then_add}

        tick(new_state)

      {0, []} ->
        state

      {0, _} ->
        new_state =
          take_sample(state)
          |> do_instruction(instructions)

        tick(new_state)

      _ ->
        new_state = %{take_sample(state) | blocked: {blocked_for - 1, then_add}}

        tick(new_state)
    end
  end

  defp do_instruction(state, [{"noop", _} | rest]) do
    %{state | instructions: rest}
  end

  defp do_instruction(state, [{"addx", number} | rest]) do
    %{state | blocked: {1, number}, instructions: rest}
  end

  defp take_sample(%{sample_at: sample_at, value: value, cycle: cycle, samples: samples} = state) do
    if (cycle + 1) in sample_at do
      %{state | samples: [value * cycle | samples]}
    else
      state
    end
    |> tock()
  end

  defp tock(%{cycle: cycle, value: value, sprites: sprites} = state) do
    %{state | cycle: cycle + 1, sprites: [sprite(value, cycle) | sprites]}
  end

  def sprite(value, cycle) do
    if rem(cycle, 40) in (value - 1)..(value + 1) do
      "#"
    else
      "."
    end
  end
end
