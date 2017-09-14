defmodule Wikitrivia.Questions.AnswerChoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Wikitrivia.Questions.AnswerChoice


  schema "answer_choices" do
    field :question_id, :id
    field :answer_choice_id, :id

    timestamps()
  end

  @doc false
  def changeset(%AnswerChoice{} = answer_choice, attrs) do
    answer_choice
    |> cast(attrs, [])
    |> validate_required([])
  end
end
