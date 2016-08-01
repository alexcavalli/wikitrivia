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
      data: []
    }
  }

  componentDidMount () {
    fetch(this.props.url)
      .then((response) => {
        return response.json()
      }).then((json) => {
        this.setState({data: json})
      }).catch((exception) => {
        console.log(this.props.url, exception)
      })
  }

  render () {
    return (
      <div className='question-panel'>
        <QuestionPrompt prompt='Sample question prompt' />
        <AnswersList data={this.state.data} />
      </div>
    )
  }
}

class QuestionPrompt extends React.Component {
  render () {
    return (
      <h4>{this.props.prompt}</h4>
    )
  }
}

class AnswersList extends React.Component {
  render () {
    let answers = this.props.data.map((question) => {
      return (
        <Answer key={question.title}>{question.title}</Answer>
      )
    })
    return (
      <ul>
        {answers}
      </ul>
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
