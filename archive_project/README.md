# Wikitrivia

A pretty simple trivia game that fetches all the trivia from Wikipedia.

## How to run this

You'll need a Postgres database in which to store the questions. Update
`dev.exs` with the configuration as desired. Then

```bash
mix deps.get
mix ecto.create && mix ecto.migrate
npm install

mix wikitrivia.fetch_trivia_items
mix wikitrivia.generate_questions

mix phoenix.server
```

Then visit localhost:4000.

It doesn't do much right now - just displays a question, lets you pick an
answer, and gives you "points". Future plans (which are obviously slightly
ambitious) are below.

That said, some of the questions and answers it generates can be pretty
humorous.

## (Intended) Features

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

### Stats UI

Players can track stats such as
* Answer success rate
* Avg answer time
* Avg quiz points
* Total points

### Additional tracking

The system should remember questions and gather global success rates. This
information can be used to weed out incredibly obvious questions (such as
those where the answer was not completely redacted, or those where a variant
of the answer is in the prompt).

The system should probably hang on to adjusted point totals, which are point
totals adjusted for questions that were rejected for being obvious.

The system could also tier questions based on average success rates, and provide
user stats on different levels of questions.

### References and sources

User authentication flow adapted from Micah Woods' article and associated project:
https://blog.codeship.com/ridiculously-fast-api-authentication-with-phoenix/
https://github.com/mwoods79/todo_api

## Original README info for reference

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

### Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
