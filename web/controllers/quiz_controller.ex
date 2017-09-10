defmodule Wikitrivia.QuizController do
  use Wikitrivia.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"quiz" => %{"num_players" => num_players, "player_name" => player_name}}) do
    %{id: quiz_id, question_ids: question_ids} = Wikitrivia.Quiz.generate
    game = Wikitrivia.GameRegistry.create(quiz_id, num_players, question_ids)
    game_state = Wikitrivia.Game.get_state(game)
    render conn, "game.json", game: game_state
  end
end
