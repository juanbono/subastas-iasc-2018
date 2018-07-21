defmodule Exchange.Bids.SwarmSupervisor do
  @moduledoc """
  Supervisor de las apuestas. Explicar
  """
  alias Exchange.{Bids, Bids.Bid}

  @doc """
  Crea la `apuesta` en el cluster y registra su `id`,
  luego lo une al grupo `:bids.
  """
  def start_bid(%Bid{bid_id: id} = bid) do
    {:ok, pid} = Swarm.register_name(id, Bids.Supervisor, :register, [bid])
    Swarm.join(:bids, pid)
  end

  @doc """
  Obtiene el `pid` de la `apuesta` con el `id` dado.
  """
  def get_bid(id), do: Swarm.whereis_name(id)

  @doc """
  Obtiene el `pid` de cada una de las `apuestas`.
  """
  def get_bids(), do: Swarm.members(:bids)
end
