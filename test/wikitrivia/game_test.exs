defmodule Wikitrivia.GameTest do
  alias Wikitrivia.Game

  use ExUnit.Case

  # Helper method to force-set the state for testing alterations. Duplicating a bunch of logic
  # from the Game code, not sure that's great. Alas.
  def game_with_state(state) do
    game_id = Ecto.UUID.generate
    name = {:via, Registry, {Registry.Games, game_id}}
    {:ok, _} = GenServer.start_link(Wikitrivia.Game, state, name: name)
    game_id
  end

  describe "add_player" do
    test "adds new players with the name 'anonymous' when the id is missing" do
      game_id = game_with_state(%{players: %{}, questions: [%{}, %{}, %{}, %{}]})
      player_id = "1a2b3c"

      {status, %{players: players}} = Game.add_player(game_id, player_id)

      assert status == :ok
      assert players == %{"1a2b3c" => %{name: "anonymous", score: 0, answers: [%{}, %{}, %{}, %{}]}}
    end

    test "does nothing when the player id is already in the game" do
      player_id = "1a2b3c"
      game_id = game_with_state(%{
        players: %{player_id => %{name: "John", score: 30, answers: [%{}, %{}, %{}, %{}]}},
        questions: [%{}, %{}, %{}, %{}]
      })

      {status, %{players: players}} = Game.add_player(game_id, player_id)

      assert status == :no_change
      assert players == %{"1a2b3c" => %{name: "John", score: 30, answers: [%{}, %{}, %{}, %{}]}}
    end
  end

  describe "update_player_name" do
    test "updates the player name to the provided name" do
      player_id = "1a2b3c"
      game_id = game_with_state(%{
        players: %{player_id => %{name: "John"}}
      })

      {status, %{players: players}} = Game.update_player_name(game_id, player_id, "Cool John")

      assert status == :ok
      assert players == %{"1a2b3c" => %{name: "Cool John"}}
    end

    test "returns a no_change response if the player name did not change" do
      player_id = "1a2b3c"
      game_id = game_with_state(%{
        players: %{player_id => %{name: "John"}}
      })

      {status, %{players: players}} = Game.update_player_name(game_id, player_id, "John")

      assert players == %{"1a2b3c" => %{name: "John"}}
      assert status == :no_change
    end

    test "returns a no_change response if the player id is not in the players list" do
      game_id = game_with_state(%{players: %{}})

      {status, %{players: players}} = Game.update_player_name(game_id, "1a2b3c", "John")

      assert status == :no_change
      assert players == %{}
    end
  end

  describe "answer_question" do
    test "answers the current question for the player if unanswered" do
      player_id = "1a2b3c"
      game_id = game_with_state(%{
        players: %{
          player_id => %{
            answers: [%{}]
          }
        },
        phase_start_time: Time.utc_now(),
        game_phase: :question,
        current_question: 0
      })

      {status, %{players: %{^player_id => %{answers: answers}}}} = Game.answer_question(game_id, player_id, "answer")

      assert status == :ok
      answer = Enum.at(answers, 0)
      assert answer[:answer] == "answer"
      assert answer[:time_left] >= 0
    end

    test "returns a no_change response if the player has already answered this question" do
      player_id = "1a2b3c"
      game_id = game_with_state(%{
        players: %{
          player_id => %{
            answers: [%{answer: "something", time_left: 2}]
          }
        },
        phase_start_time: Time.utc_now(),
        game_phase: :question,
        current_question: 0
      })

      {status, %{players: %{^player_id => %{answers: answers}}}} = Game.answer_question(game_id, player_id, "answer")

      assert status == :no_change
      assert Enum.at(answers, 0) == %{answer: "something", time_left: 2}
    end

    test "returns a no_change response if the game is not in a question phase" do
      player_id = "1a2b3c"
      game_id = game_with_state(%{
        players: %{
          player_id => %{
            answers: [%{}]
          }
        },
        game_phase: :question_results,
        current_question: 0
      })

      {status, %{players: %{^player_id => %{answers: answers}}}} = Game.answer_question(game_id, player_id, "answer")

      assert status == :no_change
      assert Enum.at(answers, 0) == %{}
    end
  end
end
