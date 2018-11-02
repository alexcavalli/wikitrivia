defmodule Wikitrivia.Game do
  @question_period_ms 5000
  @post_question_period_ms 5000

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

  # Starts the pose question -> show results loop. Ends after num_questions_left reaches 0.
  # game_timer_callback function will be called after every timed state change.
  def start(game_id, game_timer_callback) do
    start_question(game_id, game_timer_callback)
  end

  # State structure of a Game. Details:
  #   * players - Set of all players in this game.
  #   * scores - Map of all player scores in this game, keyed by player name
  #   * num_questions_left - Number of questions remaining to answer in this game
  #   * timer_state - Current state of timed component of this game. :off before entering timed
  #       periods, otherwise the name of the period (:question, :question_results, :done)
  #   * timer_data - Data associated with the timer_state (e.g. the question)
  defp init_state(game_name) do
    %{
      name: game_name,
      player_names: %{},
      players: MapSet.new(),
      scores: %{},
      num_questions_left: 5,
      timer_state: :off,
      timer_data: %{}
    }
  end

  defp award_points(player_name, points) do
    fn (state = %{scores: scores}) ->
      %{^player_name => player_score} = scores
      new_score = player_score + points
      %{state | scores: %{scores | player_name => new_score}}
    end
  end

  defp start_question(game_id, game_timer_callback) do
    Agent.update(agent_name_by_game_id(game_id), start_question_phase())
    game_timer_callback.()
    Task.async(fn -> execute_after_delay(@question_period_ms, fn -> stop_question(game_id, game_timer_callback) end) end)
  end

  defp start_question_phase do
    fn (state) -> %{state | timer_state: :question, timer_data: %{question: "data"}} end
  end

  defp stop_question(game_id, game_timer_callback) do
    Agent.update(agent_name_by_game_id(game_id), stop_question_phase())
    game_timer_callback.()
    unless game_finished?(game_id) do
      Task.async(fn -> execute_after_delay(@post_question_period_ms, fn -> start_question(game_id, game_timer_callback) end) end)
    end
  end

  defp stop_question_phase do
    fn (state = %{num_questions_left: num_questions_left}) ->
      num_questions_left = num_questions_left - 1
      timer_state = if num_questions_left <= 0, do: :done, else: :question_results
      %{state | num_questions_left: num_questions_left, timer_state: timer_state, timer_data: %{}}
    end
  end

  defp execute_after_delay(delay, execute) do
    :timer.sleep(delay)
    execute.()
  end

  defp game_finished?(game_id) do
    get_game_state(game_id).timer_state == :done
  end

  defp agent_name_by_game_id(game_id) do
    {:via, Registry, {Registry.Games, game_id}}
  end
end
