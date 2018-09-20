defmodule Wikitrivia.Repo.Migrations.InitialMigration do
  use Ecto.Migration

  def change do
    create table(:answers) do
      add :answer, :text

      timestamps()
    end

    create table(:questions) do
      add :original, :text
      add :redacted, :text
      add :answer_id, references(:answers, on_delete: :nothing) # should this be :correct_answer_id

      timestamps()
    end

    create table(:question_answers, primary_key: false) do
      add :question_id, references(:questions, on_delete: :nothing), primary_key: true
      add :answer_id, references(:answers, on_delete: :nothing), primary_key: true
    end

    create index(:questions, [:answer_id])
  end
end
