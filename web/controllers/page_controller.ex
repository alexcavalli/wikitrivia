defmodule Wikitrivia.PageController do
  use Wikitrivia.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def question(conn, _params) do
    render conn, "question.html"
  end
end
