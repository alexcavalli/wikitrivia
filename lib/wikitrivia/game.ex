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

  defp agent_name_by_game_id(game_id) do
    {:via, Registry, {Registry.Games, game_id}}
  end
end
