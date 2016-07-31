defmodule Wikitrivia.PageController do
  use Wikitrivia.Web, :controller

  def index(conn, _params) do
    questions = QuestionFetcher.fetch(5)

    render conn, "index.html", questions: questions
  end
end
