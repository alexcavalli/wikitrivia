defmodule Wikitrivia.QuestionsTest do
  use Wikitrivia.DataCase

  alias Wikitrivia.Questions

  describe "trivia_items" do
    alias Wikitrivia.Questions.TriviaItem

    @valid_attrs %{description: "some description", redacted_description: "some redacted_description", title: "some title"}
    @update_attrs %{description: "some updated description", redacted_description: "some updated redacted_description", title: "some updated title"}
    @invalid_attrs %{description: nil, redacted_description: nil, title: nil}

    def trivia_item_fixture(attrs \\ %{}) do
      {:ok, trivia_item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Questions.create_trivia_item()

      trivia_item
    end

    test "list_trivia_items/0 returns all trivia_items" do
      trivia_item = trivia_item_fixture()
      assert Questions.list_trivia_items() == [trivia_item]
    end

    test "get_trivia_item!/1 returns the trivia_item with given id" do
      trivia_item = trivia_item_fixture()
      assert Questions.get_trivia_item!(trivia_item.id) == trivia_item
    end

    test "create_trivia_item/1 with valid data creates a trivia_item" do
      assert {:ok, %TriviaItem{} = trivia_item} = Questions.create_trivia_item(@valid_attrs)
      assert trivia_item.description == "some description"
      assert trivia_item.redacted_description == "some redacted_description"
      assert trivia_item.title == "some title"
    end

    test "create_trivia_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Questions.create_trivia_item(@invalid_attrs)
    end

    test "update_trivia_item/2 with valid data updates the trivia_item" do
      trivia_item = trivia_item_fixture()
      assert {:ok, trivia_item} = Questions.update_trivia_item(trivia_item, @update_attrs)
      assert %TriviaItem{} = trivia_item
      assert trivia_item.description == "some updated description"
      assert trivia_item.redacted_description == "some updated redacted_description"
      assert trivia_item.title == "some updated title"
    end

    test "update_trivia_item/2 with invalid data returns error changeset" do
      trivia_item = trivia_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Questions.update_trivia_item(trivia_item, @invalid_attrs)
      assert trivia_item == Questions.get_trivia_item!(trivia_item.id)
    end

    test "delete_trivia_item/1 deletes the trivia_item" do
      trivia_item = trivia_item_fixture()
      assert {:ok, %TriviaItem{}} = Questions.delete_trivia_item(trivia_item)
      assert_raise Ecto.NoResultsError, fn -> Questions.get_trivia_item!(trivia_item.id) end
    end

    test "change_trivia_item/1 returns a trivia_item changeset" do
      trivia_item = trivia_item_fixture()
      assert %Ecto.Changeset{} = Questions.change_trivia_item(trivia_item)
    end
  end

  describe "questions" do
    alias Wikitrivia.Questions.Question

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def question_fixture(attrs \\ %{}) do
      {:ok, question} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Questions.create_question()

      question
    end

    test "list_questions/0 returns all questions" do
      question = question_fixture()
      assert Questions.list_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert Questions.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      assert {:ok, %Question{} = question} = Questions.create_question(@valid_attrs)
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Questions.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      assert {:ok, question} = Questions.update_question(question, @update_attrs)
      assert %Question{} = question
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = Questions.update_question(question, @invalid_attrs)
      assert question == Questions.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = Questions.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Questions.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = Questions.change_question(question)
    end
  end
end
