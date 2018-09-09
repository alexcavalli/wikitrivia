defmodule Wikitrivia.Question do
  use Ecto.Schema
  import Ecto.Changeset


  schema "questions" do
    field :answer_id, :id

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [])
    |> validate_required([])
  end
end
