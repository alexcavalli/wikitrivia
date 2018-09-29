defmodule Wikitrivia.Game do
  def create_game(game_name) do
    game_id = Ecto.UUID.generate
    # TODO: need to handle the case where this agent crashes
    # currently get the error message: "the process is not alive or there's no process currently associated with the given name, possibly because its application isn't started"
    {:ok, _} = Agent.start_link(fn -> init_state(game_name) end, name: agent_name_by_game_id(game_id))
    game_id
  end

  def get_game_state(game_id) do
    Agent.get(agent_name_by_game_id(game_id), fn s -> s end)
  end

  def has_player(game_id, player_id) do
    Agent.get(agent_name_by_game_id(game_id), fn s -> MapSet.member?(s.players, player_id) end)
  end

  def add_player(game_id, player_id) do
    player_name = "anonymous"

    # TODO: need to handle games that don't exist
    Agent.update(agent_name_by_game_id(game_id), fn (state = %{players: players, scores: scores, player_names: player_names}) ->
      players = players |> MapSet.put(player_id)
      scores = scores |> Map.put(player_id, 0)
      player_names = player_names |> Map.put(player_id, player_name)
      %{state | players: players, scores: scores, player_names: player_names}
    end)

    player_id
  end

  def update_player_name(game_id, player_id, player_name) do
    Agent.update(agent_name_by_game_id(game_id), fn (state = %{player_names: player_names}) ->
      player_names = player_names |> Map.put(player_id, player_name)
      %{ state | player_names: player_names }
    end)
  end

  def award_points(game_id, player_name, points) do
    Agent.update(agent_name_by_game_id(game_id), award_points(player_name, points))
  end

  defp init_state(game_name) do
    %{
      name: game_name,
      players: MapSet.new(),
      scores: %{},
      player_names: %{}
    }
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
