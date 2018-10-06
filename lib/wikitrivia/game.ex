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
  #     * Update player name
  #     * Start

  @question_period_ms 5000
  @post_question_period_ms 5000
  @default_num_questions 4
  @default_player_name "anonymous"

  # General events
  def create(game_name, num_questions \\ @default_num_questions) do
    game_id = Ecto.UUID.generate
    # TODO: need to handle the case where this agent crashes
    # currently get the error message: "the process is not alive or there's no process currently associated with the given name, possibly because its application isn't started"
    {:ok, _} = Agent.start_link(fn -> init_state(game_name, num_questions) end, name: agent_name_by_game_id(game_id))
    game_id
  end

  def get_state(game_id) do
    Agent.get(agent_name_by_game_id(game_id), fn s -> s end)
  end

  # User events
  def add_player(game_id, player_id) do
    Agent.get_and_update(agent_name_by_game_id(game_id), fn state -> _add_player(state, player_id) end)
  end

  defp _add_player(state = %{players: players, scores: scores}, player_id) do
    if Map.has_key?(players, player_id) do
      {{:no_change, state}, state}
    else
      new_state = %{state |
        players: Map.put(players, player_id, @default_player_name),
        scores: Map.put(scores, player_id, 0)
      }
      {{:ok, new_state}, new_state}
    end
  end

  def update_player_name(game_id, player_id, player_name) do
    Agent.get_and_update(agent_name_by_game_id(game_id), fn state -> _update_player_name(state, player_id, player_name) end)
  end

  defp _update_player_name(state = %{players: players}, player_id, player_name) do
    cond do
      !Map.has_key?(players, player_id) ->
        {{:no_change, state}, state}
      Map.fetch(players, player_id) == {:ok, player_name} ->
        {{:no_change, state}, state}
      true ->
        new_state = %{state |
          players: %{players | player_id => player_name}
        }
        {{:ok, new_state}, new_state}
    end
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
  #   * name - Name of this game, provided by user up front.
  #   * player_names - id -> name map for all players in the game.
  #   * scores - Map of all player scores in this game, keyed by player name
  #   * num_questions - Number of questions total in the game
  #   * current_question - Current question number, 0-indexed
  #   * questions - List of game questions
  #   * game_phase - Current phase of this game.
  #     * :lobby - Initial phase, waiting for players to join. Changes on the "start" event.
  #     * :question - Users are posed a question and can submit answers. On a timer, can move to
  #                   question_results or to game_results, depending on number of questions left.
  #     * :question_results - Contains updated scores from previous question phase. Always moves to
  #                           question phase after a time period.
  #     * :game_results - Final phase, with final results.
  defp init_state(game_name, num_questions) do
    %{
      name: game_name,
      player_names: %{},
      scores: %{},
      num_questions: num_questions,
      current_question: 0,
      questions: [],
      game_phase: :lobby
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
