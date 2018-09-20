defmodule Wikitrivia.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :original, :string
    field :redacted, :string

    belongs_to :answer, Wikitrivia.Answer
    many_to_many :answer_choices, Wikitrivia.Answer, join_through: "question_answers"

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:original, :redacted])
    |> put_assoc(:answer, attrs[:answer], required: true)
    |> put_assoc(:answer_choices, attrs[:answer_choices], required: true)
  end
end
