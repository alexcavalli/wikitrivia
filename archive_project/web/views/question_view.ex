defmodule Wikitrivia.QuestionView do
  use Wikitrivia.Web, :view

  def render("question.json", %{data: question}) do
    %{
      prompt: question.answer.redacted_description,
      answer_choices: Wikitrivia.AnswerChoiceView.render("show.json", data: question.answer_choices),
      correct_answer_id: question.answer.id
    }
  end
end
