defmodule Wikitrivia.UserTest do
  use Wikitrivia.ModelCase

  alias Wikitrivia.User

  @valid_attrs %{email: "example@example.com", password: "password"}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid email - too short" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :email, ""))
    refute changeset.valid?
  end

  test "changeset with invalid email - format" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :email, "john"))
    refute changeset.valid?
  end

  test "registration_changeset with valid attributes" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    assert changeset.changes.password_hash
    assert changeset.valid?
  end

  test "registration_changeset with invalid password - too short" do
    changeset = User.registration_changeset(%User{}, Map.put(@valid_attrs, :password, "1234567"))
    refute changeset.valid?
  end
end
