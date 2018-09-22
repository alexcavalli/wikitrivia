defmodule Mix.Tasks.Wikitrivia.GenerateQuestions do
  use Mix.Task

  alias Wikitrivia.Repo
  alias Wikitrivia.Question

  @shortdoc "Generates fake question answers for questions missing fake answers"

  @moduledoc """
    Generates fake question answers for questions missing fake answers

    This should not be run without a significant number of questions
    available to draw upon for answer choices. 1000 or so should be safe.

    mix wikitrivia.generate_questions
  """

  def run(_args) do
    Mix.Task.run "app.start"

    questions = File.read!("data/questions.json")
    |> Poison.decode!
    |> Enum.map(fn item -> %{ question: redact(item["question"], item["answer"]), correct_answer: item["answer"]} end)

    questions
    |> Enum.map(fn question -> Map.put(question, :answer_choices, generate_answer_choices(questions, question.correct_answer)) end)
    |> Enum.each(&load_question/1)
  end

  defp redact(question, answer) do
    String.replace(question, answer, "___")
    |> String.trim
  end

  defp generate_answer_choices(questions, correct_answer) do
    [correct_answer | generate_fake_answers(questions, correct_answer)]
    |> Enum.shuffle
  end

  defp generate_fake_answers(questions, correct_answer) do
    questions
    |> Enum.map(fn question -> question.correct_answer end)
    |> Enum.filter(fn answer -> answer != correct_answer end)
    |> Enum.shuffle
    |> Enum.take(3)
  end

  defp load_question(question) do
    Question.changeset(%Question{}, question)
    |> Repo.insert!
  end
end
