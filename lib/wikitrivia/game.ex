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

  ### General events ###

  def create(game_name, num_questions \\ @default_num_questions) do
    game_id = Ecto.UUID.generate
    # TODO: need to handle the case where this agent crashes
    # currently get the error message: "the process is not alive or there's no process currently associated with the given name, possibly because its application isn't started"
    {:ok, _} = Agent.start_link(fn -> init_state(game_name, num_questions) end, name: agent_name_by_game_id(game_id))
    game_id
  end

  # State structure of a Game. Details:
  #   * name - Name of this game, provided by user up front.
  #   * player_names - id -> name map for all players in the game.
  #   * player_answers - maps of player ids to player answer data, by question index, e.g.
  # [
  #   %{player_id => %{answer:, time_left:}, other_player_id => %{answer:, time_left: }}, # for question index 0
  #   %{player_id => %{answer:, time_left:}, other_player_id => %{answer:, time_left: }}, # for question index 1
  # ]
  #   * scores - Map of all player scores in this game, keyed by player id
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
    state = %{
      name: game_name,
      player_names: %{},
      player_answers: [],
      scores: %{},
      num_questions: num_questions,
      current_question: -1,
      questions: [],
      game_phase: :lobby,
      phase_start_time:
    }
    # dynamic stuff:
    # add questions from db:
    state = %{state | questions: [%{}, %{}, %{}, %{}]}
    # set up empty player answers maps:
    state = %{state | player_answers: [%{}, %{}, %{}, %{}]}
    state
  end

  def get_state(game_id) do
    Agent.get(agent_name_by_game_id(game_id), fn s -> s end)
  end

  ### User Events ###

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

  # TODO: We'll probably want to alter the behavior here s.t. the final player answering the
  # question immediately triggers the next phase (the question_results) phase. (there's no reason
  # to wait those extra seconds, since you can't change your answer - OR maybe we let people change
  # their answers after everyone has answered).

  # Starts the pose question -> show results loop. Ends after current_question reaches
  # num_questions - 1. The provided game_timer_callback function will be called after every timed
  # state change.
  def start(game_id, game_timer_callback) do
    start_question(game_id, game_timer_callback)
  end

  ### Timer Events ###

  defp start_question(game_id, game_timer_callback, go_to_next_state \\ &Game.set_next_state_entry/3) do
    state = Agent.get_and_update(agent_name_by_game_id(game_id), fn state -> _start_question(state) end)
    game_timer_callback.()
    go_to_next_state.(state, game_id, game_timer_callback)
  end

  defp _start_question(state = %{game_phase: :question}), do: {state, state}

  defp _start_question(state = %{current_question: current_question}) do
    new_state = %{state |
      game_phase: :question,
      current_question: current_question + 1
    }
    {new_state, new_state}
  end

  defp stop_question(game_id, game_timer_callback, go_to_next_state \\ &Game.set_next_state_entry/3) do
    state = Agent.get_and_update(agent_name_by_game_id(game_id), fn state -> _stop_question(state) end)
    game_timer_callback.()
    go_to_next_state.(state, game_id, game_timer_callback)
  end

  defp _stop_question(state = %{game_phase: :question_results}), do: {state, state}

  defp _stop_question(state = %{}) do
    new_state = state |>
      award_current_question_points |>
      Map.put(:game_phase, :question)

    {new_state, new_state}
  end

  defp award_current_question_points(state = %{current_question: current_question, questions: questions, player_answers: player_answers, scores: scores}) do
    correct_answer = questions[current_question].answer
    question_answers = player_answers[current_question]

    # I imagine this could be clarified with a for comprehension or something
    new_scores = question_answers |>
      Enum.filter(&match?({_player_id, %{answer: ^correct_answer}}, &1)) |>
      Enum.map(fn ({player_id, %{time_left: time_left}}) -> {player_id, time_left * 10} end) |> # sneaky hidden hardcoded points-per-second-left right here
      Enum.reduce(scores, fn ({player_id, add_points}, new_scores = %{player_id => player_points}) -> %{scores | player_id => player_points + add_points} end)

    %{state |
      scores: new_scores
    }
  end

  defp set_next_state_entry(state, game_id, game_timer_callback) do
    Task.async(fn ->
      :timer.sleep(@question_period_ms)
      next_state_entry_function(state).(game_id, game_timer_callback)
    end)
  end

  # Return values are functions that take a game id and a callback function. The callback should be
  # executed after updating the game state.
  defp next_state_entry_function(state) do
    case state do
      %{game_phase: :question, num_questions: num_questions, current_question: current_question} when current_question = num_questions - 1 -> &Game.stop/2
      %{game_phase: :question} -> &Game.stop_question/2
      %{game_phase: :question_results} -> &Game.start_question/2
    end
  end

  defp game_finished?(game_id) do
    get_state(game_id).game_phase == :done
  end

  defp agent_name_by_game_id(game_id) do
    {:via, Registry, {Registry.Games, game_id}}
  end
end
