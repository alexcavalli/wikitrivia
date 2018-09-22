defmodule WikitriviaWeb.GameChannel do
  use Phoenix.Channel

  alias Wikitrivia.Game

  def join("game:" <> game_id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("player_joined", %{"game_id" => game_id, "player" => player}, socket) do
    Game.add_player(game_id, player)
    %{players: players} = Game.get_game_state(game_id)
    broadcast! socket, "player_joined", %{player: player, players: players}
    {:noreply, socket}
  end

  def handle_in("go", %{"game_id" => game_id}, socket) do
    Game.start(game_id, socket)
    {:noreply, socket}
  end

  # This is probably not the right way to do this as it introduces a circular dependency between
  # Game and GameChannel. I think probably the better way to do it would be to hand off a callback
  # function to the Game to trigger on various state changes.
  def broadcast_message(socket, message_type, message) do
    broadcast! socket, message_type, message
  end
end
