# Wikitrivia

A pretty simple trivia game that fetches all the trivia from Wikipedia.

## How to run this

Forthcoming

## (Intended) Features

Grand plans that may or may not be entirely implemented one day.

### Question UI

User is presented with an prompt in the form of a description with a redacted
answer, as well as five possible answers. The user must select an answer within
the time limit. Points are awarded based on how much time was left at the time
a correct answer was selected. No points are awarded for an incorrect answer.
The player can only choose one answer.

After a full quiz, the points are tallied, and that is the score.

### Points

A player has 10 seconds to answer a question. Points are a max of 1000 (if the
player were able to answer correctly without any time elapsing), and decrease
by 1 for every hundredth of a second.

### Competitive UI

Multiple players compete to answer trivia questions accurately and quickly. This
is a synchronous competition.

### Quizzes

A group of (# TBD) questions is called a quiz. Players can send a quiz to a
friend and asynchronously compete for a top score on that quiz.

A player forfeits the remainder of the questions on a quiz if they quit in the
middle.

### Stats UI (long term idea)

Players can track stats such as
* Answer success rate
* Avg answer time
* Avg quiz points
* Total points

### Additional tracking (long term idea)

The system should remember questions and gather global success rates. This
information can be used to weed out incredibly obvious questions (such as
those where the answer was not completely redacted, or those where a variant
of the answer is in the prompt).

The system should probably hang on to adjusted point totals, which are point
totals adjusted for questions that were rejected for being obvious.

The system could also tier questions based on average success rates, and provide
user stats on different levels of questions.

### References and sources

Using Ben Hausen's guide here as a reference:
https://medium.com/@benhansen/lets-build-a-slack-clone-with-elixir-phoenix-and-react-part-1-project-setup-3252ae780a1
