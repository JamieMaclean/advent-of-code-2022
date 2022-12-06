defmodule Day2.Game do
  defstruct [:player_1, :player_2]

  alias __MODULE__

  alias Day2.{Rock, Paper, Scissors}

  @moves [%Rock{}, %Paper{}, %Scissors{}]

  @winning_response %{
    %Rock{} => %Paper{},
    %Paper{} => %Scissors{},
    %Scissors{} => %Rock{},
  }

  def new([move_1, move_2]) do
    player_1 = parse_move(move_1)

    %Game{
      player_1: player_1,
      player_2: parse_response(move_2, player_1)
    }
  end

  def score_game(%Game{} = game) do
    %{
      player_1: score_player(game.player_1, game.player_2),
      player_2: score_player(game.player_2, game.player_1)
    }
  end

  defp score_player(move, oponoent) do
    result_score(move, oponoent) + move.score
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

  defp parse_response("X", oponent) do
    {move, _} = Enum.find(@winning_response, fn {_looser, winner} ->  winner == oponent end)
    move
  end

  defp parse_response("Y", oponent), do: oponent

  defp parse_response("Z", oponent) do
    {_, move} = Enum.find(@winning_response, fn {looser, _winner} ->  looser == oponent end)
    move
  end

end
