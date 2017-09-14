defmodule Wikitrivia.Questions.TriviaItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Wikitrivia.Questions.{TriviaItem, Question, AnswerChoice}


  schema "trivia_items" do
    field :description, :string
    field :redacted_description, :string
    field :title, :string
    has_many :questions_as_answer, Question, foreign_key: :answer_id
    many_to_many :questions_as_choice, Question, join_through: AnswerChoice, join_keys: [answer_choice_id: :id, question_id: :id]

    timestamps()
  end

  @doc false
  def changeset(%TriviaItem{} = trivia_item, attrs) do
    trivia_item
    |> cast(attrs, [:title, :description, :redacted_description])
    |> validate_required([:title, :description, :redacted_description])
  end
end
