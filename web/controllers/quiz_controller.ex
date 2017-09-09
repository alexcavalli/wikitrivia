defmodule Wikitrivia.QuizController do
  use Wikitrivia.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, _params) do
  end
end
