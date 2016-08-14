defmodule Wikitrivia.Repo.Migrations.CreateTriviaItem do
  use Ecto.Migration

  def change do
    create table(:trivia_items) do
      add :title, :text
      add :description, :text
      add :redacted_description, :text

      timestamps
    end

  end
end
