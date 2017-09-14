defmodule Wikitrivia.Questions.Question do
  use Ecto.Schema
  import Ecto.Changeset
  alias Wikitrivia.Questions.{Question, TriviaItem, AnswerChoice}


  schema "questions" do
    belongs_to :answer, TriviaItem
    many_to_many :answer_choices, TriviaItem, join_through: AnswerChoice, join_keys: [question_id: :id, answer_choice_id: :id]

    timestamps()
  end

  @doc false
  def changeset(%Question{} = question, attrs) do
    question
    |> cast(attrs, [])
    |> validate_required([])
  end
end
