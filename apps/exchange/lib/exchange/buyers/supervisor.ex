defmodule Exchange.Buyers.SwarmSupervisor do
  @moduledoc """
  Supervisor de los compradores. Explicar
  """
  alias Exchange.Buyers.Buyer

  @doc """
  Crea el `comprador` en el cluster y registra su `name`,
  luego lo une al grupo `:buyers`.
  """
  def start_buyer({:error, _} = error), do: error

  def start_buyer(%Buyer{name: name} = buyer) do
    {:ok, pid} = Swarm.register_name(name, __MODULE__, :register, [buyer])
    Swarm.join(:buyers, pid)
    {:ok, pid}
  end

  @doc """
  Obtiene el `pid` del `comprador` con el `name` dado.
  """
  def get_buyer(name), do: Swarm.whereis_name(name)

  @doc """
  Devuelve una lista con los PIDs de los compradores en el sistema.
  """
  def current_buyers(), do: Swarm.members(:buyers)

  @doc """
  Cantidad de compradores en el sistema.
  """
  def number_of_buyers(), do: current_buyers() |> Enum.count()
end
