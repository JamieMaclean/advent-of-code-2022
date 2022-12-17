defmodule Day15 do
  def run(file) do
    sensors = get_signals(file)

    row = 2_000_000
    # row = 10
    signals_on_row = signals_on_row(sensors, row)

    part_1 =
      signals_on_row
      |> Enum.map(&Enum.to_list/1)
      |> List.flatten()
      |> Enum.count()
      |> IO.inspect(label: "Part 1")

    part_2 =
      for row <- 0..4_000_000, reduce: nil do
        nil ->
          case signals_on_row(sensors, row) do
            [_range] -> nil
            [_..max_1, _] -> (max_1 + 1) * 4_000_000 + row
          end

        number ->
          number
      end

    {part_1, part_2}
    |> IO.inspect()
  end

  def get_signals(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(fn string ->
      [
        _,
        _,
        <<"x=", sensor_x::binary>>,
        <<"y=", sensor_y::binary>>,
        _,
        _,
        _,
        _,
        <<"x=", beacon_x::binary>>,
        <<"y=", beacon_y::binary>>
      ] =
        String.replace(string, ",", "")
        |> String.replace(":", "")
        |> String.split(" ", trim: true)

      {{String.to_integer(sensor_x), String.to_integer(sensor_y)},
       {String.to_integer(beacon_x), String.to_integer(beacon_y)}}
    end)
  end

  def signals_on_row(signals, row) do
    signals
    |> Enum.map(fn {sensor, beacon} ->
      d = get_manhatan_distance(sensor, beacon)
      get_signal_on_row({sensor, beacon, d}, row)
    end)
    |> List.flatten()
    |> Enum.sort()
    |> then(&accumulate_ranges([], &1))
    |> Enum.reverse()
  end

  def accumulate_ranges(acc, []) do
    acc
  end

  def accumulate_ranges([], [low..high | rest]) do
    accumulate_ranges([low..high], rest)
  end

  def accumulate_ranges([low..high | rest_1] = acc, [low_2..high_2 | rest_2]) do
    if low_2 <= high do
      if high_2 > high do
        accumulate_ranges([low..high_2 | rest_1], rest_2)
      else
        accumulate_ranges([low..high | rest_1], rest_2)
      end
    else
      accumulate_ranges([low_2..high_2 | acc], rest_2)
    end
  end

  def get_manhatan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def get_signal_on_row({{signal_x, signal_y}, _, distance}, row) do
    case abs(signal_y - row) do
      diff when diff < distance ->
        (signal_x - abs(diff - distance))..(signal_x + abs(diff - distance))

      _ ->
        []
    end
  end
end
