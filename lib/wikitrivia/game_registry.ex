defmodule Wikitrivia.GameRegistry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: :game_registry])
  end

  @doc """
  Looks up the game pid for `game_id` stored in `server`.

  Returns `{:ok, pid}` if the game exists, `:error` otherwise.
  """
  def lookup(game_id) do
    GenServer.call(:game_registry, {:lookup, game_id})
  end

  @doc """
  Ensures there is a game associated with the given `game_id` in `server`.
  """
  def create(game_id, num_players, question_ids) do
    GenServer.call(:game_registry, {:create, game_id, num_players, question_ids})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:lookup, game_id}, _from, games) do
    {:reply, {:ok, Map.fetch(games, game_id)}, games}
  end

  def handle_call({:create, game_id, num_players, question_ids}, _from, games) do
    if Map.has_key?(games, game_id) do
      {:reply, :game_already_exists, games}
    else
      {:ok, game} = Wikitrivia.Game.start_link(num_players, question_ids, [])
      {:reply, game, Map.put(games, game_id, game)}
    end
  end
end
