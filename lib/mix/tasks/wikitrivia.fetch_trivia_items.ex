defmodule Mix.Tasks.Wikitrivia.FetchTriviaItems do
  use Mix.Task

  @shortdoc "Fetches trivia from Wikipedia data and loads it into the DB 'mix wikitrivia.fetch_trivia_items <num>'"

  def run(args) do
    Mix.Task.run "app.start"
    Mix.shell.info "Fetching trivia from Wikipedia..."
    TriviaItemGenerator.generate_trivia_items(String.to_integer(List.first(args)))
  end
end
