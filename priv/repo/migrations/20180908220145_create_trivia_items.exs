defmodule Wikitrivia.Repo.Migrations.CreateTriviaItems do
  use Ecto.Migration

  def change do
    create table(:trivia_items) do
      add :title, :string
      add :description, :string
      add :redacted_description, :string

      timestamps()
    end

  end
end
