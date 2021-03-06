defmodule Wikitrivia.Repo.Migrations.InitialMigration do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :question, :text
      add :correct_answer, :text
      add :answer_choices, {:array, :text}

      timestamps()
    end
  end
end
