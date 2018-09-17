defmodule Wikitrivia.GameTest do
  alias Wikitrivia.Game

  use ExUnit.Case

  test "starts a game with default state" do
    game_id = Game.create_game()
    initial_state = Game.get_game_state(game_id)
    assert initial_state == %{
      players: %{},
      scores: %{}
    }
  end

  test "adds new players" do
    game_id = Game.create_game()
    Game.add_player(game_id, 1, "Alex")
    %{players: players, scores: scores} = Game.get_game_state(game_id)
    assert players == %{1 => "Alex"}
    assert scores == %{1 => 0}
    Game.add_player(game_id, 2, "Dennis")
    %{players: players, scores: scores} = Game.get_game_state(game_id)
    assert players == %{1 => "Alex", 2 => "Dennis"}
    assert scores == %{1 => 0, 2 => 0}
  end

  test "awards points" do
    game_id = Game.create_game()
    Game.add_player(game_id, 1, "Alex")
    Game.add_player(game_id, 2, "Dennis")
    Game.award_points(game_id, 2, 100)
    %{scores: scores} = Game.get_game_state(game_id)
    assert scores == %{1 => 0, 2 => 100}
    Game.award_points(game_id, 2, 250)
    %{scores: scores} = Game.get_game_state(game_id)
    assert scores == %{1 => 0, 2 => 350}
  end
end
