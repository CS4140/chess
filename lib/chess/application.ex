defmodule Chess.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChessWeb.Telemetry,
      Chess.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:chess, :ecto_repos),
        skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:chess, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Chess.PubSub},
      # Finch HTTP client for sending emails
      {Finch, name: Chess.Finch},
      # Game-related supervisors
      {Registry, keys: :unique, name: Chess.GameRegistry},
      {DynamicSupervisor, name: Chess.GameSupervisor},
      # Game state management
      Chess.GameState,
      # Endpoint should typically be last
      ChessWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Chess.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ChessWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    System.get_env("RELEASE_NAME") != nil
  end
end
