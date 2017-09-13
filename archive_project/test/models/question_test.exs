defmodule Wikitrivia.QuestionTest do
  use Wikitrivia.ModelCase

  alias Wikitrivia.{Question, TriviaItem}

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    answer = %TriviaItem{title: "t", description: "d", redacted_description: "rd"}
    answer_choices = [%TriviaItem{title: "t", description: "d", redacted_description: "rd"}]

    changeset = Question.changeset(%Question{}, %{answer: answer, answer_choices: answer_choices})
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Question.changeset(%Question{}, @invalid_attrs)
    refute changeset.valid?
  end
end
