defmodule Wikitrivia.PageView do
  use Wikitrivia.Web, :view

  def render("question.json", %{data: data}), do: data
end
