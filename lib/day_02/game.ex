defmodule Day2.Game do
  defstruct [:player_1, :player_2]

  alias __MODULE__

  alias Day2.{Rock, Paper, Scissors}

  @moves [%Rock{}, %Paper{}, %Scissors{}]

  @winning_response %{
    %Rock{} => %Paper{},
    %Paper{} => %Scissors{},
    %Scissors{} => %Rock{}
  }

  def new_with_move_hint([move_1, move_2]) do
    %Game{
      player_1: parse_move(move_1),
      player_2: get_move_from_hint(move_2)
    }
  end

  def new_with_result_hint([move_1, move_2]) do
    player_1 = parse_move(move_1)

    %Game{
      player_1: player_1,
      player_2: get_move_for_result(move_2, player_1)
    }
  end

  def score_game(%Game{} = game) do
    %{
      player_1: score_player(game.player_1, game.player_2),
      player_2: score_player(game.player_2, game.player_1)
    }
  end

  defp score_player(move, oponent) do
    result_score(move, oponent) + move.score
  end

  def result_score(move, oponent) when move == oponent, do: 3

  def result_score(move, oponent) do
    if Map.get(@winning_response, oponent) == move do
      6
    else
      0
    end
  end

  defp parse_move(player_move) do
    Enum.find(@moves, fn move -> move.move == player_move end)
  end

  defp get_move_from_hint("X"), do: %Rock{}
  defp get_move_from_hint("Y"), do: %Paper{}
  defp get_move_from_hint("Z"), do: %Scissors{}

  defp get_move_for_result("X", oponent) do
    {move, _} = Enum.find(@winning_response, fn {_looser, winner} -> winner == oponent end)
    move
  end

  defp get_move_for_result("Y", oponent), do: oponent

  defp get_move_for_result("Z", oponent) do
    {_, move} = Enum.find(@winning_response, fn {looser, _winner} -> looser == oponent end)
    move
  end
end
