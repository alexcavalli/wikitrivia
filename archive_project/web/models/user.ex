defmodule Wikitrivia.User do
  use Wikitrivia.Web, :model

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    timestamps
  end

  @permitted_fields ~w(answer answer_choices)
  @required_fields ~w()
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:email])
    |> validate_required(:email)
    |> validate_length(:email, min: 1, max: 128)
    |> validate_format(:email, ~r/@/)
  end

  def registration_changeset(model, params \\ %{}) do
    model
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_required(:password)
    |> validate_length(:password, min: 8)
    |> put_password_hash
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        changeset
    end
  end
end
