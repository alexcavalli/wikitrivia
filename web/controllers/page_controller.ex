defmodule Wikitrivia.PageController do
  use Wikitrivia.Web, :controller

  alias Wikitrivia.Question

  def index(conn, _params) do
    render conn, "index.html"
  end

  def question(conn, _params) do
    question = random_question

    render conn, "question.json", data: question
  end

  defp random_question do
    # TODO: Fetching the table count will be slow if the table gets very large
    # Also this count could be cached
    # We're ignoring both of these issues for now
    Repo.one(
      from q in Question,
        where: q.id == ^random_question_id,
        preload: [:answer_choices, :answer]
    )
  end

  defp random_question_id do
    :rand.uniform(Repo.one(questions_count)) + Repo.one(questions_min)
  end

  defp questions_count do
    from Question, select: fragment("count(1)")
  end

  defp questions_min do
    from Question, select: fragment("min(id)")
  end
end
