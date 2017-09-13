defmodule Wikitrivia.SessionTest do
  use Wikitrivia.ModelCase

  alias Wikitrivia.Session

  @valid_attrs %{user_id: "1"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Session.changeset(%Session{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Session.changeset(%Session{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "create changeset with valid attributes" do
    changeset = Session.create_changeset(%Session{}, @valid_attrs)
    assert changeset.changes.token
    assert changeset.valid?
  end

  test "create changeset with invalid attributes" do
    changeset = Session.create_changeset(%Session{}, @invalid_attrs)
    refute changeset.valid?
  end
end
