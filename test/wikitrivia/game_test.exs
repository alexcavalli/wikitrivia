defmodule Wikitrivia.GameTest do
  alias Wikitrivia.Game

  use ExUnit.Case

  test "starts a game with default state" do
    game_id = Game.create_game()
    initial_state = Game.get_game_state(game_id)
    assert initial_state == %{
      players: MapSet.new(),
      scores: %{}
    }
  end

  test "adds new players" do
    game_id = Game.create_game()
    Game.add_player(game_id, "Alex")
    %{players: players, scores: scores} = Game.get_game_state(game_id)
    assert players == MapSet.new() |> MapSet.put("Alex")
    assert scores == %{"Alex" => 0}
    Game.add_player(game_id, "Dennis")
    %{players: players, scores: scores} = Game.get_game_state(game_id)
    assert players == MapSet.new() |> MapSet.put("Alex") |> MapSet.put("Dennis")
    assert scores == %{"Alex" => 0, "Dennis" => 0}
  end

  test "awards points" do
    game_id = Game.create_game()
    Game.add_player(game_id, "Alex")
    Game.add_player(game_id, "Dennis")
    Game.award_points(game_id, "Dennis", 100)
    %{scores: scores} = Game.get_game_state(game_id)
    assert scores == %{"Alex" => 0, "Dennis" => 100}
    Game.award_points(game_id, "Dennis", 250)
    %{scores: scores} = Game.get_game_state(game_id)
    assert scores == %{"Alex" => 0, "Dennis" => 350}
  end
end
