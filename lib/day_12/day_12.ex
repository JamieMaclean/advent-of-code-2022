defmodule Day12 do
  def run(file) do
    {terrain, start} = get_terrain(file)

    visited = []
    frontier = [%{point: start, history: [start]}]

    %{history: h} = find_end_point(terrain, frontier, visited)
    IO.inspect(length(h), label: "part 1")

    # PART 2 - Need to change the climbing range but it works
    # Will return to clean it up at some point :)

    # terrain = put_in(terrain, [20, 77], 25)
    # frontier = [%{point: {20, 77}, history: [{20, 77}]}]
    # %{history: h} = find_end_point(terrain, frontier, visited, :part_2)

    # IO.inspect(length(h), label: "part 2")

    {length(h), 0}
  end

  defp find_end_point(terrain, [%{point: {y, x}, history: h} | rest], visited, part \\ :part_1) do
    new_points = get_accessible_adjacent_nodes(terrain, {y, x}, visited)

    points_only = Enum.map(new_points, fn {point, _} -> point end)

    case Enum.find(new_points, fn
           {_, "End"} when part == :part_1 -> true
           {_, 1} when part == :part_2 -> true
           _ -> false
         end) do
      {{end_y, end_x}, _} ->
        %{point: {end_y, end_x}, history: [{end_y, end_x} | h]}

      _ ->
        frontier =
          new_points
          |> Enum.map(fn {point, _} -> %{point: point, history: [point | h]} end)
          |> then(fn points -> Enum.concat(rest, points) end)

        find_end_point(terrain, frontier, visited ++ points_only, part)
    end
  end

  def get_terrain(filename) do
    parsed_terrain =
      File.read!(filename)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    coords =
      for y <- 0..(length(parsed_terrain) - 1) do
        {y, %{}}
      end
      |> Enum.into(%{})

    parse_terrain(coords, parsed_terrain, {0, 0})
  end

  def parse_terrain(terrain, parsed, coords, start \\ {0, 0})

  def parse_terrain(terrain, [], _, start) do
    {terrain, start}
  end

  def parse_terrain(terrain, [["E" | rest_x] | rest_y], {y, x}, start) do
    put_in(terrain, [y, x], "End")
    |> parse_terrain([rest_x | rest_y], {y, x + 1}, start)
  end

  def parse_terrain(terrain, [["S" | rest_x] | rest_y], {y, x}, _start) do
    put_in(terrain, [y, x], 0)
    |> parse_terrain([rest_x | rest_y], {y, x + 1}, {y, x})
  end

  def parse_terrain(terrain, [[] | rest_y], {y, _x}, start) do
    parse_terrain(terrain, rest_y, {y + 1, 0}, start)
  end

  def parse_terrain(terrain, [[<<next>> | rest_x] | rest_y], {y, x}, start) do
    put_in(terrain, [y, x], next - ?a)
    |> parse_terrain([rest_x | rest_y], {y, x + 1}, start)
  end

  defp get_accessible_adjacent_nodes(terrain, {y, x}, visited) do
    [
      {{y - 1, x}, terrain[y - 1][x]},
      {{y + 1, x}, terrain[y + 1][x]},
      {{y, x + 1}, terrain[y][x + 1]},
      {{y, x - 1}, terrain[y][x - 1]}
    ]
    |> Enum.filter(fn
      {_, nil} -> false
      {_, "End"} -> (terrain[y][x] - 25) in -1..2
      {_, height} -> (terrain[y][x] - height) in -1..2
    end)
    |> Enum.filter(fn
      {point, _} -> point not in visited
    end)
  end
end
