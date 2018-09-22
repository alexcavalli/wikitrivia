defmodule Wikitrivia.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :question, :string
    field :correct_answer, :string
    field :answer_choices, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:question, :correct_answer, :answer_choices])
  end
end
