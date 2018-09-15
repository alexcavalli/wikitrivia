defmodule WikitriviaWeb.GameController do
  use WikitriviaWeb, :controller

  def show(conn, %{"game_id" => game_id}) do
    render(conn, "show.html", game_id: game_id, player: Ecto.UUID.generate)
  end
end
