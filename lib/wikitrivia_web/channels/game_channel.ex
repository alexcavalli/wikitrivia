defmodule WikitriviaWeb.GameChannel do
  use Phoenix.Channel

  alias Wikitrivia.Game

  def join("game:" <> _game_id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("player_joined", %{"game_id" => game_id, "player_id" => player_id}, socket) do
    result = Game.add_player(game_id, player_id)

    send_update(socket, result)
  end

  def handle_in("player_update", %{ "game_id" => game_id, "player_id" => player_id, "player_name" => player_name }, socket) do
    result = Game.update_player_name(game_id, player_id, player_name)

    send_update(socket, result)
  end

  def handle_in("start", %{"game_id" => game_id}, socket) do
    Game.start(game_id, game_timer_callback(socket))
    {:noreply, socket}
  end

  def game_timer_callback(socket) do
    fn (state) ->
      broadcast! socket, "update", state
    end
  end

  defp send_update(socket, {:no_change, _state}), do: {:noreply, socket}
  defp send_update(socket, {:ok, state}) do
    broadcast! socket, "update", state # TODO: handle_out to clean up state a bit
    {:noreply, socket}
  end
end
