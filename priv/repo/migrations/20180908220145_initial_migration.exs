defmodule Wikitrivia.Repo.Migrations.InitialMigration do
  use Ecto.Migration

  def change do
    create table(:trivia_items) do
      add :title, :string
      add :description, :string, size: 1024
      add :redacted_description, :string

      timestamps()
    end

    create table(:questions) do
      add :answer_id, references(:trivia_items, on_delete: :nothing)

      timestamps()
    end

    create table(:questions_trivia_items, primary_key: false) do
      add :question_id, references(:questions, on_delete: :nothing), primary_key: true
      add :trivia_item_id, references(:trivia_items, on_delete: :nothing), primary_key: true
    end

    create index(:questions, [:answer_id])
  end
end
