defmodule QuestionFetcher do
  defmodule Page do
    defstruct description: nil, title: nil

    def new(%{"extract" => description, "title" => title}) do
      %Page{description: clean_description(description), title: title}
    end

    def valid?(%Page{} = page) do
      String.contains?(page.description, page.title)
    end

    def redact_title(%Page{} = page) do
      %{page | description: String.replace(page.description, page.title, "___")}
    end

    defp clean_description(description) do
      description
      |> String.replace(~r/ \(.*?\)/, "")
      |> String.replace(~r/\. [A-Z].*|\.$|\.\n.*/s, ".")
    end
  end

  @language "en"
  @random_list_base_url "https://#{@language}.wikipedia.org/w/api.php?action=query&format=json&list=random&indexpageids=1&titles=&rnnamespace=0&rnfilterredir=nonredirects"
  @page_data_base_url "https://#{@language}.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&meta=&exintro=1&explaintext=1"

  def fetch(num_articles) do
    fetch_random_ids(num_articles, nil)
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
    |> Enum.map(fn(page) -> Page.new(page) end)
    |> Enum.filter(fn(page) -> Page.valid?(page) end)
    |> Enum.map(fn(page) -> Page.redact_title(page) end)
  end

  defp random_list_url(limit, nil), do: @random_list_base_url <> "&rnlimit=#{limit}"
  defp random_list_url(limit, cont_value), do: random_list_url(limit, nil) <> "&rncontinue=#{cont_value}"

  defp page_data_url(page_ids), do: @page_data_base_url <> "&pageids=#{page_ids |> Enum.join("%7C")}&exlimit=#{length page_ids}"

end
