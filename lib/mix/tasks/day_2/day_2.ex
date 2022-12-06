defmodule Mix.Tasks.Day2 do
  use Mix.Task

  alias Day2.Game

  @impl Mix.Task
  def run(_) do
    File.read!("lib/mix/tasks/day_2/input.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn moves -> 
      String.split(moves, " ", trim: true)
      |> Game.new()
      |> Game.score_game()
    end)
    |> cumulative_scores()
    |> IO.inspect()
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
