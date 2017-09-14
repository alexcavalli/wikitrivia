defmodule Mix.Tasks.Wikitrivia.FetchTriviaItems do
  use Mix.Task

  alias Wikitrivia.Questions

  @shortdoc "Fetches trivia from Wikipedia data and loads it into the DB"

  @moduledoc """
    This is where we would put any long form documentation or doctests.
  """

  def run(_args) do
    Mix.Task.run "app.start"

    Questions.generate_trivia_items(100)
  end
end
