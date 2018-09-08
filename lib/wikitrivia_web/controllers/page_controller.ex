defmodule WikitriviaWeb.PageController do
  use WikitriviaWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
