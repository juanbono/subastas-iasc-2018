defmodule Exchange.Buyers.Supervisor do
  @moduledoc """
  Supervisor de los compradores. Explicar
  """
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Exchange.Buyers.Worker, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  Crea el `comprador` en el cluster y registra su `name`,
  luego lo une al grupo `:buyers`.
  """
  def register({:error, _} = error), do: error

  def register(buyer) do
    {:ok, _pid} = Supervisor.start_child(__MODULE__, [buyer])
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
