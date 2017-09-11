defmodule Wikitrivia.GameChannel do
  use Wikitrivia.Web, :channel

  def join("games:" <> game_id, %{"player_name" => player_name}, socket) do
    {:ok, game} = Wikitrivia.GameRegistry.lookup(game_id)

    response = Wikitrivia.Game.join(game, player_name)

    case response do
      :game_is_full ->
        {:error, %{reason: "game_is_full"}}
      _ ->
        {:ok, response, assign(socket, :game, game)}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (games:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
