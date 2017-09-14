defmodule Wikitrivia.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :answer_id, references(:trivia_items, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:questions, [:answer_id])
  end
end
