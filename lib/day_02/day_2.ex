defmodule Day2 do
  alias Day2.Game

  def run(file) do
    part_1 =
      parse_file(file)
      |> play_with_move_hint()

    part_2 =
      parse_file(file)
      |> play_with_result_hint()

    {part_1.player_2, part_2.player_2}
  end

  def parse_file(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
  end

  def play_with_move_hint(games) do
    Enum.map(games, fn moves ->
      String.split(moves, " ", trim: true)
      |> Game.new_with_move_hint()
      |> Game.score_game()
    end)
    |> cumulative_scores()
    |> IO.inspect(label: "With result hint:")
  end

  def play_with_result_hint(games) do
    Enum.map(games, fn moves ->
      String.split(moves, " ", trim: true)
      |> Game.new_with_result_hint()
      |> Game.score_game()
    end)
    |> cumulative_scores()
    |> IO.inspect(label: "With result hint:")
  end

  defp cumulative_scores([scores]), do: scores

  defp cumulative_scores([score_1 | [score_2 | rest]]) do
    reduced_score = %{
      player_2: score_1.player_2 + score_2.player_2
    }

    cumulative_scores([reduced_score | rest])
  end
end
