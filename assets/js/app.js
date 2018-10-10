// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket"
import { createPlayerNameInput, createOpponentsList, createStartGameButton } from "./view"
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

const redraw = (state, view_state) => {
    const player_id = getPlayerId()
    const player_name = state.player_names[player_id]
    const game = document.getElementById("game")

    while (game.hasChildNodes()) {
        game.removeChild(game.lastChild)
    }

    const player_name_input = createPlayerNameInput(player_name, (event) => {
        channel.push("player_update", { game_id, player_id: getPlayerId(), player_name: event.target.value })
    })
    const join_game_link = document.createElement('p')
    join_game_link.appendChild(document.createTextNode(`Join Game Link: ${window.location}`))

    const game_header = document.createElement('h2')
    game_header.appendChild(document.createTextNode(`Joined Game: ${state.name}`))

    const start_game_button = createStartGameButton(() => {
        channel.push("go", { "game_id": game_id })
    })

    game.appendChild(game_header)
    game.appendChild(join_game_link)
    game.appendChild(player_name_input)
    game.appendChild(createOpponentsList(player_id, state.player_names))
    game.appendChild(start_game_button)
    player_name_input.focus()
}

// Begin garbage code
let timeLeft = 0
let updateTimer = function () {
    document.getElementById("timer").innerText = timeLeft
    timeLeft -= 1
}
let timerInterval
// End garbage code

socket.connect()

const game_id = document.getElementById("game_id").value
const channel = socket.channel(`game:${game_id}`, {})
//const btnStart = document.getElementById("btn-start")

// channels
channel.on("player_update", (state) => {
    redraw(state)
})

channel.on("player_joined", (state) => {
    redraw(state)
})

channel.on("start_question", (payload) => {
    console.log("starting question")
    console.log(payload)

    // Begin garbage code
    clearInterval(timerInterval)
    timeLeft = 5
    updateTimer()
    timerInterval = setInterval(updateTimer, 1000)
    // End garbage code
})

channel.on("stop_question", (payload) => {
    console.log("stopping question")
    console.log(payload)

    // Begin garbage code
    clearInterval(timerInterval)
    timeLeft = 5
    updateTimer()
    timerInterval = setInterval(updateTimer, 1000)
    // End garbage code
})

channel.on("stop_game", (payload) => {
    console.log("game is done")
    console.log(payload)

    // Begin garbage code
    clearInterval(timerInterval)
    // End garbage code
})

channel.join()
    .receive("ok", (resp) => { console.log("Joined successfully", resp) })
    .receive("error", (resp) => { console.log("Unable to join", resp) })

channel.push("player_joined", { game_id, player_id: getPlayerId() })