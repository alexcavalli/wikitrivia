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

  @phase_ms 10000
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
  #   * players - id -> player data:
  # %{
  #   id: 1,
  #   name: "Name",
  #   score: 15,
  #   answers: [
  #     %{answer: "Question 1 answer", time_left: 3},
  #     %{answer: "Question 2 answer", time_left: 6}
  #   ]
  # }
  #   * current_question - Current question number, 0-indexed
  #   * questions - List of game questions
  #   * game_phase - Current phase of this game.
  #     * :lobby - Initial phase, waiting for players to join. Changes on the "start" event.
  #     * :question - Users are posed a question and can submit answers. On a timer, can move to
  #                   question_results or to game_results, depending on number of questions left.
  #     * :question_results - Contains updated scores from previous question phase. Always moves to
  #                           question phase after a time period.
  #     * :game_results - Final phase, with final results.
  #   * phase_start_time - UTC server clock time for current phase start (nil unless in `question` phase)
  defp init_state(game_name, num_questions) do
    state = %{
      name: game_name,
      players: %{},
      current_question: -1,
      questions: [],
      game_phase: :lobby,
      phase_start_time: nil
    }
    # add questions from db (TODO: actually get random questions):
    questions = generate_questions(num_questions)
    state = %{state | questions: []}
    state
  end

  defp generate_questions(_num_questions) do
    [
      Wikitrivia.Repo.get(Wikitrivia.Question, 1),
      Wikitrivia.Repo.get(Wikitrivia.Question, 2),
      Wikitrivia.Repo.get(Wikitrivia.Question, 3),
      Wikitrivia.Repo.get(Wikitrivia.Question, 4)
    ] |>
    Enum.map(fn (question) -> Map.take(question, [:id, :question, :answer_choices, :correct_answer]) end)
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
    GenServer.call(name_by_game_id(game_id), {:answer_question, player_id, answer, Time.utc_now()})
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

  def handle_call({:add_player, player_id}, _from, state = %{questions: questions, players: players}) do
    if Map.has_key?(players, player_id) do
      {:reply, {:no_change, state}, state}
    else
      default_player = %{
        name: @default_player_name,
        score: 0,
        answers: (for _ <- 1..length(questions), do: %{})
      }
      new_state = %{state | players: Map.put(players, player_id, default_player)}
      {:reply, {:ok, new_state}, new_state}
    end
  end

  def handle_call({:update_player_name, player_id, player_name}, _from, state = %{players: players}) do
    cond do
      !Map.has_key?(players, player_id) ->
        {:reply, {:no_change, state}, state}
      players[player_id][:name] == player_name ->
        {:reply, {:no_change, state}, state}
      true ->
        current_player_state = Map.get(players, player_id)
        new_player_state = %{current_player_state | name: player_name}
        new_state = %{state | players: %{players | player_id => new_player_state}}
        {:reply, {:ok, new_state}, new_state}
    end
  end

  def handle_call({:answer_question, player_id, answer, answer_time}, _from, state = %{game_phase: :question}) do
    %{players: players = %{^player_id => this_player = %{answers: player_answers}}, phase_start_time: phase_start_time, current_question: current_question} = state

    question_answer = Enum.at(player_answers, current_question)
    cond do
      map_size(question_answer) > 0 ->
        {:reply, {:no_change, state}, state}
      true ->
        player_answer = %{answer: answer, time_left: trunc(@phase_ms / 1000) - Time.diff(answer_time, phase_start_time)}
        new_state = %{state |
          players: %{players |
            player_id => %{this_player |
              answers: List.replace_at(player_answers, current_question, player_answer)
            }
          }
        }
        {:reply, {:ok, new_state}, new_state}
    end
  end

  def handle_call({:answer_question, _, _, _}, _, state), do: {:reply, {:no_change, state}, state}

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
    Process.send_after(self(), {:change_game_phase, game_timer_callback}, @phase_ms)
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
      current_question: current_question + 1,
      phase_start_time: Time.utc_now()
    }
  end

  defp stop_question(state = %{game_phase: :question_results}), do: state

  defp stop_question(state = %{}) do
    state |>
      award_current_question_points |>
      Map.put(:game_phase, :question_results) |>
      Map.put(:phase_start_time, nil)
  end

  defp stop_game(state) do
    state |>
      award_current_question_points |>
      Map.put(:game_phase, :game_results) |>
      Map.put(:phase_start_time, nil)
  end

  defp award_current_question_points(state = %{current_question: current_question, questions: questions, players: players}) do
    correct_answer = Enum.at(questions, current_question).correct_answer

    # I imagine this could be clarified with a for comprehension or something
    new_players = players |>
      Enum.map(fn ({player_id, %{score: score, answers: answers}}) -> {player_id, score, Enum.at(answers, current_question)} end) |>
      Enum.map(fn ({player_id, score, answer_info}) ->
        case answer_info do
          %{answer: ^correct_answer, time_left: time_left} -> {player_id, score + time_left * 10}
          _ -> {player_id, score}
        end
      end) |>
      Enum.reduce(players, fn({player_id, new_score}, new_players) ->
        put_in(new_players[player_id][:score], new_score)
      end)

    %{state |
      players: new_players
    }
  end

  defp name_by_game_id(game_id) do
    {:via, Registry, {Registry.Games, game_id}}
  end
end
