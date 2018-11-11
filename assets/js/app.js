import "phoenix_html"
import socket from "./socket"
import { createPlayerNameInput, createOpponentsList, createStartGameButton, createQuestionPanel } from "./view"
import { runWithState } from "./util"
const uuid = require('uuid/v1')

const getPlayerId = () => {
  let playerId = document.cookie.replace(/(?:(?:^|.*;\s*)player_id\s*\=\s*([^;]*).*$)|^.*$/, "$1")

  if (!playerId) {
    playerId = uuid()

    setPlayerId(playerId)
  }

  return playerId
}

const setPlayerId = (player_id) => {
  document.cookie = `player_id=${player_id}`
}

const clearContents = (elementToClear) => {
  while (elementToClear.hasChildNodes()) {
    elementToClear.removeChild(elementToClear.lastChild)
  }
}

const drawLobby = (channel, state, mapState) => {
  const player_id = getPlayerId()
  const player_name = state && state.current && state.current.game && state.current.game.players && state.current.game.players[player_id] && state.current.game.players[player_id].name
  const game = document.getElementById("game")

  clearContents(game)

  const player_name_input = createPlayerNameInput(player_name, (event) => {
    channel.push("player_update", { game_id, player_id, player_name: event.target.value })
  })
  const join_game_link = document.createElement('p')
  join_game_link.appendChild(document.createTextNode(`Join Game Link: ${window.location}`))

  const game_header = document.createElement('h2')
  game_header.appendChild(document.createTextNode(`Joined Game: ${state.current.game.name}`))

  const start_game_button = createStartGameButton(() => {
    channel.push("start", { "game_id": game_id })
  })

  game.appendChild(game_header)
  game.appendChild(join_game_link)
  game.appendChild(player_name_input)
  game.appendChild(createOpponentsList(player_id, state.current.game.player_names))
  game.appendChild(start_game_button)
  player_name_input.focus()
}

const drawQuestion = (channel, state, mapState) => {
  const game = document.getElementById("game")

  clearContents(game)

  game.innerHTML = createQuestionPanel(channel, state, mapState)
}

const drawQuestionResults = (channel, state, mapState) => {
  const game = document.getElementById("game")

  clearContents(game)

  game.appendChild(document.createTextNode("Question Results"))
}

const drawGameResults = (channel, state, mapState) => {
  const game = document.getElementById("game")

  clearContents(game)

  game.appendChild(document.createTextNode("Game Results"))
}

const redrawer = (channel) => (state, mapState) => {
  const gamePhase = state && state.current && state.current.game && state.current.game.game_phase
  console.log(gamePhase)
  if (gamePhase === "lobby") {
    drawLobby(channel, state, mapState)
  } else if (gamePhase === "question") {
    drawQuestion(channel, state, mapState)
  } else if (gamePhase === "question_results") {
    drawQuestionResults(channel, state, mapState)
  } else if (gamePhase === "game_results") {
    drawGameResults(channel, state, mapState)
  } else {
    throw `Something went horribly wrong - invalid game phase: '${gamePhase}'.`
  }
}

const initializer = (channel) => (mapState) => {
  // Begin garbage code
  let timeLeft = 0
  let updateTimer = function () {
    document.getElementById("timer").innerText = timeLeft
    timeLeft -= 1
  }
  let timerInterval
  // End garbage code

  const player_id = getPlayerId()

  // channels
  channel.on("update", (game) => {
    console.log(game)
    mapState((state) => ({
      current: {
        game,
        view: state && state.current && state.current.view,
      },
      previous: {
        game: state && state.current && state.current.game,
        view: state && state.previous && state.previous.view
      }
    }))
  })

  channel.join()
    .receive("ok", (resp) => { console.log("Joined successfully", resp) })
    .receive("error", (resp) => { console.log("Unable to join", resp) })

  channel.push("player_joined", { game_id, player_id })
}

socket.connect()

const game_id = document.getElementById("game_id").value
const channel = socket.channel(`game:${game_id}`, {})

runWithState(initializer(channel), redrawer(channel))
