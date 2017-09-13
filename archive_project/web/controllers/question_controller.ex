defmodule Wikitrivia.QuestionController do
  use Wikitrivia.Web, :controller

  alias Wikitrivia.Question

  def question(conn, _params) do
    question = random_question

    # TODO: Answer lists need to randomized. I think this is best handled
    # server-side (so that the order is the same for all players) but probably
    # should be different every time the question is fetched (so not DB). Could
    # go either way on the DB point though - maybe in fairness it should always
    # be presented in the same order.
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
