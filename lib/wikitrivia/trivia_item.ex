defmodule Wikitrivia.TriviaItem do
  use Ecto.Schema
  import Ecto.Changeset


  schema "trivia_items" do
    field :description, :string
    field :redacted_description, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(trivia_item, attrs) do
    trivia_item
    |> cast(attrs, [:title, :description, :redacted_description])
    |> validate_required([:title, :description, :redacted_description])
  end
end
