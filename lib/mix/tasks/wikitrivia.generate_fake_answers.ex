defmodule Mix.Tasks.Wikitrivia.GenerateFakeAnswers do
  use Mix.Task

  import Ecto.Query, only: [from: 2, last: 1]

  alias Wikitrivia.Repo
  alias Wikitrivia.Answer
  alias Wikitrivia.Question

  @shortdoc "Generates fake question answers for questions missing fake answers"

  @moduledoc """
    This should not be run without a significant number of questions
    available to draw upon for answer choices. 1000 or so should be safe.
  """

  def run(_args) do
    Mix.Task.run "app.start"

    questions_without_fake_answers()
    |> generate_fake_answers
  end

  defp questions_without_fake_answers do
    questions = from q in Question,
      left_join: ac in assoc(q, :answer_choices),
      where: is_nil(ac.id),
      preload: [:answer, :answer_choices]

    Repo.all(questions)
  end

  defp generate_fake_answers(questions) do
    max_answer_id = (Answer |> last |> Repo.one).id

    questions
    |> Enum.each(fn(question) -> generate_fake_answer(question, max_answer_id) end)
  end

  defp generate_fake_answer(question, max_answer_id) do
    answer_choices = generate_answer_choices(question.answer.id, max_answer_id)

    Question.changeset(question, %{answer: question.answer, answer_choices: [question.answer | answer_choices]})
    |> Repo.update!
  end

  defp generate_answer_choices(answer_id, max_answer_id) do
    generate_random_integers(10, max_answer_id)
    |> Enum.reject(fn(id) -> answer_id == id end)
    |> Enum.uniq
    |> Enum.take(4)
    |> Enum.map(fn(id) -> Repo.get!(Answer, id) end)
  end

  defp generate_random_integers(number_to_generate, max), do: generate_random_integers([], number_to_generate, max)
  defp generate_random_integers(random_integers, 0, _), do: random_integers
  defp generate_random_integers(random_integers, number_to_generate, max) do
    generate_random_integers([:rand.uniform(max) | random_integers], number_to_generate - 1, max)
  end
end
