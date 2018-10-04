function createPlayerNameInput(player_name, oninput) {
  const element = document.createElement('input');
  element.id = "player_name"
  element.type = "text"
  element.value = player_name
  element.oninput = oninput;

  return element
}

function createOpponentsList(player_id, state) {
  const ul = document.createElement('ul')

  for (let id in state.game_state.player_names) {
    if (id !== player_id) {
      const li = document.createElement('li')

      li.appendChild(document.createTextNode(state.game_state.player_names[id]))
      ul.appendChild(li)
    }
  }

  return ul
}

export { createPlayerNameInput, createOpponentsList }