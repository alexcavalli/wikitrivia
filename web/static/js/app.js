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
import 'phoenix_html'
import React from 'react'
import ReactDOM from 'react-dom'
import {Router, IndexRoute, Route, browserHistory} from 'react-router'

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import MenuPanel from './menu_panel'
import Quiz from './quiz'

class App extends React.Component {
  render () {
    return (this.props.children)
  }
}

ReactDOM.render(
  <Router history={browserHistory}>
    <Route path='/' component={App}>
      <IndexRoute component={MenuPanel} />
      <Route path='quizzes' component={Quiz} />
    </Route>
  </Router>,
  document.getElementById('root')
)

