defmodule Wikitrivia.Repo.Migrations.CreateQuestion do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :answer_id, references(:trivia_items, on_delete: :nothing)

      timestamps
    end
    create index(:questions, [:answer_id])

  end
end
