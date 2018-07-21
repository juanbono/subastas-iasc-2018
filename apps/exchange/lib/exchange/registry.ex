defmodule Exchange.Registry do
  @moduledoc """
  Registro de la Exchange.
  """
  def start_buyer(buyer) do
    {:ok, pid} =
      Swarm.register_name(buyer.name, Exchange.Buyers.SwarmSupervisor, :register, [buyer])

    Swarm.join(:buyers, pid)
    {:ok, pid}
  end
end
