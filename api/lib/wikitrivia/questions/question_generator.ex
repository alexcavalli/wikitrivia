defmodule Wikitrivia.Questions.QuestionGenerator do

  import Ecto.Query, only: [last: 1]

  alias Wikitrivia.Repo
  alias Wikitrivia.Questions.TriviaItem

  def generate_questions_for_trivia_items(trivia_items) do
    trivia_items
    |> generate_questions
  end

  defp generate_questions(trivia_items) do
    max_trivia_item_id = (TriviaItem |> last |> Repo.one).id

    trivia_items
    |> Enum.map(fn(answer) -> generate_question(answer, max_trivia_item_id) end)
  end

  defp generate_question(answer, max_trivia_item_id) do
    answer_choices = generate_answer_choices(answer.id, max_trivia_item_id)

    %{answer: answer, answer_choices: [answer | answer_choices]}
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
