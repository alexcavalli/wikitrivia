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
import * as fetch from 'whatwg-fetch'

class QuestionPanel extends React.Component {
  constructor (props) {
    super(props)

    this.state = {
      answer_choices: []
    }
  }

  componentDidMount () {
    fetch(this.props.url)
      .then((response) => {
        if (response.ok) {
          return response.json()
        } else {
          console.log(response.json())
        }
      }).then((json) => {
        this.startQuestion(json)
      }).catch((exception) => {
        console.log(this.props.url, exception)
      })
  }

  startQuestion (questionJson) {
    questionJson.startTime = Date.now()
    questionJson.timeLeftInMilliseconds = 10000
    this.timer = setInterval(this.updateTimer.bind(this), 100)
    this.setState(questionJson)
  }

  updateTimer () {
    let stateUpdate = {timeLeftInMilliseconds: this.calculateTimeLeft()}
    if (stateUpdate.timeLeftInMilliseconds < 0) {
      stateUpdate.timeLeftInMilliseconds = 0.0
      stateUpdate.points = 0
      clearInterval(this.timer)
    }
    this.setState(stateUpdate)
  }

  // in milliseconds
  calculateTimeLeft () {
    return (10000 - (Date.now() - this.state.startTime))
  }

  selectAnswer (answerId) {
    if (this.state.selectedAnswerId) {
      return false
    }
    clearInterval(this.timer)
    let points = this.pointsForAnswer(answerId)
    this.setState({selectedAnswerId: answerId, points: points})
  }

  pointsForAnswer (answerId) {
    if (answerId !== this.state.correct_answer_id) { return 0 }
    let timeLeftInMilliseconds = this.calculateTimeLeft()
    let points = timeLeftInMilliseconds <= 0 ? 0 : Math.trunc(timeLeftInMilliseconds / 10)
    return (points)
  }

  render () {
    let answers = this.state.answer_choices.map((answerChoice) => {
      return (
        <Answer
          onClick={this.selectAnswer.bind(this, answerChoice.id)}
          key={answerChoice.id}
          isCorrect={answerChoice.id === this.state.correct_answer_id}
          isSelected={answerChoice.id === this.state.selectedAnswerId}
        >
          {answerChoice.answer}
        </Answer>
      )
    })

    return (
      <div className='question'>
        <div className='question__header'>
          <span className='question__prompt'>{this.state.prompt}</span>
          <div className='question__timer'>
            <span>{(this.state.timeLeftInMilliseconds / 1000).toFixed(1)}</span>
          </div>
        </div>
        <div className='question__answer-list'>
          <ol>
            {answers}
          </ol>
        </div>
        <Points isOutOfTime={this.state.timeLeftInMilliseconds === 0.0}
        >
          {this.state.points}
        </Points>
      </div>
    )
  }
}

class Answer extends React.Component {
  getColor () {
    if (this.props.isSelected) {
      if (this.props.isCorrect) {
        return 'green'
      } else {
        return 'red'
      }
    }
  }

  render () {
    let liStyle = {
      cursor: 'pointer',
      color: this.getColor()
    }

    return (
      <li className='question__answer' style={liStyle} onClick={this.props.onClick}>{this.props.children}</li>
    )
  }
}

class Points extends React.Component {
  message () {
    if (this.props.children === 0.0) {
      if (this.props.isOutOfTime) {
        return 'Time\'s up!'
      } else { // incorrect answer
        return 'Incorrect!'
      }
    } else {
      return `Correct! You earned ${this.props.children} points!`
    }
  }

  render () {
    if (this.props.children === undefined) {
      return null
    }

    return (
      <div className='question__footer'>
        <div className='question__points'>
          {this.message()}
        </div>
      </div>
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
