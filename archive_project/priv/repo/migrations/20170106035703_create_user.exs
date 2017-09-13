defmodule Wikitrivia.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :text, null: false
      add :password_hash, :text, null: false

      timestamps
    end
    create unique_index(:users, [:email])
  end
end
