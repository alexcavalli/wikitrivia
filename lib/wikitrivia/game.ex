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

  ## Server Callbacks

  def init({num_players, question_ids}) do
    {:ok, %{num_players: num_players, question_ids: question_ids}}
  end

  def handle_call({:get_state}, _from, game_state) do
    {:reply, game_state, game_state}
  end
end
