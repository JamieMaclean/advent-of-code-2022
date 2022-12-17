defmodule Day14 do
  def run(file) do
    rocks = get_cave(file)
    [_, {min_y, max_y}] = boundry = get_boundry(rocks)
    sand = [{500, 0}]

    part_1 =
      drop_sand(sand, rocks, boundry)
      |> Enum.count()
      |> Kernel.-(1)
      |> IO.inspect(label: "Part 1")

    part_2_rocks = [{:infinity, max_y + 2} | rocks]
    part_2_boundry = [{:infinity, :infinity}, {min_y, max_y + 2}]

    IO.inspect("=== PART 2 ===")

    part_2 =
      drop_sand(sand, part_2_rocks, part_2_boundry)
      |> Enum.count()
      |> IO.inspect(label: "Part 2")

    {part_1, part_2}
  end

  def get_cave(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(fn string ->
      String.split(string, " -> ", trim: true)
      |> Enum.map(fn string ->
        String.split(string, ",", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
    end)
    |> parse_structures
  end

  def drop_sand(
        [current | _rest] = sand,
        rocks,
        [{:infinity, :infinity}, {_min_y, max_y}] = boundry
      ) do
    [{_x, y} = new_position | _] = new_sand = increment_sand(sand, rocks, max_y)

    cond do
      new_position == {500, 0} -> new_sand
      new_position == current -> drop_sand([{500, 0} | new_sand], rocks, boundry)
      y > max_y -> new_sand
      true -> drop_sand(new_sand, rocks, boundry)
    end
  end

  def drop_sand([current | _rest] = sand, rocks, [{min_x, max_x}, {_min_y, max_y}] = boundry) do
    [{x, y} = new_position | _] = new_sand = increment_sand(sand, rocks)

    cond do
      new_position == {500, 0} -> new_sand
      new_position == current -> drop_sand([{500, 0} | new_sand], rocks, boundry)
      x < min_x or x > max_x -> new_sand
      y > max_y -> new_sand
      true -> drop_sand(new_sand, rocks, boundry)
    end
  end

  def increment_sand([{x, y} | sand], rocks) do
    new_position =
      cond do
        {x, y + 1} not in rocks and {x, y + 1} not in sand -> {x, y + 1}
        {x - 1, y + 1} not in rocks and {x - 1, y + 1} not in sand -> {x - 1, y + 1}
        {x + 1, y + 1} not in rocks and {x + 1, y + 1} not in sand -> {x + 1, y + 1}
        true -> {x, y}
      end

    [new_position | sand]
  end

  def increment_sand([{x, y} | sand], rocks, max_y) do
    new_position =
      cond do
        y + 1 == max_y -> {x, y}
        {x, y + 1} not in rocks and {x, y + 1} not in sand -> {x, y + 1}
        {x - 1, y + 1} not in rocks and {x - 1, y + 1} not in sand -> {x - 1, y + 1}
        {x + 1, y + 1} not in rocks and {x + 1, y + 1} not in sand -> {x + 1, y + 1}
        true -> {x, y}
      end

    [new_position | sand]
  end

  def get_boundry(blockages) do
    x = Enum.map(blockages, fn {x, _y} -> x end)
    y = Enum.map(blockages, fn {_x, y} -> y end)

    [{Enum.min(x), Enum.max(x)}, {Enum.min(y), Enum.max(y)}]
  end

  def parse_structures(structures) do
    Enum.map(structures, fn structure ->
      get_all_points(structure)
      |> Enum.uniq()
    end)
    |> List.flatten()
  end

  def get_all_points([{x, y}]) do
    [{x, y}]
  end

  def get_all_points([point_1 | [point_2 | rest]]) do
    get_points_between(point_1, point_2) ++ get_all_points([point_2 | rest])
  end

  def get_points_between({x1, y1}, {x2, y2}) do
    if x1 == x2 do
      Enum.map(y1..y2, fn y -> {x1, y} end)
    else
      Enum.map(x1..x2, fn x -> {x, y1} end)
    end
  end
end
