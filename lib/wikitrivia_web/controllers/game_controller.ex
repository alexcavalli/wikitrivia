defmodule WikitriviaWeb.GameController do
  use WikitriviaWeb, :controller

  alias Wikitrivia.Game

  def show(conn, %{"id" => game_id}) do
    render(conn, "show.html", game_id: game_id, player: Ecto.UUID.generate)
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, _params) do
    game_id = Game.create()
    redirect conn, to: game_path(conn, :show, game_id)
  end
end
