defmodule Wikitrivia.Game do
  @question_period_ms 5000
  @post_question_period_ms 5000

  def create_game do
    game_id = Ecto.UUID.generate
    {:ok, _} = Agent.start_link(fn -> default_state() end, name: agent_name_by_game_id(game_id))
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

  # Starts the pose question -> show results loop. Ends after num_questions_left reaches 0.
  # game_timer_callback function will be called after every timed state change.
  def start(game_id, game_timer_callback) do
    start_question(game_id, game_timer_callback)
  end

  # State structure of a Game. Details:
  #   * players - Set of all players in this game.
  #   * scores - Map of all player scores in this game, keyed by player name
  #   * num_questions_left - Number of questions remaining to answer in this game
  #   * timer_state - Current state of timed component of this game. :off when not in a timed
  #       period, otherwise the name of the period (:question, :stats)
  #   * timer_data - Data associated with the timer_state (e.g. the question)
  defp default_state do
    %{
      players: MapSet.new(),
      scores: %{},
      num_questions_left: 5,
      timer_state: :off,
      timer_data: %{}
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
