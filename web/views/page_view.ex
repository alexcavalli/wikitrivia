defmodule Wikitrivia.PageView do
  use Wikitrivia.Web, :view

  def render("question.json", %{question: question}), do: question
end
