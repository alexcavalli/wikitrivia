defmodule Wikitrivia.GameTest do
  alias Wikitrivia.Game

  use ExUnit.Case

  # Helper method to force-set the state for testing alterations. Duplicating a bunch of logic
  # from the Game code, not sure that's great. Alas.
  def game_with_state(state) do
    game_id = Ecto.UUID.generate
    agent_name = {:via, Registry, {Registry.Games, game_id}}
    {:ok, _} = Agent.start_link(fn -> state end, name: agent_name)
    game_id
  end

  test "starts a game with default state" do
    game_id = Game.create("game_name", 20)
    initial_state = Game.get_state(game_id)
    assert initial_state == %{
      name: "game_name",
      player_names: %{},
      scores: %{},
      num_questions: 20,
      current_question: 0,
      questions: [],
      game_phase: :lobby
    }
  end

  describe "add_player" do
    test "adds new players with the name 'anonymous' when the id is missing" do
      game_id = game_with_state(%{players: %{}, scores: %{}})
      player_id = "1a2b3c"

      {status, %{players: players, scores: scores}} = Game.add_player(game_id, player_id)

      assert status == :ok
      assert players == %{"1a2b3c" => "anonymous"}
      assert scores == %{"1a2b3c" => 0}
    end

    test "does nothing when the player id is already in the game" do
      player_id = "1a2b3c"
      game_id = game_with_state(%{
        players: %{player_id => "John"},
        scores: %{player_id => 30}
      })

      {status, %{players: players, scores: scores}} = Game.add_player(game_id, player_id)

      assert status == :no_change
      assert players == %{"1a2b3c" => "John"}
      assert scores == %{"1a2b3c" => 30}
    end
  end

  describe "update_player_name" do
    test "updates the player name to the provided name" do
      player_id = "1a2b3c"
      game_id = game_with_state(%{
        players: %{player_id => "John"}
      })

      {status, %{players: players}} = Game.update_player_name(game_id, player_id, "Cool John")

      assert status == :ok
      assert players == %{"1a2b3c" => "Cool John"}
    end

    test "returns a no_change response if the player name did not change" do
      player_id = "1a2b3c"
      game_id = game_with_state(%{
        players: %{player_id => "John"}
      })

      {status, %{players: players}} = Game.update_player_name(game_id, player_id, "John")

      assert players == %{"1a2b3c" => "John"}
      assert status == :no_change
    end

    test "returns a no_change response if the player id is not in the players list" do
      game_id = game_with_state(%{players: %{}})

      {status, %{players: players}} = Game.update_player_name(game_id, "1a2b3c", "John")

      assert status == :no_change
      assert players == %{}
    end
  end
end
