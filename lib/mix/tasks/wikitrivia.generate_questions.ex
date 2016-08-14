defmodule Mix.Tasks.Wikitrivia.GenerateQuestions do
  use Mix.Task

  alias Wikitrivia.TriviaItem

  @shortdoc "Generates questions for trivia items missing questions"

  @moduledoc """
    This should not be run without a significant number of trivia items
    available to draw upon for answer choices. 1000 or so should be safe.
  """

  def run(_args) do
    Mix.Task.run "app.start"


    # grab trivia items that don't have associated questions
    # generate questions for those trivia items

  end

  # We can define other functions as needed here.
end
