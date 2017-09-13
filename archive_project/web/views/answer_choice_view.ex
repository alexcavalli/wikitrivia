defmodule Wikitrivia.AnswerChoiceView do
  use Wikitrivia.Web, :view

  def render("show.json", %{data: answer_choices}) when is_list(answer_choices) do
    for answer_choice <- answer_choices do
      render("show.json", data: answer_choice)
    end
  end

  def render("show.json", %{data: answer_choice}) do
    %{
      id: answer_choice.id,
      answer: answer_choice.title
    }
  end
end
