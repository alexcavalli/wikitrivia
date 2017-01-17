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
// import 'phoenix_html'
import React from 'react'
import {Link} from 'react-router'

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
export default class MenuPanel extends React.Component {
  constructor (props) {
    super(props)

    this.state = {}
  }

  render () {
    return (
      <div className='menu'>
        <button className='menu__start-quiz'><Link to='/quizzes'>Start Solo Quiz</Link></button>
        <button className='menu__start-quiz' disabled='disabled'>Start Competitive Quiz</button>
      </div>
    )
  }
}
