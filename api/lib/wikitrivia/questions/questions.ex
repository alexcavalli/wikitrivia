defmodule Wikitrivia.Questions do
  @moduledoc """
  The Questions context.
  """

  import Ecto.Query, warn: false
  alias Wikitrivia.Repo

  alias Wikitrivia.Questions.{TriviaItem, Question}
  alias Wikitrivia.Questions.{TriviaItemGenerator, QuestionGenerator}

  @doc """
  Generates trivia_items by fetching and parsing articles from Wikipedia.
  """
  def generate_trivia_items(count) do
    TriviaItemGenerator.generate_trivia_items(count)
    |> Enum.each(&create_trivia_item/1)
  end

  @doc """
  Generates questions for trivia_items that are not yet answers to any
  questions.
  """
  def generate_questions_for_new_trivia_items do
    list_trivia_items_without_questions()
    |> QuestionGenerator.generate_questions_for_trivia_items
    |> Enum.each(&create_question/1)
  end

  @doc """
  Returns a list of trivia_items that are not yet answers to any questions.

  ## Examples

      iex> list_trivia_items_without_questions()
      [%TriviaItem{}, ...]

  """
  def list_trivia_items_without_questions do
    used_trivia_items = from q in Question,
      where: not is_nil(q.answer_id),
      select: [:id, :answer_id]

    unused_trivia_items = from t in TriviaItem,
      left_join: q in subquery(used_trivia_items), on: q.answer_id == t.id,
      where: is_nil(q.id)

    Repo.all(unused_trivia_items)
  end

  @doc """
  Returns the list of trivia_items.

  ## Examples

      iex> list_trivia_items()
      [%TriviaItem{}, ...]

  """
  def list_trivia_items do
    Repo.all(TriviaItem)
  end

  @doc """
  Gets a single trivia_item.

  Raises `Ecto.NoResultsError` if the Trivia item does not exist.

  ## Examples

      iex> get_trivia_item!(123)
      %TriviaItem{}

      iex> get_trivia_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_trivia_item!(id), do: Repo.get!(TriviaItem, id)

  @doc """
  Creates a trivia_item.

  ## Examples

      iex> create_trivia_item(%{field: value})
      {:ok, %TriviaItem{}}

      iex> create_trivia_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_trivia_item(attrs \\ %{}) do
    %TriviaItem{}
    |> TriviaItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a trivia_item.

  ## Examples

      iex> update_trivia_item(trivia_item, %{field: new_value})
      {:ok, %TriviaItem{}}

      iex> update_trivia_item(trivia_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_trivia_item(%TriviaItem{} = trivia_item, attrs) do
    trivia_item
    |> TriviaItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TriviaItem.

  ## Examples

      iex> delete_trivia_item(trivia_item)
      {:ok, %TriviaItem{}}

      iex> delete_trivia_item(trivia_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_trivia_item(%TriviaItem{} = trivia_item) do
    Repo.delete(trivia_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking trivia_item changes.

  ## Examples

      iex> change_trivia_item(trivia_item)
      %Ecto.Changeset{source: %TriviaItem{}}

  """
  def change_trivia_item(%TriviaItem{} = trivia_item) do
    TriviaItem.changeset(trivia_item, %{})
  end

  alias Wikitrivia.Questions.Question

  @doc """
  Returns the list of questions.

  ## Examples

      iex> list_questions()
      [%Question{}, ...]

  """
  def list_questions do
    Repo.all(Question)
  end

  @doc """
  Gets a single question.

  Raises `Ecto.NoResultsError` if the Question does not exist.

  ## Examples

      iex> get_question!(123)
      %Question{}

      iex> get_question!(456)
      ** (Ecto.NoResultsError)

  """
  def get_question!(id), do: Repo.get!(Question, id)

  @doc """
  Creates a question.

  ## Examples

      iex> create_question(%{field: value})
      {:ok, %Question{}}

      iex> create_question(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:answer, attrs[:answer])
    |> Ecto.Changeset.put_assoc(:answer_choices, attrs[:answer_choices])
    |> Repo.insert()
  end

  @doc """
  Updates a question.

  ## Examples

      iex> update_question(question, %{field: new_value})
      {:ok, %Question{}}

      iex> update_question(question, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question(%Question{} = question, attrs) do
    question
    |> Question.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Question.

  ## Examples

      iex> delete_question(question)
      {:ok, %Question{}}

      iex> delete_question(question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question(%Question{} = question) do
    Repo.delete(question)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question changes.

  ## Examples

      iex> change_question(question)
      %Ecto.Changeset{source: %Question{}}

  """
  def change_question(%Question{} = question) do
    Question.changeset(question, %{})
  end
end
