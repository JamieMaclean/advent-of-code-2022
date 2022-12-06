defmodule Mix.Tasks.Day2 do
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    File.read!("lib/mix/tasks/day_2/input.txt")
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> remove_last_item()
    |> create_games()
    |> Enum.map(&Day2.Game.score_game/1)
    |> cumulative_scores()
    |> IO.inspect()
  end

  defp remove_last_item(list_of_games) do
    Enum.reverse(list_of_games) 
    |> tl()
    |> Enum.reverse()
  end

  defp create_games(list_of_moves) do
    Enum.map(list_of_moves, &Day2.Game.new/1)
  end

  defp cumulative_scores([scores]), do: scores

  defp cumulative_scores([score_1 | [ score_2 | rest]]) do
    reduced_score = %{
      player_1: score_1.player_1 + score_2.player_1,
      player_2: score_1.player_2 + score_2.player_2
    }
    cumulative_scores([reduced_score | rest])
  end
end
