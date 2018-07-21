defmodule Exchange.Registry do
  @moduledoc """
  Registro de la Exchange.
  """

  def start_buyer({:error, _} = error), do: error

  def start_buyer(buyer) do
    {:ok, pid} =
      Swarm.register_name(buyer.name, Exchange.Buyers.SwarmSupervisor, :register, [buyer])

    Swarm.join(:buyers, pid)
    {:ok, pid}
  end

  @doc """
  Crea la `apuesta` en el cluster y registra su `id`,
  luego lo une al grupo `:bids.
  """
  def start_bid({:error, _} = error), do: error

  def start_bid(bid) do
    with bid2 <- Map.put(bid, :bid_id, UUID.uuid4(:hex)),
         {:ok, pid} <-
           Swarm.register_name(
             bid2.bid_id,
             Exchange.Bids.SwarmSupervisor,
             :register,
             [bid2]
           ),
         :ok <- Swarm.join(:bids, pid) do
      {:ok, bid}
    else
      {:error, _reason} = err ->
        err

      reason ->
        {:error, reason}
    end
  end
end
