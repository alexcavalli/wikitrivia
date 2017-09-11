defmodule Wikitrivia.QuizController do
  use Wikitrivia.Web, :controller

  def show(conn, %{"id" => quiz_id}) do
    {:ok, game} = Wikitrivia.GameRegistry.lookup(quiz_id)
    game_state = Wikitrivia.Game.get_state(game)
    render conn, "show.html", game: game_state
  end

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"quiz" => %{"num_players" => num_players, "player_name" => player_name}}) do
    %{id: quiz_id, question_ids: question_ids} = Wikitrivia.Quiz.generate
    Wikitrivia.GameRegistry.create(quiz_id, num_players, question_ids)
    conn |> redirect(to: quiz_path(conn, :show, quiz_id))
  end
end
