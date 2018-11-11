import "phoenix_html"
import socket from "./socket"
import { createPlayerNameInput, createOpponentsList, createStartGameButton } from "./view"
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

const redrawer = (channel) => (state, mapState) => {
  const player_id = getPlayerId()
  const player_name = state && state.current && state.current.game && state.current.game.players && state.current.game.players[player_id] && state.current.game.players[player_id].name
  const game = document.getElementById("game")

  while (game.hasChildNodes()) {
    game.removeChild(game.lastChild)
  }

  const player_name_input = createPlayerNameInput(player_name, (event) => {
    channel.push("player_update", { game_id, player_id, player_name: event.target.value })
  })
  const join_game_link = document.createElement('p')
  join_game_link.appendChild(document.createTextNode(`Join Game Link: ${window.location}`))

  const game_header = document.createElement('h2')
  game_header.appendChild(document.createTextNode(`Joined Game: ${state.current.game.name}`))

  const start_game_button = createStartGameButton(() => {
    channel.push("go", { "game_id": game_id })
  })

  game.appendChild(game_header)
  game.appendChild(join_game_link)
  game.appendChild(player_name_input)
  game.appendChild(createOpponentsList(player_id, state.current.game.player_names))
  game.appendChild(start_game_button)
  player_name_input.focus()
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
