defmodule Exchange.Bids.Supervisor do
  use DynamicSupervisor

  alias Exchange.{Bids, Bids.Bid}

  def init(_args) do
    DynamicSupervisor.init([])
  end

  @doc """
  Registra una apuesta en el sistema.
  """
  def register({:error, _} = error), do: error

  def register(%Bid{} = bid) do
    {:ok, bid_pid} = DynamicSupervisor.start_child(__MODULE__, {Bids.Worker, bid})
    {:ok, bid_state} = Bids.Worker.get_state(bid_pid)

    {:ok, bid_state}
  end

  @doc """
  Devuelve una lista con los PIDs de las `apuestas` en el sistema.
  """
  def current_bids() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end

  @doc """
  Cantidad de `apuestas` en el sistema.
  """
  def number_of_bids(), do: DynamicSupervisor.count_children(__MODULE__).workers
end
