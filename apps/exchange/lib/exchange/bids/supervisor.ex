defmodule Exchange.Bids.SwarmSupervisor do
  @moduledoc """
  Supervisor de las apuestas. Explicar
  """
  alias Exchange.Bids.Bid
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Bids.Worker, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  Crea la `apuesta` en el cluster y registra su `id`,
  luego lo une al grupo `:bids.
  """
  def register({:error, _} = error), do: error

  def register(%Bid{bid_id: id} = bid) do
    with {:ok, pid} <- Swarm.register_name(id, __MODULE__, :register, [bid], 2000),
         :ok <- Swarm.join(:bids, pid) do
      {:ok, bid}
    else
      {:error, _reason} = err ->
        err

      reason ->
        {:error, reason}
    end
  end

  @doc """
  Obtiene el `pid` de la `apuesta` con el `id` dado.
  """
  def get_bid(id), do: Swarm.whereis_name(id)

  @doc """
  Obtiene el `pid` de cada una de las `apuestas`.
  """
  def get_bids, do: Swarm.members(:bids)

  def number_of_bids, do: get_bids() |> Enum.count()
end
