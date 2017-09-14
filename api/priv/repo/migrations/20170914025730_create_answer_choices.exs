defmodule Wikitrivia.Repo.Migrations.CreateAnswerChoices do
  use Ecto.Migration

  def change do
    create table(:answer_choices) do
      add :question_id, references(:questions, on_delete: :delete_all), null: false
      add :answer_choice_id, references(:trivia_items, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:answer_choices, [:question_id])
    create index(:answer_choices, [:answer_choice_id])
    create unique_index(:answer_choices, [:question_id, :answer_choice_id])
  end
end
