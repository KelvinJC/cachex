defmodule Cachex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Instantiate the HashRing GenServer
      {ExHashRing.Ring, name: Cachex.DistributionRing}
      # Starts a worker by calling: Cachex.Worker.start_link(arg)
      # {Cachex.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cachex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
