defmodule Mix.Tasks.Wikitrivia.FetchTriviaItems do
  use Mix.Task

  alias Wikitrivia.Repo
  alias Wikitrivia.TriviaItem

  @shortdoc "Fetches trivia from Wikipedia data and loads it into the DB"

  @moduledoc """
    This is where we would put any long form documentation or doctests.
  """

  def run(_args) do
    Mix.Task.run "app.start"

    TriviaItemGenerator.generate_trivia_items(10)
    |> load_trivia_items
  end

  defp load_trivia_items(trivia_items) do
    trivia_items
    |> Enum.map(fn(item) -> TriviaItem.changeset(%TriviaItem{}, item) end)
    |> Enum.each(fn(changeset) -> Repo.insert(changeset) end)
  end
end
