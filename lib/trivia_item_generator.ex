defmodule TriviaItemGenerator do
  @language "en"
  @random_list_base_url "https://#{@language}.wikipedia.org/w/api.php?action=query&format=json&list=random&indexpageids=1&titles=&rnnamespace=0&rnfilterredir=nonredirects"
  @page_data_base_url "https://#{@language}.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&meta=&exintro=1&explaintext=1"

  def generate_trivia_items(num_trivia_items) do
    generate_total_trivia_items([], num_trivia_items, nil)
  end

  # TODO: Clean this up a bit. Change num_trivia_items param to what num_trivia_items_needed currently is.
  # Then set a guard clause on num trivia_items_needed being 0 for returning
  # Have each method call generate a bunch of trivia items and return the generated items ++ a recursive call.
  defp generate_total_trivia_items(trivia_items, num_trivia_items, _) when length(trivia_items) >= num_trivia_items, do: Enum.take(trivia_items, num_trivia_items)
  defp generate_total_trivia_items(trivia_items, num_trivia_items, rncontinue) do
    num_trivia_items_needed = num_trivia_items - length(trivia_items)
    IO.puts "Fetching #{num_trivia_items_needed} trivia items."
    {new_trivia_items, rncontinue} = fetch_trivia_items(Enum.min([num_trivia_items_needed, 20]), rncontinue)
    generate_total_trivia_items(trivia_items ++ new_trivia_items, num_trivia_items, rncontinue)
  end

  # This method is a bit of a lie, since it returns *up to* num_trivia_items.
  # Might want to rename to make that clearer or refactor to keep fetching until
  # it gets the desired amount (the latter probably won't play nice with the
  # "at most 20" thing going on in generate_total_trivia_items)
  defp fetch_trivia_items(num_trivia_items, rncontinue) do
    {page_ids, rncontinue} = fetch_random_page_ids(num_trivia_items, rncontinue)

    trivia_items = create_trivia_items_from_pages(page_ids)
    {trivia_items, rncontinue}
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

  defp create_trivia_items_from_pages(page_ids) do
    page_ids
    |> fetch_pages
    |> extract_trivia_items
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
    %{description: clean_description(description), title: title}
  end

  defp valid_trivia_item?(%{} = trivia_item) do
    String.contains?(trivia_item.description, trivia_item.title)
  end

  defp redact_trivia_item_title(%{} = trivia_item) do
    Map.put(trivia_item, :redacted_description, String.replace(trivia_item.description, trivia_item.title, "___"))
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
