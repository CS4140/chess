# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

import Config

# General application configuration
config :chess,
  ecto_repos: [Chess.Repo],
  generators: [timestamp_type: :utc_datetime]

# Repository configuration
config :chess, Chess.Repo,
  database: "chess_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

# Configures the endpoint
config :chess, ChessWeb.Endpoint,
  url: [host: "localhost", port: System.get_env("PORT")],
  check_origin: [System.get_env("URL")],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ChessWeb.ErrorHTML, json: ChessWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Chess.PubSub,
  live_view: [signing_salt: "eKhToocl"],
  # Add watchers for live reloading
  watchers: [
#    esbuild: {Esbuild, :install_and_run, [:chess, ~w(--sourcemap=inline --watch)]},
#    tailwind: {Tailwind, :install_and_run, [:chess, ~w(--watch)]}
  ]

# PubSub configuration
config :chess, Chess.PubSub,
  adapter: Phoenix.PubSub.PG2,
  pool_size: 1

# Game state configuration
config :chess, Chess.GameState,
  cleanup_interval: 3600_000, # 1 hour in milliseconds
  game_timeout: 86400_000    # 24 hours in milliseconds

# Configures the mailer
config :chess, Chess.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  chess: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  chess: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  level: :debug  # Set to debug level for development

# Additional logger configuration for game events
config :logger, :game_logger,
  format: "$time [$level] $message\n",
  metadata: [:game_id, :player_id],
  level: :debug

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Socket configuration
config :chess, ChessWeb.Endpoint,
  socket_options: [
    backlog: 1024,
    nodelay: true,
    linger: {true, 0},
    exit_on_close: false
  ]

# LiveView configuration
config :phoenix_live_view,
  signing_salt: "eKhToocl",
  temporary_assigns: [
    board: nil,
    valid_moves: []
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
