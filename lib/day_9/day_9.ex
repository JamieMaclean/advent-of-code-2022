defmodule Day9 do
  alias Day9.Knot

  def run(file) do
    moves = get_moves(file)

    part_1 =
      new_rope(2)
      |> move(moves)
      |> Knot.get_tail_history()
      |> Enum.uniq()
      |> Enum.count()
      |> IO.inspect(label: "Part 1 unique spots:")

    part_2 =
      new_rope(10)
      |> move(moves)
      |> Knot.get_tail_history()
      |> Enum.uniq()
      |> Enum.count()
      |> IO.inspect(label: "Part 2 unique spots:")

    {part_1, part_2}
  end

  def move(head, []) do
    head
  end

  def move(head, [direction | remaining_moves]) do
    Knot.move(head, direction)

    move(head, remaining_moves)
  end

  def new_rope(length) do
    for _ <- 1..length, reduce: nil do
      tail -> Knot.start_link(tail)
    end
  end

  def get_moves(filename) do
    moves =
      File.read!(filename)
      |> String.split("\n", trim: true)

    for <<direction::binary-size(1), 32, number::binary>> <- moves,
        _ <- 1..String.to_integer(number) do
      direction
    end
  end
end
