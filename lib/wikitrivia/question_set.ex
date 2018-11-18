defmodule Wikitrivia.QuestionSet do
  import Ecto.Query, only: [from: 2]

  alias Wikitrivia.Repo
  alias Wikitrivia.Question

  def generate(num_questions) do
    generate_random_valid_question_ids(num_questions)
    |> Enum.map(fn (question_id) -> Repo.get(Question, question_id) end)
    |> Enum.map(fn (question) -> Map.take(question, [:id, :question, :answer_choices, :correct_answer]) end)
  end

  defp generate_random_valid_question_ids(num_questions) do
    min_question_id = Repo.one(from Question, select: fragment("min(id)"))
    questions_count = Repo.one(from Question, select: fragment("count(1)"))
    generate_random_valid_question_ids(MapSet.new([]), num_questions, min_question_id, questions_count)
    |> MapSet.to_list
  end

  defp generate_random_valid_question_ids(question_ids, 0, _min_question_id, _questions_count), do: question_ids
  defp generate_random_valid_question_ids(question_ids, num_questions, min_question_id, questions_count) do
    new_id = random_question_id(min_question_id, questions_count)
    cond do
      MapSet.member?(question_ids, new_id) ->
        generate_random_valid_question_ids(question_ids, num_questions, min_question_id, questions_count)
      !Repo.get(Question, new_id) -> # Question does not exist
        generate_random_valid_question_ids(question_ids, num_questions, min_question_id, questions_count)
      true ->
        generate_random_valid_question_ids(MapSet.put(question_ids, new_id), num_questions - 1, min_question_id, questions_count)
    end
  end

  defp random_question_id(min_id, count) do
    :rand.uniform(count) + min_id - 1
  end
end
