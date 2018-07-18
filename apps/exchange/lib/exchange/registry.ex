defmodule Exchange.Registry do
  ############ Codigo del ejemplo de swarm, hay que adaptarlo para
  ############ que sirva para crear y registrar bids y buyers.

  @doc """
  Starts worker and registers name in the cluster, then joins the process
  to the `:foo` group
  """
  def start_bid(name) do
    {:ok, pid} = Swarm.register_name(name, Exchange.Bids.Supervisor, :register, [name])
    Swarm.join(:bids, pid)
  end

  @doc """
  Gets the pid of the worker with the given name
  """
  def get_worker(name), do: Swarm.whereis_name(name)

  @doc """
  Gets all of the pids that are members of the `:foo` group
  """
  def get_foos(), do: Swarm.members(:foo)

  @doc """
  Call some worker by name
  """
  def call_worker(name, msg), do: GenServer.call({:via, :swarm, name}, msg)

  @doc """
  Cast to some worker by name
  """
  def cast_worker(name, msg), do: GenServer.cast({:via, :swarm, name}, msg)

  @doc """
  Publish a message to all members of group `:foo`
  """
  def publish_foos(msg), do: Swarm.publish(:foo, msg)

  @doc """
  Call all members of group `:foo` and collect the results,
  any failures or nil values are filtered out of the result list
  """
  def call_foos(msg), do: Swarm.multi_call(:foo, msg)
end
