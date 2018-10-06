defmodule Wikitrivia.Game do
  # Game behaviors:
  # * Timer-based:
  #   * Start question answering period
  #     * This will add/replace a question to the state
  #     * This will also clear any previous user answers from the state
  #   * Stop question answering period
  #     * Award points based on answer correctness
  #     * Mark winner(s) if we're done
  # * User-event based:
  #   * If during question answering period
  #     * Mark answer choice for user (does nothing if user already marked a choice)
  #       * This broadcasts updated state if state changed
  #   * During lobby
  #     * Add player
  #     * Submit user name
  #     * Start

  @question_period_ms 5000
  @post_question_period_ms 5000
  @default_num_questions 4

  # General events
  def create(num_questions \\ @default_num_questions) do
    game_id = Ecto.UUID.generate
    {:ok, _} = Agent.start_link(fn -> default_state(num_questions) end, name: agent_name_by_game_id(game_id))
    game_id
  end

  def get_state(game_id) do
    Agent.get(agent_name_by_game_id(game_id), fn s -> s end)
  end

  # User events
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
  #   * num_questions - Number of questions total in the game
  #   * game_phase - Current phase of this game.
  #     * :lobby - Initial phase, waiting for players to join. Changes on the "start" event.
  #     * :question - Users are posed a question and can submit answers. On a timer, can move to
  #                   question_results or to game_results, depending on number of questions left.
  #     * :question_results - Contains updated scores from previous question phase. Always moves to
  #                           question phase after a time period.
  #     * :game_results - Final phase, with final results.
  #   * timer_data - Data associated with the game_phase (e.g. the question)
  defp default_state(num_questions) do
    %{
      players: MapSet.new(),
      scores: %{},
      num_questions: num_questions,
      game_phase: :lobby,
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
    fn (state) -> %{state | game_phase: :question, timer_data: %{question: "data"}} end
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
      game_phase = if num_questions_left <= 0, do: :done, else: :question_results
      %{state | num_questions_left: num_questions_left, game_phase: game_phase, timer_data: %{}}
    end
  end

  defp execute_after_delay(delay, execute) do
    :timer.sleep(delay)
    execute.()
  end

  defp game_finished?(game_id) do
    get_state(game_id).game_phase == :done
  end

  defp agent_name_by_game_id(game_id) do
    {:via, Registry, {Registry.Games, game_id}}
  end
end
