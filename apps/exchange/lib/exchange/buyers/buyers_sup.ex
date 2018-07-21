defmodule Exchange.Buyers.Supervisor do
  @moduledoc """
  Supervisor de los compradores. Deprecado
  """
  use DynamicSupervisor

  alias Exchange.{Buyers, Buyers.Buyer}

  def init(_args) do
    DynamicSupervisor.init([])
  end

  @doc """
  Registra un comprador en el sistema. En caso de recibir un error, lo devuelve.
  """
  def register({:error, _} = error), do: error

  def register(%Buyer{} = buyer) do
    DynamicSupervisor.start_child(__MODULE__, {Buyers.Worker, buyer})
  end

  @doc """
  Devuelve una lista con los PIDs de los compradores en el sistema.
  """
  def current_buyers() do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end

  @doc """
  Cantidad de compradores en el sistema.
  """
  def number_of_buyers() do
    DynamicSupervisor.count_children(__MODULE__).workers
  end
end
