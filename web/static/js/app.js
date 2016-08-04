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

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import React from 'react'
import ReactDOM from 'react-dom'
import 'whatwg-fetch'

class QuestionPanel extends React.Component {
  constructor (props) {
    super(props)

    this.state = {
      answers: []
    }
  }

  componentDidMount () {
      fetch(this.props.url)
      .then((response) => {
        return response.json()
      }).then((json) => {
        this.setState(json)
      }).catch((exception) => {
        console.log(this.props.url, exception)
      })
  }

  render () {
    let answers = this.state.answers.map((answer) => {
      return (
        <Answer key={answer}>{answer}</Answer>
      )
    })
    return (
      <div className='question-panel'>
        <h4>{this.state.prompt}</h4>
        <ol>
          {answers}
        </ol>
      </div>
    )
  }
}

class Answer extends React.Component {
  render () {
    return (
      <li>{this.props.children}</li>
    )
  }
}

ReactDOM.render(
  <QuestionPanel url='/question' />,
  document.getElementById('question-panel')
)

// - QuestionPanel
//   - QuestionPrompt
//   - AnswersList
//     - Answer
//   - Feedback
