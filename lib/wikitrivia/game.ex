defmodule Wikitrivia.Game do
  def create_game do
    game_id = Ecto.UUID.generate
    {:ok, _} = Agent.start_link(fn -> default_state end, name: agent_name_by_game_id(game_id))
    game_id
  end

  def get_game_state(game_id) do
    Agent.get(agent_name_by_game_id(game_id), fn s -> s end)
  end

  def add_player(game_id, player_name) do
    Agent.update(agent_name_by_game_id(game_id), add_player(player_name))
  end

  def award_points(game_id, player_name, points) do
    Agent.update(agent_name_by_game_id(game_id), award_points(player_name, points))
  end

  def start(game_id, socket) do
    start_question(game_id, socket)
  end

  def start_question(game_id, socket) do
    Agent.update(agent_name_by_game_id(game_id), start_question())
    WikitriviaWeb.GameChannel.broadcast_message(socket, "start_question", %{question: "some question data"}) # TODO: refactor
    Task.async(fn -> :timer.sleep(5000) ; stop_question(game_id, socket) end)
  end

  def stop_question(game_id, socket) do
    Agent.update(agent_name_by_game_id(game_id), stop_question())
    WikitriviaWeb.GameChannel.broadcast_message(socket, "stop_question", %{}) # TODO: refactor
    Task.async(fn -> :timer.sleep(5000) ; start_question(game_id, socket) end)
  end

  defp default_state do
    %{
      players: MapSet.new(),
      scores: %{}
    }
  end

  defp add_player(player_name) do
    fn (state = %{players: players, scores: scores}) ->
      players = players |> MapSet.put(player_name)
      scores = scores |> Map.put(player_name, 0)
      %{state | players: players, scores: scores}
    end
  end

  defp award_points(player_name, points) do
    fn (state = %{scores: scores}) ->
      %{^player_name => player_score} = scores
      new_score = player_score + points
      %{state | scores: %{scores | player_name => new_score}}
    end
  end

  defp start_question do
    fn (state) -> Map.put(state, :question, true) end
  end

  defp stop_question do
    fn (state) -> Map.put(state, :question, false) end
  end

  defp agent_name_by_game_id(game_id) do
    {:via, Registry, {Registry.Games, game_id}}
  end
end
