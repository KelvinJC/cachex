# Discache

**A lightweight, distributed in-memory cache for Elixir applications.**

Discache provides a simple key-value storage interface that automatically distributes data across multiple nodes in an Elixir cluster using consistent hashing. 
Built on the BEAM's distribution capabilities, it offers fault-tolerant caching with minimal configuration.


Features
- Transparent Distribution: Keys are automatically distributed across cluster nodes using consistent hashing
- Simple API: Familiar get/put semantics with pattern matching friendly return values
- Zero Configuration: Works out-of-the-box with your existing Elixir cluster
- Fault Tolerant: Continues operating during node failures (with configurable replication)
- Lightweight: Minimal dependencies, just Elixir/OTP and ([:ex_hash_ring](https://github.com/discord/ex_hash_ring))



## Installation

Note: 
Discache is not yet published to Hex.pm. For now, you can depend on the GitHub version.

Add discache to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:discache, github: "kelvinjc/discache"}
  ]
end
```
Then run mix deps.get to fetch the dependency.


## Usage

### Basic Operations

#### ``` Store a value ```
```elixir
:ok = Discache.put("user1", %{name: "Jane", email: "jane@example.com"})
```

#### ``` Retrieve a value ```
```elixir
case Discache.get("user1") do
  {:ok, user} -> IO.inspect(user)
  {:error, :not_found} -> IO.puts("User not found in cache")
end
```

#### ``` Delete a value ```
```elixir
:ok = Discache.delete("user1")
```

#### ``` Check if a key exists ```
```elixir
true = Discache.has_key?("user1")
```

## Cluster Setup
Discache leverages the distributed capabilities of the Erlang Virtual Machine. 
The underlying assumption is that Discache is introduced into an already existing cluster.
If this is not the case, you may connect your nodes manually or preferably, use a library like libcluster for automatic discovery.

Start separate nodes by running your project in separate bash terminals. 

#### _first terminal_
```
iex --name "cache1app@127.0.0.1" --cookie secret -S mix
```

#### _second terminal_ 
``` 
iex --name "cache2app@127.0.0.1" --cookie secret -S mix
```

### Manual node connection 
Manual connection. 
Run the following command on your second iex terminal
```
Node.connect(:"cache1app@127.0.0.1")
```

### Automatic node clustering using Libcluster
Libcluster is a library that provides a mechanism for automatically forming clusters of Erlang Virtual Machine nodes, with either static or dynamic node membership. 
It provides a pluggable "strategy" system, with a variety of strategies provided out of the box.

For more information, checkout the library [here](https://github.com/bitwalker/libcluster) 


- Add libcluster to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:libcluster, "~> 3.5"}

  ]
end
```

- Run mix deps.get to fetch the dependency.


- Define your cluster strategy.
Configure a cluster topology and add it to your application's supervision tree.
In this example we make use of the Gossip Strategy but you may use any cluster strategy that fits your use case.

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    # Add topology
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
      # ... 
      {Cluster.Supervisor, [topologies, [name: MyApp.Cluster]]},
      # ...
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

- Again, start separate nodes by running your project in separate bash terminals. 

#### _first terminal_
```
iex --name "cache1app@127.0.0.1" --cookie secret -S mix
```

#### _second terminal_ 
``` 
iex --name "cache2app@127.0.0.1" --cookie secret -S mix
```

If your run Node.list() on any iex terminal it should return the name of the other node 
 > on the first terminal
``` 
iex(cache1app@127.0.0.1)1> Node.list()
[:"cache2app@127.0.0.1"] 
```

 > on the second terminal
``` 
iex(cache2app@127.0.0.1)1> Node.list()
[:"cache1app@127.0.0.1"] 
```


## Acknowledgments:

Built on the shoulders of the BEAM community.


