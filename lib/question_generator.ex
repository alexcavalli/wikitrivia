defmodule QuestionGenerator do
  defmodule TriviaItem do
    defstruct description: nil, title: nil
  end

  defmodule Question do
    defstruct prompt: nil, answers: [], correct_answer: nil
  end

  @language "en"
  @random_list_base_url "https://#{@language}.wikipedia.org/w/api.php?action=query&format=json&list=random&indexpageids=1&titles=&rnnamespace=0&rnfilterredir=nonredirects"
  @page_data_base_url "https://#{@language}.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&meta=&exintro=1&explaintext=1"

  def generate_question do
    generate_trivia_items(5)
    |> generate_question
  end

  def generate_trivia_items(num_trivia_items) do
    generate_total_trivia_items([], num_trivia_items)
  end

  def generate_question(trivia_items) do
    %{description: prompt, title: correct_answer} = Enum.random(trivia_items)
    %Question{prompt: prompt, correct_answer: correct_answer, answers: Enum.map(trivia_items, &(&1.title))}
  end

  defp generate_total_trivia_items(trivia_items, num_trivia_items) when length(trivia_items) >= num_trivia_items, do: Enum.take(trivia_items, num_trivia_items)
  defp generate_total_trivia_items(trivia_items, num_trivia_items) do
    num_trivia_items_needed = num_trivia_items - length(trivia_items)
    IO.puts "Fetching #{num_trivia_items_needed} trivia items."
    trivia_items ++ fetch_trivia_items(Enum.min([num_trivia_items_needed, 20]))
    |> generate_total_trivia_items(num_trivia_items)
  end

  defp fetch_trivia_items(num_trivia_items) do
    fetch_random_ids(num_trivia_items, nil)
    |> fetch_pages
    |> extract_trivia_items
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

  defp extract_trivia_items(pages) do
    pages
    |> Enum.map(&new_trivia_item/1)
    |> Enum.filter(&valid_trivia_item?/1)
    |> Enum.map(&redact_trivia_item_title/1)
  end

  defp new_trivia_item(%{"extract" => description, "title" => title}) do
    %TriviaItem{description: clean_description(description), title: title}
  end

  defp valid_trivia_item?(%TriviaItem{} = trivia_item) do
    String.contains?(trivia_item.description, trivia_item.title)
  end

  defp redact_trivia_item_title(%TriviaItem{} = trivia_item) do
    %{trivia_item | description: String.replace(trivia_item.description, trivia_item.title, "___")}
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
