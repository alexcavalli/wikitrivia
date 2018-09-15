defmodule WikitriviaWeb.GameChannel do
  use Phoenix.Channel

  def join("game:" <> game_id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("player_joined", %{"player" => player}, socket) do
    broadcast! socket, "player_joined", %{player: player}
    {:noreply, socket}
  end
end
