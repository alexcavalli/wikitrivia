defmodule Wikitrivia.Question do
  use Wikitrivia.Web, :model

  schema "questions" do
    belongs_to :answer, Wikitrivia.TriviaItem
    many_to_many :answer_choices, Wikitrivia.TriviaItem, join_through: "questions_trivia_items"

    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
