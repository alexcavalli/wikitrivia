defmodule WikitriviaWeb.GameChannel do
  use Phoenix.Channel

  alias Wikitrivia.Game

  def join("game:" <> _game_id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("player_joined", %{"game_id" => game_id, "player_id" => player_id}, socket) do
    player_id = if Game.has_player(game_id, player_id) do
      player_id
    else
      Game.add_player(game_id, player_id)
    end
    game_state = Game.get_game_state(game_id)

    broadcast! socket, "player_joined", %{ game_state: game_state, player_id: player_id }
    {:noreply, socket}
  end

  def handle_in("player_update", %{ "game_id" => game_id, "player_id" => player_id, "player_name" => player_name }, socket) do
    Game.update_player_name(game_id, player_id, player_name)

    game_state = Game.get_game_state(game_id)

    broadcast! socket, "player_update", %{ game_state: game_state, player_id: player_id }
    {:noreply, socket}
  end
end
