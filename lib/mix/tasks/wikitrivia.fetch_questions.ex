defmodule Mix.Tasks.Wikitrivia.FetchQuestions do
  use Mix.Task

  @shortdoc "Fetches trivia questions from Wikipedia data and loads it into the DB 'mix wikitrivia.fetch_questions <num>'"
  @language "en"
  @random_list_base_url "https://#{@language}.wikipedia.org/w/api.php?action=query&format=json&list=random&indexpageids=1&titles=&rnnamespace=0&rnfilterredir=nonredirects"
  @page_data_base_url "https://#{@language}.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&meta=&exintro=1&explaintext=1"

  def run(args) do
    Mix.Task.run "app.start"
    Mix.shell.info "Fetching trivia questions from Wikipedia..."
    args
    |> List.first
    |> String.to_integer
    |> generate_questions
    |> load_questions
  end

  defp generate_questions(num_questions) do
    generate_total_questions([], num_questions, nil)
  end

  defp load_questions(questions) do
    {:ok, file} = File.open("data/questions.json", [:write])
    {:ok, encoded_questions} = questions
    #|> Enum.map(fn item -> Question.changeset(%Question{}, %{original: item.description, redacted: item.redacted_description, answer: %{answer: item.title}, answer_choices: []}) end)
    |> Enum.map(fn item -> %{question: item.description} end)
    |> JSON.encode
    :ok = IO.binwrite(file, encoded_questions)
    :ok = File.close(file)
  end

  # TODO: Clean this up a bit. Change num_questions param to what num_questions_needed currently is.
  # Then set a guard clause on num questions_needed being 0 for returning
  # Have each method call generate a bunch of questions and return the generated items ++ a recursive call.
  defp generate_total_questions(questions, num_questions, _) when length(questions) >= num_questions, do: Enum.take(questions, num_questions)
  defp generate_total_questions(questions, num_questions, rncontinue) do
    num_questions_needed = num_questions - length(questions)
    IO.puts "Fetching #{num_questions_needed} questions."
    {new_questions, rncontinue} = fetch_questions(Enum.min([num_questions_needed, 20]), rncontinue)
    generate_total_questions(questions ++ new_questions, num_questions, rncontinue)
  end

  # This method is a bit of a lie, since it returns *up to* num_questions.
  # Might want to rename to make that clearer or refactor to keep fetching until
  # it gets the desired amount (the latter probably won't play nice with the
  # "at most 20" thing going on in generate_total_questions)
  defp fetch_questions(num_questions, rncontinue) do
    {page_ids, rncontinue} = fetch_random_page_ids(num_questions, rncontinue)

    questions = create_questions_from_pages(page_ids)
    {questions, rncontinue}
  end

  defp fetch_random_page_ids(num, rncontinue) do
    random_list = fetch_random_list(num, rncontinue)
    {extract_page_ids(random_list), extract_rncontinue(random_list)}
  end

  defp fetch_random_list(num, rncontinue) do
    HTTPoison.start
    HTTPoison.get!(random_list_url(num, rncontinue)).body |> Poison.decode!
  end

  defp extract_page_ids(random_list) do
    random_list
    |> Map.get("query")
    |> Map.get("random")
    |> Enum.map(fn(x) -> x["id"] end)
  end

  defp extract_rncontinue(random_list) do
    random_list
    |> Map.get("continue")
    |> Map.get("rncontinue")
  end

  defp create_questions_from_pages(page_ids) do
    page_ids
    |> fetch_pages
    |> extract_questions
  end

  defp fetch_pages(page_ids) do
    HTTPoison.start
    HTTPoison.get!(page_data_url(page_ids)).body
    |> Poison.decode!
    |> Map.get("query")
    |> Map.get("pages")
    |> Map.values
  end

  defp extract_questions(pages) do
    pages
    |> Enum.map(&new_question/1)
    |> Enum.filter(&valid_question?/1)
    |> Enum.map(&redact_question_title/1)
  end

  defp new_question(%{"extract" => description, "title" => title}) do
    %{description: clean_description(description), title: title}
  end

  defp valid_question?(%{} = question) do
    String.contains?(question.description, question.title)
  end

  defp redact_question_title(%{} = question) do
    Map.put(question, :redacted_description, String.replace(question.description, question.title, "___"))
  end

  defp clean_description(description) do
    description
    |> String.replace(~r/ \(.*?\)/, "")
    |> String.replace(~r/\. [A-Z].*|\.$|\.\n.*/s, ".")
  end

  defp random_list_url(limit, nil), do: @random_list_base_url <> "&rnlimit=#{limit}"
  defp random_list_url(limit, rncontinue), do: random_list_url(limit, nil) <> "&rncontinue=#{rncontinue}"
  defp page_data_url(page_ids), do: @page_data_base_url <> "&pageids=#{page_ids |> Enum.join("%7C")}&exlimit=#{length page_ids}"
end
