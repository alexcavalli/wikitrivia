defmodule Wikitrivia.Game do
  use GenServer

  ## Client API

  @doc """
  Starts the game.
  """
  def start_link(num_players, question_ids, opts) do
    GenServer.start_link(__MODULE__, {num_players, question_ids}, opts)
  end

  @doc """
  Gets the current game state for `game_pid`.

  Returns `{:ok, state}` if the game exists, `:error` otherwise.
  """
  def get_state(game_pid) do
    GenServer.call(game_pid, {:get_state})
  end

  @doc """
  Joins the current game `game_pid` as `played_name`.

  Returns `{:ok, state}` if the game exists, `:error` otherwise.
  """
  def join(game_pid, player_name) do
    GenServer.call(game_pid, {:join, player_name})
  end

  ## Server Callbacks

  def init({num_players, question_ids}) do
    {:ok, %{num_players: num_players, question_ids: question_ids, players: %{}}}
  end

  def handle_call({:get_state}, _from, game_state) do
    {:reply, game_state, game_state}
  end

  def handle_call({:join, player_name}, _from, game_state = %{num_players: num_players, players: players}) do
    if Enum.count(players) >= num_players do
      {:reply, :game_is_full, game_state}
    else
      players = Map.put(players, player_name, %{points: 0})
      game_state = %{game_state | players: players}
      {:reply, game_state, game_state}
    end
  end
end
