defmodule Mix.Tasks.Wikitrivia.FetchQuestions do
  use Mix.Task

  alias Wikitrivia.Question
  alias Wikitrivia.Repo

  @shortdoc "Fetches trivia questions from Wikipedia data and loads it into the DB 'mix wikitrivia.fetch_questions <num>'"

  def run(args) do
    Mix.Task.run "app.start"
    Mix.shell.info "Fetching trivia questions from Wikipedia..."
    args
    |> List.first
    |> String.to_integer
    |> QuestionGenerator.generate_questions
    |> load_trivia_items
  end

  defp load_trivia_items(trivia_items) do
    trivia_items
    |> Enum.map(fn item -> Question.changeset(%Question{}, %{original: item.description, redacted: item.redacted_description, answer: %{answer: item.title}, answer_choices: []}) end)
    |> Enum.each(&Repo.insert!/1)
  end
end
