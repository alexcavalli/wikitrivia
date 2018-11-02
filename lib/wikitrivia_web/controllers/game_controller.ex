defmodule WikitriviaWeb.GameController do
  use WikitriviaWeb, :controller

  alias Wikitrivia.Game

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", game_id: id)
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"create_game" => %{"game_name" => game_name}}) do
    game_id = Game.create_game(game_name)

    redirect conn, to: game_path(conn, :show, game_id)
  end
end
