defmodule Wikitrivia.PageController do
  use Wikitrivia.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def question(conn, _params) do
    # questions = QuestionFetcher.fetch(5)
    # demo data:
    questions = [
      %QuestionFetcher.Question{description: "___ may refer to:\n___, Los Angeles County, California\n___, San Bernardino County, California\n___, listed on the NRHP in North Carolina", title: "Friendly Hills"},
      %QuestionFetcher.Question{description: "___ may refer to:\n___, American baseball player for the St.", title: "Elmer Miller"},
      %QuestionFetcher.Question{description: "The ___, formerly Bonner zoologische Beiträge, is a peer reviewed open access journal dealing with zoology.", title: "Bonn zoological Bulletin"},
      %QuestionFetcher.Question{description: "___ is a 1970 American film, based on a play by the same name, which tells the story of a widowed college professor who wants to get out from under the thumb of his aging father yet still has regrets about his plan to leave him behind when he remarries and moves to California.", title: "I Never Sang for My Father"},
      %QuestionFetcher.Question{description: "___ was an English-born Australian politician and intelligence agent .", title: "Roy Kendall"}
    ]

    render conn, "question.json", data: questions
  end
end
