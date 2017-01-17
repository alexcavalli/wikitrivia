defmodule Wikitrivia.QuizTest do
  use Wikitrivia.ModelCase

  alias Wikitrivia.{Quiz, Question}

  test "generates a new quiz with 5 questions" do
    # setup
    Enum.map(0..4, fn (_) -> { %Question{answer: nil} |> Repo.insert! } end)

    quiz = Quiz.generate(5)

    assert quiz[:id]
    assert quiz[:question_ids]
    assert length(quiz[:question_ids]) == 5
    assert length(Enum.uniq(quiz[:question_ids])) == 5
  end
end
