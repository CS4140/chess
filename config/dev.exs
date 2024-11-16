import Config

# Database Configuration
config :chess, Chess.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: Path.expand("../chess_dev.db", __DIR__),
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

# Endpoint Configuration
config :chess, ChessWeb.Endpoint,
  # Development server configuration
  http: [ip: {127, 0, 0, 1}, port: 4040],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "jVmdiCMKgUhKSidceJouzx8VzQsuXrC5q4F6D4vMRauSmLO4mxvFWXETXT2GScZp",
  
  # Asset watchers
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
#    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ],
  
  # Live reload configuration
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/chess_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ],
  
  # PubSub configuration for real-time features
  pubsub_server: Chess.PubSub

# LiveView Configuration
config :phoenix_live_view,
  debug_heex_annotations: true,
  enable_expensive_runtime_checks: true,
  temporary_assigns: [
    board: nil,
    valid_moves: []
  ]

# Logger Configuration
config :logger, :console,
  format: "[$level] $message\n",
  level: :debug,
  metadata: [:request_id]

# Phoenix Configuration
config :phoenix,
  stacktrace_depth: 20,
  plug_init_mode: :runtime

# Development Features
config :chess,
  dev_routes: true

# Game State Configuration
config :chess, Chess.GameState,
  cleanup_interval: 3600_000,  # 1 hour in milliseconds
  game_timeout: 86400_000      # 24 hours in milliseconds

# Disable Swoosh API client in development
config :swoosh, :api_client, false

# SSL Support (commented out by default)
# To use HTTPS in development:
# 1. Generate certificate: mix phx.gen.cert
# 2. Uncomment and configure below:
#
# config :chess, ChessWeb.Endpoint,
#   https: [
#     port: 4001,
#     cipher_suite: :strong,
#     keyfile: "priv/cert/selfsigned_key.pem",
#     certfile: "priv/cert/selfsigned.pem"
#   ]
