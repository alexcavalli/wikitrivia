defmodule Wikitrivia.PageController do
  use Wikitrivia.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def question(conn, _params) do
    question = QuestionGenerator.generate_question

    render conn, "question.json", data: question
  end
end
