defmodule Discache.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = [
      demo_cluster: [
        strategy: Cluster.Strategy.Gossip,
        config: [
          port: 45892,
          if_address: "0.0.0.0",
          multicast_addr: "255.255.255.255",
          broadcast_only: true
        ]
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: Discache.Cluster]]},
      # Instantiate the HashRing GenServer
      {ExHashRing.Ring, name: DistributionRing},
      # Instantiate the node monitor
      Discache.NodeMonitor,
      # Instantiate the cache
      Discache
      # Starts a worker by calling: Discache.Worker.start_link(arg)
      # {Discache.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Discache.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
