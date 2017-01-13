defmodule Wikitrivia.TriviaItem do
  use Wikitrivia.Web, :model

  schema "trivia_items" do
    field :title, :string
    field :description, :string
    field :redacted_description, :string
    has_many :questions_as_answer, Wikitrivia.Question, foreign_key: "answer_id"
    many_to_many :questions_as_choice, Wikitrivia.Question, join_through: "questions_trivia_items"

    timestamps
  end

  @required_fields ~w(title description redacted_description)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields)
    |> validate_required([:title, :description, :redacted_description])
  end
end
