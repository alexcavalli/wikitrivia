defmodule QuestionFetcher do
  defmodule Question do
    defstruct description: nil, title: nil
  end

  @language "en"
  @random_list_base_url "https://#{@language}.wikipedia.org/w/api.php?action=query&format=json&list=random&indexpageids=1&titles=&rnnamespace=0&rnfilterredir=nonredirects"
  @page_data_base_url "https://#{@language}.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&meta=&exintro=1&explaintext=1"

  def fetch(num_questions) do
    fetch_total_questions([], num_questions)
  end

  defp fetch_total_questions(questions, num_questions) when length(questions) >= num_questions, do: Enum.take(questions, num_questions)
  defp fetch_total_questions(questions, num_questions) do
    num_questions_needed = num_questions - length(questions)
    IO.puts "Fetching #{num_questions_needed} questions."
    questions ++ fetch_questions(Enum.min([num_questions_needed, 20]))
    |> fetch_total_questions(num_questions)
  end

  defp fetch_questions(num_questions) do
    fetch_random_ids(num_questions, nil)
    |> fetch_pages
    |> clean_pages
  end

  defp fetch_random_ids(num, cont_value) do
    HTTPoison.start
    HTTPoison.get!(random_list_url(num, cont_value)).body
    |> Poison.decode!
    |> Map.get("query")
    |> Map.get("random")
    |> Enum.map(fn(x) -> x["id"] end)
  end

  defp fetch_pages(page_ids) do
    HTTPoison.start
    HTTPoison.get!(page_data_url(page_ids)).body
    |> Poison.decode!
    |> Map.get("query")
    |> Map.get("pages")
    |> Map.values
  end

  defp clean_pages(pages) do
    pages
    |> Enum.map(&new_question/1)
    |> Enum.filter(&valid_question?/1)
    |> Enum.map(&redact_question_title/1)
  end

  defp new_question(%{"extract" => description, "title" => title}) do
    %Question{description: clean_description(description), title: title}
  end

  defp valid_question?(%Question{} = question) do
    String.contains?(question.description, question.title)
  end

  defp redact_question_title(%Question{} = question) do
    %{question | description: String.replace(question.description, question.title, "___")}
  end

  defp clean_description(description) do
    description
    |> String.replace(~r/ \(.*?\)/, "")
    |> String.replace(~r/\. [A-Z].*|\.$|\.\n.*/s, ".")
  end

  defp random_list_url(limit, nil), do: @random_list_base_url <> "&rnlimit=#{limit}"
  defp random_list_url(limit, cont_value), do: random_list_url(limit, nil) <> "&rncontinue=#{cont_value}"
  defp page_data_url(page_ids), do: @page_data_base_url <> "&pageids=#{page_ids |> Enum.join("%7C")}&exlimit=#{length page_ids}"
end
