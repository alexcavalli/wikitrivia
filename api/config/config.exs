# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :wikitrivia,
  ecto_repos: [Wikitrivia.Repo]

# Configures the endpoint
config :wikitrivia, WikitriviaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NJK3jQl0kdix6NygczGpUn8g2dXbNucpYEYqX2hXBwysXxpR12uxGw7nZ+sqF5DZ",
  render_errors: [view: WikitriviaWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Wikitrivia.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
