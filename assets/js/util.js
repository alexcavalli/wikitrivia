const runWithState = (fn, onStateChange) => {
  let state = null
  const mapState = (mapFn) => {
    state = JSON.parse(JSON.stringify(mapFn(state)))
    onStateChange(state, mapState)
  }

  fn(mapState)
}

export { runWithState }