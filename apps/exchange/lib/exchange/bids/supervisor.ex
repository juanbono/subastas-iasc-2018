defmodule Exchange.Bids.SwarmSupervisor do
  @moduledoc """
  Supervisor de las apuestas. Explicar
  """
  alias Exchange.Bids.Bid

  @doc """
  Crea la `apuesta` en el cluster y registra su `id`,
  luego lo une al grupo `:bids.
  """
  def start_bid(%Bid{bid_id: id} = bid) do
    with {:ok, pid} <- Swarm.register_name(id, __MODULE__, :register, [bid]),
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
