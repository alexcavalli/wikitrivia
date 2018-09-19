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
end
