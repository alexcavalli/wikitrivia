defmodule Wikitrivia.TriviaItemTest do
  use Wikitrivia.ModelCase

  alias Wikitrivia.TriviaItem

  @valid_attrs %{description: "some content", redacted_description: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = TriviaItem.changeset(%TriviaItem{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TriviaItem.changeset(%TriviaItem{}, @invalid_attrs)
    refute changeset.valid?
  end
end
