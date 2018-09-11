defmodule Mix.Tasks.Wikitrivia.FetchTriviaItems do
  use Mix.Task

  alias Wikitrivia.TriviaItem
  alias Wikitrivia.Repo

  @shortdoc "Fetches trivia from Wikipedia data and loads it into the DB 'mix wikitrivia.fetch_trivia_items <num>'"

  def run(args) do
    Mix.Task.run "app.start"
    Mix.shell.info "Fetching trivia from Wikipedia..."
    args
    |> List.first
    |> String.to_integer
    |> TriviaItemGenerator.generate_trivia_items
    |> load_trivia_items
  end

  defp load_trivia_items(trivia_items) do
    trivia_items
    |> Enum.map(fn item -> TriviaItem.changeset(%TriviaItem{}, item) end)
    |> Enum.each(&Repo.insert!/1)
  end
end
