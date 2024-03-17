defmodule Papagaio.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PapagaioWeb.Telemetry,
      Papagaio.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:papagaio, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:papagaio, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Papagaio.PubSub},
      # Start to serve requests, typically the last entry
      PapagaioWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Papagaio.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PapagaioWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    System.get_env("SKIP_MIGRATIONS") == "true"
  end
end
