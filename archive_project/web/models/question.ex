defmodule Wikitrivia.Question do
  use Wikitrivia.Web, :model

  schema "questions" do
    belongs_to :answer, Wikitrivia.TriviaItem
    many_to_many :answer_choices, Wikitrivia.TriviaItem, join_through: "questions_trivia_items"

    timestamps
  end

  @permitted_fields ~w(answer answer_choices)
  @required_fields ~w()
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [])
    |> put_assoc(:answer, params[:answer], required: true)
    |> put_assoc(:answer_choices, params[:answer_choices], required: true)
  end
end
