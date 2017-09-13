defmodule WikitriviaWeb.Router do
  use WikitriviaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WikitriviaWeb do
    pipe_through :api
  end
end
