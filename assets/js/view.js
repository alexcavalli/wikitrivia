function createPlayerNameInput(player_name, oninput) {
  const element = document.createElement('input')
  element.id = 'player_name'
  element.type = 'text'
  element.value = player_name
  element.oninput = oninput

  return element
}

function createOpponentsList(player_id, player_names) {
  const ul = document.createElement('ul')

  for (let id in player_names) {
    if (id !== player_id) {
      const li = document.createElement('li')

      li.appendChild(document.createTextNode(player_names[id]))
      ul.appendChild(li)
    }
  }

  return ul
}

function createStartGameButton(onclick) {
  const element = document.createElement('button')
  element.id = 'btn-start'
  element.onclick = onclick

  element.appendChild(document.createTextNode('Start Game!'))

  return element
}

function createQuestionPanel(channel, state, mapState) {
  const currentQuestionNumber = state.current.game.current_question
  const currentQuestion = state.current.game.questions[currentQuestionNumber]
  return `
  <div class="row">
    <div class="col-sm-12">
      <div class="card">
        <div class="card-body text-white bg-info">
          <h1 id="question-number" class="card-title">Question ${currentQuestionNumber + 1}</h1>
          <h3 id="question" class="card-text">${currentQuestion.question}</h3>
        </div>
        <div class="list-group list-group-flush bg-light btn-group-toggle text-center" data-toggle="buttons">
          ${currentQuestion.answer_choices.map(choice => `<label class="answer-choice btn btn-default list-group-item list-group-item-action"><input type="radio" name="answer-choices">${choice}</label>`)}
        </div>
        <div class="card-footer text-center text-white bg-info">
          <h3 id="timer"></h3>
        </div>
        <div id="who-answered" class="card-body">
          <p>Who's answered?</p>
        </div>
      </div>
    </div>
  </div>
  `
}

export { createPlayerNameInput, createOpponentsList, createStartGameButton, createQuestionPanel }

//////// Stashing this code here - this was all the event handling stuff related to the question UI.
// let disableAnswerChoices = function() {
//   Array.prototype.forEach.call(answerChoiceBtns, function(btnAnswerChoice) {
//     btnAnswerChoice.firstChild.disabled = true;
//   });
// }

// let selectedAnswer = "";

// // `this` receiver is the answer button selected
// let selectAnswer = function() {
//   selectedAnswer = this.innerText;
//   this.classList.add("list-group-item-warning");
//   // time left offset here is due to the weird way this timer is working (the current value of
//   // timeLeft is actually the next value on the timer, i.e. it's always a second ahead of reality)
//   addUserAnsweredBadge("You", timeLeft + 1, true);
//   disableAnswerChoices();
// };

// let addUserAnsweredBadge = function(username, answerTime, isYou) {
//   let badge = document.createElement("span");
//   if (isYou) {
//     badge.id = "you-answered-badge";
//   }
//   badge.classList.add("badge");
//   badge.classList.add("badge-primary");
//   badge.appendChild(document.createTextNode(username + " (" + answerTime + ")"));
//   document.getElementById("who-answered").appendChild(badge);
// };

// Array.prototype.forEach.call(answerChoiceBtns, function(btnAnswerChoice, index) {
//   btnAnswerChoice.appendChild(document.createTextNode(questionData.answer_choices[index]));
//   btnAnswerChoice.addEventListener("click", selectAnswer);
// });

// let timeLeft = 10;
// let updateTimeLeft = function() {
//   document.getElementById("timer").innerText = timeLeft;
//   timeLeft -= 1;
//   if (timeLeft >= 0) {
//     setTimeout(updateTimeLeft, 1000);
//   } else {
//     revealAnswer();
//     disableAnswerChoices();
//   };
// };
// updateTimeLeft();

// let revealAnswer = function() {
//   Array.prototype.forEach.call(answerChoiceBtns, function(btnAnswerChoice) {
//     btnAnswerChoice.classList.remove("list-group-item-warning");
//     const answerText = btnAnswerChoice.innerText;
//     if (selectedAnswer && selectedAnswer === answerText) {
//       const yourBadge = document.getElementById("you-answered-badge");
//       yourBadge.classList.remove("badge-primary");
//       if (selectedAnswer === questionData.correct_answer) {
//         btnAnswerChoice.classList.add("list-group-item-success");
//         yourBadge.classList.add("badge-success");
//       } else {
//         btnAnswerChoice.classList.add("list-group-item-danger");
//         yourBadge.classList.add("badge-danger");
//       }
//     }
//   })

//   // Fake other people answering results: (this is all nonsense, ignore this code, these would
//   // be triggered by the backend revealing who was right and wrong).
//   const answeredBadges = document.getElementById("who-answered").childNodes;
//   Array.prototype.forEach.call(answeredBadges, function(badge) {
//     if (badge.id === "you-answered-badge") { return; }
//     if (badge.nodeName !== "SPAN") { return; }

//     badge.classList.remove("badge-primary");
//     // flip a coin on them getting the answer right
//     if (Math.floor(Math.random() * 2) == 0) {
//       badge.classList.add("badge-success");
//     } else {
//       badge.classList.add("badge-danger");
//     }
//   });
// };
