defmodule Day10 do
  alias Day10.Circuit

  def run(file) do
    instructions = get_instructions(file)

    {:ok, circuit} = Circuit.start_link([instructions, [20, 60, 100, 140, 180, 220]])

    {part_1, part_2} =
      give_instructions(circuit)
      |> Circuit.get_samples()

    Enum.chunk_every(part_2, 40)
    |> Enum.each(fn a ->
      IO.puts(a)
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

  defp give_instructions(circuit) do
    case Circuit.tic(circuit) do
      :ok -> give_instructions(circuit)
      :blocked -> give_instructions(circuit)
      :finished -> circuit
    end
  end
end
