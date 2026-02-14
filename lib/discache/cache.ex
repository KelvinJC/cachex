defmodule Discache.Cache do
  use GenServer
  alias ExHashRing.Ring

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts , name: __MODULE__)
  end

  @spec init(any()) :: {:ok, map()}
  def init(_opts), do: {:ok, %{}}

  @spec get(any()) :: {:ok, any()} | {:error, atom()}
  def get(key) do
    case Ring.find_node(DistributionRing, key) do
      {:ok, node} ->
        response = GenServer.call({__MODULE__, node}, {:get, key})
        {:ok, response}
      {:error, _} ->
        {:error, :not_found}
    end
  end

  @spec put(any(), any()) :: :ok
  def put(key, value) do
    case Ring.find_node(DistributionRing, key) do
      {:ok, node} ->
        GenServer.cast({__MODULE__, node}, {:put, key, value})

      {:error, _} ->
        GenServer.cast({__MODULE__, Node.self()}, {:put, key, value})
    end
  end

  def handle_cast({:put, key, value}, cache) do
    {:noreply, Map.put(cache, key, value)}
  end

  def handle_call({:get, key}, _from, cache) do
    {:reply, Map.get(cache, key), cache}
  end
end
