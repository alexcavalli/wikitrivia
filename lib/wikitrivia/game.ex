defmodule Wikitrivia.Game do
  use GenServer

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
    {:ok, _} = GenServer.start_link(__MODULE__, init_state(game_name, num_questions), name: name_by_game_id(game_id))
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
      current_question: -1,
      questions: [],
      game_phase: :lobby
      # phase_start_time: probably need this for doing point calcs
    }
    # dynamic stuff:
    # add questions from db:
    state = %{state | questions: [Wikitrivia.Repo.get(Wikitrivia.Question, 1), Wikitrivia.Repo.get(Wikitrivia.Question, 2), Wikitrivia.Repo.get(Wikitrivia.Question, 3), Wikitrivia.Repo.get(Wikitrivia.Question, 4)]}
    # set up empty player answers maps:
    state = %{state | player_answers: [%{}, %{}, %{}, %{}]}
    state
  end

  def get_state(game_id) do
    GenServer.call(name_by_game_id(game_id), :get_state)
  end

  def add_player(game_id, player_id) do
    GenServer.call(name_by_game_id(game_id), {:add_player, player_id})
  end

  def update_player_name(game_id, player_id, player_name) do
    GenServer.call(name_by_game_id(game_id), {:update_player_name, player_id, player_name})
  end

  def answer_question(game_id, player_id, answer) do
    # TODO
  end

  # TODO: We'll probably want to alter the behavior here s.t. the final player answering the
  # question immediately triggers the next phase (the question_results) phase. (there's no reason
  # to wait those extra seconds, since you can't change your answer - OR maybe we let people change
  # their answers after everyone has answered).

  # Starts the pose question -> show results loop. Ends after current_question reaches
  # num_questions - 1. The provided game_timer_callback function will be called after every timed
  # state change.

  # THIS EVENT CALL DOES NOT RETURN ANY STATE (the provided callback function should be relied upon for that)
  def start(game_id, game_timer_callback) do
    GenServer.cast(name_by_game_id(game_id), {:start_game, game_timer_callback})
  end


  ### Server (callbacks) ###

  def init(state) do
    {:ok, state}
  end

  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_call({:add_player, player_id}, _from, state = %{players: players, scores: scores}) do
    if Map.has_key?(players, player_id) do
      {:reply, {:no_change, state}, state}
    else
      new_state = %{state |
        players: Map.put(players, player_id, @default_player_name),
        scores: Map.put(scores, player_id, 0)
      }
      {:reply, {:ok, new_state}, new_state}
    end
  end

  def handle_call({:update_player_name, player_id, player_name}, _from, state = %{players: players}) do
    cond do
      !Map.has_key?(players, player_id) ->
        {:reply, {:no_change, state}, state}
      Map.fetch(players, player_id) == {:ok, player_name} ->
        {:reply, {:no_change, state}, state}
      true ->
        new_state = %{state |
          players: %{players | player_id => player_name}
        }
        {:reply, {:ok, new_state}, new_state}
    end
  end

  def handle_cast({:start_game, game_timer_callback}, state) do
    send(self(), {:change_game_phase, game_timer_callback})
    {:noreply, state}
  end

  def handle_info({:change_game_phase, game_timer_callback}, state) do
    {cont, new_state} = go_to_next_state(state)
    game_timer_callback.(new_state)
    unless cont == :stop do
      set_next_state_timer(game_timer_callback)
    end
    {:noreply, new_state}
  end

  defp set_next_state_timer(game_timer_callback) do
    Process.send_after(self(), {:change_game_phase, game_timer_callback}, @question_period_ms)
  end

  defp go_to_next_state(state) do
    case state do
      %{game_phase: :lobby} -> {:ok, start_question(state)}
      %{game_phase: :question, questions: questions, current_question: current_question} when current_question == length(questions) - 1 -> {:stop, stop_game(state)}
      %{game_phase: :question} -> {:ok, stop_question(state)}
      %{game_phase: :question_results} -> {:ok, start_question(state)}
    end
  end

  defp start_question(state = %{game_phase: :question}), do: state

  defp start_question(state = %{current_question: current_question}) do
    %{state |
      game_phase: :question,
      current_question: current_question + 1
    }
  end

  defp stop_question(state = %{game_phase: :question_results}), do: state

  defp stop_question(state = %{}) do
    state |>
      award_current_question_points |>
      Map.put(:game_phase, :question_results)
  end

  defp stop_game(state) do
    state |>
      award_current_question_points |>
      Map.put(:game_phase, :game_results)
  end

  defp award_current_question_points(state = %{current_question: current_question, questions: questions, player_answers: player_answers, scores: scores}) do
    correct_answer = Enum.at(questions, current_question).correct_answer
    question_answers = Enum.at(player_answers, current_question)

    # I imagine this could be clarified with a for comprehension or something
    new_scores = question_answers |>
      Enum.filter(&match?({_player_id, %{answer: ^correct_answer}}, &1)) |>
      Enum.map(fn ({player_id, %{time_left: time_left}}) -> {player_id, time_left * 10} end) |> # the "10" is sneaky hidden hardcoded points-per-second-left right here
      Enum.reduce(scores, fn ({player_id, add_points}, new_scores) ->
        %{^player_id => player_points} = new_scores
        %{scores | player_id => player_points + add_points}
      end)

    %{state |
      scores: new_scores
    }
  end

  defp name_by_game_id(game_id) do
    {:via, Registry, {Registry.Games, game_id}}
  end
end
