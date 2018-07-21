defmodule Exchange.Buyers.SwarmSupervisor do
  @moduledoc """
  Supervisor de los compradores. Explicar
  """
  alias Exchange.Buyers.Buyer
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

  def start_buyer({:error, _} = error), do: error

  def start_buyer(%Buyer{name: name} = buyer) do
    with {:ok, pid} <- Swarm.register_name(name, __MODULE__, :register, [buyer], 2000),
         :ok <- Swarm.join(:buyers, pid) do
      {:ok, pid}
    else
      {:error, _reason} = err ->
        err
    end
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
