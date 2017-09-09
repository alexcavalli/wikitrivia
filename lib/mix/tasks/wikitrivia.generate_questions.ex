defmodule Mix.Tasks.Wikitrivia.GenerateQuestions do
  use Mix.Task

  import Ecto.Query, only: [from: 2, last: 1]

  alias Wikitrivia.Repo
  alias Wikitrivia.TriviaItem
  alias Wikitrivia.Question

  @shortdoc "Generates questions for trivia items missing questions"

  @moduledoc """
    This should not be run without a significant number of trivia items
    available to draw upon for answer choices. 1000 or so should be safe.
  """

  def run(_args) do
    Mix.Task.run "app.start"

    trivia_items_without_questions
    |> generate_questions
  end

  defp trivia_items_without_questions do
    used_trivia_items = from q in Question,
      where: not is_nil(q.answer_id),
      select: [:id, :answer_id]

    unused_trivia_items = from t in TriviaItem,
      left_join: q in subquery(used_trivia_items), on: q.answer_id == t.id,
      where: is_nil(q.id)

    Repo.all(unused_trivia_items)
  end

  defp generate_questions(trivia_items) do
    max_trivia_item_id = (TriviaItem |> last |> Repo.one).id

    trivia_items
    |> Enum.each(fn(answer) -> generate_question(answer, max_trivia_item_id) end)
  end

  defp generate_question(answer, max_trivia_item_id) do
    answer_choices = generate_answer_choices(answer.id, max_trivia_item_id)

    Question.changeset(%Question{}, %{answer: answer, answer_choices: [answer | answer_choices]})
    |> Repo.insert
  end

  defp generate_answer_choices(answer_id, max_trivia_item_id) do
    generate_random_integers(10, max_trivia_item_id)
    |> Enum.reject(fn(id) -> answer_id == id end)
    |> Enum.uniq
    |> Enum.map(fn(id) -> Repo.get!(TriviaItem, id) end)
    |> Enum.take(4)
  end

  defp generate_random_integers(number_to_generate, max), do: generate_random_integers([], number_to_generate, max)
  defp generate_random_integers(random_integers, 0, _), do: random_integers
  defp generate_random_integers(random_integers, number_to_generate, max) do
    generate_random_integers([:rand.uniform(max) | random_integers], number_to_generate - 1, max)
  end

end
