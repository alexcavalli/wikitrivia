defmodule Wikitrivia.Repo.Migrations.CreateTriviaItems do
  use Ecto.Migration

  def change do
    create table(:trivia_items) do
      add :title, :string, null: false
      add :description, :string, null: false
      add :redacted_description, :string, null: false

      timestamps()
    end

  end
end
