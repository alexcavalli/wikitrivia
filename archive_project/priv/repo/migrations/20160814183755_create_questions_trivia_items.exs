defmodule Wikitrivia.Repo.Migrations.CreateQuestionsTriviaItems do
  use Ecto.Migration

  def change do
    create table(:questions_trivia_items, primary_key: false) do
      add :question_id, references(:questions, on_delete: :nothing), primary_key: true
      add :trivia_item_id, references(:trivia_items, on_delete: :nothing), primary_key: true
    end
  end
end
