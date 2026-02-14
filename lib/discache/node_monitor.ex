defmodule Discache.NodeMonitor do
  @moduledoc """
   A Genserver to keep track of all nodes in the cluster.

   It is a client to the net_kernel process and listens for messages
   in the format of {:nodeup, node} or {:nodedown, node} and updates the HashRing accordingly
  """
  use GenServer
  alias ExHashRing.Ring

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :no_state, name: __MODULE__)
  end

  def init(:no_state = state) do
    :net_kernel.monitor_nodes(:true)
    Ring.add_nodes(DistributionRing, [node() | Node.list()])
    {:ok, state}
  end

  def handle_info({:nodeup, node}, state) do
    Ring.add_node(DistributionRing, node)
    {:noreply, state}
  end

  def handle_info({:nodedown, node}, state) do
    Ring.remove_node(DistributionRing, node)
    {:noreply, state}
  end
end
