defmodule Wikitrivia.QuizView do
  use Wikitrivia.Web, :view

  def render("game.json", %{game: game_state}) do
    game_state
  end
end
