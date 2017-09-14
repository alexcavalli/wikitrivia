defmodule Wikitrivia.Repo.Migrations.CreateTriviaItems do
  use Ecto.Migration

  def change do
    create table(:trivia_items) do
      add :title, :text, null: false
      add :description, :text, null: false
      add :redacted_description, :text, null: false

      timestamps()
    end

  end
end
