defmodule WikitriviaWeb.GameChannel do
  use Phoenix.Channel

  alias Wikitrivia.Game

  def join("game:" <> _game_id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("player_joined", %{"game_id" => game_id, "player_id" => player_id}, socket) do
    if !Game.has_player(game_id, player_id) do
      Game.add_player(game_id, player_id)
    end

    game_state = Game.get_game_state(game_id)

    broadcast! socket, "player_joined", game_state
    {:noreply, socket}
  end

  def handle_in("player_update", %{ "game_id" => game_id, "player_id" => player_id, "player_name" => player_name }, socket) do
    Game.update_player_name(game_id, player_id, player_name)

    game_state = Game.get_game_state(game_id)

    broadcast! socket, "player_update", game_state
    {:noreply, socket}
  end

  def handle_in("go", %{"game_id" => game_id}, socket) do
    Game.start(game_id, game_timer_callback(game_id, socket))
    {:noreply, socket}
  end

  def game_timer_callback(game_id, socket) do
    fn ->
      game_state = Game.get_game_state(game_id)
      {message_type, message_data} = message_for_timer_state(game_state)
      broadcast! socket, message_type, message_data
    end
  end

  defp message_for_timer_state(%{timer_state: :question, timer_data: question_data, num_questions_left: num_questions_left}) do
    {"start_question", %{question_number: 6 - num_questions_left, question: question_data}} # This question number calculation is dumb
  end

  defp message_for_timer_state(%{timer_state: :question_results, scores: scores}) do
    {"stop_question", scores}
  end

  defp message_for_timer_state(%{timer_state: :done, scores: scores}) do
    {"stop_game", scores}
  end
end
