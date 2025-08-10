defmodule ElixirPlayground.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElixirPlaygroundWeb.Telemetry,
      ElixirPlayground.Repo,
      {DNSCluster, query: Application.get_env(:elixir_playground, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixirPlayground.PubSub},
      # Start a worker by calling: ElixirPlayground.Worker.start_link(arg)
      # {ElixirPlayground.Worker, arg},
      # Start to serve requests, typically the last entry
      ElixirPlaygroundWeb.Endpoint,
      {Finch, name: ElixirPlayground.Finch}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirPlayground.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirPlaygroundWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
