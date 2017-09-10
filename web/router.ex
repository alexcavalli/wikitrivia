defmodule Wikitrivia.Router do
  use Wikitrivia.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Wikitrivia do
    pipe_through :api

    get "/question", QuestionController, :question
    resources "/users", UserController, only: [:create]
    resources "/sessions", SessionController, only: [:create]
  end

  scope "/", Wikitrivia do
    pipe_through :browser # Use the default browser stack

    resources "/quizzes", QuizController, only: [:new, :create]
    get "/question", PageController, :question # temporary, just to have question somewhere
    get "/*path", PageController, :index
  end
end
