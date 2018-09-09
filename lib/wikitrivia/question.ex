defmodule Wikitrivia.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    belongs_to :answer, Wikitrivia.TriviaItem
    many_to_many :answer_choices, Wikitrivia.TriviaItem, join_through: "questions_trivia_items"

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [])
    |> put_assoc(:answer, attrs[:answer], required: true)
    |> put_assoc(:answer_choices, attrs[:answer_choices], required: true)
  end
end
